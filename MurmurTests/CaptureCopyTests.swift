import XCTest
@testable import Murmur

final class CaptureCopyTests: XCTestCase {
    func testKitCaptionsMatchCaptureHome() {
        XCTAssertEqual(CaptureCopy.idleCaption, "Tap to speak")
        // Listening teaches the second tap rather than restating what the well already shows.
        XCTAssertEqual(CaptureCopy.listeningCaption, "Tap again when you're done")
        XCTAssertEqual(CaptureCopy.thinkingCaption, "One moment")
        XCTAssertEqual(CaptureCopy.successCaption, SuccessCopy.caption)
        XCTAssertEqual(CaptureCopy.listeningPlaceholder, "Say it when you're ready")
        XCTAssertEqual(CaptureCopy.firstRunCaption, "Tap, then just say it")
        XCTAssertEqual(CaptureCopy.firstRunTitle, "Say what you need to remember.")
    }

    func testCopyStaysQuiet() {
        let lines = [
            CaptureCopy.firstRunTitle,
            CaptureCopy.firstRunCaption,
            CaptureCopy.firstRunFootnote,
            CaptureCopy.idleCaption,
            CaptureCopy.listeningCaption,
            CaptureCopy.thinkingCaption,
            CaptureCopy.successCaption
        ]
        for line in lines {
            let lower = line.lowercased()
            XCTAssertFalse(line.contains("!"))
            XCTAssertFalse(lower.contains("error"))
            XCTAssertFalse(lower.contains("failed"))
            XCTAssertFalse(lower.contains("invalid"))
            XCTAssertFalse(LoggingPolicy.looksLikeBannedContent(line))
        }
        XCTAssertFalse(CaptureCopy.firstRunTitle.lowercased().contains("mic"))
        XCTAssertFalse(CaptureCopy.idleCaption.lowercased().contains("mic"))
    }
}

@MainActor
final class CaptureViewModelFirstRunTests: XCTestCase {
    func testFirstRunUntilListeningStarts() async {
        let suite = "murmur.tests.firstRun.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let model = CaptureViewModel(
            speech: FakeSpeechService(),
            permissions: FakePermissionsService(),
            eventKit: FakeEventKitService(),
            synth: FakeSpeechSynth(),
            defaults: defaults
        )
        model.applySession(isSignedIn: true)
        XCTAssertTrue(model.showsFirstRun)

        model.tapWell()
        await model.flushPendingListen()

        XCTAssertEqual(model.state, .listening)
        XCTAssertFalse(model.showsFirstRun)
        XCTAssertTrue(defaults.bool(forKey: CaptureFirstRun.defaultsKey))
        defaults.removePersistentDomain(forName: suite)
    }

    func testPermissionDenialKeepsFirstRun() async {
        let suite = "murmur.tests.firstRun.denied.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let permissions = FakePermissionsService()
        permissions.microphone = .needed
        let model = CaptureViewModel(
            speech: FakeSpeechService(),
            permissions: permissions,
            eventKit: FakeEventKitService(),
            synth: FakeSpeechSynth(),
            defaults: defaults
        )
        model.applySession(isSignedIn: true)
        model.tapWell()
        await model.flushPendingListen()

        XCTAssertTrue(model.showsFirstRun)
        XCTAssertEqual(model.state, .idle)
        defaults.removePersistentDomain(forName: suite)
    }
}
