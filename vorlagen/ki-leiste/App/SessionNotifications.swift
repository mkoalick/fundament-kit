import Cocoa
import UserNotifications
import CryptoKit

final class SessionNotifications: NSObject, UNUserNotificationCenterDelegate {
    private let center = UNUserNotificationCenter.current()
    private let ledgerURL: URL
    private let tracker: SessionEventTracker
    private var lastLedger: Data?
    private var reportedPermission = false
    private(set) var authorization: UNAuthorizationStatus = .notDetermined
    var onEvents: (([SessionEventTracker.Event]) -> Void)?
    var onOpenSession: ((String) -> Void)?
    var onSettingsChanged: (() -> Void)?

    init(ledgerURL: URL = AppPaths().notificationLedger) {
        self.ledgerURL = ledgerURL
        let data = try? Data(contentsOf: ledgerURL)
        let stamps = data.flatMap { try? JSONDecoder().decode([String: SessionEventTracker.Stamp].self, from: $0) }
        tracker = SessionEventTracker(stamps: stamps)
        super.init()
        center.delegate = self
    }

    var readyHintAfterSeconds: TimeInterval {
        get { tracker.minimumWorkForReadyHint }
        set { tracker.minimumWorkForReadyHint = newValue }
    }

    var allowed: Bool { authorization == .authorized || authorization == .provisional }
    var permissionLabel: String {
        switch authorization {
        case .authorized, .provisional: return L("Notifications allowed")
        case .denied: return L("Allow notifications in System Settings …")
        default: return L("Allow notifications …")
        }
    }

    func refreshSettings() {
        center.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                guard let self = self else { return }
                let changed = self.authorization != settings.authorizationStatus
                self.authorization = settings.authorizationStatus
                if changed || !self.reportedPermission {
                    AppLog.write("Notifications: \(self.permissionLabel)")
                    self.reportedPermission = true
                }
                if changed { self.onSettingsChanged?() }
            }
        }
    }

    func requestPermission() {
        // Called only by the explicit menu action, never while scanning sessions.
        if authorization == .denied {
            if let settings = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.systempreferences") {
                NSWorkspace.shared.open(settings)
            }
            return
        }
        center.requestAuthorization(options: [.alert]) { [weak self] _, error in
            if let error = error { AppLog.write("Notification permission failed: \(error)") }
            self?.refreshSettings()
        }
    }

    func observe(_ sessions: [SessionDisplay], fresh: Bool, enabled: Bool, nativeEnabled: Bool) {
        let events = tracker.observe(sessions, fresh: fresh)
        guard fresh else { return }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        if let data = try? encoder.encode(tracker.stamps), data != lastLedger {
            do {
                try FileManager.default.createDirectory(at: ledgerURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
                try data.write(to: ledgerURL, options: .atomic)
                try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: ledgerURL.path)
                lastLedger = data
            } catch { AppLog.write("Notification ledger not saved: \(error)") }
        }
        // Always advance the baseline even when notifications are disabled or
        // awaiting permission. Enabling them must not create an old-event flood.
        if enabled, !events.isEmpty { onEvents?(events) }
        guard nativeEnabled, allowed else { return }
        for event in events { deliver(event) }
    }

    func testNotification() {
        guard allowed else { return }
        let content = UNMutableNotificationContent()
        content.title = String(format: L("%@ · Test"), AppIdentity.displayName)
        content.body = L("New questions and completed results appear here as a brief notice.")
        center.add(UNNotificationRequest(identifier: "test-notification", content: content, trigger: nil)) { error in
            AppLog.write(error == nil ? "Test notification handed to macOS" : "Test notification failed")
        }
    }

    private func deliver(_ event: SessionEventTracker.Event) {
        let session = event.session
        let content = UNMutableNotificationContent()
        content.title = session.state == "waiting" ? String(format: L("Needs you · %@"), session.repo) : String(format: L("Done · %@"), session.repo)
        content.subtitle = String(session.name.prefix(80))
        content.body = String((session.state == "waiting" ? session.question : session.completionText).prefix(220))
        content.threadIdentifier = session.repo
        content.userInfo = ["session_id": session.id]
        // Replace the notification for the same session; new questions do not
        // accumulate a stack. No sound and no app activation on delivery.
        let identifier = "session-" + SHA256.hash(data: Data(session.id.utf8)).map { String(format: "%02x", $0) }.joined()
        center.add(UNNotificationRequest(identifier: identifier, content: content, trigger: nil)) { error in
            if let error = error { AppLog.write("Notification not delivered: \(error)") }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier,
           let id = response.notification.request.content.userInfo["session_id"] as? String {
            DispatchQueue.main.async { [weak self] in self?.onOpenSession?(id) }
        }
        completionHandler()
    }
}
