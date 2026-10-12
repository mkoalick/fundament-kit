import Foundation

// The collector (closed sessions, reports, external sources, register file) and
// the Claude provider that combines hook state with the fallback list.
func collectorTests() {
    collectorMergeTests()
    claudeProviderTests()
}

private final class FakeProvider: SessionProvider {
    var records: [SessionRecord] = []
    var name: String { "fake" }
    var watchPaths: [URL] { [] }
    func collect(now: Date, changed: Set<String>) -> [SessionRecord] { records }
}

private func open(_ id: String, _ status: SessionRecord.Status, active: Date? = nil) -> SessionRecord {
    var record = SessionRecord(id: id, provider: "claude", nativeId: String(id.split(separator: ":").last ?? ""))
    record.status = status
    record.activeAt = active
    record.since = active
    record.repo = "api-server"
    return record
}

private func collectorMergeTests() {
    let folder = temporaryFolder("collector")
    defer { try? FileManager.default.removeItem(at: folder) }
    let paths = AppPaths(base: folder.appendingPathComponent("support"), home: folder)
    let provider = FakeProvider()
    let collector = SessionCollector(paths: paths, providers: [provider])
    let t0 = Date(timeIntervalSince1970: 1_800_000_000)

    provider.records = [open("claude:a", .working, active: t0), open("claude:b", .done, active: t0), open("claude:c", .waiting, active: t0)]
    provider.records[2].question = "Which one?"
    var snapshot = collector.collect(now: t0)
    check(snapshot.visible.count == 3, "Open sessions are visible")
    check(FileManager.default.fileExists(atPath: paths.register.path), "The register file is written")

    provider.records = []
    snapshot = collector.collect(now: t0.addingTimeInterval(60))
    let a = snapshot.local.first { $0.id == "claude:a" }, b = snapshot.local.first { $0.id == "claude:b" }
    let c = snapshot.local.first { $0.id == "claude:c" }
    check(snapshot.visible.isEmpty && snapshot.local.count == 3, "Ended sessions leave the strip but stay in the register")
    check(a?.status == .unknown && a?.open == false && a?.closedAt == t0.addingTimeInterval(60), "A vanished working session becomes unknown")
    check(b?.status == .done, "A finished session keeps its result after closing")
    check(c?.question == "" && c?.status == .unknown, "A closed session no longer waits for anything")
    snapshot = collector.collect(now: t0.addingTimeInterval(60 + 16 * 60))
    check(snapshot.local.map { $0.id } == ["claude:b"], "Closed sessions without result go after 15 minutes, done ones stay")
    snapshot = collector.collect(now: t0.addingTimeInterval(60 + 25 * 3600))
    check(snapshot.local.isEmpty, "Done sessions go after a day")

    // History survives an app restart through the register file.
    provider.records = [open("claude:d", .working, active: t0)]
    _ = collector.collect(now: t0)
    provider.records = []
    _ = collector.collect(now: t0.addingTimeInterval(10))
    let restarted = SessionCollector(paths: paths, providers: [provider])
    check(restarted.collect(now: t0.addingTimeInterval(20)).local.first?.id == "claude:d", "Closed history is reloaded after a restart")

    // Explicit reports from the helper's report command.
    let r = SessionCollector(paths: paths, providers: [provider])
    provider.records = [open("claude:e", .working, active: t0)]
    try? SessionCollector.writeReport(id: "claude:e", report: SessionReport(status: .done, result: "Shipped."), paths: paths, now: t0.addingTimeInterval(5))
    snapshot = r.collect(now: t0.addingTimeInterval(6))
    check(snapshot.local.first { $0.id == "claude:e" }?.status == .done && snapshot.local.first { $0.id == "claude:e" }?.result == "Shipped.", "A newer report marks done")
    snapshot = r.collect(now: t0.addingTimeInterval(7))
    check(snapshot.local.first { $0.id == "claude:e" }?.status == .done, "The report holds while nothing new happens")
    provider.records = [open("claude:e", .working, active: t0.addingTimeInterval(30))]
    snapshot = r.collect(now: t0.addingTimeInterval(31))
    check(snapshot.local.first { $0.id == "claude:e" }?.status == .working, "New work replaces an older report")
    try? SessionCollector.writeReport(id: "claude:e", report: SessionReport(status: .blocked, result: "Old"), paths: paths, now: t0.addingTimeInterval(20))
    snapshot = r.collect(now: t0.addingTimeInterval(32))
    check(snapshot.local.first { $0.id == "claude:e" }?.status == .working, "A report older than the last work is ignored")
    check(snapshot.local.first { $0.id == "claude:e" }?.since == t0.addingTimeInterval(30), "Since stays with the evidence")

    // External sources: stale after 90 s, local ids win, origin defaults to the source name.
    var external = open("server:phone:x", .waiting, active: t0)
    external.question = "Approve?"
    var duplicate = open("claude:e", .done)
    duplicate.repo = "elsewhere"
    let register = SessionRegister(source: "Phone", generatedAt: t0.addingTimeInterval(31), sessions: [external, duplicate])
    try? writePrivately(try! SessionRegister.encoder().encode(register), to: paths.sources.appendingPathComponent("phone.json"))
    try? writePrivately(Data("not json".utf8), to: paths.sources.appendingPathComponent("broken.json"))
    snapshot = r.collect(now: t0.addingTimeInterval(40))
    check(snapshot.external.map { $0.id } == ["server:phone:x"], "External rows join, local ids win, broken files are skipped")
    check(snapshot.external.first?.origin == "Phone" && snapshot.external.first?.stale == false, "A fresh source keeps its label")
    snapshot = r.collect(now: t0.addingTimeInterval(31 + 91))
    check(snapshot.external.first?.stale == true, "A source that stopped writing turns stale")
    check(SessionDisplay(snapshot.external[0]).state == "unknown", "A stale source cannot show a current question")

    // The register is rewritten on change and at least every 30 s, never in between.
    let stamp = { (try? FileManager.default.attributesOfItem(atPath: paths.register.path))?[.modificationDate] as? Date }
    let w = SessionCollector(paths: AppPaths(base: folder.appendingPathComponent("w"), home: folder), providers: [provider])
    provider.records = [open("claude:f", .working, active: t0)]
    _ = w.collect(now: t0)
    let registerFile = folder.appendingPathComponent("w/sessions.json")
    let first = try? Data(contentsOf: registerFile)
    _ = w.collect(now: t0.addingTimeInterval(10))
    check((try? Data(contentsOf: registerFile)) == first, "No rewrite without a change within 30 s")
    _ = w.collect(now: t0.addingTimeInterval(31))
    check((try? Data(contentsOf: registerFile)) != first, "A heartbeat rewrite after 30 s shows the app is running")
    _ = stamp
    let decoded = try? SessionRegister.decoder().decode(SessionRegister.self, from: Data(contentsOf: registerFile))
    check(decoded?.schema == 1 && decoded?.sessions.first?.id == "claude:f", "The register file has the documented format")
    let permissions = (try? FileManager.default.attributesOfItem(atPath: registerFile.path))?[.posixPermissions] as? NSNumber
    check(permissions?.intValue == 0o600, "The register is private")
}

private func claudeProviderTests() {
    let folder = temporaryFolder("claudeprovider")
    defer { try? FileManager.default.removeItem(at: folder) }
    let home = folder.appendingPathComponent("home")
    let paths = AppPaths(base: folder.appendingPathComponent("support"), home: home)
    let repo = home.appendingPathComponent("Projects/api-server")
    try? FileManager.default.createDirectory(at: repo.appendingPathComponent(".git"), withIntermediateDirectories: true)
    try? FileManager.default.createDirectory(at: repo.appendingPathComponent("src/deep"), withIntermediateDirectories: true)
    var alive: Set<Int32> = [101, 102, 103, 201]
    let provider = ClaudeProvider(paths: paths, repos: RepoResolver(), useRegistry: true, isAlive: { pid, _ in alive.contains(pid) })
    let store = ClaudeHookStore(folder: paths.claudeHooks)
    let t0 = Date(timeIntervalSince1970: 1_800_000_000)
    func hook(_ id: String, pid: Int32, cwd: String, _ change: (inout ClaudeHookRecord) -> Void = { _ in }) {
        store.update(id) { _ in
            var record = ClaudeHookRecord(sessionId: id, at: t0)
            record.pid = pid
            record.cwd = cwd
            change(&record)
            return record
        }
    }
    hook("s1", pid: 101, cwd: repo.appendingPathComponent("src/deep").path) { $0.status = .working; $0.title = "Fix the login" }
    hook("s2", pid: 102, cwd: repo.path) { $0.endedAt = t0 }
    hook("s3", pid: 999, cwd: repo.path)
    hook("s4", pid: 103, cwd: home.appendingPathComponent("Library/Application Support/Meter").path)
    hook("s5", pid: 201, cwd: repo.path) { $0.status = .waiting; $0.statusSource = "hook:Notification:permission_prompt"; $0.since = t0 }

    // Claude's own list: s5 is working again since the permission was granted; s6 has no hooks yet.
    try? FileManager.default.createDirectory(at: paths.claudeSessions, withIntermediateDirectories: true)
    let ms = { (date: Date) in Int(date.timeIntervalSince1970 * 1000) }
    for (pid, id, status) in [(201, "s5", "busy"), (202, "s6", "idle")] as [(Int32, String, String)] {
        let entry: [String: Any] = ["pid": Int(pid), "sessionId": id, "cwd": repo.path, "startedAt": ms(t0), "kind": "interactive",
                                    "status": status, "updatedAt": ms(t0.addingTimeInterval(9)), "statusUpdatedAt": ms(t0.addingTimeInterval(9))]
        try? JSONSerialization.data(withJSONObject: entry).write(to: paths.claudeSessions.appendingPathComponent("\(pid).json"))
    }
    alive.insert(202)
    var records = Dictionary(provider.collect(now: t0.addingTimeInterval(10), changed: []).map { ($0.id, $0) }, uniquingKeysWith: { a, _ in a })
    check(records["claude:s1"]?.repo == "api-server" && records["claude:s1"]?.repoPath == repo.path, "A session in a subfolder groups under its git repository")
    check(records["claude:s1"]?.title == "Fix the login" && records["claude:s1"]?.status == .working, "Hook state and title come through")
    check(records["claude:s2"] == nil && records["claude:s3"] == nil, "Ended sessions and dead processes are left out")
    check(records["claude:s4"] == nil, "Helper apps below ~/Library are not work")
    check(records["claude:s5"]?.status == .working && records["claude:s5"]?.statusSource == "claude-registry:after-permission",
          "A granted permission shows as work before the tool finishes")
    check(records["claude:s6"]?.status == .ready && records["claude:s6"]?.statusSource.hasPrefix("claude-registry") == true,
          "Sessions without hooks still appear through the fallback")
    check(records.count == 3, "No session appears twice")

    let hooksOnly = ClaudeProvider(paths: paths, repos: RepoResolver(), useRegistry: false, isAlive: { pid, _ in alive.contains(pid) })
    records = Dictionary(hooksOnly.collect(now: t0.addingTimeInterval(10), changed: []).map { ($0.id, $0) }, uniquingKeysWith: { a, _ in a })
    check(records["claude:s6"] == nil && records["claude:s5"]?.status == .waiting, "Without the fallback only hooks count")
}

// Flag-file switches in the menu (settings.json "menuToggles").
func menuToggleTests() {
    let folder = temporaryFolder("toggles")
    defer { try? FileManager.default.removeItem(at: folder) }
    let file = folder.appendingPathComponent("flags/delivery-off").path
    let decoded = try? JSONDecoder().decode(BarSettings.self, from: Data(#"{"menuToggles":[{"title":"Delivery","file":"\#(file)"}]}"#.utf8))
    let flag = decoded?.menuToggles.first
    check(flag?.onWhenMissing == true && flag?.isOn == true, "A toggle without its file is on by default")
    FileManager.default.createFile(atPath: folder.appendingPathComponent("flags").path, contents: nil)
    try? FileManager.default.removeItem(at: folder.appendingPathComponent("flags"))
    try? FileManager.default.createDirectory(at: folder.appendingPathComponent("flags"), withIntermediateDirectories: true)
    FileManager.default.createFile(atPath: file, contents: Data())
    check(flag?.isOn == false, "The flag file switches it off")
    let inverse = BarSettings.MenuToggle(title: "Debug", file: file, onWhenMissing: false)
    check(inverse.isOn, "An inverse toggle is on while the file exists")
    check((try? JSONDecoder().decode(BarSettings.self, from: JSONEncoder().encode(decoded!)))?.menuToggles == decoded?.menuToggles,
          "Toggles survive a save and reload")
    check(BarSettings.MenuToggle(title: "x", file: "~/a").url.path == FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("a").path,
          "A tilde in the path means the home folder")
}
