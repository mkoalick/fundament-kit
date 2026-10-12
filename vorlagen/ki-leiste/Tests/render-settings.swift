import SwiftUI

// Renders every settings tab, plus a wide strip preview, to PNG without ever
// showing a window, for README screenshots and visual checks.
//   render-settings <output directory> [dark] [-AppleLanguages "(xx)"]
// The language is read by Foundation from -AppleLanguages like any other
// process argument; this file never has to parse it itself. scripts/render-images.sh
// runs this binary from inside a temporary .app bundle that carries the
// en.lproj/de.lproj built from Resources/Localizable.xcstrings, so Bundle.main
// actually finds a translation to pick from.
let app = NSApplication.shared
app.setActivationPolicy(.prohibited)
let output = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? ".")
let store = SettingsStore(url: FileManager.default.temporaryDirectory.appendingPathComponent("ki-leiste-render-\(getpid()).json"))
let model = SettingsModel(store: store)
model.repos = [
    .init(id: "api-server", reported: "#3B7DD8"),
    .init(id: "docs", reported: nil),
    .init(id: "web-app", reported: "#2F9E8F")
]
model.notificationsAllowed = true
let appearanceName = CommandLine.arguments.count > 2 && CommandLine.arguments[2] == "dark" ? NSAppearance.Name.darkAqua : .aqua

model.hookState = .installed

// Renders any SwiftUI view, sized exactly, to a PNG at the given size. Used
// for both the settings tabs (their own fixed window size) and the wide
// strip preview below.
func renderPNG<V: View>(_ view: V, size: NSSize, to fileName: String) throws {
    let host = NSHostingView(rootView: view)
    host.frame = NSRect(origin: .zero, size: size)
    let window = NSWindow(contentRect: host.frame, styleMask: [.borderless], backing: .buffered, defer: false)
    window.appearance = NSAppearance(named: appearanceName)
    window.contentView = host
    host.layoutSubtreeIfNeeded()
    RunLoop.current.run(until: Date().addingTimeInterval(0.4))
    guard let rep = host.bitmapImageRepForCachingDisplay(in: host.bounds) else { return }
    host.cacheDisplay(in: host.bounds, to: rep)
    try rep.representation(using: .png, properties: [:])?.write(to: output.appendingPathComponent(fileName))
}

for (tab, name) in [(SettingsTab.appearance, "appearance"), (.colors, "colors"), (.repos, "repos"), (.sources, "sources"), (.behaviour, "behaviour")] {
    model.selectedTab = tab
    try renderPNG(SettingsView(model: model), size: NSSize(width: 560, height: 600), to: "settings-\(name).png")
}

// A wide strip preview with realistic sample data (own repos, own sessions,
// every state at least once) for the README's hero image - never real
// session or repository names.
let stripSamples: [StripPreview.Group] = [
    StripPreview.Group(repo: "api-server", color: "#3B7DD8", items: [
        StripPreview.Sample(state: "waiting", name: "Migration", badge: "C"),
        StripPreview.Sample(state: "working", name: "Tests", badge: "G"),
        StripPreview.Sample(state: "done", name: "Rollout", badge: "C")]),
    StripPreview.Group(repo: "web-app", color: "#2F9E8F", items: [
        StripPreview.Sample(state: "blocked", name: "Packages", badge: "M"),
        StripPreview.Sample(state: "working", name: "Hotfix", badge: "C")]),
    StripPreview.Group(repo: "docs", color: "#8E8E93", items: [
        StripPreview.Sample(state: "done", name: "Changelog", badge: "C")]),
    StripPreview.Group(repo: "mobile", color: "#8E5BA6", items: [
        StripPreview.Sample(state: "unknown", name: "Build", badge: "G"),
        StripPreview.Sample(state: "waiting", name: "Release notes", badge: "C")])
]
try renderPNG(StripPreview(settings: model.settings, samples: stripSamples), size: NSSize(width: 1200, height: 30), to: "strip.png")

print("rendered")
