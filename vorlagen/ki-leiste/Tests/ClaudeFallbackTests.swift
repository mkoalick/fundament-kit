import Foundation

// Tests for the undocumented-registry fallback: the transcript reader
// (title, model, pending question, SESSION_REPORT) and the registry reader
// (~/.claude/sessions/*.json) built on top of it. All fixtures are synthetic;
// nothing here ever touches the real ~/.claude.

// MARK: - Fixture helpers

private func claudeWriteLines(_ url: URL, _ lines: [[String: Any]]) {
    try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    var text = ""
    for object in lines {
        let data = try! JSONSerialization.data(withJSONObject: object, options: [])
        text += String(data: data, encoding: .utf8)! + "\n"
    }
    try! text.write(to: url, atomically: true, encoding: .utf8)
}

private func claudeAppendLine(_ url: URL, _ object: [String: Any]) {
    let data = try! JSONSerialization.data(withJSONObject: object, options: [])
    let line = String(data: data, encoding: .utf8)! + "\n"
    let handle = try! FileHandle(forWritingTo: url)
    handle.seekToEndOfFile()
    handle.write(line.data(using: .utf8)!)
    try? handle.close()
}

private func claudeTouchFile(_ url: URL) {
    try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try! "{}\n".write(to: url, atomically: true, encoding: .utf8)
}

// `FileManager.contentsOfDirectory` resolves symlinks in the parent path
// (macOS temp folders sit under /var, itself a symlink to /private/var); a
// path built by simple string concatenation does not. Compare resolved forms
// so the test is not tripped up by that, independent of the real bug surface.
private func claudeResolved(_ path: String?) -> String? {
    path.map { URL(fileURLWithPath: $0).resolvingSymlinksInPath().path }
}

private func claudeResolved(_ url: URL) -> String {
    url.resolvingSymlinksInPath().path
}

private func claudeAssistantText(_ text: String, model: String? = nil, at: Date) -> [String: Any] {
    var message: [String: Any] = ["role": "assistant", "content": [["type": "text", "text": text]]]
    if let model = model { message["model"] = model }
    return ["type": "assistant", "timestamp": formatDate(at), "message": message]
}

private func claudeAssistantToolUse(id: String, questions: [[String: Any]], at: Date) -> [String: Any] {
    let message: [String: Any] = ["role": "assistant",
                                   "content": [["type": "tool_use", "id": id, "name": "AskUserQuestion", "input": ["questions": questions]]]]
    return ["type": "assistant", "timestamp": formatDate(at), "message": message]
}

private func claudeUserToolResult(id: String, content: String, at: Date) -> [String: Any] {
    ["type": "user", "timestamp": formatDate(at),
     "message": ["role": "user", "content": [["type": "tool_result", "tool_use_id": id, "content": content]]]]
}

private func claudeUserText(_ text: String, at: Date) -> [String: Any] {
    ["type": "user", "timestamp": formatDate(at), "message": ["role": "user", "content": text]]
}

private func claudeTitleEvent(custom: String? = nil, ai: String? = nil) -> [String: Any] {
    if let custom = custom { return ["type": "custom-title", "customTitle": custom] }
    return ["type": "ai-title", "aiTitle": ai ?? ""]
}

private func claudeQuestion(_ question: String, header: String = "", multiSelect: Bool = false, options: [String] = []) -> [String: Any] {
    ["question": question, "header": header, "multiSelect": multiSelect, "options": options.map { ["label": $0] }]
}

private func claudeRegistryEntry(pid: Int32, sessionId: String, cwd: String, kind: String = "interactive", status: String,
                                  waitingFor: String? = nil, startedAt: Date, statusUpdatedAt: Date? = nil, updatedAt: Date? = nil) -> [String: Any] {
    var object: [String: Any] = ["pid": pid, "sessionId": sessionId, "cwd": cwd, "kind": kind, "status": status,
                                  "startedAt": Int(startedAt.timeIntervalSince1970 * 1000)]
    if let waitingFor = waitingFor { object["waitingFor"] = waitingFor }
    if let statusUpdatedAt = statusUpdatedAt { object["statusUpdatedAt"] = Int(statusUpdatedAt.timeIntervalSince1970 * 1000) }
    if let updatedAt = updatedAt { object["updatedAt"] = Int(updatedAt.timeIntervalSince1970 * 1000) }
    return object
}

private func claudeWriteRegistry(_ url: URL, _ object: [String: Any]) {
    try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    let data = try! JSONSerialization.data(withJSONObject: object, options: [])
    try! data.write(to: url)
}

// MARK: - ClaudeTranscriptReader: title precedence, model, pending question, cache

private func claudeTranscriptTitleAndPendingTests() {
    let root = temporaryFolder("claude-transcript-a")
    let file = root.appendingPathComponent("session-a.jsonl")
    let base = Date(timeIntervalSince1970: 1_800_000_000)
    let reader = ClaudeTranscriptReader()

    claudeWriteLines(file, [
        claudeTitleEvent(ai: "Erstbezeichnung automatisch"),
        claudeAssistantText("Hallo, ich fange an.", model: "claude-sonnet-5-model-x", at: base.addingTimeInterval(1)),
        claudeAssistantText("Kurzer Zwischenschritt.", model: "<synthetic>", at: base.addingTimeInterval(2)),
        claudeTitleEvent(custom: "Eigener Titel"),
        claudeAssistantToolUse(id: "toolu_q1",
                                questions: [claudeQuestion("Welche Variante?", header: "Variante", multiSelect: true, options: ["Rot", "Blau"])],
                                at: base.addingTimeInterval(3))
    ])

    var summary = reader.summary(path: file.path)
    check(summary.title == "Eigener Titel", "A later custom-title wins over an earlier ai-title")
    check(summary.model == "claude-sonnet-5-model-x", "A synthetic model value never overrides the last real model")
    check(summary.pending?.text == "Welche Variante?", "An unanswered AskUserQuestion becomes the pending question")
    check(summary.pending?.questions.first?.header == "Variante"
          && summary.pending?.questions.first?.multiSelect == true
          && summary.pending?.questions.first?.options == ["Rot", "Blau"],
          "Structured question fields (header, multiSelect, options) survive parsing")
    check(summary.report == nil, "No SESSION_REPORT line yet means no report")

    claudeAppendLine(file, claudeUserToolResult(id: "toolu_q1", content: "Antwort: Rot", at: base.addingTimeInterval(4)))
    summary = reader.summary(path: file.path)
    check(summary.pending == nil, "A matching tool_result clears the pending question")

    // Push the title and pending-question lines out of the 1 MB tail window;
    // the cache must keep the title, everything else may legitimately reset.
    let padding = String(repeating: "x", count: 2_000_000)
    claudeAppendLine(file, claudeUserText(padding, at: base.addingTimeInterval(5)))
    claudeAppendLine(file, claudeUserText("Ende der Unterhaltung.", at: base.addingTimeInterval(6)))
    summary = reader.summary(path: file.path)
    check(summary.title == "Eigener Titel", "The title survives a tail that no longer reaches the title line")
    check(summary.lastActivity == base.addingTimeInterval(6), "Last activity reflects the final event even past a truncated line")

    try? FileManager.default.removeItem(at: root)
}

// MARK: - ClaudeTranscriptReader: SESSION_REPORT validity and ordering

private func claudeTranscriptReportValidityTests() {
    let root = temporaryFolder("claude-transcript-b")
    let file = root.appendingPathComponent("session-b.jsonl")
    let base = Date(timeIntervalSince1970: 1_800_100_000)
    let reader = ClaudeTranscriptReader()

    claudeWriteLines(file, [
        claudeAssistantText(##"SESSION_REPORT: {"status":"waiting"}"##, at: base.addingTimeInterval(1)),
        claudeAssistantText(##"SESSION_REPORT: {"status":"done","result":"Fertig","question":"Trotzdem offen?"}"##, at: base.addingTimeInterval(2))
    ])
    var summary = reader.summary(path: file.path)
    check(summary.report == nil, "A waiting report without a question and a done report with one are both invalid")

    claudeAppendLine(file, claudeAssistantText(##"SESSION_REPORT: {"status":"waiting","question":"Variante A oder B?"}"##, at: base.addingTimeInterval(3)))
    summary = reader.summary(path: file.path)
    check(summary.report?.report.status == .waiting && summary.report?.report.question == "Variante A oder B?",
          "A valid waiting report with a question is accepted")

    claudeAppendLine(file, claudeAssistantText(##"SESSION_REPORT: {"status":"done","result":"Testlauf abgeschlossen"}"##, at: base.addingTimeInterval(4)))
    summary = reader.summary(path: file.path)
    check(summary.report?.report.status == .done && summary.report?.report.result == "Testlauf abgeschlossen",
          "A later valid report replaces an earlier valid one")

    try? FileManager.default.removeItem(at: root)
}

// MARK: - ClaudeRegistryReader: filters, waiting reasons, pending/report override, freshness

private func claudeRegistryTests() {
    let root = temporaryFolder("claude-registry")
    let home = root.appendingPathComponent("home")
    let paths = AppPaths(base: root.appendingPathComponent("support"), home: home)
    let repos = RepoResolver()
    let transcripts = ClaudeTranscriptReader()
    let base = Date(timeIntervalSince1970: 1_800_200_000)

    let deadPid: Int32 = 70001
    func isAliveStub(_ pid: Int32) -> Bool { pid != deadPid }

    func transcriptFile(folder: String, sessionId: String) -> URL {
        paths.claudeProjects.appendingPathComponent(folder).appendingPathComponent("\(sessionId).jsonl")
    }

    claudeWriteRegistry(paths.claudeSessions.appendingPathComponent("dead.json"),
                         claudeRegistryEntry(pid: deadPid, sessionId: "sess-dead", cwd: "/Users/alex/Projects/dead-session",
                                             status: "idle", startedAt: base))

    claudeWriteRegistry(paths.claudeSessions.appendingPathComponent("kind.json"),
                         claudeRegistryEntry(pid: 70002, sessionId: "sess-kind", cwd: "/Users/alex/Projects/wrong-kind",
                                             kind: "background", status: "idle", startedAt: base))

    claudeWriteRegistry(paths.claudeSessions.appendingPathComponent("library.json"),
                         claudeRegistryEntry(pid: 70003, sessionId: "sess-lib",
                                             cwd: home.appendingPathComponent("Library/Application Support/Helper").path,
                                             status: "busy", startedAt: base))

    claudeWriteRegistry(paths.claudeSessions.appendingPathComponent("good.json"),
                         claudeRegistryEntry(pid: 70004, sessionId: "sess-good", cwd: "/Users/alex/Projects/api-server",
                                             status: "busy", startedAt: base, statusUpdatedAt: base.addingTimeInterval(5)))

    claudeWriteRegistry(paths.claudeSessions.appendingPathComponent("waitreason.json"),
                         claudeRegistryEntry(pid: 70005, sessionId: "sess-waitreason", cwd: "/Users/alex/Projects/wait-reason",
                                             status: "waiting", waitingFor: "permission", startedAt: base, statusUpdatedAt: base.addingTimeInterval(5)))

    claudeWriteRegistry(paths.claudeSessions.appendingPathComponent("waitnone.json"),
                         claudeRegistryEntry(pid: 70006, sessionId: "sess-waitnone", cwd: "/Users/alex/Projects/wait-none",
                                             status: "waiting", startedAt: base, statusUpdatedAt: base.addingTimeInterval(5)))

    claudeWriteRegistry(paths.claudeSessions.appendingPathComponent("pending.json"),
                         claudeRegistryEntry(pid: 70007, sessionId: "sess-pending", cwd: "/Users/alex/Projects/pending-case",
                                             status: "busy", startedAt: base, statusUpdatedAt: base.addingTimeInterval(5)))
    claudeWriteLines(transcriptFile(folder: "-Users-alex-Projects-pending-case", sessionId: "sess-pending"), [
        claudeAssistantToolUse(id: "toolu_p1", questions: [claudeQuestion("Variante A oder B?", header: "Variante")], at: base.addingTimeInterval(6))
    ])

    claudeWriteRegistry(paths.claudeSessions.appendingPathComponent("fresh.json"),
                         claudeRegistryEntry(pid: 70008, sessionId: "sess-fresh", cwd: "/Users/alex/Projects/fresh-report", status: "idle", startedAt: base))
    claudeWriteLines(transcriptFile(folder: "-Users-alex-Projects-fresh-report", sessionId: "sess-fresh"), [
        claudeAssistantText(##"SESSION_REPORT: {"status":"done","result":"Migration geprüft","title":"Migrationscheck"}"##, at: base.addingTimeInterval(6))
    ])

    claudeWriteRegistry(paths.claudeSessions.appendingPathComponent("stale.json"),
                         claudeRegistryEntry(pid: 70009, sessionId: "sess-stale", cwd: "/Users/alex/Projects/stale-report", status: "busy",
                                             startedAt: base, statusUpdatedAt: base.addingTimeInterval(100)))
    claudeWriteLines(transcriptFile(folder: "-Users-alex-Projects-stale-report", sessionId: "sess-stale"), [
        claudeAssistantText(##"SESSION_REPORT: {"status":"done","result":"Alter Teilauftrag"}"##, at: base.addingTimeInterval(10))
    ])

    claudeWriteRegistry(paths.claudeSessions.appendingPathComponent("freshworking.json"),
                         claudeRegistryEntry(pid: 70010, sessionId: "sess-freshworking", cwd: "/Users/alex/Projects/fresh-working-report", status: "busy",
                                             startedAt: base, statusUpdatedAt: base.addingTimeInterval(10)))
    claudeWriteLines(transcriptFile(folder: "-Users-alex-Projects-fresh-working-report", sessionId: "sess-freshworking"), [
        claudeAssistantText(##"SESSION_REPORT: {"status":"waiting","question":"Weiter mit Plan B?"}"##, at: base.addingTimeInterval(20))
    ])

    let reader = ClaudeRegistryReader(paths: paths, repos: repos, transcripts: transcripts, isAlive: isAliveStub)
    let sessions = reader.sessions(now: base.addingTimeInterval(1000))
    func find(_ nativeId: String) -> SessionRecord? { sessions.first { $0.nativeId == nativeId } }

    check(find("sess-dead") == nil, "A session whose process is no longer alive is dropped")
    check(find("sess-kind") == nil, "A non-interactive registry entry is dropped")
    check(find("sess-lib") == nil, "A helper process working under ~/Library is dropped")

    let good = find("sess-good")
    check(good?.status == .working && good?.statusSource == "claude-registry" && good?.id == "claude:sess-good",
          "A plain busy session with no transcript keeps the raw registry status and gets a stable id")
    check(good?.repo == "api-server", "Repo name falls back to the working directory's folder name outside any git checkout")

    let waitReason = find("sess-waitreason")
    check(waitReason?.status == .waiting && waitReason?.question.isEmpty == true
          && waitReason?.statusSource == "claude-registry:waiting:permission",
          "A waiting entry without a concrete question exposes its reason for a translated placeholder")

    let waitNone = find("sess-waitnone")
    check(waitNone?.status == .waiting && waitNone?.statusSource == "claude-registry",
          "A waiting entry with neither a reason nor transcript evidence keeps the plain registry source")

    let pending = find("sess-pending")
    check(pending?.status == .waiting && pending?.question == "Variante A oder B?"
          && pending?.statusSource == "claude-transcript:AskUserQuestion",
          "An open AskUserQuestion in the transcript overrides a busy registry status")

    let fresh = find("sess-fresh")
    check(fresh?.status == .done && fresh?.result == "Migration geprüft" && fresh?.title == "Migrationscheck"
          && fresh?.statusSource == "report",
          "An idle session (no activity marker to be older than) takes a reported done status")

    let stale = find("sess-stale")
    check(stale?.status == .working && stale?.result.isEmpty == true && stale?.statusSource == "claude-registry",
          "A SESSION_REPORT older than the current activity is ignored while the session is busy again")

    let freshWorking = find("sess-freshworking")
    check(freshWorking?.status == .waiting && freshWorking?.question == "Weiter mit Plan B?" && freshWorking?.statusSource == "report",
          "A report at least as new as the current activity is honored even while the registry still says busy")

    try? FileManager.default.removeItem(at: root)
}

// MARK: - transcriptPath: sanitization and fallback search

private func claudeTranscriptPathTests() {
    let root = temporaryFolder("claude-path")
    let projects = root.appendingPathComponent("projects")
    try? FileManager.default.createDirectory(at: projects, withIntermediateDirectories: true)

    // Primary scheme: every character outside A-Z/a-z/0-9 becomes "-", one for
    // one, including "_" and "." - no collapsing of the resulting repeats.
    let cwdA = "/Users/alex/Projects/_internal.tools/my_app"
    let folderA = "-Users-alex-Projects--internal-tools-my-app"
    let sessionA = "sess-sanitize-a"
    claudeTouchFile(projects.appendingPathComponent(folderA).appendingPathComponent("\(sessionA).jsonl"))
    let foundA = ClaudeRegistryReader.transcriptPath(projects: projects, cwd: cwdA, sessionId: sessionA)
    check(claudeResolved(foundA) == claudeResolved(projects.appendingPathComponent(folderA).appendingPathComponent("\(sessionA).jsonl")),
          "Underscore and dot sanitize the same way as every other non-alphanumeric character")

    // Fallback scheme: only "/" replaced, every other character kept as is.
    let cwdB = "/Users/alex/Projects/legacy.app"
    let sessionB = "sess-sanitize-b"
    let folderBSlashOnly = cwdB.replacingOccurrences(of: "/", with: "-")
    claudeTouchFile(projects.appendingPathComponent(folderBSlashOnly).appendingPathComponent("\(sessionB).jsonl"))
    let foundB = ClaudeRegistryReader.transcriptPath(projects: projects, cwd: cwdB, sessionId: sessionB)
    check(claudeResolved(foundB) == claudeResolved(projects.appendingPathComponent(folderBSlashOnly).appendingPathComponent("\(sessionB).jsonl")),
          "An older slash-only sanitization scheme is tried when the primary one does not exist")

    // Last resort: neither scheme matches, the session id is still found one level deep.
    let cwdC = "/Users/alex/Projects/totally-different-cwd"
    let sessionC = "sess-sanitize-c"
    let unrelatedFolder = "some-other-window-name"
    claudeTouchFile(projects.appendingPathComponent(unrelatedFolder).appendingPathComponent("\(sessionC).jsonl"))
    let foundC = ClaudeRegistryReader.transcriptPath(projects: projects, cwd: cwdC, sessionId: sessionC)
    check(claudeResolved(foundC) == claudeResolved(projects.appendingPathComponent(unrelatedFolder).appendingPathComponent("\(sessionC).jsonl")),
          "When neither sanitization scheme matches, a one-level-deep search still finds the session id")

    let foundNone = ClaudeRegistryReader.transcriptPath(projects: projects, cwd: "/Users/alex/Projects/missing", sessionId: "sess-missing")
    check(foundNone == nil, "No matching transcript anywhere yields nil instead of guessing")

    try? FileManager.default.removeItem(at: root)
}

func claudeFallbackTests() {
    claudeTranscriptTitleAndPendingTests()
    claudeTranscriptReportValidityTests()
    claudeRegistryTests()
    claudeTranscriptPathTests()
}
