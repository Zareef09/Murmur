import XCTest
@testable import Murmur

@MainActor
final class OnboardingGateTests: XCTestCase {
    func testCompletePersistsOnThisDevice() {
        let suite = "murmur.tests.onboarding.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        let gate = OnboardingGate(defaults: defaults)
        XCTAssertFalse(gate.isComplete)
        gate.complete()
        XCTAssertTrue(OnboardingGate(defaults: defaults).isComplete)
        defaults.removePersistentDomain(forName: suite)
    }
}
