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

    func testKitCopyAndPermissionPriming() {
        XCTAssertEqual(OnboardingCopy.slide1Title, "Say it once. It’s kept.")
        XCTAssertEqual(OnboardingCopy.slide2Title, "Two things to allow")
        XCTAssertEqual(OnboardingCopy.slide3Title, "One press, hands free")
        XCTAssertEqual(OnboardingCopy.allowAccess, "Allow access")
        XCTAssertEqual(OnboardingCopy.setItUp, "Set it up")
        XCTAssertEqual(OnboardingCopy.continueTitle, "Continue")
        XCTAssertEqual(OnboardingCopy.microphoneHint, "So Murmur can hear you")
        XCTAssertFalse(OnboardingCopy.slide2Body.contains("!"))
        XCTAssertFalse(OnboardingCopy.slide2Body.lowercased().contains("error"))
        XCTAssertFalse(OnboardingCopy.slide2Body.lowercased().contains("failed"))
    }

    func testSlide2StaysUntilPrimingKindsGranted() {
        let permissions = FakePermissionsService()
        permissions.microphone = .needed
        permissions.reminders = .granted
        permissions.calendar = .granted
        XCTAssertFalse(OnboardingAccess.primingKindsGranted(permissions))
        XCTAssertEqual(
            OnboardingAccess.slide2CTA(granted: false, didAsk: false),
            OnboardingCopy.allowAccess
        )
        XCTAssertEqual(
            OnboardingAccess.slide2CTA(granted: false, didAsk: true),
            OnboardingCopy.continueTitle
        )
        permissions.microphone = .granted
        XCTAssertTrue(OnboardingAccess.primingKindsGranted(permissions))
        XCTAssertEqual(
            OnboardingAccess.slide2CTA(granted: true, didAsk: true),
            OnboardingCopy.next
        )
    }
}
