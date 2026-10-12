import Cocoa
let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let toast = SessionToast()
let screens = NSScreen.screens
let screen = screens[largestScreenIndex(screens.map { $0.frame })!]
let visible = menuSafeVisibleFrame(screen: screen.frame, visible: screen.visibleFrame, menuHeight: NSStatusBar.system.thickness)
let bar = CGRect(x: screen.frame.minX, y: visible.maxY - 60, width: screen.frame.width, height: 60)
toast.anchor = { _ in (bar, CGRect(x: bar.maxX - 90, y: bar.minY + 4, width: 70, height: 22), screen.frame) }
var changes: [Bool] = []
toast.onVisibilityChanged = { changes.append($0) }
toast.enqueue([ToastMessage(title: "Strip · 3-second test", body: "This test hint disappears by itself; your active window keeps the focus.")])
guard toast.isVisible, toast.frame.minX >= screen.frame.minX, toast.frame.maxX <= screen.frame.maxX,
      toast.frame.maxY < bar.minY, !app.isActive else {
    print("FAILED: Toast must be onscreen below the bar without app activation"); exit(1)
}
let began = ProcessInfo.processInfo.systemUptime
let check = Timer(timeInterval: 3.2, repeats: false) { _ in
    guard !toast.isVisible, changes.first == true, changes.contains(false), !app.isActive,
          ProcessInfo.processInfo.systemUptime - began >= 3 else {
        print("FAILED: Toast must auto-hide after 3 seconds without app activation"); exit(1)
    }
    print("Native toast: visibility, screen bounds, no focus, 3-second auto-hide passed")
    fflush(stdout)
    app.terminate(nil)
}
RunLoop.main.add(check, forMode: .common)
app.run()
