import Cocoa

struct ToastMessage {
    let sessionID: String?
    let state: String
    let title: String
    let body: String

    init(session: SessionDisplay) {
        sessionID = session.id
        state = session.state
        title = "\(session.state == "waiting" ? L("Needs you") : L("Done")) · \(session.repo) · \(session.name)"
        body = session.state == "waiting" ? session.question : session.completionText
    }

    init(title: String, body: String) {
        sessionID = nil
        state = "waiting"
        self.title = title
        self.body = body
    }
}

struct ToastQueue {
    private(set) var messages: [ToastMessage] = []
    mutating func append(_ message: ToastMessage) {
        if let id = message.sessionID { messages.removeAll { $0.sessionID == id } }
        messages.append(message)
        if messages.count > 8 {
            // Prefer pending input over a burst of completion notices.
            let discard = messages.firstIndex { $0.state != "waiting" } ?? 0
            messages.remove(at: discard)
        }
    }
    mutating func pop() -> ToastMessage? {
        guard !messages.isEmpty else { return nil }
        return messages.removeFirst()
    }
    mutating func clear() { messages.removeAll() }
}

private final class ToastPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}

private final class ToastClickView: NSView {
    var onClick: (() -> Void)?
    override func hitTest(_ point: NSPoint) -> NSView? { self }
    override func mouseDown(with event: NSEvent) { NSApp.preventWindowOrdering(); onClick?() }
}

final class SessionToast {
    static let duration: TimeInterval = 3
    private let panel: ToastPanel
    private var timer: Timer?
    private var queue = ToastQueue()
    private var current: ToastMessage?
    private var startedAt: TimeInterval = 0
    var anchor: ((String?) -> (bar: CGRect, chip: CGRect?, screen: CGRect)?)?
    var onOpenSession: ((String) -> Void)?
    var onVisibilityChanged: ((Bool) -> Void)?
    var isVisible: Bool { panel.isVisible }
    var frame: CGRect { panel.frame }

    init() {
        panel = ToastPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        panel.hidesOnDeactivate = false
        panel.becomesKeyOnlyIfNeeded = true
        panel.isMovableByWindowBackground = false
    }

    deinit { timer?.invalidate() }

    func enqueue(_ messages: [ToastMessage]) {
        for message in messages { queue.append(message) }
        if !isVisible { showNext() }
    }

    func dismiss(clearQueue: Bool = true) {
        timer?.invalidate()
        timer = nil
        panel.orderOut(nil)
        current = nil
        if clearQueue { queue.clear() }
        onVisibilityChanged?(false)
    }

    private func showNext() {
        guard let message = queue.pop(), let location = anchor?(message.sessionID) else { dismiss(); return }
        current = message
        let width = min(380, location.screen.width - 16)
        let height: CGFloat = 76
        let desiredX = location.chip?.minX ?? location.bar.maxX - width - 8
        let x = min(max(location.screen.minX + 8, desiredX), location.screen.maxX - width - 8)
        let y = max(location.screen.minY + 8, location.bar.minY - height - 6)
        let box = NSRect(x: x, y: y, width: width, height: height)
        let view = ToastClickView(frame: NSRect(origin: .zero, size: box.size))
        view.wantsLayer = true
        view.layer?.cornerRadius = 10
        view.layer?.masksToBounds = true
        let effect = NSVisualEffectView(frame: view.bounds)
        effect.autoresizingMask = [.width, .height]
        effect.material = .popover
        effect.blendingMode = .behindWindow
        effect.state = .active
        view.addSubview(effect)
        let stripe = NSView(frame: NSRect(x: 0, y: 0, width: 5, height: height))
        stripe.wantsLayer = true
        stripe.layer?.backgroundColor = SessionAppearance.colors(message.state).background.cgColor
        view.addSubview(stripe)
        let title = NSTextField(labelWithString: message.title)
        title.font = .systemFont(ofSize: 11, weight: .semibold)
        title.lineBreakMode = .byTruncatingTail
        title.frame = NSRect(x: 14, y: 51, width: width - 28, height: 17)
        view.addSubview(title)
        let body = NSTextField(wrappingLabelWithString: message.body)
        body.font = .systemFont(ofSize: 11)
        body.maximumNumberOfLines = 2
        body.lineBreakMode = .byTruncatingTail
        body.frame = NSRect(x: 14, y: 12, width: width - 28, height: 32)
        view.addSubview(body)
        view.toolTip = message.title + "\n" + message.body
        view.onClick = { [weak self] in
            guard let self = self else { return }
            let id = self.current?.sessionID
            self.dismiss()
            if let id = id { self.onOpenSession?(id) }
        }
        panel.contentView = view
        panel.setFrame(box, display: true)
        panel.orderFrontRegardless() // Nonactivating; only this short requested hint floats.
        startedAt = ProcessInfo.processInfo.systemUptime
        onVisibilityChanged?(true)
        timer?.invalidate()
        let timeout = Timer(timeInterval: Self.duration, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.panel.orderOut(nil)
            self.current = nil
            self.onVisibilityChanged?(false)
            fflush(stdout)
            self.showNext()
        }
        timer = timeout
        RunLoop.main.add(timeout, forMode: .common)
    }
}
