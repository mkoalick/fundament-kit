import Cocoa

// Every preference of the strip in one readable JSON file. Missing keys fall
// back to their defaults, so older files and hand edits keep working.
struct BarSettings: Codable, Equatable {
    enum ChipStyle: String, Codable, CaseIterable { case calm, bold }
    enum RepoLabel: String, Codable, CaseIterable { case abbreviation, stripe }
    enum ScreenChoice: String, Codable, CaseIterable { case largest, main }
    enum Placement: String, Codable, CaseIterable { case makeRoom, floating }

    // A switch in the menu that creates or removes a flag file, for scripts
    // that check such a file (for example a kill switch for an automation).
    struct MenuToggle: Codable, Equatable {
        var title: String
        var file: String
        var onWhenMissing = true   // checked while the file does not exist

        init(title: String, file: String, onWhenMissing: Bool = true) {
            self.title = title
            self.file = file
            self.onWhenMissing = onWhenMissing
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            title = try c.decode(String.self, forKey: .title)
            file = try c.decode(String.self, forKey: .file)
            onWhenMissing = (try? c.decode(Bool.self, forKey: .onWhenMissing)) ?? true
        }

        var url: URL { URL(fileURLWithPath: (file as NSString).expandingTildeInPath) }
        var isOn: Bool { FileManager.default.fileExists(atPath: url.path) != onWhenMissing }
    }

    struct Repo: Codable, Equatable {
        var color: String?
        var abbreviation: String?
        var hidden = false
    }

    static let defaultStatusColors = [
        "waiting": "#F02991", "working": "#267A40", "done": "#FFD12E",
        "blocked": "#F2781A", "unknown": "#8E8E93"
    ]

    var showBar = true
    var style = ChipStyle.calm
    var fontSize = 11.0
    var maxRows = 2
    var showModelBadge = true
    var repoLabel = RepoLabel.abbreviation
    var screen = ScreenChoice.largest
    var placement = Placement.makeRoom
    var pulseInput = true
    var shrinkDelayMinutes = 5.0
    var statusColors = BarSettings.defaultStatusColors
    var repos: [String: Repo] = [:]
    var nativeNotifications = true
    var popupHints = false
    var readyHintAfterSeconds = 60.0
    var overviewURL = ""
    var menuBarLabel = ""          // text in the menu bar; empty shows the icon
    var watchClaude = true
    var watchCodex = true
    var useClaudeRegistry = true   // Claude's internal session list as a fallback to the hooks
    var menuToggles: [MenuToggle] = []

    init() {}

    private enum Keys: String, CodingKey {
        case showBar, style, fontSize, maxRows, showModelBadge, repoLabel, screen, placement, pulseInput,
             shrinkDelayMinutes, statusColors, repos, nativeNotifications, popupHints, readyHintAfterSeconds, overviewURL,
             menuBarLabel, watchClaude, watchCodex, useClaudeRegistry, menuToggles
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: Keys.self)
        func value<T: Decodable>(_ key: Keys, _ fallback: T) -> T { (try? c.decodeIfPresent(T.self, forKey: key)) ?? fallback }
        let base = BarSettings()
        showBar = value(.showBar, base.showBar)
        style = value(.style, base.style)
        fontSize = min(13, max(10, value(.fontSize, base.fontSize)))
        maxRows = min(2, max(1, value(.maxRows, base.maxRows)))
        showModelBadge = value(.showModelBadge, base.showModelBadge)
        repoLabel = value(.repoLabel, base.repoLabel)
        screen = value(.screen, base.screen)
        placement = value(.placement, base.placement)
        pulseInput = value(.pulseInput, base.pulseInput)
        shrinkDelayMinutes = max(0, value(.shrinkDelayMinutes, base.shrinkDelayMinutes))
        // A partial color list keeps the defaults for the states it omits. Files
        // of the first versions name the states in German.
        let legacy = ["input": "waiting", "arbeitet": "working", "fertig": "done", "blockiert": "blocked", "unbekannt": "unknown"]
        let stored = value(.statusColors, [String: String]())
        let renamed = Dictionary(stored.map { (legacy[$0.key] ?? $0.key, $0.value) }, uniquingKeysWith: { first, _ in first })
        statusColors = base.statusColors.merging(renamed.filter { base.statusColors[$0.key] != nil }) { _, custom in custom }
        repos = value(.repos, base.repos)
        nativeNotifications = value(.nativeNotifications, base.nativeNotifications)
        popupHints = value(.popupHints, base.popupHints)
        readyHintAfterSeconds = max(0, value(.readyHintAfterSeconds, base.readyHintAfterSeconds))
        overviewURL = value(.overviewURL, base.overviewURL)
        menuBarLabel = String(value(.menuBarLabel, base.menuBarLabel).prefix(6))
        watchClaude = value(.watchClaude, base.watchClaude)
        watchCodex = value(.watchCodex, base.watchCodex)
        useClaudeRegistry = value(.useClaudeRegistry, base.useClaudeRegistry)
        menuToggles = value(.menuToggles, base.menuToggles)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: Keys.self)
        try c.encode(showBar, forKey: .showBar)
        try c.encode(style, forKey: .style)
        try c.encode(fontSize, forKey: .fontSize)
        try c.encode(maxRows, forKey: .maxRows)
        try c.encode(showModelBadge, forKey: .showModelBadge)
        try c.encode(repoLabel, forKey: .repoLabel)
        try c.encode(screen, forKey: .screen)
        try c.encode(placement, forKey: .placement)
        try c.encode(pulseInput, forKey: .pulseInput)
        try c.encode(shrinkDelayMinutes, forKey: .shrinkDelayMinutes)
        try c.encode(statusColors, forKey: .statusColors)
        try c.encode(repos, forKey: .repos)
        try c.encode(nativeNotifications, forKey: .nativeNotifications)
        try c.encode(popupHints, forKey: .popupHints)
        try c.encode(readyHintAfterSeconds, forKey: .readyHintAfterSeconds)
        try c.encode(overviewURL, forKey: .overviewURL)
        try c.encode(menuBarLabel, forKey: .menuBarLabel)
        try c.encode(watchClaude, forKey: .watchClaude)
        try c.encode(watchCodex, forKey: .watchCodex)
        try c.encode(useClaudeRegistry, forKey: .useClaudeRegistry)
        try c.encode(menuToggles, forKey: .menuToggles)
    }

    func abbreviation(for repo: String) -> String {
        let custom = repos[repo]?.abbreviation?.trimmingCharacters(in: .whitespaces) ?? ""
        return custom.isEmpty ? repoAbbreviation(repo) : String(custom.prefix(3)).uppercased()
    }

    func repoColor(_ repo: String, reported: String?) -> NSColor {
        NSColor(hex: repos[repo]?.color ?? "") ?? NSColor(hex: reported ?? "") ?? .systemGray
    }

    func isHidden(_ repo: String) -> Bool { repos[repo]?.hidden ?? false }
}

final class SettingsStore {
    let url: URL
    private(set) var current: BarSettings
    private(set) var revision = 0
    var onChange: ((BarSettings) -> Void)?

    static var defaultURL: URL { AppPaths().settings }

    init(url: URL = SettingsStore.defaultURL) {
        self.url = url
        let data = try? Data(contentsOf: url)
        current = data.flatMap { try? JSONDecoder().decode(BarSettings.self, from: $0) } ?? BarSettings()
    }

    func update(_ change: (inout BarSettings) -> Void) {
        var next = current
        change(&next)
        guard next != current else { return }
        current = next
        revision += 1
        saveNow()
        onChange?(next)
    }

    func saveNow() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try encoder.encode(current).write(to: url, options: .atomic)
        } catch { AppLog.write("Settings not saved: \(error)") }
    }
}

extension NSColor {
    convenience init?(hex: String) {
        let raw = hex.trimmingCharacters(in: .whitespaces)
        guard raw.count == 7, raw.hasPrefix("#"), raw.dropFirst().allSatisfy({ $0.isHexDigit }),
              let value = UInt32(raw.dropFirst(), radix: 16) else { return nil }
        self.init(srgbRed: CGFloat((value >> 16) & 0xFF) / 255, green: CGFloat((value >> 8) & 0xFF) / 255,
                  blue: CGFloat(value & 0xFF) / 255, alpha: 1)
    }

    var hexString: String {
        guard let rgb = usingColorSpace(.sRGB) else { return "#8E8E93" }
        func byte(_ part: CGFloat) -> Int { Int((min(1, max(0, part)) * 255).rounded()) }
        return String(format: "#%02X%02X%02X", byte(rgb.redComponent), byte(rgb.greenComponent), byte(rgb.blueComponent))
    }

    // WCAG relative luminance; picks whichever of black or white reads better.
    var readableText: NSColor {
        guard let rgb = usingColorSpace(.sRGB) else { return .white }
        func linear(_ c: CGFloat) -> CGFloat { c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4) }
        let luminance = 0.2126 * linear(rgb.redComponent) + 0.7152 * linear(rgb.greenComponent) + 0.0722 * linear(rgb.blueComponent)
        return luminance > 0.179 ? .black : .white
    }
}
