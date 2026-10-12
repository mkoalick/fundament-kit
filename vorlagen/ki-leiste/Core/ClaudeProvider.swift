import Foundation

// Claude Code sessions. The documented hooks are the main source: the helper
// keeps one state file per session. Claude's own session list under
// ~/.claude/sessions is undocumented and only fills gaps: sessions started
// before the hooks were installed, and the moment a permission was granted
// (no hook reports that until the tool has finished).
final class ClaudeProvider: SessionProvider {
    let paths: AppPaths
    let repos: RepoResolver
    var useRegistry: Bool
    private let store: ClaudeHookStore
    private let transcripts = ClaudeTranscriptReader()
    private lazy var registry = ClaudeRegistryReader(paths: paths, repos: repos, transcripts: transcripts,
                                                      isAlive: { [weak self] pid in self?.isAlive(pid, nil) ?? false })
    private let isAlive: (Int32, Date?) -> Bool
    // Transcripts change with every step of work; titles do not. Re-read at most this often.
    private var summaries: [String: (summary: ClaudeTranscriptSummary, readAt: Date)] = [:]
    static let transcriptInterval: TimeInterval = 20

    init(paths: AppPaths, repos: RepoResolver, useRegistry: Bool = true,
         isAlive: @escaping (Int32, Date?) -> Bool = { ProcessInspector.isAlive($0, startedAt: $1) }) {
        self.paths = paths
        self.repos = repos
        self.useRegistry = useRegistry
        self.isAlive = isAlive
        store = ClaudeHookStore(folder: paths.claudeHooks)
    }

    var name: String { "claude" }
    var watchPaths: [URL] { useRegistry ? [paths.claudeHooks, paths.claudeSessions] : [paths.claudeHooks] }

    func collect(now: Date, changed: Set<String>) -> [SessionRecord] {
        let fallback = useRegistry ? registry.sessions(now: now) : []
        let fallbackById = Dictionary(fallback.map { ($0.nativeId, $0) }, uniquingKeysWith: { _, last in last })
        var result: [SessionRecord] = []
        var covered = Set<String>()
        let library = paths.home.appendingPathComponent("Library").path + "/"
        for hook in store.all() {
            covered.insert(hook.sessionId)
            guard hook.endedAt == nil, !hook.cwd.hasPrefix(library) else { continue }
            let alive = hook.pid.map { isAlive($0, hook.pidStartedAt) } ?? (now.timeIntervalSince(hook.lastEventAt) < 6 * 3600)
            guard alive else { continue }
            var record = SessionRecord(id: "claude:\(hook.sessionId)", provider: "claude", nativeId: hook.sessionId)
            let repo = repos.resolve(hook.cwd)
            record.cwd = hook.cwd
            record.repo = repo.name
            record.repoPath = repo.root
            record.color = repo.color
            record.status = hook.status
            record.question = hook.question
            record.questions = hook.questions
            record.result = hook.result
            record.task = hook.task
            record.since = hook.since
            record.activeAt = hook.activeAt
            record.reportedAt = hook.reportedAt
            record.pid = hook.pid ?? fallbackById[hook.sessionId]?.pid
            record.transcriptPath = hook.transcriptPath.isEmpty ? nil : hook.transcriptPath
            record.statusSource = hook.statusSource
            record.lastMessage = hook.lastMessage
            let summary = hook.transcriptPath.isEmpty ? ClaudeTranscriptSummary() : transcriptSummary(hook.transcriptPath, now: now)
            record.title = !hook.title.isEmpty ? hook.title : summary.title
            record.model = !hook.model.isEmpty ? hook.model : summary.model
            // A granted permission only shows up in Claude's own list until the tool finishes.
            if hook.status == .waiting, hook.statusSource.hasPrefix("hook:Notification:permission") || hook.statusSource == "hook:PermissionRequest",
               let live = fallbackById[hook.sessionId], live.status == .working, (live.since ?? .distantPast) > hook.since {
                record.status = .working
                record.question = ""
                record.since = live.since
                record.activeAt = live.since
                record.statusSource = "claude-registry:after-permission"
            }
            result.append(record)
        }
        for record in fallback where !covered.contains(record.nativeId) { result.append(record) }
        // Forget transcripts of sessions that are gone.
        let current = Set(result.compactMap { $0.transcriptPath })
        summaries = summaries.filter { current.contains($0.key) }
        if now.timeIntervalSince(lastCleanup) > 3600 {
            lastCleanup = now
            store.removeExpired(now: now) { [isAlive] hook in hook.pid.map { isAlive($0, hook.pidStartedAt) } ?? false }
        }
        return result
    }

    private var lastCleanup = Date.distantPast

    private func transcriptSummary(_ path: String, now: Date) -> ClaudeTranscriptSummary {
        if let cached = summaries[path], now.timeIntervalSince(cached.readAt) < ClaudeProvider.transcriptInterval, !cached.summary.title.isEmpty {
            return cached.summary
        }
        let summary = transcripts.summary(path: path)
        summaries[path] = (summary, now)
        return summary
    }
}
