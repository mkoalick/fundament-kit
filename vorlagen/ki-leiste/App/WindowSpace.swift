import Cocoa
import ApplicationServices

// AX/CG use a top-left origin; AppKit uses a bottom-left origin. The origin
// is always the top of the primary display, including for other monitors.
// Choose by logical display area: more available workspace wins. Keep the
// primary display (first) when two screens have the same area.
func largestScreenIndex(_ frames: [CGRect]) -> Int? {
    guard !frames.isEmpty else { return nil }
    var winner = 0
    for index in frames.indices where frames[index].width * frames[index].height > frames[winner].width * frames[winner].height {
        winner = index
    }
    return winner
}

// Secondary displays can report a visibleFrame reaching into the menu bar.
// Reserve at least AppKit's actual menu-bar thickness; keep larger notch insets.
func menuSafeVisibleFrame(screen: CGRect, visible: CGRect, menuHeight: CGFloat) -> CGRect {
    var result = visible
    let top = min(visible.maxY, screen.maxY - menuHeight)
    result.size.height = max(0, top - visible.minY)
    return result
}

struct BarLayout {
    let bar: CGRect
    let workArea: CGRect

    init(screen: CGRect, visible: CGRect, primaryTop: CGFloat, height: CGFloat) {
        bar = CGRect(x: screen.minX, y: primaryTop - visible.maxY,
                     width: screen.width, height: height)
        workArea = CGRect(x: visible.minX, y: bar.maxY,
                          width: visible.width, height: max(0, visible.height - height))
    }

    // At least one full point of overlap; AX rounding at the edge is not a collision.
    func overlaps(_ window: CGRect) -> Bool {
        let shared = window.intersection(bar)
        return !shared.isNull && shared.width >= 1 && shared.height >= 1
    }

    func adjusted(_ window: CGRect) -> CGRect? {
        guard window.intersects(bar), window.width > 0, window.height > 0 else { return nil }
        var result = window
        result.origin.y = workArea.minY
        result.size.height = min(window.height, workArea.height)
        return result
    }
}

func sameFrame(_ a: CGRect, _ b: CGRect) -> Bool {
    abs(a.minX - b.minX) < 1 && abs(a.minY - b.minY) < 1 &&
    abs(a.width - b.width) < 1 && abs(a.height - b.height) < 1
}

final class WindowSpace {
    struct Change {
        let window: AXUIElement
        var original: CGRect
        var requested: CGRect
        var applied: CGRect
    }
    private var changes: [Change] = []
    struct Refusal {
        let pid: pid_t
        let frame: CGRect
        let owner: String
    }
    // Windows that refused an adjustment stay as they are and are not retried
    // until they move or resize - no half-second jumping, no hidden strip.
    private var refusals: [Refusal] = []
    private(set) var displayID: CGDirectDisplayID?

    @discardableResult
    func selectDisplay(_ id: CGDirectDisplayID) -> Bool {
        guard displayID != id else { return false }
        let changed = displayID != nil
        if changed { restore() }
        displayID = id
        return changed
    }
    private let snapshot: () -> [[String: Any]]?

    init(snapshot: @escaping () -> [[String: Any]]? = {
        CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]]
    }) {
        self.snapshot = snapshot
    }
    private(set) var status = ""
    var trusted: Bool { AXIsProcessTrusted() }

    func requestPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    private func attribute(_ element: AXUIElement, _ name: String) -> CFTypeRef? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, name as CFString, &value) == .success else { return nil }
        return value
    }

    private func frame(_ window: AXUIElement) -> CGRect? {
        guard let position = attribute(window, kAXPositionAttribute),
              let size = attribute(window, kAXSizeAttribute),
              CFGetTypeID(position) == AXValueGetTypeID(), CFGetTypeID(size) == AXValueGetTypeID() else { return nil }
        var point = CGPoint.zero, dimensions = CGSize.zero
        guard AXValueGetValue(position as! AXValue, .cgPoint, &point),
              AXValueGetValue(size as! AXValue, .cgSize, &dimensions) else { return nil }
        return CGRect(origin: point, size: dimensions)
    }

    // Returns the frame the window actually took. Apps may round the size
    // (Terminal snaps to whole lines), so callers judge the result themselves.
    private func setFrame(_ window: AXUIElement, _ target: CGRect) -> CGRect? {
        guard let current = frame(window) else { return nil }
        func resize() -> Bool {
            if abs(current.height - target.height) < 1 && abs(current.width - target.width) < 1 { return true }
            var size = target.size
            guard let value = AXValueCreate(.cgSize, &size) else { return false }
            return AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, value) == .success
        }
        func move() -> Bool {
            if abs(current.minX - target.minX) < 1 && abs(current.minY - target.minY) < 1 { return true }
            var point = target.origin
            guard let value = AXValueCreate(.cgPoint, &point) else { return false }
            return AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, value) == .success
        }
        // Shrink before moving down; when restoring, move up before expanding.
        if target.height <= current.height {
            guard resize(), move() else { return nil }
        } else {
            guard move(), resize() else { return nil }
        }
        return frame(window)
    }

    // Read only onscreen CG windows, then match by process and geometry. Never
    // enumerate/move windows from another Space or match by a window title.
    // Only fullscreen hides the strip. A single window that cannot be adjusted
    // is left alone and simply covers part of the back-ordered strip.
    func makeRoom(_ layout: BarLayout, screen: CGRect) -> Bool {
        guard trusted else { status = L("Accessibility access missing"); return false }
        guard let visible = snapshot() else {
            status = L("Windows cannot be checked"); return false
        }
        var candidates: [(pid: pid_t, rect: CGRect, owner: String)] = []
        var present: [(pid: pid_t, rect: CGRect)] = []
        for info in visible {
            guard let pid = info[kCGWindowOwnerPID as String] as? Int,
                  pid != Int(getpid()),
                  (info[kCGWindowLayer as String] as? Int) == 0,
                  (info[kCGWindowAlpha as String] as? Double ?? 1) > 0,
                  let bounds = info[kCGWindowBounds as String] as? NSDictionary,
                  let rect = CGRect(dictionaryRepresentation: bounds),
                  rect.width > 1, rect.height > 1 else { continue }
            // Fullscreen windows often hide the menu bar and may not expose
            // AXFullScreen. Check geometry before changing any other window.
            if rect.minX <= screen.minX + 1 && rect.minY <= screen.minY + 1 &&
                rect.maxX >= screen.maxX - 1 && rect.maxY >= screen.maxY - 1 {
                status = L("Strip hidden in full screen"); return false
            }
            present.append((pid_t(pid), rect))
            // Previously adjusted windows need reflow even when a shorter bar
            // no longer intersects them. Recompute from their saved original,
            // so shrinking the strip gives their height and position back.
            let managed = changes.contains { change in
                var owner: pid_t = 0
                AXUIElementGetPid(change.window, &owner)
                return owner == pid_t(pid) && sameFrame(rect, change.applied)
            }
            if layout.overlaps(rect) || managed {
                candidates.append((pid_t(pid), rect, info[kCGWindowOwnerName as String] as? String ?? "?"))
            }
        }
        refusals.removeAll { refusal in !present.contains { $0.pid == refusal.pid && sameFrame($0.rect, refusal.frame) } }
        var windowsByPID: [pid_t: [AXUIElement]] = [:]
        for (pid, rect, owner) in candidates {
            if refusals.contains(where: { $0.pid == pid && sameFrame($0.frame, rect) }) { continue }
            if windowsByPID[pid] == nil {
                let application = AXUIElementCreateApplication(pid)
                AXUIElementSetMessagingTimeout(application, 0.15)
                windowsByPID[pid] = attribute(application, kAXWindowsAttribute) as? [AXUIElement] ?? []
            }
            guard let window = windowsByPID[pid]?.first(where: { element in
                guard let actual = frame(element) else { return false }
                return sameFrame(actual, rect)
            }), let current = frame(window) else {
                refusals.append(Refusal(pid: pid, frame: rect, owner: owner)); continue
            }
            if attribute(window, "AXFullScreen") as? Bool == true {
                status = L("Strip hidden in full screen"); return false
            }
            let existing = changes.firstIndex { CFEqual($0.window, window) }
            let kept = existing.flatMap { sameFrame(current, changes[$0].applied) ? changes[$0] : nil }
            let original = kept?.original ?? current
            let target = layout.adjusted(original) ?? original
            guard target.height > 0 else {
                refusals.append(Refusal(pid: pid, frame: current, owner: owner)); continue
            }
            // Already placed for this exact strip (possibly rounded by the app):
            // no further write, otherwise snapping apps get resized every tick.
            if let kept = kept, sameFrame(kept.requested, target) { continue }
            var applied = current
            if !sameFrame(current, target) {
                // Accept app rounding (snapped heights, minimum sizes) as long as
                // the window clears the strip and does not grow further down.
                guard let actual = setFrame(window, target), !layout.overlaps(actual),
                      actual.maxY <= max(target.maxY, original.maxY) + 1 else {
                    // A failed write may already have resized the window. Roll
                    // that back immediately; never leave a half-applied change.
                    _ = setFrame(window, current)
                    refusals.append(Refusal(pid: pid, frame: frame(window) ?? current, owner: owner)); continue
                }
                applied = actual
            }
            if sameFrame(applied, original) {
                if let index = existing { changes.remove(at: index) }
            } else {
                let change = Change(window: window, original: original, requested: target, applied: applied)
                if let index = existing { changes[index] = change } else { changes.append(change) }
            }
        }
        // Discard closed windows instead of accumulating stale AX references.
        changes.removeAll { change in
            guard let current = frame(change.window) else { return true }
            // A user/app move supersedes the saved placement. If the new frame
            // overlaps the strip, the candidate above records it as a new base.
            return !sameFrame(current, change.applied)
        }
        let refused = Set(refusals.map { $0.owner }).sorted()
        status = L("Window area below the strip") +
            (refused.isEmpty ? "" : " · \(L("not adjustable")): " + refused.joined(separator: ", "))
        return true
    }

    func restore() {
        for change in changes {
            // Respect any positioning the user changed after our adjustment.
            if let current = frame(change.window), sameFrame(current, change.applied) {
                _ = setFrame(change.window, change.original)
            }
        }
        changes.removeAll()
    }
}
