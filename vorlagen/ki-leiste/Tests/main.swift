import Cocoa

let screen = CGRect(x: 0, y: 0, width: 1512, height: 982)
let visible = CGRect(x: 0, y: 70, width: 1512, height: 874)
let layout = BarLayout(screen: screen, visible: visible, primaryTop: 982, height: 30)
check(layout.bar == CGRect(x: 0, y: 38, width: 1512, height: 30), "Full width below menu/notch")
check(layout.workArea == CGRect(x: 0, y: 68, width: 1512, height: 844), "Dock excluded")
check(layout.adjusted(CGRect(x: 10, y: 38, width: 800, height: 874)) == CGRect(x: 10, y: 68, width: 800, height: 844), "Maximized window shrinks to preserve bottom edge")
check(layout.adjusted(CGRect(x: 10, y: 50, width: 400, height: 300)) == CGRect(x: 10, y: 68, width: 400, height: 300), "Small window moves without resizing")
check(layout.adjusted(CGRect(x: 10, y: 68, width: 400, height: 300)) == nil, "A touching edge is not overlap")
check(layout.adjusted(CGRect(x: 1600, y: 38, width: 400, height: 300)) == nil, "Other monitor left alone")
check(layout.adjusted(CGRect(x: 10, y: 200, width: 400, height: 300)) == nil, "User positioned windows left alone")
let left = BarLayout(screen: CGRect(x: -1920, y: -100, width: 1920, height: 1080), visible: CGRect(x: -1920, y: -30, width: 1920, height: 986), primaryTop: 982, height: 30)
check(left.bar == CGRect(x: -1920, y: 26, width: 1920, height: 30), "Secondary monitor uses primary coordinate origin")
check(left.adjusted(CGRect(x: -1800, y: 26, width: 1000, height: 986)) == CGRect(x: -1800, y: 56, width: 1000, height: 956), "Negative-coordinate monitor fits")
check(sameFrame(CGRect(x: 0, y: 68, width: 400, height: 300), CGRect(x: 0, y: 68.5, width: 400, height: 300)), "Subpixel AX rounding tolerated")
check(!sameFrame(CGRect(x: 0, y: 68, width: 400, height: 300), CGRect(x: 0, y: 80, width: 400, height: 300)), "User reposition prevents restoration")
check(largestScreenIndex([]) == nil, "No display gives no bar target")
check(largestScreenIndex([screen, CGRect(x: 1512, y: 0, width: 2560, height: 1440)]) == 1, "Largest logical display wins")
check(largestScreenIndex([screen, CGRect(x: -1512, y: 0, width: 1512, height: 982)]) == 0, "Equal display area keeps primary")
check(largestScreenIndex([CGRect(x: 0, y: 0, width: 2560, height: 1440), screen]) == 0, "Disconnect fallback selects remaining largest")
check(menuSafeVisibleFrame(screen: screen, visible: screen, menuHeight: 24).maxY == 958, "Secondary display always leaves native menu-bar space")
check(menuSafeVisibleFrame(screen: screen, visible: visible, menuHeight: 24) == visible, "Notch and dock insets are retained")
let aboveScreen = CGRect(x: 0, y: 982, width: 2560, height: 1440)
let aboveVisible = CGRect(x: 0, y: 1042, width: 2560, height: 1347)
let aboveLayout = BarLayout(screen: aboveScreen, visible: aboveVisible, primaryTop: 982, height: 30)
check(aboveLayout.bar == CGRect(x: 0, y: -1407, width: 2560, height: 30), "Larger display above primary keeps correct AX origin")

func session(_ id: String = "mac:claude:alpha", _ state: String = "working", _ question: String = "", _ result: String = "", fresh: Bool = true) -> SessionDisplay {
    SessionDisplay(["id": id, "repo": "notes", "provider": "claude", "title": "A long session with Unicode 🧪 and several wörds", "status": state, "question": question, "result": result, "open": state != "done"], fresh: fresh)!
}
let model = session()
check(model.shortName.count <= 20 && model.shortName.hasSuffix("…"), "Long names shrink safely including Unicode")
check(model.modelBadge == "C", "Claude has its own model badge")
check(session("phone:claude:alpha").modelBadge == "C", "A remote origin does not hide the model")
check(SessionDisplay(["id": "mac:codex:abc", "provider": "codex"], fresh: true)!.modelBadge == "G", "Codex gets the requested G badge")
let mini = SessionDisplay(["id": "mac:claude:mini", "provider": "claude", "model": "MiniMax-M3.1-Flash-Preview"], fresh: true)!
check(mini.modelBadge == "M" && mini.modelLabel.contains("MiniMax-M3.1"), "Actual MiniMax model overrides Claude host engine")
check(SessionDisplay(["id": "a", "provider": "minimax"], fresh: true)!.modelBadge == "M", "Native MiniMax engine is recognized without a model guess")
func record(_ id: String, open: Bool, repo: String = "api-server") -> SessionRecord {
    var value = SessionRecord(id: id, provider: "claude")
    value.open = open
    value.repo = repo
    return value
}
let openRows = (0..<4).map { record("claude:open\($0)", open: true) }
let closedRows = (0..<6).map { record("claude:closed\($0)", open: false) }
check(CollectorSnapshot(local: openRows + closedRows, external: [], generatedAt: Date()).visible.count == 4, "Four open sessions exclude six historical rows")
check(CollectorSnapshot(local: openRows + [openRows[0]], external: [], generatedAt: Date()).visible.count == 4, "Repeated IDs have just one visible chip")
check(CollectorSnapshot(local: openRows, external: [record("claude:open0", open: true, repo: "elsewhere")], generatedAt: Date()).visible.filter { $0.id == "claude:open0" }.map { $0.repo } == ["api-server"], "Local sessions win over an external copy")
check(CollectorSnapshot(local: [], external: closedRows, generatedAt: Date()).visible.isEmpty, "Closed external rows never show in the strip")
check(CollectorSnapshot(local: openRows, external: [record("server:phone:a", open: true)], generatedAt: Date()).visible.count == 5, "Open external sessions are shown next to the local ones")
check(SessionDisplay(["id": "a", "status": "working", "stale": true], fresh: true)!.state == "unknown", "A stale external source cannot claim current work, also with the old German state names")
check(SessionDisplay(["id": "a", "task": "  Backup   prüfen\n"], fresh: true)!.name == "Backup prüfen", "Task is normalized fallback name")
check(SessionDisplay(["id": "abc123"], fresh: true)!.name == "Session abc123", "Unnamed session has stable ID fallback")
check(SessionDisplay(["status": "waiting"], fresh: true) == nil, "Missing identity never becomes a targeted session")
check(session("mac:claude:alpha", "waiting", fresh: false).state == "unknown", "Stale input cannot pulse as current")
check(session("mac:claude:alpha", "done", fresh: false).state == "done", "Explicit completed results survive stale samples")
check(session("mac:claude:alpha", "done").process == "closed", "Closed completed session remains renderable")
check(model.id != session("mac:claude:beta").id, "Two sessions in same repo stay separate")
let tracker = SessionEventTracker()
check(tracker.observe([session("mac:claude:alpha", "waiting", "Alt?")], fresh: true).isEmpty, "Initial baseline never floods old input alerts")
check(tracker.observe([session()], fresh: true).isEmpty, "Working transitions do not notify")
let waiting = session("mac:claude:alpha", "waiting", "A oder B?")
check(tracker.observe([waiting], fresh: true).count == 1, "Fresh new input notifies")
check(tracker.observe([waiting], fresh: true).isEmpty, "Identical samples do not repeat input")
check(tracker.observe([session("mac:claude:alpha", "waiting", "C oder D?")], fresh: true).count == 1, "New question while waiting notifies once")
let resumed = SessionEventTracker(stamps: tracker.stamps)
check(resumed.observe([session("mac:claude:alpha", "waiting", "C oder D?")], fresh: true).isEmpty, "Persisted state deduplicates app restarts")
let oldLaunch = SessionEventTracker(stamps: tracker.stamps)
check(oldLaunch.observe([session("mac:claude:alpha", "done", "", "Alt")], fresh: false).isEmpty, "Saved-state startup with stale sample stays quiet")
check(oldLaunch.observe([session("mac:claude:alpha", "done", "", "Alt"), session("mac:claude:new-old", "waiting", "Schon vorher?")], fresh: true).isEmpty, "First fresh sample after stale startup never replays old transitions")
check(oldLaunch.observe([session("mac:claude:alpha", "done", "", "Alt"), session("mac:claude:new-old", "waiting", "Neue Frage nach Start?")], fresh: true).count == 1, "New event after startup baseline still notifies")
let previous = tracker.stamps
check(tracker.observe([session("mac:claude:alpha", "done", "", "OK")], fresh: false).isEmpty && tracker.stamps == previous, "Offline sample cannot emit or overwrite event baseline")
check(tracker.observe([session("mac:claude:alpha", "done", "", "OK")], fresh: true).count == 1, "Explicit fresh completion notifies")
check(tracker.observe([session("mac:claude:alpha", "done", "", "OK")], fresh: true).isEmpty, "Completion is not repeated")
check(tracker.observe([session("mac:claude:alpha", "ready")], fresh: true).isEmpty, "Ready after explicit done stays in same display state without duplicate popup")
check(tracker.observe([session("mac:claude:alpha", "waiting")], fresh: true).isEmpty, "Missing question never creates a vague input alert")
check(tracker.observe([session(), session("mac:claude:new", "waiting", "Neue Frage?")], fresh: true).count == 1, "New independent waiting session notifies")
let serialized = try JSONEncoder().encode(tracker.stamps)
check(!String(data: serialized, encoding: .utf8)!.contains("Neue Frage"), "Persisted ledger contains no question text")
let restored = SessionEventTracker(stamps: try JSONDecoder().decode([String: SessionEventTracker.Stamp].self, from: serialized))
check(restored.observe([session(), session("mac:claude:new", "waiting", "Neue Frage?")], fresh: true).isEmpty, "JSON roundtrip keeps deduplication")

check(repoAbbreviation("notes") == "NO", "Single-word repo uses first two letters")
check(repoAbbreviation("shop-backend") == "SB", "Compound repo uses word initials")
check(repoAbbreviation("_build-tools") == "BT", "Leading symbols do not become repo abbreviation")
let compact = SessionStripLayout(counts: [6, 4, 5, 10], width: 1920)
check(compact.rows == 1, "All 25 real sessions fit largest display without scrolling")
check(compact.placements.filter { $0.sessionIndex != nil }.count == 25, "Compact layout never drops sessions")
check(compact.placements.allSatisfy { $0.x >= 0 && $0.x + $0.width <= 1920 }, "Every compact chip stays inside screen")
let narrow = SessionStripLayout(counts: [6, 4, 5, 10], width: 1512)
check(narrow.rows == 1 && narrow.placements.allSatisfy { $0.x + $0.width <= 1512 }, "25 sessions also fit laptop in a single compact row")
let many = SessionStripLayout(counts: [35, 20, 30], width: 1512)
check(many.rows > 1, "High counts wrap instead of scrolling or hiding sessions")
check(many.placements.filter { $0.sessionIndex != nil }.count == 85 && many.placements.allSatisfy { $0.x + $0.width <= 1512 }, "All 85 wrapped sessions remain inside screen")

var hints = ToastQueue()
hints.append(ToastMessage(session: session("mac:claude:alpha", "waiting", "Erste Frage?")))
hints.append(ToastMessage(session: session("mac:claude:alpha", "waiting", "Aktuelle Frage?")))
check(hints.messages.count == 1 && hints.pop()?.body == "Aktuelle Frage?", "Pending popup uses latest question for exact native session")
for i in 0..<8 { hints.append(ToastMessage(session: session("mac:claude:q\(i)", "waiting", "Frage?"))) }
hints.append(ToastMessage(session: session("mac:claude:done", "done", "", "Erledigt")))
check(hints.messages.count == 8 && hints.messages.allSatisfy { $0.state == "waiting" }, "Popup burst is bounded and pending input has priority")
hints.clear()
check(hints.pop() == nil, "Closing popup queue discards pending hints")
check(ToastMessage(session: session("mac:claude:done", "done")).body == "Task completed.", "Explicit completion with no text gets a truthful short hint")
check(SessionToast.duration == 3, "Local popup duration is exactly three seconds")
check(tracker.observe([session("mac:claude:blocked", "blocked")], fresh: true).isEmpty, "Blocked state does not create requested input/completion popup")

check(session("mac:claude:idle", "ready").state == "done", "Fresh ready and done share requested yellow display state")
check(session("mac:claude:idle", "ready", fresh: false).state == "unknown", "Stale ready stays unknown instead of claiming current completion")
check(ToastMessage(session: session("mac:claude:idle", "ready")).body == "The session is waiting for its next task.", "Idle popup does not claim an explicit completed assignment")
let idleTracker = SessionEventTracker()
let start = Date()
_ = idleTracker.observe([session()], fresh: true, now: start)
check(idleTracker.observe([session()], fresh: true, now: start.addingTimeInterval(30)).isEmpty, "Continued work stays quiet")
check(idleTracker.observe([session("mac:claude:alpha", "ready")], fresh: true, now: start.addingTimeInterval(61)).count == 1, "Working-to-idle after a minute creates one completion hint")
check(idleTracker.observe([session("mac:claude:alpha", "done", "", "Geprüft")], fresh: true, now: start.addingTimeInterval(62)).isEmpty, "Later explicit result does not repeat already-yellow completion popup")
let quickTracker = SessionEventTracker()
_ = quickTracker.observe([session()], fresh: true, now: start)
check(quickTracker.observe([session("mac:claude:alpha", "ready")], fresh: true, now: start.addingTimeInterval(20)).isEmpty, "Short turn end stays quiet")
check(quickTracker.observe([session("mac:claude:alpha", "ready"), session("mac:claude:opened", "ready")], fresh: true, now: start.addingTimeInterval(25)).isEmpty, "Newly opened idle session stays quiet")
check(quickTracker.observe([session("mac:claude:alpha", "done", "", "Geprüft"), session("mac:claude:opened", "ready")], fresh: true, now: start.addingTimeInterval(30)).isEmpty, "Same yellow display state does not notify again")
check(quickTracker.observe([session("mac:claude:done2", "done", "", "Explizit")], fresh: true, now: start.addingTimeInterval(31)).count == 1, "Explicit completion notifies regardless of work time")
let twoRows = SessionStripLayout(counts: [6, 4, 5, 10], width: 1920, preferredRows: 2)
check(twoRows.rows == 2 && twoRows.placements.filter { $0.sessionIndex != nil }.count == 25, "Double-height strip uses two rows for all 25 sessions")
check(twoRows.placements.filter { $0.sessionIndex != nil }.map { $0.width }.min()! > compact.placements.filter { $0.sessionIndex != nil }.map { $0.width }.min()!, "Two rows give longer mini names")

let twentySeven = SessionStripLayout(counts: [8, 4, 5, 10], width: 1920, preferredRows: 2)
check(twentySeven.rows == 2 && twentySeven.placements.filter { $0.sessionIndex != nil }.count == 27, "Repeated group headers fit 27 actual sessions into requested two rows")

check(session("server:phone:alpha").modelBadge == "C", "A remote producer also shows the model badge")
let adaptiveFew = SessionStripLayout(counts: [3, 2, 2], width: 1920, adaptive: true)
check(adaptiveFew.rows == 1, "Few sessions use one adaptive row")
let adaptiveUsual = SessionStripLayout(counts: [8, 4, 5, 10], width: 1920, adaptive: true)
check(adaptiveUsual.rows == 2, "Actual 27 sessions get two adaptive rows")
let adaptiveCrowded = SessionStripLayout(counts: [35, 20, 30], width: 1512, adaptive: true)
check(adaptiveCrowded.rows == 2 && adaptiveCrowded.placements.filter { $0.sessionIndex != nil }.count == 85, "Crowded adaptive strip never creates third row or drops sessions")
check(adaptiveCrowded.placements.allSatisfy { $0.x + $0.width <= 1512 }, "Dense two-row session chips stay inside display")

let manyRepos = SessionStripLayout(counts: Array(repeating: 1, count: 500), width: 1512, adaptive: true)
check(manyRepos.rows == 2 && manyRepos.placements.filter { $0.sessionIndex != nil }.count == 500 && manyRepos.placements.allSatisfy { $0.x + $0.width <= 1512 }, "Even maximum separate repo density stays in two rows without dropping sessions")

// Settings: defaults, partial files, clamping, overrides, readable text.
let partial = try JSONDecoder().decode(BarSettings.self, from: Data(##"{"style":"bold","fontSize":40,"statusColors":{"input":"#000000"},"repos":{"web-app":{"abbreviation":"wa","hidden":true}}}"##.utf8))
check(partial.style == .bold && partial.fontSize == 13 && partial.maxRows == 2, "Partial settings keep defaults and clamp values")
check(partial.statusColors["waiting"] == "#000000" && partial.statusColors["working"] == BarSettings.defaultStatusColors["working"], "Partial color list keeps the other defaults, and old German keys still apply")
check(partial.isHidden("web-app") && partial.abbreviation(for: "web-app") == "WA" && partial.abbreviation(for: "shop-backend") == "SB", "Repo overrides apply, others keep the automatic abbreviation")
check((try? JSONDecoder().decode(BarSettings.self, from: Data("{}".utf8))) == BarSettings(), "Empty file gives the defaults")
check((try? JSONDecoder().decode(BarSettings.self, from: Data(#"{"style":"neon","maxRows":"x"}"#.utf8)))?.style == .calm, "Unknown values fall back instead of failing")
let roundTrip = try JSONDecoder().decode(BarSettings.self, from: JSONEncoder().encode(partial))
check(roundTrip == partial, "Settings survive a save and reload")
check(NSColor(hex: "#F02991")?.hexString == "#F02991" && NSColor(hex: "pink") == nil, "Hex colors round-trip, invalid ones are rejected")
check(NSColor(hex: "#FFD12E")!.readableText == .black && NSColor(hex: "#267A40")!.readableText == .white, "Chip text picks the readable color")
check(partial.repoColor("api", reported: "#3B7DD8").hexString == "#3B7DD8" && partial.repoColor("x", reported: nil) == .systemGray, "Reported repo color is the fallback")
let storeURL = FileManager.default.temporaryDirectory.appendingPathComponent("ki-leiste-test-\(getpid()).json")
let store = SettingsStore(url: storeURL)
var settingChanges = 0
store.onChange = { _ in settingChanges += 1 }
store.update { $0.fontSize = 12 }
store.update { $0.fontSize = 12 }
check(settingChanges == 1 && store.revision == 1 && SettingsStore(url: storeURL).current.fontSize == 12, "Store saves real changes once and ignores no-ops")
try? FileManager.default.removeItem(at: storeURL)
SessionAppearance.statusColors["done"] = "#00FF00"
check(SessionAppearance.color("ready").hexString == "#00FF00", "Ready uses the configured done color")
SessionAppearance.statusColors = BarSettings.defaultStatusColors
let single = SessionStripLayout(counts: [8, 4, 5], width: 1512, adaptive: true, rowLimit: 1)
check(single.rows == 1 && single.placements.filter { $0.sessionIndex != nil }.count == 17, "One-row limit squeezes all sessions into one row")
let stripes = SessionStripLayout(counts: [3, 3], width: 1512, adaptive: true, header: 9)
check(stripes.placements.filter { $0.sessionIndex == nil }.allSatisfy { $0.width == 9 }, "Stripe-only repo labels use the narrow header")

let layoutChecks = checks
hookTests()
claudeFallbackTests()
codexProviderTests()
collectorTests()
menuToggleTests()
print("Window layout: \(layoutChecks) checks, collector and providers: \(checks - layoutChecks) checks passed")

// Native integration: only the fixture's CG windows are supplied. No user
// windows are enumerated by AX or moved, and the fixture never takes focus.
if let fixturePath = CommandLine.arguments.dropFirst().first {
    guard AXIsProcessTrusted() else { fatalError("Integration tests need Accessibility permission") }
    let process = Process()
    process.executableURL = URL(fileURLWithPath: fixturePath)
    let pipe = Pipe()
    process.standardOutput = pipe
    try process.run()
    cleanup = { if process.isRunning { process.terminate(); process.waitUntilExit() } }
    defer { cleanup() }
    _ = pipe.fileHandleForReading.availableData
    let application = AXUIElementCreateApplication(process.processIdentifier)
    func read(_ element: AXUIElement, _ key: String) -> CFTypeRef? {
        var value: CFTypeRef?
        _ = AXUIElementCopyAttributeValue(element, key as CFString, &value)
        return value
    }
    let windows = read(application, kAXWindowsAttribute) as? [AXUIElement] ?? []
    check(!windows.isEmpty, "Fixture exposes an AX window")
    let window = windows.first!
    func frame() -> CGRect {
        var point = CGPoint.zero, size = CGSize.zero
        _ = AXValueGetValue(read(window, kAXPositionAttribute) as! AXValue, .cgPoint, &point)
        _ = AXValueGetValue(read(window, kAXSizeAttribute) as! AXValue, .cgSize, &size)
        return CGRect(origin: point, size: size)
    }
    func move(_ point: CGPoint) {
        var point = point
        _ = AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, AXValueCreate(.cgPoint, &point)!)
    }
    func resize(_ size: CGSize) {
        var size = size
        _ = AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, AXValueCreate(.cgSize, &size)!)
    }
    let display = NSScreen.screens.first!
    let live = BarLayout(screen: display.frame, visible: display.visibleFrame, primaryTop: display.frame.maxY, height: 30)
    let cgScreen = CGRect(x: display.frame.minX, y: 0, width: display.frame.width, height: display.frame.height)
    let space = WindowSpace(snapshot: {
        (CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]])?.filter {
            ($0[kCGWindowOwnerPID as String] as? Int) == Int(process.processIdentifier)
        }
    })
    space.selectDisplay(1)
    let original = frame()
    check(original.intersects(live.bar), "Native fixture actually overlaps the strip")
    check(space.makeRoom(live, screen: cgScreen), "Native AX adjustment succeeds")
    check(sameFrame(frame(), live.adjusted(original)!), "Native window is below the strip")
    Thread.sleep(forTimeInterval: 0.2) // CG snapshot catches up after the AX write.
    let taller = BarLayout(screen: display.frame, visible: display.visibleFrame, primaryTop: display.frame.maxY, height: 60)
    check(space.makeRoom(taller, screen: cgScreen), "Native repeated adjustment succeeds")
    check(sameFrame(frame(), taller.adjusted(original)!), "Repeated adjustment moves to new boundary")
    Thread.sleep(forTimeInterval: 0.2)
    check(space.makeRoom(live, screen: cgScreen), "Shrinking from two rows to one reflows without explicit restoration")
    check(sameFrame(frame(), live.adjusted(original)!), "Smaller strip returns the window to the nearer boundary")
    Thread.sleep(forTimeInterval: 0.2)
    check(space.makeRoom(live, screen: cgScreen), "Unchanged geometry keeps a stable reservation")
    check(sameFrame(frame(), live.adjusted(original)!), "Repeated reservation does not creep downward")
    space.restore()
    check(sameFrame(frame(), original), "Native restoration retains the original across repeated adjustments")
    resize(CGSize(width: original.width, height: display.visibleFrame.height))
    move(original.origin)
    let maximized = frame()
    Thread.sleep(forTimeInterval: 0.2)
    check(space.makeRoom(live, screen: cgScreen), "Large window fits a single-row reservation")
    Thread.sleep(forTimeInterval: 0.2)
    check(space.makeRoom(taller, screen: cgScreen), "Large window shrinks for two rows")
    check(sameFrame(frame(), taller.adjusted(maximized)!), "Growing strip computes large-window height from its original")
    Thread.sleep(forTimeInterval: 0.2)
    check(space.makeRoom(live, screen: cgScreen), "Large window expands when second row disappears")
    check(sameFrame(frame(), live.adjusted(maximized)!), "Shrinking strip returns all newly available height")
    var withDock = display.visibleFrame
    withDock.origin.y += 50
    withDock.size.height -= 50
    let dockLayout = BarLayout(screen: display.frame, visible: withDock, primaryTop: display.frame.maxY, height: 30)
    Thread.sleep(forTimeInterval: 0.2)
    check(space.makeRoom(dockLayout, screen: cgScreen), "Visible work-area change reflows managed windows without a new bar collision")
    check(sameFrame(frame(), dockLayout.adjusted(maximized)!), "Dock change updates the available window height")
    Thread.sleep(forTimeInterval: 0.2)
    check(space.makeRoom(live, screen: cgScreen), "Window regains space when the work area expands again")
    check(sameFrame(frame(), live.adjusted(maximized)!), "Work-area expansion restores all available height")
    space.restore()
    check(sameFrame(frame(), maximized), "Large window regains full original geometry when reservation ends")
    resize(original.size)
    move(original.origin)
    Thread.sleep(forTimeInterval: 0.2)
    check(space.makeRoom(live, screen: cgScreen), "Native second adjustment succeeds")
    check(space.selectDisplay(2), "Display-ID change is recognized")
    check(sameFrame(frame(), original), "Previous-display window regains original size and position")
    Thread.sleep(forTimeInterval: 0.2)
    check(space.makeRoom(live, screen: cgScreen), "Native adjustment on next display succeeds")
    check(!space.selectDisplay(2), "Unchanged display never releases active reservation")
    check(sameFrame(frame(), live.adjusted(original)!), "Same display keeps room for its bar")
    move(CGPoint(x: original.minX + 50, y: live.workArea.minY + 100))
    let userFrame = frame()
    space.restore()
    check(sameFrame(frame(), userFrame), "Native restoration respects later user moves")
    move(original.origin)
    Thread.sleep(forTimeInterval: 0.2)
    check(space.makeRoom(live, screen: cgScreen), "Window can enter reservation again after a manual move")
    move(CGPoint(x: original.minX + 70, y: original.minY))
    let manualBaseline = frame()
    Thread.sleep(forTimeInterval: 0.2)
    check(space.makeRoom(taller, screen: cgScreen), "Manual placement overlapping a growing strip is adjusted")
    check(sameFrame(frame(), taller.adjusted(manualBaseline)!), "Manual placement becomes the new original baseline")
    space.restore()
    check(sameFrame(frame(), manualBaseline), "Release restores the latest user placement rather than old coordinates")
    move(original.origin)
    Thread.sleep(forTimeInterval: 0.2)
    let tightVisible = CGRect(x: display.visibleFrame.minX, y: display.visibleFrame.maxY - 120, width: display.visibleFrame.width, height: 120)
    let tight = BarLayout(screen: display.frame, visible: tightVisible, primaryTop: display.frame.maxY, height: 30)
    check(space.makeRoom(tight, screen: cgScreen), "Minimum window size never hides the bar")
    check(!tight.overlaps(frame()) && frame().maxY <= original.maxY + 1, "Clamped window clears the strip without growing downward")
    space.restore()
    check(sameFrame(frame(), original), "Clamped adjustment restores the original")
    resize(CGSize(width: original.width, height: 250))
    Thread.sleep(forTimeInterval: 0.2)
    let minimal = frame()
    check(space.makeRoom(tight, screen: cgScreen) && space.status.contains("not adjustable"), "Window at minimum size is refused instead of pushed down")
    check(sameFrame(frame(), minimal), "Refused adjustment rolls back")
    Thread.sleep(forTimeInterval: 0.2)
    check(space.makeRoom(tight, screen: cgScreen) && sameFrame(frame(), minimal), "Refused window is not retried while unchanged")
    resize(original.size)
    Thread.sleep(forTimeInterval: 0.2)
    let blocked = WindowSpace(snapshot: { [[kCGWindowOwnerPID as String: Int(process.processIdentifier),
        kCGWindowLayer as String: 0, kCGWindowBounds as String: CGRect(x: original.minX + 7, y: original.minY, width: original.width, height: original.height).dictionaryRepresentation]] })
    check(blocked.makeRoom(live, screen: cgScreen) && blocked.status.contains("not adjustable"), "Unmatchable window is skipped without hiding the bar")
    check(blocked.makeRoom(live, screen: cgScreen) && blocked.status.contains("not adjustable"), "Refused window stays refused while unchanged")
    check(sameFrame(frame(), original), "Unmatchable window is untouched")
    let fullscreen = WindowSpace(snapshot: { [[kCGWindowOwnerPID as String: Int(process.processIdentifier),
        kCGWindowLayer as String: 0, kCGWindowBounds as String: cgScreen.dictionaryRepresentation]] })
    check(!fullscreen.makeRoom(live, screen: cgScreen), "Fullscreen hides bar before AX writes")
    check(sameFrame(frame(), original), "Fullscreen guard leaves window untouched")
    print("Window layout + native AX: \(checks) checks passed")
}
