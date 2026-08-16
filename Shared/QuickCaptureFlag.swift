import Foundation

/// Start-listening flag shared via App Group. Bool only — no titles, tokens, or history.
enum QuickCaptureFlag: Sendable {
    static let appGroupID = "group.app.murmur.capture"
    static let didArm = Notification.Name("murmur.quickCapture.didArm")

    private static let key = "pending"

    private static var store: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    static var isArmed: Bool {
        store.bool(forKey: key)
    }

    static func arm() {
        store.set(true, forKey: key)
        NotificationCenter.default.post(name: didArm, object: nil)
    }

    static func consume() {
        store.set(false, forKey: key)
    }
}
