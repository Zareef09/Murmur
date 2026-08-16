import Foundation
import Observation

/// First-launch slides. Subsequent launches skip them when the user is signed in, or once completed on this device.
@MainActor
@Observable
final class OnboardingGate {
    static let defaultsKey = "murmur.onboarding.completed"

    private let defaults: UserDefaults
    private(set) var isComplete: Bool

    init(defaults: UserDefaults = .standard, isComplete: Bool? = nil) {
        self.defaults = defaults
        if let isComplete {
            self.isComplete = isComplete
        } else {
            self.isComplete = defaults.bool(forKey: Self.defaultsKey)
        }
    }

    func complete() {
        isComplete = true
        defaults.set(true, forKey: Self.defaultsKey)
    }
}
