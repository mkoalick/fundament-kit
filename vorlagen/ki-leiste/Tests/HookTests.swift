import Foundation

// Claude Code hook events folded into session state, and the installer that
// merges the hooks into settings.json without touching anything else.
func hookTests() {
    hookFoldTests()
    hookStoreTests()
    hookInstallerTests()
}

private func event(_ name: String, _ extra: [String: Any] = [:]) -> [String: Any] {
    var value: [String: Any] = ["session_id": "abc-123", "hook_event_name": name, "cwd": "/Users/alex/Projects/api-server",
                                "transcript_path": "/Users/alex/.claude/projects/-Users-alex-Projects-api-server/abc-123.jsonl"]
    value.merge(extra) { _, new in new }
    return value
}

private func hookFoldTests() {
    let caller = ProcessInspector.Info(pid: 4242, parent: 1, name: "claude", startedAt: Date(timeIntervalSince1970: 1_000))
    var now = Date(timeIntervalSince1970: 2_000)
    func step(_ record: ClaudeHookRecord?, _ name: String, _ extra: [String: Any] = [:], seconds: TimeInterval = 1) -> ClaudeHookRecord? {
        now = now.addingTimeInterval(seconds)
        return ClaudeHookFold.apply(event(name, extra), at: now, to: record, caller: caller)
    }

    var record = step(nil, "SessionStart", ["source": "startup", "model": "claude-test-1", "session_title": "Migrate the database"])
    check(record?.status == .ready && record?.pid == 4242 && record?.title == "Migrate the database", "SessionStart opens a ready session with pid and title")
    check(record?.model == "claude-test-1" && record?.cwd == "/Users/alex/Projects/api-server", "Start carries model and folder")
    record = step(record, "UserPromptSubmit", ["prompt": "secret prompt text"])
    check(record?.status == .working && record?.activeAt == now, "A prompt means work")
    check(!(String(data: try! SessionRegister.encoder().encode(record!), encoding: .utf8)!.contains("secret prompt")), "The prompt text is never stored")
    record = step(record, "PreToolUse", ["tool_name": "AskUserQuestion", "tool_input": ["questions": [
        ["question": "Which variant?", "header": "Variant", "multiSelect": false, "options": [["label": "A"], ["label": "B"]]]]]])
    check(record?.status == .waiting && record?.question == "Which variant?", "AskUserQuestion waits with its question")
    check(record?.questions.first?.options == ["A", "B"] && record?.questions.first?.header == "Variant", "Structured options survive")
    record = step(record, "PostToolUse", ["tool_name": "AskUserQuestion"])
    check(record?.status == .working && record?.question == "" && record?.questions.isEmpty == true, "An answered question means work again")
    record = step(record, "Notification", ["notification_type": "permission_prompt", "message": "Claude needs your permission to use Bash"])
    check(record?.status == .waiting && record?.question == "Claude needs your permission to use Bash", "A permission prompt waits")
    record = step(record, "Notification", ["notification_type": "idle_prompt", "message": "Claude is waiting for your input"])
    check(record?.status == .waiting, "An idle reminder does not end a pending permission")
    record = step(record, "PostToolUse", ["tool_name": "Bash"])
    check(record?.status == .working, "A finished tool clears the permission wait")
    record = step(record, "Notification", ["notification_type": "auth_success", "message": "ok"])
    check(record?.status == .working && record?.lastEvent == "PostToolUse", "Unrelated notifications change nothing")
    record = step(record, "Stop", ["last_assistant_message": "Done.\nSESSION_REPORT: {\"status\":\"done\",\"result\":\"Migration applied.\"}"])
    check(record?.status == .done && record?.result == "Migration applied." && record?.statusSource == "report", "A report at the end of a turn marks done")
    record = step(record, "UserPromptSubmit")
    check(record?.status == .working && record?.result == "", "A new prompt clears the old result")
    record = step(record, "Stop", ["last_assistant_message": "I changed three files."])
    check(record?.status == .ready && record?.lastMessage == "I changed three files.", "A plain turn end means ready, never done")
    record = step(record, "Stop", ["last_assistant_message": "MYNAME_SESSION_REPORT: {\"status\":\"fertig\",\"ergebnis\":\"Alles erledigt.\"}"])
    check(record?.status == .done && record?.result == "Alles erledigt.", "Personal prefixes and the first versions' keys are accepted")
    record = step(record, "Stop", ["last_assistant_message": "SESSION_REPORT: {\"status\":\"done\",\"question\":\"Really?\"}"])
    check(record?.status == .ready, "An invalid report (done with a question) is ignored")
    record = step(record, "SessionStart", ["source": "startup"])
    record = step(record, "UserPromptSubmit")
    record = step(record, "SessionStart", ["source": "compact"])
    check(record?.status == .working, "Compaction in the middle of work keeps working")

    // A background hook that started earlier must not overwrite newer state.
    let later = step(record, "Stop", ["last_assistant_message": "ok", "model": "claude-test-2"])
    let late = ClaudeHookFold.apply(event("PostToolUse", ["model": "claude-test-3"]), at: now.addingTimeInterval(-5), to: later, caller: caller)
    check(late?.status == .ready && late?.model == "claude-test-3", "A late event refreshes facts but not the status")

    record = step(later, "SessionEnd", ["reason": "prompt_input_exit"])
    check(record?.endedAt == now && record?.endReason == "prompt_input_exit", "SessionEnd closes")
    record = step(record, "UserPromptSubmit")
    check(record?.endedAt == nil, "Activity after an end reopens (resume in the same process)")

    record = step(record, "PermissionRequest", ["tool_name": "Bash", "tool_input": ["command": "export TOKEN=abc && deploy", "description": "Deploy the app"]])
    check(record?.question == "Bash: Deploy the app" && record?.status == .waiting, "A permission request names tool and description")
    check(!(record?.question.contains("TOKEN") ?? true), "The command line itself is never stored")
    record = step(record, "Notification", ["notification_type": "permission_prompt", "message": "Claude needs your permission to use Bash"])
    check(record?.question == "Bash: Deploy the app", "The generic notification keeps the precise permission text")
    record = step(record, "StopFailure", ["error_type": "rate_limit"])
    check(record?.status == .blocked && record?.result == "rate_limit", "A failed turn is blocked with its reason")

    check(ClaudeHookFold.apply(event("Stop", ["session_id": "../../etc"]), at: now, to: nil, caller: caller) == nil, "Path-like session ids are refused")
    check(ClaudeHookFold.apply(["session_id": "abc"], at: now, to: nil, caller: caller) == nil, "Events without a name are refused")
    let other = ClaudeHookFold.apply(event("UserPromptSubmit", ["model": "<synthetic>"]), at: now, to: nil, caller: nil)
    check(other?.model == "" && other?.pid == nil, "Synthetic models and unknown callers leave fields empty")
}

private func hookStoreTests() {
    let folder = temporaryFolder("hookstore")
    defer { try? FileManager.default.removeItem(at: folder) }
    let store = ClaudeHookStore(folder: folder)
    let start = Date(timeIntervalSince1970: 5_000)
    store.update("s1") { _ in ClaudeHookRecord(sessionId: "s1", at: start) }
    let attributes = try? FileManager.default.attributesOfItem(atPath: store.url("s1").path)
    check((attributes?[.posixPermissions] as? NSNumber)?.intValue == 0o600, "Hook state files are private")
    // Twenty hooks of one session at once: the lock keeps every change.
    DispatchQueue.concurrentPerform(iterations: 20) { _ in
        store.update("s1") { old in
            var next = old ?? ClaudeHookRecord(sessionId: "s1", at: start)
            next.task += "x"
            return next
        }
    }
    check(store.read("s1")?.task.count == 20, "Concurrent hooks of one session never lose an update")
    check(store.update("../escape") { _ in ClaudeHookRecord(sessionId: "x", at: start) } == nil, "The store refuses unsafe names")
    store.update("s2") { _ in
        var ended = ClaudeHookRecord(sessionId: "s2", at: start)
        ended.endedAt = start
        return ended
    }
    store.removeExpired(now: start.addingTimeInterval(25 * 3600), isAlive: { $0.sessionId == "s1" })
    check(store.read("s2") == nil && store.read("s1") != nil, "Ended sessions are removed after a day, live ones stay")
}

private func hookInstallerTests() {
    let installer = ClaudeHookInstaller(helperPath: "/Applications/Agent Strip.app/Contents/MacOS/ki-leiste-hook", marker: "ki-leiste-hook")
    check(installer.command == "[ -x '/Applications/Agent Strip.app/Contents/MacOS/ki-leiste-hook' ] && '/Applications/Agent Strip.app/Contents/MacOS/ki-leiste-hook' claude-hook; true # ki-leiste-hook",
          "The hook command survives spaces and ends silently without the app")
    check(ClaudeHookInstaller(helperPath: "/tmp/it's/hook").command.contains("'/tmp/it'\\''s/hook'"), "Quotes in the path are escaped for the shell")

    // A settings file with many foreign hooks in the user's own formatting.
    let foreign = ##"""
    {
      "permissions": {
        "allow": ["Bash(git status)", "Read(\/etc\/hosts)"],
        "deny": []
      },
      "model": "opus",
      "hooks": {
        "PreToolUse": [
          {
            "matcher": "Bash",
            "hooks": [
              { "type": "command", "command": "python3 ~/.claude/hooks/guard.py", "timeout": 5 }
            ]
          },
          {
            "matcher": "Write|Edit",
            "hooks": [{"type": "command", "command": "echo \"ünïcødé ✓\" >> /tmp/log"}]
          }
        ],
        "SessionStart": [
          {
            "hooks": [
              {
                "type": "command",
                "command": "cat ~/notes.md"
              }
            ]
          }
        ],
        "PreCompact": [{"hooks": [{"type": "command", "command": "true"}]}]
      },
      "statusLine": {"type": "command", "command": "~/bin/status"},
      "language": "de"
    }

    """##
    let original = Data(foreign.utf8)
    guard let installed = try? installer.installed(into: original) else { check(false, "Install into a busy settings file"); return }
    check((try? installer.state(of: installed)) == .installed, "After install every hook is present")
    check((try? JSONSerialization.jsonObject(with: installed)) != nil, "The result is valid JSON")
    check((try? installer.removed(from: installed)) == original, "Removing our hooks restores the file byte for byte")
    let text = String(decoding: installed, as: UTF8.self)
    for snippet in [#"{ "type": "command", "command": "python3 ~/.claude/hooks/guard.py", "timeout": 5 }"#,
                    #""hooks": [{"type": "command", "command": "echo \"ünïcødé ✓\" >> /tmp/log"}]"#,
                    #""allow": ["Bash(git status)", "Read(\/etc\/hosts)"],"#,
                    #""PreCompact": [{"hooks": [{"type": "command", "command": "true"}]}]"#] {
        check(text.contains(snippet), "Foreign entry kept character for character: \(snippet.prefix(40))")
    }
    check(installer.foreignView(installed) == installer.foreignView(original), "Foreign settings mean the same after install")
    check(text.contains("\n      {\n        \"matcher\": \"AskUserQuestion\","), "New entries follow the file's indentation")
    check((try? installer.installed(into: installed)) == installed, "Installing twice changes nothing")

    // Counter-check: the byte comparison really notices a changed foreign hook.
    let tampered = Data(text.replacingOccurrences(of: "guard.py\", \"timeout\": 5", with: "guard.py\", \"timeout\": 6").utf8)
    check((try? installer.removed(from: tampered)) != original, "A changed foreign hook is detected by the comparison")

    // A moved app makes the entries outdated; reinstall replaces only ours.
    let moved = ClaudeHookInstaller(helperPath: "/Users/alex/Applications/Agent Strip.app/Contents/MacOS/ki-leiste-hook", marker: "ki-leiste-hook")
    check((try? moved.state(of: installed)) == .outdated, "A moved app is reported as outdated")
    if let reinstalled = try? moved.installed(into: installed) {
        check((try? moved.state(of: reinstalled)) == .installed, "Reinstall after moving is complete")
        check(!String(decoding: reinstalled, as: UTF8.self).contains("'/Applications/Agent Strip.app"), "Old entries are gone")
        check((try? moved.removed(from: reinstalled)) == original, "Reinstall still leaves every foreign byte alone")
    } else { check(false, "Reinstall after moving") }

    // Other shapes: missing, empty, no hooks yet, empty lists, tabs, CRLF, one line.
    for (label, input) in [("missing file", nil), ("empty file", Data("  \n".utf8)), ("empty object", Data("{}".utf8)),
                           ("no hooks key", Data("{\n\t\"model\": \"opus\"\n}\n".utf8)),
                           ("empty hooks", Data("{\r\n  \"hooks\": {}\r\n}\r\n".utf8)),
                           ("empty lists", Data(#"{"hooks": {"Stop": [], "PreToolUse": [ ]}}"#.utf8)),
                           ("one line", Data(#"{"hooks":{"Stop":[{"hooks":[{"type":"command","command":"say hi"}]}]}}"#.utf8))] as [(String, Data?)] {
        guard let result = try? installer.installed(into: input) else { check(false, "Install into \(label)"); continue }
        check((try? installer.state(of: result)) == .installed && (try? JSONSerialization.jsonObject(with: result)) != nil, "Install into \(label)")
        if let input = input, (try? JSONSerialization.jsonObject(with: input)) != nil {
            check(installer.foreignView(result) == installer.foreignView(input), "Foreign content unchanged in \(label)")
        }
        if label == "no hooks key" || label == "one line" || label == "empty object" {
            check((try? installer.removed(from: result)) == input, "Round trip is byte-identical for \(label)")
        }
        if label == "no hooks key" { check(String(decoding: result, as: UTF8.self).contains("\n\t\"hooks\": {\n\t\t\"SessionStart\""), "Tabs stay tabs") }
        if label == "empty hooks" { check(!String(decoding: result, as: UTF8.self).replacingOccurrences(of: "\r\n", with: "").contains("\n"), "CRLF files stay CRLF") }
    }

    // Refusals: never write what cannot be understood.
    for (label, input) in [("comments", "{ // mine\n \"hooks\": {} }"), ("trailing comma", "{\"a\": 1,}"),
                           ("hooks not an object", "{\"hooks\": []}"), ("event not a list", "{\"hooks\": {\"Stop\": {}}}"),
                           ("top level list", "[]")] {
        check((try? installer.installed(into: Data(input.utf8))) == nil, "Refuses \(label)")
    }

    // Files: symlink followed, permissions kept, backup written, refusal leaves the file alone.
    let folder = temporaryFolder("installer")
    defer { try? FileManager.default.removeItem(at: folder) }
    let real = folder.appendingPathComponent("dotfiles/settings.json")
    try? FileManager.default.createDirectory(at: real.deletingLastPathComponent(), withIntermediateDirectories: true)
    FileManager.default.createFile(atPath: real.path, contents: original, attributes: [.posixPermissions: 0o600])
    let link = folder.appendingPathComponent("settings.json")
    try? FileManager.default.createSymbolicLink(at: link, withDestinationURL: real)
    let backups = folder.appendingPathComponent("backups")
    let outcome = try? installer.install(at: link, backups: backups)
    check(outcome?.changed == true, "Install writes the file")
    check((try? FileManager.default.destinationOfSymbolicLink(atPath: link.path)) != nil, "The symlink stays a symlink")
    check((try? installer.state(of: Data(contentsOf: real))) == .installed, "The real file behind the link was changed")
    let permissions = (try? FileManager.default.attributesOfItem(atPath: real.path))?[.posixPermissions] as? NSNumber
    check(permissions?.intValue == 0o600, "File permissions are kept")
    check(outcome?.backup.flatMap { try? Data(contentsOf: $0) } == original, "The backup holds the previous version")
    check((try? installer.install(at: link, backups: backups))?.changed == false, "A second install does not write")
    check((try? installer.uninstall(at: link, backups: backups))?.changed == true && (try? Data(contentsOf: real)) == original,
          "Uninstall restores the original bytes")
    let saved = ((try? FileManager.default.contentsOfDirectory(at: backups, includingPropertiesForKeys: nil)) ?? []).compactMap { try? Data(contentsOf: $0) }
    check(saved.count == 2 && saved.contains(original), "Backups made in the same second do not overwrite each other")
    let broken = folder.appendingPathComponent("broken.json")
    FileManager.default.createFile(atPath: broken.path, contents: Data("{ nope".utf8))
    check((try? installer.install(at: broken, backups: backups)) == nil && (try? Data(contentsOf: broken)) == Data("{ nope".utf8),
          "Invalid settings are left untouched")
    let fresh = folder.appendingPathComponent("new/settings.json")
    check((try? installer.install(at: fresh, backups: backups))?.backup == nil && (try? installer.state(of: Data(contentsOf: fresh))) == .installed,
          "A missing settings file is created without a backup")
}
