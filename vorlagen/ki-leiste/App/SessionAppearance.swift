import Cocoa

enum SessionAppearance {
    static let pulseMinimum: Float = 0.3
    static let pulseDuration: TimeInterval = 0.4
    // Set from the user's settings; the defaults keep tests and the toast fixture working.
    static var statusColors = BarSettings.defaultStatusColors

    static func color(_ state: String) -> NSColor { color(state, palette: statusColors) }

    static func colorFor(_ state: String, in settings: BarSettings) -> NSColor { color(state, palette: settings.statusColors) }

    private static func color(_ state: String, palette: [String: String]) -> NSColor {
        let key = state == "ready" ? "done" : state
        return NSColor(hex: palette[key] ?? palette["unknown"] ?? "") ?? .systemGray
    }

    static func colors(_ state: String) -> (background: NSColor, foreground: NSColor) {
        let background = color(state)
        return (background, background.readableText)
    }
}
