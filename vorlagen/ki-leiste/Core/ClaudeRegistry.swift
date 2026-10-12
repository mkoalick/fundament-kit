import Foundation

// Fallback source: Claude's own, undocumented session registry
// (~/.claude/sessions/*.json), one file per interactive CLI process. Used
// where the documented hooks have not (yet) reported a session. Liveness is
// checked against the kernel, never trusted from the file, since a crashed
// session leaves its file behind.
final class ClaudeRegistryReader {
    private let paths: AppPaths
    private let repos: RepoResolver
    private let transcripts: ClaudeTranscriptReader
    private let isAlive: (Int32) -> Bool

    init(paths: AppPaths, repos: RepoResolver, transcripts: ClaudeTranscriptReader,
         isAlive: @escaping (Int32) -> Bool = { ProcessInspector.isAlive($0) }) {
        self.paths = paths
        self.repos = repos
        self.transcripts = transcripts
        self.isAlive = isAlive
    }

    func sessions(now: Date) -> [SessionRecord] {
        guard let files = try? FileManager.default.contentsOfDirectory(at: paths.claudeSessions, includingPropertiesForKeys: nil) else {
            return []
        }
        var result: [SessionRecord] = []
        for file in files where file.pathExtension == "json" {
            guard let data = try? Data(contentsOf: file),
                  let object = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
                  let record = record(from: object) else { continue }
            result.append(record)
        }
        return result
    }

    private func record(from object: [String: Any]) -> SessionRecord? {
        guard let pid = (object["pid"] as? NSNumber)?.int32Value, pid > 0, isAlive(pid) else { return nil }
        guard let nativeId = object["sessionId"] as? String, !nativeId.isEmpty else { return nil }
        guard object["kind"] as? String == "interactive" else { return nil }
        guard let cwd = object["cwd"] as? String, !cwd.isEmpty else { return nil }

        // These are helper/automation processes, not work the strip should show.
        let libraryPrefix = paths.home.appendingPathComponent("Library").path + "/"
        guard !cwd.hasPrefix(libraryPrefix) else { return nil }

        func millis(_ key: String) -> Date? {
            guard let number = object[key] as? NSNumber else { return nil }
            return Date(timeIntervalSince1970: number.doubleValue / 1000)
        }

        let startedAt = millis("startedAt")
        let statusUpdatedAt = millis("statusUpdatedAt")
        let updatedAt = millis("updatedAt")
        let waitingFor = (object["waitingFor"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let status: SessionRecord.Status
        switch object["status"] as? String ?? "" {
        case "working", "busy", "shell": status = .working
        case "idle": status = .ready
        case "waiting": status = .waiting
        default: status = .unknown
        }

        // Current evidence of work only exists while the session is actually
        // working or waiting; an idle session has none to compare a report against.
        let activeAt: Date? = (status == .working || status == .waiting) ? (statusUpdatedAt ?? updatedAt) : nil

        let repo = repos.resolve(cwd)
        let transcriptPath = ClaudeRegistryReader.transcriptPath(projects: paths.claudeProjects, cwd: cwd, sessionId: nativeId)

        var record = SessionRecord(id: "claude:\(nativeId)", provider: "claude", nativeId: nativeId)
        record.cwd = cwd
        record.repo = repo.name
        record.repoPath = repo.root
        record.color = repo.color
        record.since = statusUpdatedAt ?? startedAt
        record.activeAt = activeAt
        record.open = true
        record.pid = pid
        record.transcriptPath = transcriptPath
        record.status = status
        record.statusSource = "claude-registry"

        if let transcriptPath = transcriptPath {
            let summary = transcripts.summary(path: transcriptPath)
            record.title = summary.title
            record.model = summary.model

            if let pending = summary.pending {
                if ClaudeRegistryReader.isFresh(at: pending.at, activeAt: activeAt) {
                    record.status = .waiting
                    record.question = pending.text
                    record.questions = pending.questions
                    record.statusSource = "claude-transcript:AskUserQuestion"
                    if let at = pending.at { record.activeAt = at }
                }
            } else if let report = summary.report, ClaudeRegistryReader.isFresh(at: report.at, activeAt: activeAt) {
                record.status = report.report.status
                record.question = report.report.question
                record.result = report.report.result
                if !report.report.task.isEmpty { record.task = report.report.task }
                if !report.report.title.isEmpty { record.title = report.report.title }
                record.reportedAt = report.at
                record.statusSource = "report"
            }
        }

        // A registry "waiting" with no concrete question surfaces its reason
        // (if any) so the UI can show a translated placeholder.
        if record.status == .waiting, record.question.isEmpty {
            record.statusSource = waitingFor.isEmpty ? "claude-registry" : "claude-registry:waiting:\(waitingFor)"
        }

        return record
    }

    // Without a fresher activity marker, nothing contradicts the transcript
    // evidence, so it is taken as current.
    private static func isFresh(at: Date?, activeAt: Date?) -> Bool {
        guard let activeAt = activeAt else { return true }
        guard let at = at else { return false }
        return at >= activeAt
    }

    // Claude Code names a project folder after its working directory, with
    // every character outside A-Z/a-z/0-9 (including "/" itself) replaced by
    // "-", one for one, with no collapsing of repeats. Older or unusual
    // installs may instead replace only "/"; failing both, the session id is
    // searched one level deep across every project folder.
    static func transcriptPath(projects: URL, cwd: String, sessionId: String) -> String? {
        let fileManager = FileManager.default
        func candidate(_ folderName: String) -> String? {
            let path = projects.appendingPathComponent(folderName).appendingPathComponent("\(sessionId).jsonl").path
            return fileManager.fileExists(atPath: path) ? path : nil
        }
        if let found = candidate(sanitize(cwd)) { return found }
        if let found = candidate(cwd.replacingOccurrences(of: "/", with: "-")) { return found }

        guard let folders = try? fileManager.contentsOfDirectory(at: projects, includingPropertiesForKeys: nil) else { return nil }
        for folder in folders {
            let path = folder.appendingPathComponent("\(sessionId).jsonl").path
            if fileManager.fileExists(atPath: path) { return path }
        }
        return nil
    }

    private static func sanitize(_ cwd: String) -> String {
        var result = ""
        result.reserveCapacity(cwd.count)
        for scalar in cwd.unicodeScalars {
            switch scalar.value {
            case 48...57, 65...90, 97...122: result.unicodeScalars.append(scalar) // 0-9, A-Z, a-z
            default: result.append("-")
            }
        }
        return result
    }
}
