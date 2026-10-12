import Foundation
import CryptoKit

func L(_ key: String) -> String { NSLocalizedString(key, comment: "") }

// What the strip, the menu, and the notifications need to know about a session.
// `state` is the displayed state: "ready" shows as "done" (not working right now),
// and a stale external source shows only final states.
struct SessionDisplay {
    let id: String
    let repo: String
    let engine: String
    let model: String
    let name: String
    let state: String
    let reportedState: String
    let question: String
    let result: String
    let task: String
    let process: String
    let repoColor: String?
    let origin: String?
    let lastMessage: String

    init(_ record: SessionRecord, fresh: Bool = true) {
        func clean(_ text: String) -> String { text.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ") }
        id = record.id
        repo = record.repo.isEmpty ? "?" : record.repo
        engine = record.provider.isEmpty ? "?" : record.provider
        model = record.model
        task = clean(record.task)
        let topic = clean(record.title)
        name = !topic.isEmpty ? topic : (!task.isEmpty ? task : "Session \(id.suffix(6))")
        reportedState = record.status.rawValue
        let sourceFresh = fresh && !record.stale
        let effective: SessionRecord.Status = sourceFresh || [.done, .blocked].contains(record.status) ? record.status : .unknown
        state = (effective == .ready ? SessionRecord.Status.done : effective).rawValue
        question = clean(record.question)
        result = clean(record.result)
        process = record.open ? "open" : "closed"
        repoColor = record.color
        origin = record.origin
        lastMessage = clean(record.lastMessage)
    }

    // Rows as plain dictionaries (register JSON, tests).
    init?(_ raw: [String: Any], fresh: Bool) {
        guard let id = raw["id"] as? String, !id.isEmpty,
              let data = try? JSONSerialization.data(withJSONObject: raw),
              let record = try? SessionRegister.decoder().decode(SessionRecord.self, from: data) else { return nil }
        self.init(record, fresh: fresh)
    }

    // A waiting session without a concrete question (only Claude's fallback list
    // knows it waits) shows a generic line, but never raises a vague notification.
    var questionOrHint: String {
        question.isEmpty && state == "waiting" ? L("Waiting for your input or permission") : question
    }

    var completionText: String {
        if !result.isEmpty { return result }
        if reportedState == "ready" { return lastMessage.isEmpty ? L("The session is waiting for its next task.") : lastMessage }
        return L("Task completed.")
    }

    var shortName: String { name.count > 20 ? String(name.prefix(19)) + "…" : name }
    var modelFamily: String {
        let detected = model.lowercased()
        if detected.contains("minimax") { return "minimax" }
        if detected.contains("claude") { return "claude" }
        return engine.lowercased()
    }
    var modelBadge: String {
        switch modelFamily {
        case "claude": return "C"
        case "minimax": return "M"
        case "codex": return "G"
        default: return "?"
        }
    }
    var modelLabel: String {
        let family = ["claude": "Claude", "minimax": "MiniMax", "codex": "Codex"][modelFamily] ?? engine
        return model.isEmpty ? family : "\(family) · \(model)"
    }
    var stateLabel: String {
        switch state {
        case "waiting": return L("waiting")
        case "working": return L("working")
        case "done": return L("done")
        case "ready": return L("ready")
        case "blocked": return L("blocked")
        default: return L("unclear")
        }
    }
    var stateSymbol: String {
        switch state {
        case "waiting": return "💬"
        case "working": return "↻"
        case "done": return "✓"
        case "ready": return "○"
        case "blocked": return "!"
        default: return "?"
        }
    }
    var priority: Int {
        ["waiting", "working", "blocked", "ready", "unknown", "done"].firstIndex(of: state) ?? 4
    }
}

// Only IDs, states, and hashes are persisted, not questions or result texts.
// First fresh sample is a baseline; reopening the app never replays old alerts.
final class SessionEventTracker {
    struct Stamp: Codable, Equatable {
        let state: String
        let digest: String
    }
    struct Event {
        let session: SessionDisplay
        let fingerprint: String
    }
    private(set) var stamps: [String: Stamp]
    private var initialized: Bool
    // A turn end ("ready") only notifies after real work. Short answers are
    // usually watched live, and newly opened idle sessions never notify.
    var minimumWorkForReadyHint: TimeInterval = 60 // set from the user's settings
    private var workingSince: [String: Date] = [:] // in memory only

    init(stamps: [String: Stamp]? = nil) {
        self.stamps = stamps ?? [:]
        initialized = false // First fresh sample is always the current-process baseline.
    }

    func observe(_ sessions: [SessionDisplay], fresh: Bool, now: Date = Date()) -> [Event] {
        guard fresh else { return [] }
        var next: [String: Stamp] = [:]
        var events: [Event] = []
        var working: [String: Date] = [:]
        for session in sessions {
            let detail = session.state == "waiting" ? session.question : (session.state == "done" ? session.result : "")
            let digest = SHA256.hash(data: Data(detail.utf8)).map { String(format: "%02x", $0) }.joined()
            let stamp = Stamp(state: session.state, digest: digest)
            next[session.id] = stamp
            let old = stamps[session.id]
            let changed = old?.state != stamp.state || (session.state == "waiting" && old?.digest != stamp.digest)
            let workedFor = workingSince[session.id].map { now.timeIntervalSince($0) } ?? 0
            if session.state == "working" { working[session.id] = workingSince[session.id] ?? now }
            let quickTurn = session.state == "done" && session.reportedState == "ready" &&
                workedFor < minimumWorkForReadyHint
            if initialized, changed, !quickTurn,
               session.state == "done" || (session.state == "waiting" && !session.question.isEmpty) {
                events.append(Event(session: session, fingerprint: "\(session.state)-\(digest)"))
            }
        }
        stamps = next
        workingSince = working
        initialized = true
        return events.sorted { a, b in
            if a.session.priority != b.session.priority { return a.session.priority < b.session.priority }
            return a.session.id < b.session.id
        }
    }
}

func repoAbbreviation(_ name: String) -> String {
    let words = name.split(whereSeparator: { !$0.isLetter && !$0.isNumber })
    if words.count > 1 { return words.prefix(2).compactMap { $0.first }.map(String.init).joined().uppercased() }
    return String((words.first.map(String.init) ?? "?").prefix(2)).uppercased()
}

struct SessionStripLayout {
    struct Placement {
        let repoIndex: Int
        let sessionIndex: Int? // nil is the repo header
        let row: Int
        let x: CGFloat
        let width: CGFloat
    }
    let placements: [Placement]
    let rows: Int

    // `rowLimit` caps adaptive rows (1 or 2); `header` is the repo label width.
    init(counts: [Int], width: CGFloat, preferredRows: Int = 1, adaptive: Bool = false, rowLimit: Int = 2, header headerWidth: CGFloat = 26) {
        let padding: CGFloat = 8
        var header = headerWidth, gap: CGFloat = 3, groupGap: CGFloat = 8
        let total = counts.reduce(0, +)
        let groupCount = counts.filter { $0 > 0 }.count
        let oneRowBudget = total > 0 ? (width - padding * 2 - CGFloat(groupCount) * (header + groupGap) - CGFloat(total) * gap) / CGFloat(total) : 130
        let requestedRows = adaptive ? (oneRowBudget >= 100 || rowLimit < 2 ? 1 : 2) : max(1, preferredRows)
        let budget = total > 0 ? ((width - padding * 2) * CGFloat(requestedRows) - CGFloat(groupCount) * (header + groupGap) - CGFloat(total) * gap) / CGFloat(total) : 130
        // Prefer one compact row. When this would make names illegible, wrap
        // to extra rows and reserve the corresponding space for app windows.
        var chipWidth = min(max(budget >= 44 ? budget : 64, 1), min(130, max(1, width - padding * 2 - header)))
        let right = width - padding
        func arrange(_ chip: CGFloat) -> (placements: [Placement], rows: Int) {
            var result: [Placement] = []
            var row = 0
            var x = padding
            for repo in counts.indices where counts[repo] > 0 {
                if x + header + chip > right && x > padding { row += 1; x = padding }
                result.append(Placement(repoIndex: repo, sessionIndex: nil, row: row, x: x, width: header))
                x += header
                for session in 0..<counts[repo] {
                    if x + chip > right && x > padding + header {
                        row += 1; x = padding
                        result.append(Placement(repoIndex: repo, sessionIndex: nil, row: row, x: x, width: header))
                        x += header
                    }
                    result.append(Placement(repoIndex: repo, sessionIndex: session, row: row, x: x, width: chip))
                    x += chip + gap
                }
                x += groupGap
            }
            return (result, row + 1)
        }
        var trial = arrange(chipWidth)
        // Repeated group headers at row breaks need extra space. Tighten the
        // estimate until the requested rows really fit, before adding a row.
        let minimumWidth: CGFloat = adaptive ? 1 : 44
        while trial.rows > requestedRows, chipWidth > minimumWidth {
            chipWidth = max(minimumWidth, chipWidth - 1)
            trial = arrange(chipWidth)
        }
        if adaptive {
            // Even an extreme number of separate repo headings must stay in
            // two rows. Compress group markers and gaps too, rather than
            // silently clipping a third row or omitting sessions.
            while trial.rows > requestedRows {
                header *= 0.8
                gap *= 0.8
                groupGap *= 0.8
                chipWidth *= 0.8
                trial = arrange(chipWidth)
            }
        }
        placements = trial.placements
        rows = trial.rows
    }
}
