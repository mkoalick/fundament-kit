import Cocoa
import QuartzCore
import UserNotifications

// Borderless panel directly below the menu bar, never taking key or main focus.
final class BarPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}

// The strip's container: catches every click (including on child views like
// labels) and opens the menu over it, instead of activating anything itself.
final class BarClickView: NSView {
    var forwardsHitTesting = false
    var onClick: (() -> Void)?
    override func hitTest(_ point: NSPoint) -> NSView? { forwardsHitTesting ? super.hitTest(point) : self }
    override func mouseDown(with event: NSEvent) { NSApp.preventWindowOrdering(); onClick?() }
    override func accessibilityPerformPress() -> Bool { onClick?(); return onClick != nil }
}

class Companion: NSObject, NSApplicationDelegate, NSMenuDelegate {
    var item: NSStatusItem!
    var timer: Timer?
    var windowTimer: Timer?
    let windowSpace = WindowSpace()
    let notifications = SessionNotifications()
    let toast = SessionToast()
    let settingsStore = SettingsStore()
    var settingsWindow: SettingsWindowController?
    var settings: BarSettings { settingsStore.current }
    var pendingToastEvents: [SessionEventTracker.Event] = []
    var displayedSessions: [String: SessionDisplay] = [:]
    var sessionViews: [String: NSView] = [:]
    var pendingNotificationSession: String?
    var barHeight: CGFloat = 30
    // Grow at once, shrink only after one row has been enough for a while:
    // every height change moves the adjusted app windows.
    var oneRowSince: Date?
    var lastBarSignature = ""
    var barHasContent = false
    var lastPlacementStatus = ""
    // The collector runs on its own queue, woken by file events and a slow timer.
    let paths = AppPaths()
    let repos = RepoResolver()
    let collectorQueue = DispatchQueue(label: "collector", qos: .utility)
    var collector: SessionCollector!
    var watcher: FileWatcher?
    var pendingChanges = Set<String>()
    var collectScheduled = false
    var lastCollect = Date.distantPast
    var lastRepoClear = Date.distantPast
    var providerSignature = ""
    var snapshot = CollectorSnapshot(local: [], external: [], generatedAt: .distantPast)
    var hookState: ClaudeHookInstaller.State = .notInstalled

    // Last sample, kept for the menu, which is built only when it opens.
    var models: [SessionDisplay] = []
    var staleSources = false

    var barPanel: BarPanel?
    var barContainer: BarClickView?
    var barEffectView: NSVisualEffectView?

    var targetScreen: NSScreen? {
        let screens = NSScreen.screens
        if settings.screen == .main { return screens.first }
        guard let index = largestScreenIndex(screens.map { $0.frame }) else { return nil }
        return screens[index]
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        let menuPositionKey = "NSStatusItem Preferred Position StatusMenu"
        if UserDefaults.standard.object(forKey: menuPositionKey) == nil {
            UserDefaults.standard.set(0, forKey: menuPositionKey)
        }
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.autosaveName = "StatusMenu"
        item.isVisible = true
        updateStatusItemLabel()
        let menu = NSMenu()
        menu.delegate = self
        item.menu = menu
        NotificationCenter.default.addObserver(self, selector: #selector(screenParamsChanged), name: NSApplication.didChangeScreenParametersNotification, object: nil)
        toast.anchor = { [weak self] id in
            guard let self = self, let panel = self.barPanel, panel.isVisible, let screen = self.targetScreen else { return nil }
            let chip = id.flatMap { self.sessionViews[$0] }
            let chipFrame = chip.map { panel.convertToScreen($0.convert($0.bounds, to: nil)) }
            return (panel.frame, chipFrame, screen.frame)
        }
        toast.onOpenSession = { [weak self] id in self?.showSession(id) }
        notifications.onEvents = { [weak self] events in self?.pendingToastEvents.append(contentsOf: events) }
        notifications.onOpenSession = { [weak self] id in self?.showSession(id) }
        notifications.onSettingsChanged = { [weak self] in
            guard let self = self else { return }
            self.settingsWindow?.model.notificationsAllowed = self.notifications.allowed
        }
        notifications.refreshSettings()
        settingsStore.onChange = { [weak self] _ in self?.applySettings() }
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(motionChanged), name: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification, object: nil)
        collector = SessionCollector(paths: paths, providers: [])
        for folder in [paths.claudeHooks, paths.reports, paths.sources] {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        }
        applySettings()
        // The slow timer only checks whether processes are still alive (no child
        // processes); everything else arrives as file events.
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in self?.scheduleCollect(after: 0) }
        windowTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in self?.updateWindowSpace() }
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(spaceChanged), name: NSWorkspace.activeSpaceDidChangeNotification, object: nil)
    }

    func updateStatusItemLabel() {
        let label = settings.menuBarLabel.trimmingCharacters(in: .whitespaces)
        if label.isEmpty {
            let image = NSImage(systemSymbolName: "rectangle.topthird.inset.filled", accessibilityDescription: AppIdentity.displayName)
            image?.isTemplate = true
            item.button?.image = image
            item.button?.title = ""
        } else {
            item.button?.image = nil
            item.button?.title = label
        }
    }

    // MARK: - Collecting

    // Providers follow the settings; rebuilt only when their options change.
    func configureProviders() {
        let signature = "\(settings.watchClaude)-\(settings.watchCodex)-\(settings.useClaudeRegistry)"
        guard signature != providerSignature else { return }
        providerSignature = signature
        let settings = self.settings
        collectorQueue.async { [weak self] in
            guard let self = self else { return }
            var providers: [SessionProvider] = []
            if settings.watchClaude { providers.append(ClaudeProvider(paths: self.paths, repos: self.repos, useRegistry: settings.useClaudeRegistry)) }
            if settings.watchCodex { providers.append(CodexProvider(paths: self.paths, repos: self.repos)) }
            self.collector.providers = providers
            let watchPaths = self.collector.watchPaths
            DispatchQueue.main.async {
                self.watcher?.stop()
                self.watcher = FileWatcher(paths: watchPaths, queue: self.collectorQueue) { [weak self] changed in
                    self?.collectorQueue.async { self?.noteChanges(changed) }
                }
                self.watcher?.start()
                self.scheduleCollect(after: 0)
            }
        }
    }

    // Runs on the collector queue: coalesces bursts of file events into one round,
    // and at most one round per second (every tool call of every session is an event).
    func noteChanges(_ changed: Set<String>) {
        pendingChanges.formUnion(changed)
        guard !collectScheduled else { return }
        collectScheduled = true
        let wait = max(0.25, 1 - Date().timeIntervalSince(lastCollect))
        collectorQueue.asyncAfter(deadline: .now() + wait) { [weak self] in self?.collectNow() }
    }

    func scheduleCollect(after delay: TimeInterval) {
        collectorQueue.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self, !self.collectScheduled else { return }
            self.collectScheduled = true
            self.collectNow()
        }
    }

    private func collectNow() {
        lastCollect = Date()
        let changed = pendingChanges
        pendingChanges.removeAll()
        collectScheduled = false
        // A color changed in VS Code shows up within a minute; resolving every
        // folder in every round would cost more than it brings.
        if Date().timeIntervalSince(lastRepoClear) > 60 { repos.clear(); lastRepoClear = Date() }
        let next = collector.collect(now: Date(), changed: changed)
        let state = currentHookState()
        DispatchQueue.main.async { [weak self] in
            self?.snapshot = next
            self?.hookState = state
            self?.settingsWindow?.model.hookState = state
            self?.refresh()
        }
    }

    // settings.json is only parsed again when it changed (collector queue only).
    private var hookStateStamp: FileStamp?
    private var cachedHookState: ClaudeHookInstaller.State = .notInstalled
    private func currentHookState() -> ClaudeHookInstaller.State {
        let stamp = FileStamp(paths.claudeSettings.resolvingSymlinksInPath().path)
        guard stamp == nil || stamp != hookStateStamp else { return cachedHookState }
        hookStateStamp = stamp
        cachedHookState = (try? ClaudeHookInstaller(helperPath: AppIdentity.helperURL.path)
            .state(of: try? Data(contentsOf: paths.claudeSettings))) ?? .notInstalled
        return cachedHookState
    }

    func applySettings() {
        updateStatusItemLabel()
        configureProviders()
        SessionAppearance.statusColors = settings.statusColors
        notifications.readyHintAfterSeconds = settings.readyHintAfterSeconds
        if !settings.popupHints { toast.dismiss() }
        if let model = settingsWindow?.model, model.settings != settings { model.settings = settings }
        refresh()
    }

    @objc func motionChanged() { refresh() }

    @objc func screenParamsChanged() {
        toast.dismiss()
        barPanel?.orderOut(nil)
        refresh()
    }

    // The strip stays visible: it is back-ordered and cannot cover windows.
    @objc func spaceChanged() {
        toast.dismiss()
        if let panel = barPanel, panel.isVisible, settings.placement == .makeRoom { panel.orderBack(nil) }
        updateWindowSpace()
    }

    func applicationWillTerminate(_ notification: Notification) { toast.dismiss(); windowSpace.restore() }

    // MARK: - Stand lesen

    func refresh() {
        guard snapshot.generatedAt != .distantPast else { return }
        let rows = snapshot.visible
        staleSources = rows.contains { $0.stale }
        models = rows.map { SessionDisplay($0) }
        displayedSessions = Dictionary(models.map { ($0.id, $0) }, uniquingKeysWith: { _, last in last })
        notifications.observe(models, fresh: true, enabled: settings.popupHints, nativeEnabled: settings.nativeNotifications)
        notifications.refreshSettings()
        settingsWindow?.model.updateRepos(models)

        updateBar(sessions: models.filter { !settings.isHidden($0.repo) }, disconnected: false)
        let counts = stateCounts(models)
        item.button?.toolTip = String(format: L("Waiting: %ld · Working: %ld · Done: %ld"), counts.input, counts.working, counts.done)
        if !pendingToastEvents.isEmpty {
            let events = pendingToastEvents
            pendingToastEvents.removeAll()
            toast.enqueue(events.map { ToastMessage(session: $0.session) })
        }
        if let id = pendingNotificationSession {
            pendingNotificationSession = nil
            showSession(id)
        }
    }

    func stateCounts(_ list: [SessionDisplay]) -> (input: Int, working: Int, done: Int, unclear: Int) {
        (list.filter { $0.state == "waiting" }.count,
         list.filter { $0.state == "working" }.count,
         list.filter { $0.state == "done" }.count,
         list.filter { !["waiting", "working", "done"].contains($0.state) }.count)
    }

    // MARK: - Menu (built only when it opens)

    func menuNeedsUpdate(_ menu: NSMenu) { fillMenu(menu) }

    func dotImage(_ color: NSColor, size: CGFloat = 9) -> NSImage {
        NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
            color.setFill()
            NSBezierPath(ovalIn: rect).fill()
            return true
        }
    }

    func fillMenu(_ menu: NSMenu) {
        menu.removeAllItems()
        let time = DateFormatter.localizedString(from: snapshot.generatedAt, dateStyle: .none, timeStyle: .medium)
        menu.addItem(withTitle: String(format: L("Updated %@"), time), action: nil, keyEquivalent: "")
        if staleSources { menu.addItem(withTitle: L("An external source has not reported for a while"), action: nil, keyEquivalent: "") }
        let total = stateCounts(models)
        menu.addItem(withTitle: String(format: L("Waiting: %ld · Working: %ld · Done: %ld"), total.input, total.working, total.done), action: nil, keyEquivalent: "")
        if settings.watchClaude, hookState != .installed {
            let setup = menu.addItem(withTitle: hookState == .outdated ? L("Update Claude Code hooks …") : L("Set up Claude Code hooks …"),
                                     action: #selector(openSourceSettings), keyEquivalent: "")
            setup.target = self
        }
        menu.addItem(NSMenuItem.separator())

        // Repos with input first, then working ones, then alphabetical.
        let groups = Dictionary(grouping: models, by: { $0.repo })
        let names = groups.keys.sorted { a, b in
            let pa = groups[a]?.map { min($0.priority, 2) }.min() ?? 9
            let pb = groups[b]?.map { min($0.priority, 2) }.min() ?? 9
            if pa != pb { return pa < pb }
            return a.localizedCaseInsensitiveCompare(b) == .orderedAscending
        }
        for repo in names {
            let list = (groups[repo] ?? []).sorted { $0.priority < $1.priority }
            let c = stateCounts(list)
            let parts = [(c.working, L("working")), (c.input, L("waiting")), (c.unclear, L("unclear")), (c.done, L("done"))]
                .filter { $0.0 > 0 }.map { "\($0.0) \($0.1)" }
            let header = NSMenuItem(title: ([repo] + parts).joined(separator: " · "), action: nil, keyEquivalent: "")
            header.image = dotImage(settings.repoColor(repo, reported: list.compactMap { $0.repoColor }.first))
            menu.addItem(header)
            for session in list {
                let state = session.state == "waiting" ? L("waiting for you") : session.stateLabel
                let entry = NSMenuItem(title: "\(String(session.name.prefix(60))) · \(state)", action: nil, keyEquivalent: "")
                entry.indentationLevel = 1
                let details = NSMenu()
                for (field, text) in [("id", session.id), (L("model"), session.modelLabel), (L("task"), session.task),
                                      (L("question"), session.questionOrHint), (L("result"), session.result),
                                      (L("source"), session.origin ?? ""), (L("process"), session.process == "open" ? L("running") : L("ended"))] where !text.isEmpty {
                    details.addItem(withTitle: "\(field): \(String(text.prefix(180)))", action: nil, keyEquivalent: "")
                }
                entry.submenu = details
                menu.addItem(entry)
            }
        }

        menu.addItem(NSMenuItem.separator())
        let toggle = menu.addItem(withTitle: L("Show the strip below the menu bar"), action: #selector(toggleBar), keyEquivalent: "")
        toggle.target = self
        toggle.state = settings.showBar ? .on : .off
        for (index, flag) in settings.menuToggles.enumerated() where !flag.title.isEmpty {
            let entry = menu.addItem(withTitle: flag.title, action: #selector(switchMenuToggle(_:)), keyEquivalent: "")
            entry.target = self
            entry.tag = index
            entry.state = flag.isOn ? .on : .off
        }
        let prefs = menu.addItem(withTitle: L("Settings …"), action: #selector(openSettings), keyEquivalent: ",")
        prefs.target = self
        if settings.nativeNotifications, !notifications.allowed {
            let permission = menu.addItem(withTitle: notifications.permissionLabel, action: #selector(requestNotifications), keyEquivalent: "")
            permission.target = self
        }
        if settings.placement == .makeRoom, !windowSpace.trusted {
            let access = menu.addItem(withTitle: L("Allow Accessibility access …"), action: #selector(requestAccessibility), keyEquivalent: "")
            access.target = self
            let reveal = menu.addItem(withTitle: L("Show app in Finder for permission"), action: #selector(revealApp), keyEquivalent: "")
            reveal.target = self
        }
        let placement = menu.addItem(withTitle: lastPlacementStatus.isEmpty ? windowSpace.status : lastPlacementStatus, action: nil, keyEquivalent: "")
        placement.isEnabled = false
        if URL(string: settings.overviewURL)?.scheme?.hasPrefix("http") == true {
            let open = menu.addItem(withTitle: L("Open session overview"), action: #selector(openOverview), keyEquivalent: "")
            open.target = self
        }
        let quit = menu.addItem(withTitle: L("Quit"), action: #selector(quitApp), keyEquivalent: "q")
        quit.target = self
    }

    // MARK: - The strip below the menu bar

    func ensureBarPanel() {
        guard barPanel == nil else { return }
        let panel = BarPanel(contentRect: NSRect(x: 0, y: 0, width: 100, height: 22), styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        // A normal, back-ordered panel cannot cover foreground app windows,
        // even between the window checks or when Accessibility stops responding.
        panel.level = .normal
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        panel.isMovableByWindowBackground = false
        panel.becomesKeyOnlyIfNeeded = true
        panel.hidesOnDeactivate = false

        let container = BarClickView(frame: NSRect(x: 0, y: 0, width: 100, height: 22))
        container.forwardsHitTesting = true
        container.wantsLayer = true
        container.layer?.masksToBounds = true
        container.onClick = { [weak self] in self?.showBarMenu() }

        let effect = NSVisualEffectView(frame: container.bounds)
        effect.autoresizingMask = [.width, .height]
        effect.material = .menu
        effect.blendingMode = .behindWindow
        effect.state = .active
        effect.wantsLayer = true
        container.addSubview(effect)

        panel.contentView = container
        barPanel = panel
        barContainer = container
        barEffectView = effect
    }

    func positionBar() {
        guard let panel = barPanel, let screen = targetScreen else { return }
        let visible = menuSafeVisibleFrame(screen: screen.frame, visible: screen.visibleFrame, menuHeight: NSStatusBar.system.thickness)
        let target = NSRect(x: screen.frame.minX, y: visible.maxY - barHeight, width: screen.frame.width, height: barHeight)
        if panel.frame != target { panel.setFrame(target, display: true) }
    }

    func logPlacement(_ text: String) {
        guard let panel = barPanel else { return }
        let status = "\(text) · \(L("Access")): \(windowSpace.trusted) · \(L("visible")): \(panel.isVisible) · \(Int(panel.frame.width)) × \(Int(panel.frame.height))"
        if status != lastPlacementStatus {
            AppLog.write(status)
            lastPlacementStatus = status
        }
    }

    func updateWindowSpace() {
        guard settings.showBar, barHasContent, let screen = targetScreen,
              let panel = barPanel else { barPanel?.orderOut(nil); return }
        // Never adjust windows while the user drags or clicks; the strip stays.
        if CGEventSource.buttonState(.combinedSessionState, button: .left) { return }
        if let id = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber,
           windowSpace.selectDisplay(CGDirectDisplayID(id.uint32Value)) {
            toast.dismiss()
            panel.orderOut(nil)
        }
        positionBar()
        // Floating needs no permission: the strip simply lies on top of the
        // windows' upper edge and nothing is ever moved.
        if settings.placement == .floating {
            windowSpace.restore()
            if panel.level != .floating { panel.level = .floating }
            if !panel.isVisible { panel.orderFrontRegardless() }
            logPlacement(L("The strip is floating above the windows"))
            return
        }
        if panel.level != .normal { panel.level = .normal; panel.orderBack(nil) }
        let primaryTop = NSScreen.screens.first?.frame.maxY ?? screen.frame.maxY
        let visible = menuSafeVisibleFrame(screen: screen.frame, visible: screen.visibleFrame, menuHeight: NSStatusBar.system.thickness)
        let layout = BarLayout(screen: screen.frame, visible: visible,
                               primaryTop: primaryTop, height: barHeight)
        let cgScreen = CGRect(x: screen.frame.minX, y: primaryTop - screen.frame.maxY,
                              width: screen.frame.width, height: screen.frame.height)
        // Hiding never moves windows back: a brief fullscreen or a missing
        // permission must not make every adjusted window jump up and down.
        if windowSpace.makeRoom(layout, screen: cgScreen) {
            if !panel.isVisible { panel.orderBack(nil) }
        } else { panel.orderOut(nil); toast.dismiss() }
        logPlacement(windowSpace.status)
    }

    func repoHeader(_ repo: String, color: NSColor, frame: NSRect) -> NSView {
        let view = NSView(frame: frame)
        view.toolTip = repo
        let stripe = NSView(frame: NSRect(x: 0, y: (frame.height - 12) / 2, width: 3, height: 12))
        stripe.wantsLayer = true
        stripe.layer?.cornerRadius = 1.5
        stripe.layer?.backgroundColor = color.cgColor
        view.addSubview(stripe)
        if settings.repoLabel == .abbreviation, frame.width > 10 {
            let title = NSTextField(labelWithString: settings.abbreviation(for: repo))
            title.font = .systemFont(ofSize: 9, weight: .semibold)
            title.textColor = .secondaryLabelColor
            let fitted = title.fittingSize
            title.frame = NSRect(x: 6, y: (frame.height - fitted.height) / 2, width: max(0, frame.width - 6), height: fitted.height)
            view.addSubview(title)
        }
        return view
    }

    // Calm style: only a session that waits for you is filled with color; all
    // others are quiet neutral chips with a status dot. Bold fills every chip.
    func sessionChip(_ session: SessionDisplay, label: String, frame: NSRect) -> NSView {
        let calm = settings.style == .calm
        let status = SessionAppearance.color(session.state)
        let attention = session.state == "waiting"
        let filled = !calm || attention
        let quiet = !filled && ["done", "unknown"].contains(session.state)
        let textColor: NSColor = filled ? status.readableText : (quiet ? .secondaryLabelColor : .labelColor)
        let chip = BarClickView(frame: frame)
        chip.onClick = { [weak self, weak chip] in
            guard let chip = chip else { return }
            self?.showSession(session.id, anchor: chip)
        }
        chip.wantsLayer = true
        chip.layer?.masksToBounds = true
        chip.layer?.cornerRadius = 6
        chip.layer?.backgroundColor = (filled ? status : NSColor.labelColor.withAlphaComponent(0.07)).cgColor
        if session.state == "blocked", !filled {
            chip.layer?.borderWidth = 1
            chip.layer?.borderColor = status.cgColor
        }
        var left: CGFloat = 8
        var right = frame.width - 7
        if calm {
            let dot = NSView(frame: NSRect(x: 8, y: (frame.height - 7) / 2, width: 7, height: 7))
            dot.wantsLayer = true
            dot.layer?.cornerRadius = 3.5
            dot.layer?.backgroundColor = (filled ? textColor : status).cgColor
            chip.addSubview(dot)
            left = 20
        }
        if settings.showModelBadge, frame.width >= 64 {
            let badge = NSTextField(labelWithString: session.modelBadge)
            badge.font = .monospacedSystemFont(ofSize: 9, weight: calm ? .semibold : .bold)
            badge.textColor = textColor.withAlphaComponent(calm ? 0.55 : 0.85)
            badge.alignment = .center
            let height = badge.fittingSize.height
            if calm {
                badge.frame = NSRect(x: frame.width - 17, y: (frame.height - height) / 2, width: 11, height: height)
                right = frame.width - 19
            } else {
                badge.frame = NSRect(x: 5, y: (frame.height - height) / 2, width: 12, height: height)
                left = 19
            }
            chip.addSubview(badge)
        }
        if right - left >= 12 {
            let title = NSTextField(labelWithString: label)
            title.font = .systemFont(ofSize: CGFloat(settings.fontSize), weight: .medium)
            title.textColor = textColor
            title.lineBreakMode = .byTruncatingTail
            let height = title.fittingSize.height
            title.frame = NSRect(x: left, y: (frame.height - height) / 2, width: right - left, height: height)
            chip.addSubview(title)
        }
        chip.toolTip = "\(session.repo) · \(session.modelLabel) · \(session.name)\n\(session.stateLabel)" + (session.questionOrHint.isEmpty ? "" : "\n\(session.questionOrHint)")
        chip.setAccessibilityElement(true)
        chip.setAccessibilityRole(.button)
        chip.setAccessibilityLabel("\(session.repo), \(session.modelLabel), \(session.name), \(session.stateLabel)")
        if attention, settings.pulseInput, !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion {
            let pulse = CABasicAnimation(keyPath: "opacity")
            pulse.fromValue = 1
            pulse.toValue = calm ? 0.55 : SessionAppearance.pulseMinimum
            pulse.duration = SessionAppearance.pulseDuration * (calm ? 2 : 1)
            pulse.autoreverses = true
            pulse.repeatCount = .infinity
            chip.layer?.add(pulse, forKey: "inputPulse")
        }
        return chip
    }

    func updateBar(sessions: [SessionDisplay], disconnected: Bool) {
        ensureBarPanel()
        guard let panel = barPanel, let container = barContainer, let effectView = barEffectView else { return }
        guard settings.showBar else { panel.orderOut(nil); toast.dismiss(); barHasContent = false; lastBarSignature = ""; windowSpace.restore(); return }
        barHasContent = true
        let groups = Dictionary(grouping: sessions, by: { $0.repo })
        let names = groups.keys.sorted { a, b in
            let ap = groups[a]?.map { $0.priority }.min() ?? 9
            let bp = groups[b]?.map { $0.priority }.min() ?? 9
            if ap != bp { return ap < bp }
            return a.localizedCaseInsensitiveCompare(b) == .orderedAscending
        }
        let lists = names.map { name in
            (groups[name] ?? []).sorted { a, b in
                if a.priority != b.priority { return a.priority < b.priority }
                if a.name != b.name { return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending }
                return a.id < b.id
            }
        }
        guard let screen = targetScreen else { panel.orderOut(nil); return }
        let counts = lists.map { $0.count }
        let header: CGFloat = settings.repoLabel == .abbreviation ? 26 : 9
        let needed: CGFloat = SessionStripLayout(counts: counts, width: screen.frame.width, adaptive: true,
                                                 rowLimit: settings.maxRows, header: header).rows == 1 ? 30 : 60
        if needed > barHeight {
            barHeight = needed
            oneRowSince = nil
        } else if needed < barHeight {
            let since = oneRowSince ?? Date()
            oneRowSince = since
            if Date().timeIntervalSince(since) >= settings.shrinkDelayMinutes * 60 { barHeight = needed; oneRowSince = nil }
        } else { oneRowSince = nil }
        let layout = SessionStripLayout(counts: counts, width: screen.frame.width, adaptive: true,
                                        rowLimit: barHeight > 30 ? 2 : 1, header: header)
        let reduceMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        let appearance = panel.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua])?.rawValue ?? ""
        let signature = ([barHeight, screen.frame.width].map { "\($0)" } + ["\(settingsStore.revision)", "\(reduceMotion)", "\(disconnected)", appearance] +
            lists.flatMap { $0 }.map { [$0.id, $0.repo, $0.repoColor ?? "", $0.name, $0.state, $0.stateLabel, $0.modelBadge, $0.modelLabel, $0.question].joined(separator: "\u{1F}") })
            .joined(separator: "\u{1E}")
        // Unchanged content keeps its views: no redraw, no restarted pulse.
        guard signature != lastBarSignature || container.subviews.count < 2 else { updateWindowSpace(); return }
        lastBarSignature = signature
        if panel.frame.height != barHeight { toast.dismiss() }
        for view in container.subviews where view !== effectView { view.removeFromSuperview() }
        sessionViews.removeAll()
        positionBar()
        let document = BarClickView(frame: container.bounds)
        document.forwardsHitTesting = true
        document.autoresizingMask = [.width, .height]
        document.onClick = { [weak self] in self?.showBarMenu() }
        // Layer colors are resolved once, so resolve them in the strip's own appearance.
        panel.effectiveAppearance.performAsCurrentDrawingAppearance {
            let hairline = NSView(frame: NSRect(x: 0, y: 0, width: container.bounds.width, height: 1))
            hairline.wantsLayer = true
            hairline.layer?.backgroundColor = NSColor.separatorColor.cgColor
            hairline.autoresizingMask = [.width]
            document.addSubview(hairline)
            for placement in layout.placements {
                let y = CGFloat(layout.rows - 1 - placement.row) * 26 + (barHeight - CGFloat(layout.rows) * 26) / 2 + 2
                let list = lists[placement.repoIndex]
                if let index = placement.sessionIndex {
                    let session = list[index]
                    let duplicates = list.filter { $0.shortName == session.shortName }.count > 1
                    let label = session.shortName + (duplicates ? " · " + String(session.id.suffix(4)) : "")
                    let chip = sessionChip(session, label: label, frame: NSRect(x: placement.x, y: y, width: placement.width, height: 22))
                    document.addSubview(chip)
                    sessionViews[session.id] = chip
                } else {
                    let repo = names[placement.repoIndex]
                    let color = settings.repoColor(repo, reported: list.compactMap { $0.repoColor }.first)
                    document.addSubview(repoHeader(repo, color: color, frame: NSRect(x: placement.x, y: y, width: placement.width, height: 22)))
                }
            }
        }
        if sessions.isEmpty {
            let title = NSTextField(labelWithString: L("No agent sessions"))
            title.font = .systemFont(ofSize: 11)
            title.textColor = .secondaryLabelColor
            title.frame = NSRect(x: 10, y: (barHeight - 16) / 2, width: 250, height: 16)
            document.addSubview(title)
        }
        container.addSubview(document)
        updateWindowSpace()
    }

    func showSession(_ id: String, anchor: NSView? = nil) {
        guard let session = displayedSessions[id] else { return }
        let menu = NSMenu()
        menu.addItem(withTitle: "\(session.repo) · \(session.modelLabel)", action: nil, keyEquivalent: "")
        menu.addItem(withTitle: session.name, action: nil, keyEquivalent: "")
        menu.addItem(withTitle: "\(session.stateSymbol) \(session.stateLabel)", action: nil, keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        for (label, value) in [(L("Question"), session.questionOrHint), (L("Result"), session.result), (L("Task"), session.task)] where !value.isEmpty {
            let detail = menu.addItem(withTitle: "\(label): \(String(value.prefix(280)))", action: nil, keyEquivalent: "")
            detail.toolTip = value
            let copy = menu.addItem(withTitle: String(format: L("Copy %@"), label), action: #selector(copyDetail(_:)), keyEquivalent: "")
            copy.target = self
            copy.representedObject = value
        }
        menu.addItem(withTitle: session.process == "open" ? L("Process running") : L("Process ended"), action: nil, keyEquivalent: "")
        let view = anchor ?? sessionViews[id] ?? barContainer
        guard let view = view else { pendingNotificationSession = id; return }
        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: 0), in: view)
    }

    func showBarMenu() {
        guard let container = barContainer else { return }
        let menu = NSMenu()
        fillMenu(menu)
        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: 0), in: container)
    }

    @objc func copyDetail(_ sender: NSMenuItem) {
        guard let value = sender.representedObject as? String else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(value, forType: .string)
    }
    @objc func requestNotifications() { notifications.requestPermission() }
    @objc func testNotification() {
        if settings.nativeNotifications, notifications.allowed { notifications.testNotification() }
        if settings.popupHints || !settings.nativeNotifications || !notifications.allowed {
            toast.enqueue([ToastMessage(title: String(format: L("%@ · Test"), AppIdentity.displayName), body: L("This hint disappears after three seconds."))])
        }
    }

    @objc func toggleBar() { settingsStore.update { $0.showBar.toggle() } }

    // Turning a toggle off writes its flag file (or removes it, for toggles that
    // are on while the file exists). Private folder and file permissions.
    @objc func switchMenuToggle(_ sender: NSMenuItem) {
        guard settings.menuToggles.indices.contains(sender.tag) else { return }
        let flag = settings.menuToggles[sender.tag]
        let createFile = flag.isOn == flag.onWhenMissing
        if createFile {
            try? FileManager.default.createDirectory(at: flag.url.deletingLastPathComponent(), withIntermediateDirectories: true,
                                                     attributes: [.posixPermissions: 0o700])
            FileManager.default.createFile(atPath: flag.url.path, contents: Data("off\n".utf8), attributes: [.posixPermissions: 0o600])
        } else {
            try? FileManager.default.removeItem(at: flag.url)
        }
        AppLog.write("Menu toggle \"\(flag.title)\" is now \(flag.isOn ? "on" : "off")")
    }

    @objc func openSourceSettings() { presentSettings(tab: .sources) }

    @objc func openSettings() { presentSettings(tab: nil) }

    func presentSettings(tab: SettingsTab?) {
        if settingsWindow == nil {
            let model = SettingsModel(store: settingsStore)
            model.sendTestHint = { [weak self] in self?.testNotification() }
            model.requestNotifications = { [weak self] in self?.notifications.requestPermission() }
            model.revealFile = { [weak self] in
                guard let self = self else { return }
                if !FileManager.default.fileExists(atPath: self.settingsStore.url.path) { self.settingsStore.saveNow() }
                NSWorkspace.shared.activateFileViewerSelecting([self.settingsStore.url])
            }
            model.installHooks = { [weak self] install in self?.changeHooks(install: install) }
            model.helperPath = AppIdentity.helperURL.path
            model.settingsPath = paths.claudeSettings.path
            settingsWindow = SettingsWindowController(model: model)
        }
        if let tab = tab { settingsWindow?.model.selectedTab = tab }
        settingsWindow?.model.hookState = hookState
        settingsWindow?.model.updateRepos(models)
        settingsWindow?.model.notificationsAllowed = notifications.allowed
        settingsWindow?.present()
    }

    // Writes Claude Code's settings.json only on this explicit button press.
    func changeHooks(install: Bool) {
        let installer = ClaudeHookInstaller(helperPath: AppIdentity.helperURL.path)
        let backups = paths.base.appendingPathComponent("backups")
        do {
            let outcome = install ? try installer.install(at: paths.claudeSettings, backups: backups)
                                  : try installer.uninstall(at: paths.claudeSettings, backups: backups)
            let backup = outcome.backup.map { String(format: L("Backup: %@"), $0.path) } ?? ""
            settingsWindow?.model.hookMessage = (outcome.changed ? (install ? L("Hooks installed.") : L("Hooks removed.")) : L("Nothing to change.")) + (backup.isEmpty ? "" : " " + backup)
            AppLog.write("Claude hooks \(install ? "installed" : "removed"), changed: \(outcome.changed)")
        } catch {
            settingsWindow?.model.hookMessage = "\(error)"
            AppLog.write("Claude hooks not changed: \(error)")
        }
        scheduleCollect(after: 0)
    }

    @objc func openOverview() {
        if let url = URL(string: settings.overviewURL) { NSWorkspace.shared.open(url) }
    }
    @objc func requestAccessibility() { windowSpace.requestPermission() }
    @objc func revealApp() {
        // Foreground is explicitly requested by this user-selected menu action.
        NSWorkspace.shared.activateFileViewerSelecting([Bundle.main.bundleURL])
    }
    @objc func quitApp() { NSApp.terminate(nil) }
}

if CommandLine.arguments.contains("--diagnose") {
    print("\(L("App")): \(Bundle.main.bundleIdentifier ?? L("no app bundle")) · \(Bundle.main.bundleURL.path)")
    print("\(L("Accessibility")): \(AXIsProcessTrusted() ? L("active") : L("missing"))")
    print("\(L("Settings")): \(SettingsStore.defaultURL.path)")
    if let index = largestScreenIndex(NSScreen.screens.map { $0.frame }) {
        let screen = NSScreen.screens[index]
        print("\(L("Largest screen")): \(screen.frame.width) × \(screen.frame.height); \(AppIdentity.displayName): \(screen.frame.width) × \(L("adaptive 30/60"))")
    }
    exit(0)
}

let app = NSApplication.shared
let delegate = Companion()
app.delegate = delegate
app.run()
