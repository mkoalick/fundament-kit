import Foundation

// Synthetic rollout construction. Every path, id and text below is made up
// for the test - never a real ~/.codex value.

private func jsonLine(_ dict: [String: Any]) -> String {
    let data = try! JSONSerialization.data(withJSONObject: dict, options: [])
    return String(data: data, encoding: .utf8)!
}

private func sessionMetaLine(nativeId: String, cwd: String, source: Any, at: Date) -> String {
    jsonLine([
        "timestamp": formatDate(at),
        "type": "session_meta",
        "payload": [
            "id": nativeId,
            "session_id": nativeId,
            "cwd": cwd,
            "source": source,
            "timestamp": formatDate(at),
        ],
    ])
}

private func taskStartedLine(at: Date) -> String {
    jsonLine(["timestamp": formatDate(at), "type": "event_msg",
              "payload": ["type": "task_started", "started_at": formatDate(at), "turn_id": "turn"]])
}

private func taskCompleteLine(at: Date) -> String {
    jsonLine(["timestamp": formatDate(at), "type": "event_msg",
              "payload": ["type": "task_complete", "completed_at": formatDate(at), "started_at": formatDate(at), "turn_id": "turn"]])
}

private func requestUserInputLine(at: Date, callId: String, questions: [[String: Any]]) -> String {
    let argsData = try! JSONSerialization.data(withJSONObject: ["questions": questions])
    let args = String(data: argsData, encoding: .utf8)!
    return jsonLine(["timestamp": formatDate(at), "type": "response_item",
                      "payload": ["type": "function_call", "name": "request_user_input", "call_id": callId, "arguments": args]])
}

private func functionCallOutputLine(at: Date, callId: String) -> String {
    jsonLine(["timestamp": formatDate(at), "type": "response_item",
              "payload": ["type": "function_call_output", "call_id": callId, "output": "{}"]])
}

private func assistantMessageLine(at: Date, text: String) -> String {
    jsonLine(["timestamp": formatDate(at), "type": "response_item",
              "payload": ["type": "message", "role": "assistant", "content": [["type": "output_text", "text": text]]]])
}

private func turnContextLine(at: Date, model: String) -> String {
    jsonLine(["timestamp": formatDate(at), "type": "turn_context", "payload": ["turn_id": "turn", "model": model]])
}

private func paddingLine(_ n: Int) -> String {
    jsonLine(["timestamp": formatDate(Date()), "type": "token_usage_record",
              "payload": ["n": n, "pad": String(repeating: "x", count: 200)]])
}

private func writeRollout(_ url: URL, _ lines: [String]) {
    try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try? (lines.joined(separator: "\n") + "\n").write(to: url, atomically: true, encoding: .utf8)
}

private func rolloutPath(in home: URL, id: String) -> URL {
    home.appendingPathComponent(".codex/sessions/2026/10/12/rollout-2026-10-12T10-00-00-\(id).jsonl")
}

// MARK: - Fakes

private final class FakeCodexProcesses: CodexProcessSource {
    var pidList: [Int32] = []
    var filesByPid: [Int32: [String]] = [:]
    var startByPid: [Int32: Date] = [:]
    var aliveSet: Set<Int32> = []
    private(set) var openFilesCalls = 0

    func codexPids() -> [Int32] { pidList }
    func openFiles(_ pid: Int32) -> [String] { openFilesCalls += 1; return filesByPid[pid] ?? [] }
    func startTime(_ pid: Int32) -> Date? { startByPid[pid] }
    func isAlive(_ pid: Int32, startedAt: Date?) -> Bool {
        guard aliveSet.contains(pid) else { return false }
        guard let startedAt = startedAt, let real = startByPid[pid] else { return true }
        return abs(real.timeIntervalSince(startedAt)) < 1
    }
}

private final class FakeClock {
    var current: Date
    init(_ date: Date) { current = date }
    func now() -> Date { current }
}

private func newPaths(_ root: URL) -> (AppPaths, URL) {
    let home = root.appendingPathComponent("home")
    return (AppPaths(base: root.appendingPathComponent("base"), home: home), home)
}

private let base0 = Date(timeIntervalSince1970: 1_760_000_000)

// MARK: - Scenarios

func codexProviderTests() {
    scenarioWorking()
    scenarioReadyAfterComplete()
    scenarioOpenQuestionWithStructuredQuestions()
    scenarioAnsweredQuestionReturnsToWork()
    scenarioExplicitReportAfterWork()
    scenarioStaleReportIgnoredAfterNewTask()
    scenarioExecSourceExcluded()
    scenarioSubagentSourceExcluded()
    scenarioModelFromTurnContext()
    scenarioTruncatedTailFirstLineHarmless()
    scenarioScanScheduling()
}

private func scenarioWorking() {
    let root = temporaryFolder("codex-working")
    cleanup = { try? FileManager.default.removeItem(at: root) }
    let (paths, home) = newPaths(root)
    let fake = FakeCodexProcesses()
    let t0 = base0
    let path = rolloutPath(in: home, id: "working")
    writeRollout(path, [
        sessionMetaLine(nativeId: "nid-working", cwd: "/Users/alex/Projects/api-server", source: "cli", at: t0),
        taskStartedLine(at: t0.addingTimeInterval(1)),
    ])
    fake.pidList = [101]; fake.aliveSet = [101]
    fake.filesByPid[101] = [path.path]
    fake.startByPid[101] = t0
    let provider = CodexProvider(paths: paths, repos: RepoResolver(), processes: fake, clock: { t0 })
    let records = provider.collect(now: t0, changed: [])
    check(records.count == 1, "codex: one working session discovered")
    check(records.first?.status == .working, "codex: task_started maps to working")
    check(records.first?.statusSource == "codex-rollout:turn", "codex: working status source is turn-based")
    check(records.first?.id == "codex:nid-working", "codex: id combines provider and native id")
    cleanup(); cleanup = {}
}

private func scenarioReadyAfterComplete() {
    let root = temporaryFolder("codex-ready")
    cleanup = { try? FileManager.default.removeItem(at: root) }
    let (paths, home) = newPaths(root)
    let fake = FakeCodexProcesses()
    let t0 = base0
    let path = rolloutPath(in: home, id: "ready")
    writeRollout(path, [
        sessionMetaLine(nativeId: "nid-ready", cwd: "/Users/alex/Projects/api-server", source: "cli", at: t0),
        taskStartedLine(at: t0.addingTimeInterval(1)),
        taskCompleteLine(at: t0.addingTimeInterval(5)),
    ])
    fake.pidList = [102]; fake.aliveSet = [102]
    fake.filesByPid[102] = [path.path]
    fake.startByPid[102] = t0
    let provider = CodexProvider(paths: paths, repos: RepoResolver(), processes: fake, clock: { t0 })
    let records = provider.collect(now: t0, changed: [])
    check(records.first?.status == .ready, "codex: task_complete maps to ready")
    check(records.first?.since == t0.addingTimeInterval(5), "codex: ready since is the completion time")
    cleanup(); cleanup = {}
}

private func scenarioOpenQuestionWithStructuredQuestions() {
    let root = temporaryFolder("codex-question")
    cleanup = { try? FileManager.default.removeItem(at: root) }
    let (paths, home) = newPaths(root)
    let fake = FakeCodexProcesses()
    let t0 = base0
    let path = rolloutPath(in: home, id: "question")
    writeRollout(path, [
        sessionMetaLine(nativeId: "nid-question", cwd: "/Users/alex/Projects/api-server", source: "vscode", at: t0),
        taskStartedLine(at: t0.addingTimeInterval(1)),
        requestUserInputLine(at: t0.addingTimeInterval(2), callId: "call-1", questions: [
            ["question": "Variante A oder B?", "header": "Wahl", "multiSelect": false, "options": [["label": "A"], ["label": "B"]]],
        ]),
    ])
    fake.pidList = [103]; fake.aliveSet = [103]
    fake.filesByPid[103] = [path.path]
    fake.startByPid[103] = t0
    let provider = CodexProvider(paths: paths, repos: RepoResolver(), processes: fake, clock: { t0 })
    let record = provider.collect(now: t0, changed: []).first
    check(record?.status == .waiting, "codex: open request_user_input maps to waiting")
    check(record?.statusSource == "codex-rollout:request_user_input", "codex: waiting status source names the call")
    check(record?.question == "Variante A oder B?", "codex: question text carried over")
    check(record?.questions.count == 1, "codex: one structured question parsed")
    check(record?.questions.first?.header == "Wahl", "codex: question header parsed")
    check(record?.questions.first?.options == ["A", "B"], "codex: question options parsed")
    check(record?.since == t0.addingTimeInterval(2), "codex: waiting since is the question time")
    cleanup(); cleanup = {}
}

private func scenarioAnsweredQuestionReturnsToWork() {
    let root = temporaryFolder("codex-answered")
    cleanup = { try? FileManager.default.removeItem(at: root) }
    let (paths, home) = newPaths(root)
    let fake = FakeCodexProcesses()
    let t0 = base0
    let path = rolloutPath(in: home, id: "answered")
    writeRollout(path, [
        sessionMetaLine(nativeId: "nid-answered", cwd: "/Users/alex/Projects/api-server", source: "cli", at: t0),
        taskStartedLine(at: t0.addingTimeInterval(1)),
        requestUserInputLine(at: t0.addingTimeInterval(2), callId: "call-1", questions: [["question": "A oder B?"]]),
        functionCallOutputLine(at: t0.addingTimeInterval(3), callId: "call-1"),
    ])
    fake.pidList = [104]; fake.aliveSet = [104]
    fake.filesByPid[104] = [path.path]
    fake.startByPid[104] = t0
    let provider = CodexProvider(paths: paths, repos: RepoResolver(), processes: fake, clock: { t0 })
    let record = provider.collect(now: t0, changed: []).first
    check(record?.status == .working, "codex: answered question falls back to the turn's working state")
    check(record?.question == "", "codex: answered question clears the question text")
    cleanup(); cleanup = {}
}

private func scenarioExplicitReportAfterWork() {
    let root = temporaryFolder("codex-report")
    cleanup = { try? FileManager.default.removeItem(at: root) }
    let (paths, home) = newPaths(root)
    let fake = FakeCodexProcesses()
    let t0 = base0
    let path = rolloutPath(in: home, id: "report")
    writeRollout(path, [
        sessionMetaLine(nativeId: "nid-report", cwd: "/Users/alex/Projects/api-server", source: "cli", at: t0),
        taskStartedLine(at: t0.addingTimeInterval(1)),
        assistantMessageLine(at: t0.addingTimeInterval(2), text: "Fertig.\nSESSION_REPORT: {\"status\":\"done\",\"result\":\"Migration angewendet.\"}"),
        taskCompleteLine(at: t0.addingTimeInterval(3)),
    ])
    fake.pidList = [105]; fake.aliveSet = [105]
    fake.filesByPid[105] = [path.path]
    fake.startByPid[105] = t0
    let provider = CodexProvider(paths: paths, repos: RepoResolver(), processes: fake, clock: { t0 })
    let record = provider.collect(now: t0, changed: []).first
    check(record?.status == .done, "codex: explicit report overrides task_complete's ready")
    check(record?.result == "Migration angewendet.", "codex: report result carried over")
    check(record?.statusSource == "report", "codex: report status source is 'report'")
    check(record?.since == t0.addingTimeInterval(2), "codex: report since is the report time, not the completion time")
    cleanup(); cleanup = {}
}

private func scenarioStaleReportIgnoredAfterNewTask() {
    let root = temporaryFolder("codex-stale-report")
    cleanup = { try? FileManager.default.removeItem(at: root) }
    let (paths, home) = newPaths(root)
    let fake = FakeCodexProcesses()
    let t0 = base0
    let path = rolloutPath(in: home, id: "stale")
    writeRollout(path, [
        sessionMetaLine(nativeId: "nid-stale", cwd: "/Users/alex/Projects/api-server", source: "cli", at: t0),
        taskStartedLine(at: t0.addingTimeInterval(1)),
        assistantMessageLine(at: t0.addingTimeInterval(2), text: "SESSION_REPORT: {\"status\":\"done\",\"result\":\"Erster Lauf.\"}"),
        taskStartedLine(at: t0.addingTimeInterval(10)),
    ])
    fake.pidList = [106]; fake.aliveSet = [106]
    fake.filesByPid[106] = [path.path]
    fake.startByPid[106] = t0
    let provider = CodexProvider(paths: paths, repos: RepoResolver(), processes: fake, clock: { t0 })
    let record = provider.collect(now: t0, changed: []).first
    check(record?.status == .working, "codex: a later task_started clears an earlier report")
    check(record?.result == "", "codex: stale report's result does not leak into the new turn")
    cleanup(); cleanup = {}
}

private func scenarioExecSourceExcluded() {
    let root = temporaryFolder("codex-exec")
    cleanup = { try? FileManager.default.removeItem(at: root) }
    let (paths, home) = newPaths(root)
    let fake = FakeCodexProcesses()
    let t0 = base0
    let path = rolloutPath(in: home, id: "exec")
    writeRollout(path, [
        sessionMetaLine(nativeId: "nid-exec", cwd: "/Users/alex/Projects/api-server", source: "exec", at: t0),
        taskStartedLine(at: t0.addingTimeInterval(1)),
    ])
    fake.pidList = [107]; fake.aliveSet = [107]
    fake.filesByPid[107] = [path.path]
    fake.startByPid[107] = t0
    let provider = CodexProvider(paths: paths, repos: RepoResolver(), processes: fake, clock: { t0 })
    let records = provider.collect(now: t0, changed: [])
    check(records.isEmpty, "codex: 'codex exec' sessions (source exec) are excluded")
    cleanup(); cleanup = {}
}

private func scenarioSubagentSourceExcluded() {
    let root = temporaryFolder("codex-subagent")
    cleanup = { try? FileManager.default.removeItem(at: root) }
    let (paths, home) = newPaths(root)
    let fake = FakeCodexProcesses()
    let t0 = base0
    let path = rolloutPath(in: home, id: "subagent")
    writeRollout(path, [
        sessionMetaLine(nativeId: "nid-subagent", cwd: "/Users/alex/Projects/api-server", source: ["subagent": "review"], at: t0),
        taskStartedLine(at: t0.addingTimeInterval(1)),
    ])
    fake.pidList = [108]; fake.aliveSet = [108]
    fake.filesByPid[108] = [path.path]
    fake.startByPid[108] = t0
    let provider = CodexProvider(paths: paths, repos: RepoResolver(), processes: fake, clock: { t0 })
    let records = provider.collect(now: t0, changed: [])
    check(records.isEmpty, "codex: subagent threads (source is an object) are excluded")
    cleanup(); cleanup = {}
}

private func scenarioModelFromTurnContext() {
    let root = temporaryFolder("codex-model")
    cleanup = { try? FileManager.default.removeItem(at: root) }
    let (paths, home) = newPaths(root)
    let fake = FakeCodexProcesses()
    let t0 = base0
    let path = rolloutPath(in: home, id: "model")
    writeRollout(path, [
        sessionMetaLine(nativeId: "nid-model", cwd: "/Users/alex/Projects/api-server", source: "cli", at: t0),
        turnContextLine(at: t0.addingTimeInterval(1), model: "gpt-6-astra"),
        turnContextLine(at: t0.addingTimeInterval(2), model: "<redacted>"),
        taskStartedLine(at: t0.addingTimeInterval(3)),
    ])
    fake.pidList = [109]; fake.aliveSet = [109]
    fake.filesByPid[109] = [path.path]
    fake.startByPid[109] = t0
    let provider = CodexProvider(paths: paths, repos: RepoResolver(), processes: fake, clock: { t0 })
    let record = provider.collect(now: t0, changed: []).first
    check(record?.model == "gpt-6-astra", "codex: model comes from the last valid turn_context, placeholders ignored")
    cleanup(); cleanup = {}
}

private func scenarioTruncatedTailFirstLineHarmless() {
    let root = temporaryFolder("codex-truncated")
    cleanup = { try? FileManager.default.removeItem(at: root) }
    let (paths, home) = newPaths(root)
    let fake = FakeCodexProcesses()
    let t0 = base0
    let path = rolloutPath(in: home, id: "truncated")
    var lines = [sessionMetaLine(nativeId: "nid-truncated", cwd: "/Users/alex/Projects/api-server", source: "cli", at: t0)]
    for n in 0..<1_500 { lines.append(paddingLine(n)) } // pushes the file well past the 262144-byte tail window
    lines.append(taskStartedLine(at: t0.addingTimeInterval(1)))
    lines.append(taskCompleteLine(at: t0.addingTimeInterval(2)))
    writeRollout(path, lines)
    fake.pidList = [110]; fake.aliveSet = [110]
    fake.filesByPid[110] = [path.path]
    fake.startByPid[110] = t0
    let provider = CodexProvider(paths: paths, repos: RepoResolver(), processes: fake, clock: { t0 })
    let record = provider.collect(now: t0, changed: []).first
    check(record != nil, "codex: a rollout larger than the tail window still yields a session")
    check(record?.status == .ready, "codex: the cut-off first line of the tail does not corrupt the real status")
    cleanup(); cleanup = {}
}

// Covers: first collect scans; a new rollout path for a known pid triggers a
// rescan of known pids; no change inside 60s means no openFiles calls; a
// missed pid is still picked up by the 60s safety net; a dead pid disappears
// immediately; a pid reused with a different start time counts as dead too.
private func scenarioScanScheduling() {
    let root = temporaryFolder("codex-scheduling")
    cleanup = { try? FileManager.default.removeItem(at: root) }
    let (paths, home) = newPaths(root)
    let fake = FakeCodexProcesses()
    let clock = FakeClock(base0)
    let t0 = base0

    let fileA = rolloutPath(in: home, id: "p1-old")
    writeRollout(fileA, [
        sessionMetaLine(nativeId: "nid-p1-old", cwd: "/Users/alex/Projects/api-server", source: "cli", at: t0),
        taskStartedLine(at: t0.addingTimeInterval(1)),
    ])
    fake.pidList = [201]; fake.aliveSet = [201]
    fake.filesByPid[201] = [fileA.path]
    fake.startByPid[201] = t0

    let provider = CodexProvider(paths: paths, repos: RepoResolver(), processes: fake, clock: { clock.now() })

    let first = provider.collect(now: t0, changed: [])
    check(first.count == 1 && first.first?.transcriptPath == fileA.path, "codex: first collect discovers the only known pid")
    let callsAfterFirst = fake.openFilesCalls
    check(callsAfterFirst == 1, "codex: first collect reads openFiles exactly once (one untracked pid)")

    let second = provider.collect(now: t0, changed: [])
    check(second.count == 1, "codex: an unchanged tick keeps reporting the session")
    check(fake.openFilesCalls == callsAfterFirst, "codex: no filesystem change inside 60s means no new openFiles calls")

    let fileB = rolloutPath(in: home, id: "p1-new")
    writeRollout(fileB, [
        sessionMetaLine(nativeId: "nid-p1-new", cwd: "/Users/alex/Projects/api-server-v2", source: "cli", at: t0.addingTimeInterval(20)),
        taskStartedLine(at: t0.addingTimeInterval(21)),
    ])
    fake.filesByPid[201] = [fileB.path] // the same process switched rollout files via /new
    let third = provider.collect(now: t0, changed: [fileB.path])
    check(third.first?.transcriptPath == fileB.path, "codex: a new unmapped rollout path for a known pid triggers a rescan that follows it")
    check(third.first?.id == "codex:nid-p1-new", "codex: the record now reflects the new rollout's native id")
    check(fake.openFilesCalls == callsAfterFirst + 1, "codex: the rescan re-reads the known pid's open files once")
    let callsAfterThird = fake.openFilesCalls

    clock.current = t0.addingTimeInterval(30)
    fake.pidList.append(202)
    fake.aliveSet.insert(202)
    let fileC = rolloutPath(in: home, id: "p2")
    writeRollout(fileC, [
        sessionMetaLine(nativeId: "nid-p2", cwd: "/Users/alex/Projects/batch-jobs", source: "cli", at: t0.addingTimeInterval(30)),
        taskStartedLine(at: t0.addingTimeInterval(31)),
    ])
    fake.filesByPid[202] = [fileC.path]
    fake.startByPid[202] = t0.addingTimeInterval(30)
    let fourth = provider.collect(now: t0.addingTimeInterval(30), changed: [])
    check(fourth.count == 1, "codex: a brand-new pid without a filesystem event is not yet picked up inside 60s")
    check(fake.openFilesCalls == callsAfterThird, "codex: still no extra openFiles call before the safety net is due")

    clock.current = t0.addingTimeInterval(65)
    let fifth = provider.collect(now: t0.addingTimeInterval(65), changed: [])
    check(fifth.count == 2, "codex: the 60s safety net eventually discovers the missed pid")
    check(fake.openFilesCalls == callsAfterThird + 1, "codex: the safety net rescans only the still-unmapped pid")

    fake.aliveSet.remove(201)
    let sixth = provider.collect(now: t0.addingTimeInterval(65), changed: [])
    check(sixth.count == 1 && sixth.first?.id == "codex:nid-p2", "codex: a dead process disappears immediately, without waiting for a scan")

    fake.startByPid[202] = t0.addingTimeInterval(999) // pid 202 reused by an unrelated process
    let seventh = provider.collect(now: t0.addingTimeInterval(65), changed: [])
    check(seventh.isEmpty, "codex: a reused pid with a different start time counts as dead too")

    cleanup(); cleanup = {}
}
