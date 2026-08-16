import AppIntents
import XCTest
@testable import Murmur

final class QuickCaptureFlagTests: XCTestCase {
    override func setUp() {
        super.setUp()
        QuickCaptureFlag.consume()
    }

    override func tearDown() {
        QuickCaptureFlag.consume()
        super.tearDown()
    }

    func testArmAndConsumeAreABoolOnly() {
        XCTAssertFalse(QuickCaptureFlag.isArmed)
        QuickCaptureFlag.arm()
        XCTAssertTrue(QuickCaptureFlag.isArmed)
        QuickCaptureFlag.consume()
        XCTAssertFalse(QuickCaptureFlag.isArmed)
        XCTAssertEqual(QuickCaptureIntent.openAppWhenRun, true)
        XCTAssertFalse(LoggingPolicy.looksLikeBannedContent("quick capture"))
    }
}

final class CaptureShortcutsTests: XCTestCase {
    func testDonatesOneQuickCaptureShortcut() {
        XCTAssertEqual(CaptureShortcuts.appShortcuts.count, 1)
        XCTAssertEqual(QuickCaptureIntent.title, "Quick capture")
    }
}

@MainActor
final class CaptureViewModelQuickCaptureTests: XCTestCase {
    override func setUp() {
        super.setUp()
        QuickCaptureFlag.consume()
    }

    override func tearDown() {
        QuickCaptureFlag.consume()
        super.tearDown()
    }

    func testPendingStartsListeningWhenSignedIn() async {
        let speech = FakeSpeechService()
        let model = CaptureViewModel(
            speech: speech,
            permissions: FakePermissionsService(),
            eventKit: FakeEventKitService(),
            synth: FakeSpeechSynth()
        )
        model.applySession(isSignedIn: true)
        QuickCaptureFlag.arm()

        XCTAssertTrue(model.applyQuickCaptureIfPending())
        await model.flushPendingListen()

        XCTAssertEqual(model.state, .listening)
        XCTAssertEqual(speech.startCount, 1)
        XCTAssertFalse(QuickCaptureFlag.isArmed)
    }

    func testPendingStaysArmedWhileSignedOut() {
        let model = CaptureViewModel(
            speech: FakeSpeechService(),
            permissions: FakePermissionsService(),
            eventKit: FakeEventKitService(),
            synth: FakeSpeechSynth()
        )
        QuickCaptureFlag.arm()

        XCTAssertFalse(model.applyQuickCaptureIfPending())
        XCTAssertEqual(model.state, .signedOut)
        XCTAssertTrue(QuickCaptureFlag.isArmed)
    }

    func testPendingWaitsWhileConfirming() async {
        let speech = FakeSpeechService()
        let model = CaptureViewModel(
            speech: speech,
            permissions: FakePermissionsService(),
            eventKit: FakeEventKitService(),
            synth: FakeSpeechSynth()
        )
        model.applySession(isSignedIn: true)
        model.tapWell()
        await model.flushPendingListen()
        speech.committedText = "call mom"
        speech.onTurnEnded?()
        await model.flushPendingSave()
        XCTAssertEqual(model.state, .confirming)

        QuickCaptureFlag.arm()
        XCTAssertFalse(model.applyQuickCaptureIfPending())
        XCTAssertTrue(QuickCaptureFlag.isArmed)

        model.confirmCancel()
        XCTAssertTrue(model.applyQuickCaptureIfPending())
        await model.flushPendingListen()
        XCTAssertEqual(model.state, .listening)
        XCTAssertFalse(QuickCaptureFlag.isArmed)
    }
}
