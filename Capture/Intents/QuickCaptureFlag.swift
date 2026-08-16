import Foundation

/// In-app start-listening flag for `QuickCaptureIntent`. App Group sharing is Session 84.
/// Bool only — no titles, tokens, or history.
enum QuickCaptureFlag: Sendable {
    static let didArm = Notification.Name("murmur.quickCapture.didArm")

    private static let key = "murmur.quickCapture.pending"

    static var isArmed: Bool {
        UserDefaults.standard.bool(forKey: key)
    }

    static func arm() {
        UserDefaults.standard.set(true, forKey: key)
        NotificationCenter.default.post(name: didArm, object: nil)
    }

    static func consume() {
        UserDefaults.standard.set(false, forKey: key)
    }
}
