import Foundation

// Cases found in the first review; the reviewers reproduced each against the earlier code.
func reviewFixTests() {
    let installer = ClaudeHookInstaller(helperPath: "/Applications/KI-Leiste.app/Contents/MacOS/ki-leiste-hook", marker: "ki-leiste-hook")

    // Two "hooks" keys: every JSON reader keeps the last, so editing the first would do nothing.
    let twice = Data(#"{"hooks": {"Stop": []}, "model": "x", "hooks": {"Stop": []}}"#.utf8)
    check((try? installer.installed(into: twice)) == nil, "A settings file with \"hooks\" twice is refused")
    let eventTwice = Data(#"{"hooks": {"Stop": [], "Stop": []}}"#.utf8)
    check((try? installer.installed(into: eventTwice)) == nil, "An event listed twice is refused")

    // A foreign hook that merely mentions the marker stays untouched.
    let foreign = Data(#"{"hooks": {"Stop": [{"hooks": [{"type": "command", "command": "echo 'see ki-leiste-hook' # ki-leiste-hook"}]}]}}"#.utf8)
    check((try? installer.state(of: foreign)) == .notInstalled, "A foreign command with the marker word is not ours")
    check((try? installer.removed(from: foreign)) == foreign, "Removing never touches a foreign command with the marker word")
    if let installed = try? installer.installed(into: foreign) {
        check((try? installer.removed(from: installed)) == foreign, "Install and remove keep the look-alike foreign hook")
    } else { check(false, "Install next to a look-alike foreign hook") }

    // A dangling symlink: the real file is created behind it, the link stays.
    let folder = temporaryFolder("review")
    defer { try? FileManager.default.removeItem(at: folder) }
    let link = folder.appendingPathComponent("settings.json")
    let target = folder.appendingPathComponent("dotfiles/claude/settings.json")
    try? FileManager.default.createSymbolicLink(atPath: link.path, withDestinationPath: "dotfiles/claude/settings.json")
    let outcome = try? installer.install(at: link, backups: folder.appendingPathComponent("backups"))
    check(outcome?.changed == true && (try? FileManager.default.destinationOfSymbolicLink(atPath: link.path)) != nil,
          "A symlink whose target does not exist yet stays a symlink")
    check((try? installer.state(of: Data(contentsOf: target))) == .installed, "The file behind the dangling symlink is created")

    // An unknown notification after the end does not reopen the session.
    let caller = ProcessInspector.Info(pid: 7, parent: 1, name: "claude", startedAt: Date(timeIntervalSince1970: 1))
    var record = ClaudeHookFold.apply(["session_id": "s", "hook_event_name": "SessionEnd", "reason": "other"],
                                      at: Date(timeIntervalSince1970: 100), to: nil, caller: caller)
    record = ClaudeHookFold.apply(["session_id": "s", "hook_event_name": "Notification", "notification_type": "something_new"],
                                  at: Date(timeIntervalSince1970: 101), to: record, caller: caller)
    check(record?.endedAt != nil, "An unknown late notification keeps an ended session ended")
    record = ClaudeHookFold.apply(["session_id": "s", "hook_event_name": "TotallyNewEvent"], at: Date(timeIntervalSince1970: 102), to: record, caller: caller)
    check(record?.endedAt != nil, "An unknown event keeps an ended session ended")

    // Claude's own list: a reused pid and a path-like session id are both ignored.
    let home = folder.appendingPathComponent("home")
    let paths = AppPaths(base: folder.appendingPathComponent("support"), home: home)
    try? FileManager.default.createDirectory(at: paths.claudeSessions, withIntermediateDirectories: true)
    let started = Date(timeIntervalSince1970: 1_800_000_000)
    func entry(_ pid: Int, _ id: String, procStart: String?) {
        var object: [String: Any] = ["pid": pid, "sessionId": id, "cwd": "/Users/alex/Projects/api-server", "kind": "interactive",
                                     "status": "idle", "startedAt": Int(started.timeIntervalSince1970 * 1000)]
        object["procStart"] = procStart
        try? JSONSerialization.data(withJSONObject: object).write(to: paths.claudeSessions.appendingPathComponent("\(pid).json"))
    }
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "EEE MMM d HH:mm:ss yyyy"
    entry(11, "same-process", procStart: formatter.string(from: started))
    entry(12, "reused-pid", procStart: formatter.string(from: started))
    entry(13, "../../escape", procStart: nil)
    let reader = ClaudeRegistryReader(paths: paths, repos: RepoResolver(), transcripts: ClaudeTranscriptReader(),
                                      isAlive: { _ in true },
                                      processStart: { pid in pid == 12 ? started.addingTimeInterval(3600) : started })
    let ids = Set(reader.sessions(now: started).map { $0.nativeId })
    check(ids == ["same-process"], "A reused pid and an unsafe session id are both left out")
    check(ClaudeRegistryReader.parseProcStart("Mon Oct  5 08:45:18 2026") != nil, "Single-digit days with two spaces parse")

    // Old and new color keys together: the new key wins, every time.
    for _ in 0..<20 {
        let settings = try? JSONDecoder().decode(BarSettings.self, from: Data(##"{"statusColors":{"input":"#111111","waiting":"#222222"}}"##.utf8))
        if settings?.statusColors["waiting"] != "#222222" { check(false, "The current color key wins over the old one"); return }
    }
    check(true, "The current color key wins over the old one")
}
