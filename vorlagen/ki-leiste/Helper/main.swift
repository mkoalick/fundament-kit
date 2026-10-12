import Foundation

// Command-line helper inside the app bundle (Contents/MacOS). Claude Code runs
// it for every hook event; people can run it to install hooks, report a status,
// or print what the app currently sees. It links only Foundation, so a hook
// costs a few milliseconds, and it never writes to stdout from a hook: Claude
// Code would add that text to the conversation.

let started = Date()
var arguments = Array(CommandLine.arguments.dropFirst())

func option(_ name: String) -> String? {
    guard let index = arguments.firstIndex(of: name), index + 1 < arguments.count else { return nil }
    let value = arguments[index + 1]
    arguments.removeSubrange(index...index + 1)
    return value
}

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data((message + "\n").utf8))
    exit(1)
}

let supportOverride = option("--support") ?? ProcessInfo.processInfo.environment["KI_LEISTE_SUPPORT"]
let paths = AppPaths(base: supportOverride.map { URL(fileURLWithPath: ($0 as NSString).expandingTildeInPath) })
let command = arguments.first ?? "help"

switch command {
case "claude-hook":
    // Never fail a hook: whatever happens, exit 0 without output.
    let input = FileHandle.standardInput.readData(ofLength: 4 * 1024 * 1024)
    guard let event = (try? JSONSerialization.jsonObject(with: input)) as? [String: Any],
          let sessionId = event["session_id"] as? String else { exit(0) }
    let caller = ProcessInspector.callingProgram()
    ClaudeHookStore(folder: paths.claudeHooks).update(sessionId) { existing in
        ClaudeHookFold.apply(event, at: started, to: existing, caller: caller)
    }
    exit(0)

case "report":
    // report --status done [--result …] [--question …] [--task …] [--session claude:<id>]
    let environment = ProcessInfo.processInfo.environment
    let id = option("--session") ?? environment["CLAUDE_CODE_SESSION_ID"].map { "claude:\($0)" }
    guard let id = id, id.range(of: "^[a-z]+:[A-Za-z0-9_-]+$", options: .regularExpression) != nil else {
        fail("report: --session claude:<id> or codex:<id> is required outside a Claude Code session")
    }
    var json: [String: Any] = ["status": option("--status") ?? ""]
    for key in ["question", "result", "task", "title"] { if let value = option("--\(key)") { json[key] = value } }
    guard let report = SessionReport(json: json) else {
        fail("report: --status must be working, waiting (with --question), ready, done (without --question) or blocked")
    }
    do { try SessionCollector.writeReport(id: id, report: report, paths: paths) } catch { fail("report: could not write") }

case "hooks":
    // hooks status|install|uninstall [--settings <file>] [--helper <path>]
    let settings = option("--settings").map { URL(fileURLWithPath: ($0 as NSString).expandingTildeInPath) } ?? paths.claudeSettings
    let helper = option("--helper") ?? AppIdentity.helperURL.path
    let installer = ClaudeHookInstaller(helperPath: helper)
    let action = arguments.count > 1 ? arguments[1] : "status"
    do {
        switch action {
        case "status":
            let state = try installer.state(of: try? Data(contentsOf: settings))
            print("\(settings.path): \(state)")
        case "install":
            let outcome = try installer.install(at: settings, backups: paths.base.appendingPathComponent("backups"))
            print(outcome.changed ? "Installed in \(settings.path)" + (outcome.backup.map { "; backup: \($0.path)" } ?? "") : "Already installed")
        case "uninstall":
            let outcome = try installer.uninstall(at: settings, backups: paths.base.appendingPathComponent("backups"))
            print(outcome.changed ? "Removed from \(settings.path)" + (outcome.backup.map { "; backup: \($0.path)" } ?? "") : "Nothing to remove")
        default:
            fail("hooks: status, install or uninstall")
        }
    } catch { fail("\(error)") }

case "collect":
    // Prints what the app would show, without the app. --no-write keeps the register untouched.
    let repos = RepoResolver()
    let collector = SessionCollector(paths: paths, providers: [
        ClaudeProvider(paths: paths, repos: repos, useRegistry: !arguments.contains("--hooks-only")),
        CodexProvider(paths: paths, repos: repos)
    ])
    collector.writesRegister = !arguments.contains("--no-write")
    let snapshot = collector.collect()
    let register = SessionRegister(source: nil, generatedAt: snapshot.generatedAt, sessions: snapshot.local + snapshot.external)
    let encoder = SessionRegister.encoder()
    encoder.outputFormatting.insert(.prettyPrinted)
    print(String(decoding: (try? encoder.encode(register)) ?? Data(), as: UTF8.self))

case "version", "--version":
    print(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "dev")

default:
    print("""
    Usage: \(AppIdentity.helperName) <command>
      hooks status|install|uninstall [--settings <file>]   Claude Code hooks in settings.json
      report --status <state> [--result …] [--question …]   report this session's state
      collect [--no-write] [--hooks-only]                   print the sessions the app sees
      claude-hook                                           (run by Claude Code, reads one event on stdin)
    Options: --support <folder>  use another data folder
    """)
}
