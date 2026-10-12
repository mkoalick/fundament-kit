import Foundation

// Process facts the provider needs about Codex CLI processes, narrow enough to
// fake in tests. The live implementation defers to ProcessInspector; no `ps`,
// no `lsof` child process either way.
protocol CodexProcessSource {
    func codexPids() -> [Int32]
    func openFiles(_ pid: Int32) -> [String]
    func startTime(_ pid: Int32) -> Date?
    func isAlive(_ pid: Int32, startedAt: Date?) -> Bool
}

struct LiveCodexProcesses: CodexProcessSource {
    func codexPids() -> [Int32] { ProcessInspector.pids(named: "codex") }
    func openFiles(_ pid: Int32) -> [String] { ProcessInspector.openFiles(pid) }
    func startTime(_ pid: Int32) -> Date? { ProcessInspector.info(pid)?.startedAt }
    func isAlive(_ pid: Int32, startedAt: Date?) -> Bool { ProcessInspector.isAlive(pid, startedAt: startedAt) }
}

// The evidence the status parse pulled out of a rollout tail, independent of
// the record's identity fields (cwd, repo, pid, ...). Defaults are the
// "nothing happened yet" state.
private struct CodexLifecycle {
    var status: SessionRecord.Status = .unknown
    var statusSource = "codex-rollout"
    var question = ""
    var questions: [SessionRecord.Question] = []
    var result = ""
    var task = ""
    var title = ""
    var since: Date?
    var activeAt: Date?
    var reportedAt: Date?
    var model = ""
}

// One codex process the provider has matched to a rollout file. `statusCache`
// avoids re-tailing and re-parsing the file when it has not changed.
private struct CodexTracked {
    var pid: Int32
    var path: String
    var nativeId: String
    var cwd: String
    var createdAt: Date?     // session_meta timestamp: the session's own start, the `since` fallback
    var startedAt: Date?     // the process's start time, to catch a reused pid
    var statusCache: (stamp: FileStamp, lifecycle: CodexLifecycle)?
}

// A still-open request_user_input call: the question is live until a matching
// function_call_output answers it.
private struct CodexPending {
    let question: String
    let questions: [SessionRecord.Question]
    let reportedAt: Date?
    let since: Date?
}

// The most recent valid SESSION_REPORT line inside the current turn, cleared
// whenever a new turn starts.
private struct CodexReport {
    let report: SessionReport
    let reportedAt: Date?
}

// Reads codex rollout files (~/.codex/sessions) to report live `codex` CLI /
// VS Code sessions. Keeps a pid -> rollout mapping that a full scan refreshes
// only when something might have changed; everything else is a cheap liveness
// check against the stored start time.
final class CodexProvider: SessionProvider {
    private let paths: AppPaths
    private let repos: RepoResolver
    private let processes: CodexProcessSource
    private let clock: () -> Date

    private var tracked: [Int32: CodexTracked] = [:]
    private var didFirstScan = false
    private var lastFullScan: Date?

    init(paths: AppPaths, repos: RepoResolver, processes: CodexProcessSource = LiveCodexProcesses(), clock: @escaping () -> Date = Date.init) {
        self.paths = paths
        self.repos = repos
        self.processes = processes
        self.clock = clock
    }

    var name: String { "codex" }
    var watchPaths: [URL] { [paths.codexSessions] }

    func collect(now: Date, changed: Set<String>) -> [SessionRecord] {
        let marker = "/.codex/sessions/"
        let knownPaths = Set(tracked.values.map { $0.path })
        let hasNewRollout = changed.contains { path in
            path.contains(marker) && path.hasSuffix(".jsonl") && !knownPaths.contains(path)
        }
        let currentTime = clock()
        let safetyNetDue = lastFullScan.map { currentTime.timeIntervalSince($0) >= 60 } ?? true
        let needsFullScan = !didFirstScan || hasNewRollout || safetyNetDue

        if needsFullScan {
            // A new, unmapped rollout path can mean an already-known codex
            // process switched files via /new - rescan its open files too.
            fullScan(includeKnownPids: hasNewRollout)
            lastFullScan = currentTime
        }
        didFirstScan = true

        // Always: drop anything whose pid died or was recycled by another
        // process (different start time), without touching openFiles.
        for pid in Array(tracked.keys) where !processes.isAlive(pid, startedAt: tracked[pid]?.startedAt) {
            tracked.removeValue(forKey: pid)
        }

        return tracked.keys.compactMap { buildRecord(pid: $0) }.sorted { $0.id < $1.id }
    }

    // MARK: - Discovery

    private func fullScan(includeKnownPids: Bool) {
        let livePids = Set(processes.codexPids())
        let targets = includeKnownPids ? livePids : livePids.subtracting(tracked.keys)
        for pid in targets {
            if let found = discover(pid: pid) {
                tracked[pid] = found
            }
        }
        for pid in tracked.keys where !livePids.contains(pid) {
            tracked.removeValue(forKey: pid)
        }
    }

    // Looks at every open file of `pid`, keeps the ones that look like a
    // codex rollout written by a real CLI/VS Code session (not `codex exec`,
    // not a subagent thread), and picks the most recently started one.
    private func discover(pid: Int32) -> CodexTracked? {
        let candidates = processes.openFiles(pid).filter { $0.contains("/.codex/sessions/") && $0.hasSuffix(".jsonl") }
        var best: (nativeId: String, cwd: String, createdAt: Date?, path: String)?
        for path in candidates {
            guard let line = firstLine(of: path),
                  let event = jsonObject(line),
                  event["type"] as? String == "session_meta",
                  let payload = event["payload"] as? [String: Any],
                  let source = payload["source"] as? String, source == "cli" || source == "vscode" else { continue }
            let nativeId = (payload["id"] as? String) ?? (payload["session_id"] as? String) ?? ""
            guard !nativeId.isEmpty else { continue }
            let cwd = payload["cwd"] as? String ?? ""
            let createdAt = parseDate(payload["timestamp"] as? String ?? "")
            if best == nil || (createdAt ?? .distantPast) > (best!.createdAt ?? .distantPast) {
                best = (nativeId, cwd, createdAt, path)
            }
        }
        guard let chosen = best else { return nil }
        return CodexTracked(pid: pid, path: chosen.path, nativeId: chosen.nativeId, cwd: chosen.cwd,
                             createdAt: chosen.createdAt, startedAt: processes.startTime(pid), statusCache: nil)
    }

    // The first line of a file without reading the whole thing; a rollout's
    // first line (session_meta) carries the full system prompt and can be large.
    private func firstLine(of path: String, cap: Int = 4 << 20) -> Data? {
        guard let handle = FileHandle(forReadingAtPath: path) else { return nil }
        defer { try? handle.close() }
        var buffer = Data()
        while buffer.count < cap {
            guard let chunk = try? handle.read(upToCount: 65_536), !chunk.isEmpty else { break }
            buffer.append(chunk)
            if let newline = buffer.firstIndex(of: UInt8(ascii: "\n")) {
                return buffer[..<newline]
            }
        }
        return buffer.isEmpty ? nil : buffer
    }

    // MARK: - Records

    private func buildRecord(pid: Int32) -> SessionRecord? {
        guard let entry = tracked[pid] else { return nil }
        var record = SessionRecord(id: "codex:\(entry.nativeId)", provider: "codex", nativeId: entry.nativeId)
        record.cwd = entry.cwd
        let repo = repos.resolve(entry.cwd)
        record.repo = repo.name
        record.repoPath = repo.root
        record.color = repo.color
        record.open = true
        record.pid = pid
        record.transcriptPath = entry.path

        let lifecycle = statusFor(pid: pid)
        record.status = lifecycle.status
        record.statusSource = lifecycle.statusSource
        record.question = lifecycle.question
        record.questions = lifecycle.questions
        record.result = lifecycle.result
        record.task = lifecycle.task
        record.title = lifecycle.title
        record.since = lifecycle.since ?? entry.createdAt
        record.activeAt = lifecycle.activeAt
        record.reportedAt = lifecycle.reportedAt
        record.model = lifecycle.model
        return record
    }

    // Re-parses the rollout tail only when its FileStamp (mtime + size) changed.
    private func statusFor(pid: Int32) -> CodexLifecycle {
        guard var entry = tracked[pid] else { return CodexLifecycle() }
        guard let stamp = FileStamp(entry.path) else { return entry.statusCache?.lifecycle ?? CodexLifecycle() }
        if let cache = entry.statusCache, cache.stamp == stamp { return cache.lifecycle }
        let lifecycle = CodexProvider.parseLifecycle(lines: tailLines(entry.path, limit: 262_144))
        entry.statusCache = (stamp, lifecycle)
        tracked[pid] = entry
        return lifecycle
    }

    // MARK: - Status parsing

    // One pass over the rollout tail: event_msg turns (task_started /
    // user_message start work, task_complete ends it), a pending
    // request_user_input question (answered by its function_call_output),
    // the last explicit SESSION_REPORT in an assistant message, and the
    // model from the last turn_context. A completed turn means ready, never
    // that the task itself is done - only an explicit report says that.
    private static func parseLifecycle(lines: [Data]) -> CodexLifecycle {
        var life = CodexLifecycle()
        var pending: [String: CodexPending] = [:]
        var pendingOrder: [String] = []
        var report: CodexReport?

        for line in lines {
            guard let event = jsonObject(line), let payload = event["payload"] as? [String: Any] else { continue }
            let eventType = event["type"] as? String ?? ""
            let kind = payload["type"] as? String ?? ""
            let whenRaw = event["timestamp"] as? String ?? ""
            let when = parseDate(whenRaw)

            switch eventType {
            case "event_msg":
                if kind == "task_started" || kind == "user_message" {
                    let activeRaw = whenRaw.isEmpty ? (payload["started_at"] as? String ?? "") : whenRaw
                    let active = parseDate(activeRaw) ?? when
                    life.status = .working
                    life.activeAt = active
                    life.since = active
                    life.question = ""
                    life.result = ""
                    life.statusSource = "codex-rollout:turn"
                    pending.removeAll(); pendingOrder.removeAll()
                    report = nil
                } else if kind == "task_complete" {
                    let completeRaw = whenRaw.isEmpty ? (payload["completed_at"] as? String ?? "") : whenRaw
                    let completed = parseDate(completeRaw) ?? when
                    life.status = .ready
                    life.since = completed
                    life.question = ""
                    life.statusSource = "codex-rollout:turn"
                    pending.removeAll(); pendingOrder.removeAll()
                }
            case "response_item":
                if kind == "function_call", let fnName = payload["name"] as? String,
                   fnName == "request_user_input" || fnName == "functions.request_user_input" {
                    if let callId = payload["call_id"] as? String {
                        let rawQuestions = parseJSONObject(payload["arguments"] as? String ?? "{}")?["questions"] as? [Any] ?? []
                        let joined = rawQuestions.compactMap { ($0 as? [String: Any])?["question"] as? String }.joined(separator: "\n")
                        let trimmed = joined.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty {
                            pending[callId] = CodexPending(question: String(trimmed.prefix(2000)),
                                                            questions: SessionRecord.Question.parse(rawQuestions),
                                                            reportedAt: when, since: when)
                            pendingOrder.removeAll { $0 == callId }
                            pendingOrder.append(callId)
                        }
                    }
                } else if kind == "function_call_output" {
                    if let callId = payload["call_id"] as? String {
                        pending.removeValue(forKey: callId)
                        pendingOrder.removeAll { $0 == callId }
                    }
                } else if kind == "message", payload["role"] as? String == "assistant" {
                    let blocks = payload["content"] as? [Any] ?? []
                    let texts = blocks.compactMap { block -> String? in
                        guard let dict = block as? [String: Any], dict["type"] as? String == "output_text" else { return nil }
                        return dict["text"] as? String
                    }
                    if !texts.isEmpty, let found = SessionReport.last(in: texts.joined(separator: "\n")) {
                        report = CodexReport(report: found, reportedAt: when)
                    }
                }
            case "turn_context":
                if let model = payload["model"] as? String, !model.hasPrefix("<") {
                    life.model = model
                }
            default:
                break
            }
        }

        if let lastId = pendingOrder.last, let open = pending[lastId] {
            life.status = .waiting
            life.question = open.question
            life.questions = open.questions
            life.result = ""
            life.statusSource = "codex-rollout:request_user_input"
            life.since = open.since
            life.reportedAt = open.reportedAt
        } else if let found = report {
            let reportedAt = found.reportedAt ?? Date.distantPast
            let activeAt = life.activeAt ?? Date.distantPast
            if reportedAt >= activeAt {
                life.status = found.report.status
                life.question = found.report.question
                life.result = found.report.result
                life.task = found.report.task
                life.title = found.report.title
                life.since = found.reportedAt
                life.reportedAt = found.reportedAt
                life.statusSource = "report"
            }
        }

        return life
    }
}

// A JSON object from a string (function_call arguments are a JSON-encoded
// string, not a nested object). Never throws; invalid input yields nil.
private func parseJSONObject(_ raw: String) -> [String: Any]? {
    guard let data = raw.data(using: .utf8) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
}
