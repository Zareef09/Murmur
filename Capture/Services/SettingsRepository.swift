import Foundation

@MainActor
protocol SettingsRepositorying: AnyObject {
    func alwaysConfirm(userId: UUID) -> Bool
    func setAlwaysConfirm(_ value: Bool, userId: UUID)
}

/// Last-known `always_confirm` in this app's UserDefaults (not an App Group). Default **true**.
/// Session 23 mirrors this to `user_settings`. Capture must not wait on the network to read this.
@MainActor
final class SettingsRepository: SettingsRepositorying {
    static let shared = SettingsRepository()

    static let defaultAlwaysConfirm = true

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func alwaysConfirm(userId: UUID) -> Bool {
        let key = Self.key(userId: userId)
        guard defaults.object(forKey: key) != nil else {
            return Self.defaultAlwaysConfirm
        }
        return defaults.bool(forKey: key)
    }

    func setAlwaysConfirm(_ value: Bool, userId: UUID) {
        defaults.set(value, forKey: Self.key(userId: userId))
    }

    private static func key(userId: UUID) -> String {
        "murmur.settings.alwaysConfirm.\(userId.uuidString)"
    }
}
