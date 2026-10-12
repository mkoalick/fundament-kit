import Foundation

// Everything the strip shows at one moment.
struct CollectorSnapshot {
    var local: [SessionRecord]        // this Mac: open sessions plus recently closed ones
    var external: [SessionRecord]     // from files in the sources folder
    var generatedAt: Date

    var visible: [SessionRecord] {
        var seen = Set<String>()
        return (local + external).filter { $0.open && seen.insert($0.id).inserted }
    }
}

// Asks every provider for its sessions, keeps closed ones for a while, applies
// explicit reports, adds external sources, and writes the register file other
// tools read. Runs on one serial queue; `collect` is also usable on its own.
final class SessionCollector {
    static let keepClosed: TimeInterval = 15 * 60
    static let keepClosedFinal: TimeInterval = 24 * 3600   // done or blocked stays visible in the register longer
    static let externalStaleAfter: TimeInterval = 90
    static let maximumRows = 500

    let paths: AppPaths
    var providers: [SessionProvider]
    private var previous: [String: SessionRecord] = [:]
    private var lastRegister: Data?
    private var lastRegisterWrite = Date.distantPast
    private var lastCleanup = Date.distantPast
    var writesRegister = true

    init(paths: AppPaths, providers: [SessionProvider]) {
        self.paths = paths
        self.providers = providers
        // Closed sessions survive an app restart through the last register.
        if let data = try? Data(contentsOf: paths.register),
           let register = try? SessionRegister.decoder().decode(SessionRegister.self, from: data) {
            previous = Dictionary(register.sessions.map { ($0.id, $0) }, uniquingKeysWith: { _, last in last })
        }
    }

    var watchPaths: [URL] { providers.flatMap { $0.watchPaths } + [paths.reports, paths.sources] }

    func collect(now: Date = Date(), changed: Set<String> = []) -> CollectorSnapshot {
        let current = providers.flatMap { $0.collect(now: now, changed: changed) }
        var merged = merge(current: current, now: now)
        applyReports(to: &merged, now: now)
        let local = bounded(merged)
        previous = Dictionary(local.map { ($0.id, $0) }, uniquingKeysWith: { _, last in last })
        let localIds = Set(local.map { $0.id })
        let external = readSources(now: now).filter { !localIds.contains($0.id) }
        if writesRegister { writeRegister(local, now: now) }
        if now.timeIntervalSince(lastCleanup) > 3600 { cleanup(now: now) }
        return CollectorSnapshot(local: local, external: external, generatedAt: now)
    }

    private func merge(current: [SessionRecord], now: Date) -> [String: SessionRecord] {
        var result: [String: SessionRecord] = [:]
        let currentIds = Set(current.map { $0.id })
        for old in previous.values where !currentIds.contains(old.id) {
            var closed = old
            if closed.open {
                closed.open = false
                closed.closedAt = now
            }
            if ![.done, .blocked].contains(closed.status) {
                closed.status = .unknown
                closed.question = ""
                closed.statusSource = "process-gone"
            }
            closed.questions = []
            let keep = [.done, .blocked].contains(closed.status) ? SessionCollector.keepClosedFinal : SessionCollector.keepClosed
            if now.timeIntervalSince(closed.closedAt ?? now) > keep { continue }
            result[closed.id] = closed
        }
        for var record in current {
            if let old = previous[record.id] {
                if let oldActive = old.activeAt, oldActive > (record.activeAt ?? .distantPast) { record.activeAt = oldActive }
                // A report applied earlier stays until newer evidence of work arrives.
                if old.statusSource == "report", let reported = old.reportedAt,
                   reported >= (record.activeAt ?? .distantPast), reported > (record.reportedAt ?? .distantPast) {
                    record.status = old.status
                    record.question = old.question
                    record.result = old.result
                    if !old.task.isEmpty { record.task = old.task }
                    record.reportedAt = old.reportedAt
                    record.statusSource = "report"
                }
            }
            result[record.id] = record
        }
        return result
    }

    // Reports written by the helper's `report` command: <reports>/<id>.json
    private func applyReports(to records: inout [String: SessionRecord], now: Date) {
        let files = (try? FileManager.default.contentsOfDirectory(at: paths.reports, includingPropertiesForKeys: nil)) ?? []
        for file in files where file.pathExtension == "json" {
            guard let data = try? Data(contentsOf: file),
                  let object = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
                  let id = object["id"] as? String, var record = records[id],
                  let report = SessionReport(json: object),
                  let at = (object["reportedAt"] as? String).flatMap(parseDate) else { continue }
            guard at >= max(record.reportedAt ?? .distantPast, record.activeAt ?? .distantPast) else { continue }
            if !record.open, ![.done, .blocked].contains(report.status) { continue }
            record.status = report.status
            record.question = report.question
            record.questions = []
            record.result = report.result
            if !report.task.isEmpty { record.task = report.task }
            if !report.title.isEmpty { record.title = report.title }
            record.reportedAt = at
            record.since = at
            record.statusSource = "report"
            records[id] = record
        }
    }

    // Open rows first, then the most recent history; bounded on disk.
    private func bounded(_ records: [String: SessionRecord]) -> [SessionRecord] {
        let sorted = records.values.sorted { a, b in
            if a.open != b.open { return a.open }
            let ta = a.reportedAt ?? a.since ?? .distantPast, tb = b.reportedAt ?? b.since ?? .distantPast
            if ta != tb { return ta > tb }
            return a.id < b.id
        }
        return Array(sorted.prefix(SessionCollector.maximumRows))
    }

    private func readSources(now: Date) -> [SessionRecord] {
        let files = (try? FileManager.default.contentsOfDirectory(at: paths.sources, includingPropertiesForKeys: nil)) ?? []
        let decoder = SessionRegister.decoder()
        var result: [SessionRecord] = []
        for file in files.sorted(by: { $0.path < $1.path }) where file.pathExtension == "json" {
            guard let data = try? Data(contentsOf: file),
                  let register = try? decoder.decode(SessionRegister.self, from: data) else { continue }
            let stale = now.timeIntervalSince(register.generatedAt) > SessionCollector.externalStaleAfter
            let label = register.source ?? file.deletingPathExtension().lastPathComponent
            for var record in register.sessions.prefix(SessionCollector.maximumRows) {
                record.stale = record.stale || stale
                record.origin = record.origin ?? label
                result.append(record)
            }
        }
        return result
    }

    // The register is written when something changed and at least every 30 s,
    // so a reader can tell a running app from a stopped one.
    private func writeRegister(_ local: [SessionRecord], now: Date) {
        let encoder = SessionRegister.encoder()
        guard let body = try? encoder.encode(local) else { return }
        guard body != lastRegister || now.timeIntervalSince(lastRegisterWrite) >= 30 else { return }
        let register = SessionRegister(source: nil, generatedAt: now, sessions: local)
        guard let data = try? encoder.encode(register) else { return }
        do {
            try writePrivately(data, to: paths.register)
            lastRegister = body
            lastRegisterWrite = now
        } catch {}
    }

    private func cleanup(now: Date) {
        lastCleanup = now
        let files = (try? FileManager.default.contentsOfDirectory(at: paths.reports, includingPropertiesForKeys: [.contentModificationDateKey])) ?? []
        for file in files {
            let modified = (try? file.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? now
            if now.timeIntervalSince(modified) > SessionCollector.keepClosedFinal { try? FileManager.default.removeItem(at: file) }
        }
    }

    // Used by the helper's `report` command.
    static func writeReport(id: String, report: SessionReport, paths: AppPaths, now: Date = Date()) throws {
        let object: [String: Any] = ["id": id, "status": report.status.rawValue, "question": report.question, "result": report.result,
                                     "task": report.task, "title": report.title, "reportedAt": formatDate(now)]
        let data = try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
        let name = id.replacingOccurrences(of: "[^A-Za-z0-9_-]", with: "_", options: .regularExpression)
        try writePrivately(data, to: paths.reports.appendingPathComponent(name + ".json"))
    }
}
