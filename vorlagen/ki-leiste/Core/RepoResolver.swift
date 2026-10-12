import Foundation

// Which repository a working directory belongs to, read from the files git
// keeps on disk (no `git` child process). A session in a subfolder groups under
// its repository; a linked worktree groups under the repository it belongs to.
final class RepoResolver {
    struct Repo: Equatable {
        let name: String
        let root: String       // git top level of this checkout (or the folder itself)
        let mainRoot: String   // the main checkout for a linked worktree, else == root
        let color: String?
    }

    private var cache: [String: Repo] = [:]
    private let fileManager = FileManager.default

    func clear() { cache.removeAll() }

    func resolve(_ cwd: String) -> Repo {
        if let known = cache[cwd] { return known }
        let repo = lookup(cwd)
        cache[cwd] = repo
        return repo
    }

    private func lookup(_ cwd: String) -> Repo {
        guard !cwd.isEmpty else { return Repo(name: "?", root: "", mainRoot: "", color: nil) }
        let start = URL(fileURLWithPath: cwd).standardizedFileURL
        var folder = start
        while true {
            let dotGit = folder.appendingPathComponent(".git")
            var isFolder: ObjCBool = false
            if fileManager.fileExists(atPath: dotGit.path, isDirectory: &isFolder) {
                let root = folder.path
                let main = isFolder.boolValue ? root : (mainCheckout(gitFile: dotGit) ?? root)
                let name = URL(fileURLWithPath: main).lastPathComponent
                let color = vscodeColor(cwd) ?? vscodeColor(root) ?? (main != root ? vscodeColor(main) : nil)
                return Repo(name: name, root: root, mainRoot: main, color: color)
            }
            let parent = folder.deletingLastPathComponent()
            if parent.path == folder.path { break }
            folder = parent
        }
        return Repo(name: start.lastPathComponent, root: start.path, mainRoot: start.path, color: vscodeColor(cwd))
    }

    // A linked worktree's `.git` is a file: "gitdir: <main>/.git/worktrees/<name>".
    // That folder's `commondir` points back to "<main>/.git". Submodules use the
    // same file form but have no commondir; they are their own repository.
    private func mainCheckout(gitFile: URL) -> String? {
        guard let text = try? String(contentsOf: gitFile, encoding: .utf8),
              let line = text.split(separator: "\n").first(where: { $0.hasPrefix("gitdir:") }) else { return nil }
        let raw = line.dropFirst("gitdir:".count).trimmingCharacters(in: .whitespaces)
        let gitDir = raw.hasPrefix("/") ? URL(fileURLWithPath: raw) : gitFile.deletingLastPathComponent().appendingPathComponent(raw)
        guard let common = try? String(contentsOf: gitDir.appendingPathComponent("commondir"), encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines), !common.isEmpty else { return nil }
        let commonDir = (common.hasPrefix("/") ? URL(fileURLWithPath: common) : gitDir.appendingPathComponent(common)).standardizedFileURL
        guard commonDir.lastPathComponent == ".git" else { return nil }
        return commonDir.deletingLastPathComponent().path
    }

    // VS Code colors each window from the folder's .vscode/settings.json; the same
    // color marks the repository in the strip. Order: what the window shows most.
    static let colorKeys = ["titleBar.activeBackground", "activityBar.background", "statusBar.background", "statusBar.noFolderBackground"]

    func vscodeColor(_ folder: String) -> String? {
        guard let text = try? String(contentsOfFile: folder + "/.vscode/settings.json", encoding: .utf8) else { return nil }
        return RepoResolver.color(fromSettings: text)
    }

    static func color(fromSettings text: String) -> String? {
        // settings.json is JSON with comments and trailing commas.
        var cleaned = text.replacingOccurrences(of: "(?m)^\\s*//.*$", with: "", options: .regularExpression)
        cleaned = cleaned.replacingOccurrences(of: ",(\\s*[}\\]])", with: "$1", options: .regularExpression)
        guard let data = cleaned.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        let custom = object["workbench.colorCustomizations"] as? [String: Any] ?? [:]
        let candidates = colorKeys.map { custom[$0] } + [object["peacock.color"]]
        for case let value as String in candidates
        where value.range(of: "^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$", options: .regularExpression) != nil {
            return String(value.prefix(7)).uppercased()
        }
        return nil
    }
}
