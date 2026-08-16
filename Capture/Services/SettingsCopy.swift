import Foundation

/// Settings screen copy. Account row never includes email, name, or a user id.
enum SettingsCopy {
    static let title = "Settings"
    static let captureSection = "Capture"
    static let confirmLabel = "Always confirm before saving"
    static let confirmDescription = "Glance at what Murmur heard before it files it."
    static let accountSection = "Account"
    static let accountTitle = "Signed in with Apple"
    static let accountSubtitle = "History stays on this iPhone"
    static let signOut = "Sign out"
    static let close = "Close"
    /// Spec §12: network down later — capture still works; settings stay on this phone.
    static let usingThisPhone = "Using the last settings on this iPhone."
    static let permissionsSection = "Permissions"
    static let openSettings = "Open Settings"
    static let microphone = "Microphone"
    static let speech = "Speech"
    static let reminders = "Reminders"
    static let calendar = "Calendar"
    static let microphoneHint = "Needed so Murmur can hear you"
    static let speechHint = "Needed so words stay on this iPhone"
    static let remindersHint = "Needed to save reminders"
    static let calendarHint = "Needed to save events"

    static func versionLine(version: String, build: String) -> String {
        "murmur \(version) (\(build))"
    }

    static var bundledVersionLine: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return versionLine(version: version, build: build)
    }
}
