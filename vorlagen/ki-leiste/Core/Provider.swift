import Foundation

// A source of local agent sessions. The collector asks every enabled provider
// for its current sessions whenever a watched path changes or the slow timer
// fires. Providers keep their own caches; `collect` must be cheap when nothing
// changed and must never block on the network or a child process.
protocol SessionProvider: AnyObject {
    var name: String { get }                 // "claude", "codex"
    var watchPaths: [URL] { get }            // folders whose changes should trigger a refresh
    func collect(now: Date, changed: Set<String>) -> [SessionRecord]
}

// Where the app keeps its files: ~/Library/Application Support/<bundle id>/.
// The hook helper lives inside the same bundle and resolves the same folder.
struct AppPaths {
    let base: URL
    let home: URL

    init(base: URL? = nil, home: URL = FileManager.default.homeDirectoryForCurrentUser) {
        self.home = home
        if let base = base {
            self.base = base
        } else {
            let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            self.base = support.appendingPathComponent(AppPaths.bundleIdentifier)
        }
    }

    static var bundleIdentifier: String { Bundle.main.bundleIdentifier ?? "dev.agentstrip.cli" }

    var settings: URL { base.appendingPathComponent("settings.json") }
    var register: URL { base.appendingPathComponent("sessions.json") }        // written by the app for other tools
    var claudeHooks: URL { base.appendingPathComponent("claude-hooks") }       // one state file per Claude session
    var reports: URL { base.appendingPathComponent("reports") }                // explicit reports from the CLI
    var sources: URL { base.appendingPathComponent("sources") }                // external session sources
    var notificationLedger: URL { base.appendingPathComponent("notification-ledger.json") }
    var log: URL { base.appendingPathComponent("app.log") }

    var claudeDirectory: URL { home.appendingPathComponent(".claude") }
    var claudeSessions: URL { claudeDirectory.appendingPathComponent("sessions") }
    var claudeProjects: URL { claudeDirectory.appendingPathComponent("projects") }
    var claudeSettings: URL { claudeDirectory.appendingPathComponent("settings.json") }
    var codexSessions: URL { home.appendingPathComponent(".codex/sessions") }
}

// Reads at most the last `limit` bytes of a file, split into lines. Transcripts
// and rollouts grow to many megabytes; their current state sits at the end.
func tailLines(_ path: String, limit: Int) -> [Data] {
    guard let handle = FileHandle(forReadingAtPath: path) else { return [] }
    defer { try? handle.close() }
    guard let end = try? handle.seekToEnd() else { return [] }
    let start = end > UInt64(limit) ? end - UInt64(limit) : 0
    try? handle.seek(toOffset: start)
    guard let data = try? handle.readToEnd() else { return [] }
    var lines = data.split(separator: UInt8(ascii: "\n"), omittingEmptySubsequences: true).map { Data($0) }
    if start > 0, !lines.isEmpty { lines.removeFirst() } // the first line is cut
    return lines
}

func jsonObject(_ line: Data) -> [String: Any]? {
    (try? JSONSerialization.jsonObject(with: line)) as? [String: Any]
}

// File modification time and size, the change key for cached parses.
struct FileStamp: Equatable {
    let modified: Date
    let size: UInt64

    init?(_ path: String) {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: path),
              let modified = attributes[.modificationDate] as? Date,
              let size = attributes[.size] as? NSNumber else { return nil }
        self.modified = modified
        self.size = size.uint64Value
    }
}
