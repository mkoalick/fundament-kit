import Cocoa
final class TestWindow: NSWindow {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let screen = NSScreen.screens.first!
let window = TestWindow(contentRect: NSRect(x: 100, y: screen.visibleFrame.maxY - 300, width: 400, height: 260), styleMask: [.titled, .resizable], backing: .buffered, defer: false)
window.setFrame(NSRect(x: 100, y: screen.visibleFrame.maxY - 300, width: 400, height: 300), display: true)
window.minSize = NSSize(width: 300, height: 250)
window.orderBack(nil)
let ready = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
    print("ready")
    fflush(stdout)
}
app.run()
