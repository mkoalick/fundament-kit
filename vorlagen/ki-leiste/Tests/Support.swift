import Foundation

// Minimal test harness shared by every suite: a failed check prints its label
// and ends the run with exit code 1; `cleanup` restores anything a suite changed.
var checks = 0
var cleanup: () -> Void = {}
func check(_ condition: Bool, _ label: String) {
    guard condition else { cleanup(); print("FAILED: \(label)"); exit(1) }
    checks += 1
}

// A fresh temporary folder per suite, removed by the caller.
func temporaryFolder(_ name: String) -> URL {
    let url = FileManager.default.temporaryDirectory.appendingPathComponent("agentstrip-tests-\(name)-\(getpid())")
    try? FileManager.default.removeItem(at: url)
    try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
}

func fixture(_ relative: String) -> URL {
    URL(fileURLWithPath: CommandLine.arguments.count > 0 ? #filePath : "").deletingLastPathComponent()
        .appendingPathComponent("fixtures").appendingPathComponent(relative)
}
