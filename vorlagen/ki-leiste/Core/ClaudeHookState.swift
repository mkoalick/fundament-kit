import Foundation

// The state of one Claude Code session as told by its hooks. The hook helper
// folds every event into this record and stores it as
// <app support>/claude-hooks/<session id>.json; the Claude provider reads it.
// Hook payloads: https://code.claude.com/docs/en/hooks
struct ClaudeHookRecord: Codable, Equatable {
    var sessionId: String
    var cwd = ""
    var transcriptPath = ""
    var pid: Int32?
    var pidStartedAt: Date?
    var model = ""
    var title = ""
    var status: SessionRecord.Status = .ready
    var question = ""
    var questions: [SessionRecord.Question] = []
    var result = ""
    var task = ""
    var lastMessage = ""
    var startedAt: Date
    var since: Date
    var activeAt: Date?
    var reportedAt: Date?
    var endedAt: Date?
    var endReason = ""
    var lastEvent = ""
    var lastEventAt: Date
    var statusSource = ""

    init(sessionId: String, at now: Date) {
        self.sessionId = sessionId
        startedAt = now
        since = now
        lastEventAt = now
    }
}

enum ClaudeHookFold {
    static func isValidSessionId(_ id: String) -> Bool {
        !id.isEmpty && id.count <= 128 && id.range(of: "^[A-Za-z0-9_-]+$", options: .regularExpression) != nil
    }

    // Applies one hook event. `now` is when the hook process started, so a
    // late-finishing background hook cannot overwrite a newer state.
    static func apply(_ event: [String: Any], at now: Date, to existing: ClaudeHookRecord?,
                      caller: ProcessInspector.Info?) -> ClaudeHookRecord? {
        guard let sessionId = event["session_id"] as? String, isValidSessionId(sessionId),
              let name = event["hook_event_name"] as? String else { return nil }
        var record = existing ?? ClaudeHookRecord(sessionId: sessionId, at: now)
        func text(_ key: String) -> String { (event[key] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines) }

        if !text("cwd").isEmpty { record.cwd = text("cwd") }
        if !text("transcript_path").isEmpty { record.transcriptPath = text("transcript_path") }
        let model = text("model")
        if !model.isEmpty, !model.hasPrefix("<") { record.model = String(model.prefix(200)) }
        if let caller = caller, caller.pid != record.pid || record.pidStartedAt == nil {
            record.pid = caller.pid
            record.pidStartedAt = caller.startedAt
        }
        // An event that started before the last applied one only refreshes facts.
        if let existing = existing, now < existing.lastEventAt { return record }

        func set(_ status: SessionRecord.Status, _ source: String) {
            if record.status != status { record.since = now }
            record.status = status
            record.statusSource = source
        }
        func clearQuestion() {
            record.question = ""
            record.questions = []
        }
        var changesState = true

        switch name {
        case "SessionStart":
            let title = text("session_title")
            if !title.isEmpty { record.title = String(title.prefix(300)) }
            // A compaction happens in the middle of work; it is not a new start.
            if text("source") != "compact" {
                clearQuestion()
                record.result = ""
                set(.ready, "hook:SessionStart")
            }
            record.endedAt = nil
            record.endReason = ""
        case "UserPromptSubmit":
            clearQuestion()
            record.result = ""
            record.activeAt = now
            set(.working, "hook:UserPromptSubmit")
        case "PreToolUse":
            record.activeAt = now
            if text("tool_name") == "AskUserQuestion" {
                let input = event["tool_input"] as? [String: Any] ?? [:]
                record.questions = SessionRecord.Question.parse(input["questions"])
                record.question = String(record.questions.map { $0.question }.joined(separator: "\n").prefix(2000))
                record.reportedAt = now
                set(record.question.isEmpty ? .working : .waiting, "hook:AskUserQuestion")
            } else if record.status != .working {
                clearQuestion()
                set(.working, "hook:PreToolUse")
            }
        case "PermissionRequest":
            // The tool's own short description, never its full input: a command
            // line can carry secrets, and this text may travel further.
            let tool = text("tool_name")
            let description = ((event["tool_input"] as? [String: Any])?["description"] as? String ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            record.questions = []
            record.question = String((description.isEmpty ? tool : "\(tool): \(description)").prefix(300))
            record.activeAt = now
            set(.waiting, "hook:PermissionRequest")
        case "PostToolUse", "PostToolUseFailure", "PermissionDenied":
            record.activeAt = now
            if record.status != .working {
                clearQuestion()
                set(.working, "hook:" + name)
            }
        case "Notification":
            let message = String(text("message").prefix(2000))
            switch text("notification_type") {
            case "permission_prompt":
                // PermissionRequest already named the tool; keep the more precise text.
                if !(record.status == .waiting && record.statusSource == "hook:PermissionRequest") {
                    record.questions = []
                    record.question = message
                    set(.waiting, "hook:Notification:permission_prompt")
                }
            case "elicitation_dialog", "elicitation_url_dialog", "agent_needs_input":
                record.questions = []
                record.question = message
                set(.waiting, "hook:Notification:" + text("notification_type"))
            case "elicitation_complete", "elicitation_response":
                clearQuestion()
                set(.working, "hook:Notification:" + text("notification_type"))
            case "idle_prompt":
                if record.status == .working { set(.ready, "hook:Notification:idle_prompt") }
            default:
                changesState = false
            }
        case "Stop":
            let message = text("last_assistant_message")
            record.lastMessage = String(message.suffix(500))
            clearQuestion()
            if let report = SessionReport.last(in: message) {
                record.question = report.question
                record.result = report.result
                if !report.task.isEmpty { record.task = report.task }
                if !report.title.isEmpty { record.title = report.title }
                record.reportedAt = now
                set(report.status, "report")
            } else {
                record.result = ""
                set(.ready, "hook:Stop")
            }
        case "StopFailure":
            // A turn that ended on an error (usage limit, overload, auth) waits for the user.
            let reason = [text("error_type"), text("error"), text("reason")].first { !$0.isEmpty } ?? "error"
            clearQuestion()
            record.result = String(reason.prefix(300))
            record.reportedAt = now
            set(.blocked, "hook:StopFailure")
        case "SessionEnd":
            record.endedAt = now
            record.endReason = text("reason")
        default:
            changesState = false
        }
        if name != "SessionEnd", name != "SessionStart" { record.endedAt = nil }
        if changesState {
            record.lastEvent = name
            record.lastEventAt = now
        }
        return record
    }
}

// Reading and writing the per-session hook files. The helper takes an exclusive
// lock on a sidecar file, so two hooks of the same session never interleave.
struct ClaudeHookStore {
    let folder: URL

    func url(_ sessionId: String) -> URL { folder.appendingPathComponent(sessionId + ".json") }

    func read(_ sessionId: String) -> ClaudeHookRecord? {
        guard let data = try? Data(contentsOf: url(sessionId)) else { return nil }
        return try? SessionRegister.decoder().decode(ClaudeHookRecord.self, from: data)
    }

    func all() -> [ClaudeHookRecord] {
        let files = (try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? []
        let decoder = SessionRegister.decoder()
        return files.filter { $0.pathExtension == "json" }.compactMap { file in
            (try? Data(contentsOf: file)).flatMap { try? decoder.decode(ClaudeHookRecord.self, from: $0) }
        }
    }

    // Read, change, and write one session's record under an exclusive lock.
    @discardableResult
    func update(_ sessionId: String, _ change: (ClaudeHookRecord?) -> ClaudeHookRecord?) -> ClaudeHookRecord? {
        guard ClaudeHookFold.isValidSessionId(sessionId) else { return nil }
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        let lock = open(folder.appendingPathComponent(".\(sessionId).lock").path, O_CREAT | O_RDWR, 0o600)
        guard lock >= 0 else { return nil }
        defer { close(lock) }
        guard flock(lock, LOCK_EX) == 0 else { return nil }
        defer { flock(lock, LOCK_UN) }
        guard let next = change(read(sessionId)),
              let data = try? SessionRegister.encoder().encode(next) else { return nil }
        try? writePrivately(data, to: url(sessionId))
        return next
    }

    // Records of sessions that ended (or whose process vanished) a day ago go.
    func removeExpired(now: Date, olderThan age: TimeInterval = 24 * 3600, isAlive: (ClaudeHookRecord) -> Bool) {
        for record in all() where now.timeIntervalSince(record.lastEventAt) > age && (record.endedAt != nil || !isAlive(record)) {
            try? FileManager.default.removeItem(at: url(record.sessionId))
            try? FileManager.default.removeItem(at: folder.appendingPathComponent(".\(record.sessionId).lock"))
        }
    }
}
