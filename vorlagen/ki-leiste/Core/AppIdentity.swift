import Foundation

// The few names that identify this app outside its bundle. The bundle id and
// display name come from Info.plist; these stay stable across renames of the
// bundle because other files refer to them.
enum AppIdentity {
    // Marks the hook commands this app adds to Claude Code's settings.json.
    static let hookMarker = "ki-leiste-hook"
    // Name of the command-line helper inside Contents/MacOS (set by the build).
    static var helperName: String { Bundle.main.object(forInfoDictionaryKey: "HookHelperName") as? String ?? "ki-leiste-hook" }

    static var displayName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "KI-Leiste"
    }

    // The helper next to the running executable (the app and the helper share Contents/MacOS).
    static var helperURL: URL {
        Bundle.main.bundleURL.appendingPathComponent("Contents/MacOS").appendingPathComponent(helperName)
    }
}
