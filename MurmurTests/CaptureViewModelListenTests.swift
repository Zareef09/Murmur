import SwiftData
import XCTest
@testable import Murmur

@MainActor
final class CaptureViewModelListenTests: XCTestCase {
    func testTapWellStartsListeningAndKeepsTranscriptAfterSilence() async throws {
        let speech = FakeSpeechService()
        let eventKit = FakeEventKitService()
        let container = try Persistence.makeContainer(inMemory: true)
        let model = CaptureViewModel(
            speech: speech,
            permissions: FakePermissionsService(),
            eventKit: eventKit,
            synth: FakeSpeechSynth(),
            modelContext: container.mainContext
        )
        model.applySession(isSignedIn: true)

        model.tapWell()
        await model.flushPendingListen()

        XCTAssertEqual(model.state, .listening)
        XCTAssertEqual(speech.startCount, 1)

        speech.committedText = ""
        speech.partialText = "Call mom"
        speech.onTranscriptChange?()
        XCTAssertEqual(model.transcriptPartial, "Call mom")

        speech.committedText = "Call mom"
        speech.partialText = ""
        speech.onTranscriptChange?()
        speech.onTurnEnded?()
        await model.flushPendingSave()

        XCTAssertEqual(model.state, .confirming)
        XCTAssertEqual(model.transcriptText.lowercased(), "call mom")
        XCTAssertNil(model.speechFact)
        XCTAssertTrue(eventKit.reminderTitles.isEmpty)
        XCTAssertEqual(model.pendingIntent?.destination, .reminder)
    }

    func testEmptySilenceReturnsIdleWithNothingCaptured() async {
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
        XCTAssertEqual(model.state, .listening)

        speech.committedText = ""
        speech.partialText = ""
        speech.onTurnEnded?()

        XCTAssertEqual(model.state, .idle)
        XCTAssertEqual(model.speechFact, SpeechCopy.nothingCaptured)
        XCTAssertTrue(model.transcriptText.isEmpty)
    }

    func testNeededPermissionDoesNotStartSpeech() async {
        let speech = FakeSpeechService()
        let permissions = FakePermissionsService()
        permissions.speech = .needed
        let model = CaptureViewModel(
            speech: speech,
            permissions: permissions,
            eventKit: FakeEventKitService(),
            synth: FakeSpeechSynth()
        )
        model.applySession(isSignedIn: true)
        model.tapWell()
        await model.flushPendingListen()

        XCTAssertEqual(model.state, .idle)
        XCTAssertEqual(speech.startCount, 0)
        XCTAssertEqual(model.speechFact, SpeechCopy.notAllowedYet)
    }

    func testSignedOutTapDoesNotListen() {
        let speech = FakeSpeechService()
        let model = CaptureViewModel(
            speech: speech,
            permissions: FakePermissionsService(),
            eventKit: FakeEventKitService(),
            synth: FakeSpeechSynth()
        )
        model.tapWell()
        XCTAssertEqual(model.state, .signedOut)
        XCTAssertEqual(speech.startCount, 0)
    }

    func testLevelFeedsTheWellThenClearsOnSilence() async {
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

        speech.onLevelChange?(0.7)
        XCTAssertEqual(model.listenLevel, 0.7, accuracy: 0.001)

        speech.onTurnEnded?()
        XCTAssertEqual(model.listenLevel, 0)
        XCTAssertEqual(model.state, .idle)
    }
}
