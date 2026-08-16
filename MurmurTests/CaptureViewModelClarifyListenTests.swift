import SwiftData
import XCTest
@testable import Murmur

@MainActor
final class CaptureViewModelClarifyListenTests: XCTestCase {
    func testUnsureSpeaksThenListensOnce() async throws {
        let speech = FakeSpeechService()
        let synth = FakeSpeechSynth()
        let eventKit = FakeEventKitService()
        let container = try Persistence.makeContainer(inMemory: true)
        let model = CaptureViewModel(
            speech: speech,
            permissions: FakePermissionsService(),
            eventKit: eventKit,
            synth: synth,
            modelContext: container.mainContext
        )
        model.applySession(isSignedIn: true)
        model.tapWell()
        await model.flushPendingListen()
        speech.committedText = "call mom later"
        speech.onTurnEnded?()
        await model.flushPendingSave()
        await model.flushPendingSpeak()

        XCTAssertEqual(synth.spoken, [ClarifyCopy.when])
        XCTAssertEqual(speech.startCount, 2)
        XCTAssertTrue(model.showsClarification)
        XCTAssertEqual(model.state, .listening)
        XCTAssertEqual(model.pendingIntent?.clarificationKind, .date)
        XCTAssertEqual(model.speechFact, ClarifyCopy.when)
    }

    func testAnswerGoesToConfirmWithoutASecondQuestion() async throws {
        let speech = FakeSpeechService()
        let synth = FakeSpeechSynth()
        let container = try Persistence.makeContainer(inMemory: true)
        let model = CaptureViewModel(
            speech: speech,
            permissions: FakePermissionsService(),
            eventKit: FakeEventKitService(),
            synth: synth,
            modelContext: container.mainContext
        )
        model.applySession(isSignedIn: true)
        model.tapWell()
        await model.flushPendingListen()
        speech.committedText = "call mom later"
        speech.onTurnEnded?()
        await model.flushPendingSave()
        await model.flushPendingSpeak()

        speech.committedText = "tomorrow"
        speech.onTurnEnded?()
        await model.flushPendingSave()

        XCTAssertEqual(synth.spoken, [ClarifyCopy.when])
        XCTAssertEqual(model.clarificationAnswer, "tomorrow")
        XCTAssertEqual(model.state, .confirming)
        XCTAssertTrue(
            model.pendingIntent?.taskText.lowercased().contains("mom") == true,
            model.pendingIntent?.taskText ?? ""
        )
        XCTAssertNotNil(model.pendingIntent?.date)
        XCTAssertEqual(synth.spoken.count, 1)
    }

    func testEmptyClarifyListenDoesNotSpeakAgain() async throws {
        let speech = FakeSpeechService()
        let synth = FakeSpeechSynth()
        let model = CaptureViewModel(
            speech: speech,
            permissions: FakePermissionsService(),
            eventKit: FakeEventKitService(),
            synth: synth
        )
        model.applySession(isSignedIn: true)
        model.tapWell()
        await model.flushPendingListen()
        speech.committedText = "call mom later"
        speech.onTurnEnded?()
        await model.flushPendingSave()
        await model.flushPendingSpeak()

        speech.committedText = ""
        speech.onTurnEnded?()

        XCTAssertEqual(synth.spoken, [ClarifyCopy.when])
        XCTAssertEqual(model.state, .clarifying)
        XCTAssertEqual(model.speechFact, ClarifyCopy.when)
        XCTAssertNil(model.clarificationAnswer)
    }

    func testTapFallbackGoesToConfirm() async throws {
        let speech = FakeSpeechService()
        let synth = FakeSpeechSynth()
        let model = CaptureViewModel(
            speech: speech,
            permissions: FakePermissionsService(),
            eventKit: FakeEventKitService(),
            synth: synth
        )
        model.applySession(isSignedIn: true)
        model.tapWell()
        await model.flushPendingListen()
        speech.committedText = "buy groceries on Friday"
        speech.onTurnEnded?()
        await model.flushPendingSave()
        await model.flushPendingSpeak()

        XCTAssertTrue(model.showsClarification)
        model.tapClarificationAnswer("Reminders")

        XCTAssertEqual(model.clarificationAnswer, "Reminders")
        XCTAssertEqual(model.state, .confirming)
        XCTAssertFalse(model.showsClarification)
        XCTAssertEqual(model.pendingIntent?.destination, .reminder)
        XCTAssertFalse(model.pendingIntent?.needsClarification ?? true)
        XCTAssertEqual(synth.spoken, [ClarifyCopy.destination])
    }

    func testStartOverReturnsIdle() async throws {
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
        speech.committedText = "call mom later"
        speech.onTurnEnded?()
        await model.flushPendingSave()
        await model.flushPendingSpeak()

        model.startOver()

        XCTAssertEqual(model.state, .idle)
        XCTAssertNil(model.pendingIntent)
        XCTAssertFalse(model.showsClarification)
        XCTAssertTrue(model.transcriptText.isEmpty)
    }

    func testMergeClassifiesOnceThenAlwaysConfirms() async throws {
        let settings = FakeSettingsSync()
        settings.alwaysConfirm = false
        let speech = FakeSpeechService()
        let synth = FakeSpeechSynth()
        let model = CaptureViewModel(
            settingsSync: settings,
            speech: speech,
            permissions: FakePermissionsService(),
            eventKit: FakeEventKitService(),
            synth: synth
        )
        model.applySession(isSignedIn: true)
        model.tapWell()
        await model.flushPendingListen()
        speech.committedText = "meeting tomorrow"
        speech.onTurnEnded?()
        await model.flushPendingSave()
        await model.flushPendingSpeak()

        speech.committedText = "3pm"
        speech.onTurnEnded?()

        XCTAssertEqual(synth.spoken.count, 1)
        XCTAssertEqual(model.state, .confirming)
        XCTAssertEqual(model.pendingIntent?.destination, .event)
        XCTAssertEqual(model.pendingIntent?.hasExplicitTime, true)
        XCTAssertEqual(
            Calendar.current.component(.hour, from: model.pendingIntent?.date ?? .distantPast),
            15
        )
    }

    func testTwoWeekdaysTapMergesThatDay() async throws {
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
        speech.committedText = "call mom Friday or Saturday"
        speech.onTurnEnded?()
        await model.flushPendingSave()
        await model.flushPendingSpeak()

        XCTAssertEqual(model.pendingIntent?.clarificationKind, .date)
        model.tapClarificationAnswer("Saturday")

        XCTAssertEqual(model.state, .confirming)
        XCTAssertEqual(model.clarificationAnswer, "Saturday")
        let weekday = Calendar.current.component(
            .weekday,
            from: model.pendingIntent?.date ?? .distantPast
        )
        XCTAssertEqual(weekday, 7)
    }
}
