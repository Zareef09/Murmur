import SwiftData
import XCTest
@testable import Murmur

final class ContinuationPhraseTests: XCTestCase {
    func testJoiningWordsSuggestMore() {
        XCTAssertTrue(ContinuationPhrase.suggestsMore("call mom and"))
        XCTAssertTrue(ContinuationPhrase.suggestsMore("call mom then gym"))
        XCTAssertTrue(ContinuationPhrase.suggestsMore("gym at 7, dinner at 8"))
        XCTAssertTrue(ContinuationPhrase.suggestsMore("dinner also drinks"))
    }

    func testPlainTurnDoesNotSuggestMore() {
        XCTAssertFalse(ContinuationPhrase.suggestsMore("call mom at five"))
        XCTAssertFalse(ContinuationPhrase.suggestsMore("buy milk"))
    }

    /// "and" inside a word must not hold the microphone open.
    func testSubstringsDoNotCount() {
        XCTAssertFalse(ContinuationPhrase.suggestsMore("understand the brief"))
        XCTAssertFalse(ContinuationPhrase.suggestsMore("sandwich"))
    }

    func testWindowWidensOnceAndStays() {
        var watch = SilenceWatch()
        let voiced = Date(timeIntervalSince1970: 1_800_000_000)
        watch.heardVoice(at: voiced)
        XCTAssertTrue(watch.shouldStop(now: voiced.addingTimeInterval(1.5)))

        watch.allowLongerPause()
        XCTAssertTrue(watch.isWaitingForMore)
        XCTAssertFalse(watch.shouldStop(now: voiced.addingTimeInterval(1.5)))
        XCTAssertFalse(watch.shouldStop(now: voiced.addingTimeInterval(3.9)))
        XCTAssertTrue(watch.shouldStop(now: voiced.addingTimeInterval(4)))
    }
}

@MainActor
final class ListeningTapTests: XCTestCase {
    /// Tapping mid-turn keeps what was said rather than throwing it away.
    func testTapWhileListeningEndsTheTurnAndKeepsTheWords() async throws {
        let speech = FakeSpeechService()
        let container = try Persistence.makeContainer(inMemory: true)
        let model = CaptureViewModel(
            speech: speech,
            permissions: FakePermissionsService(),
            eventKit: FakeEventKitService(),
            synth: FakeSpeechSynth(),
            modelContext: container.mainContext
        )
        model.applySession(isSignedIn: true)
        model.tapWell()
        await model.flushPendingListen()
        XCTAssertEqual(model.state, .listening)

        // Partial only: the recogniser has not finalised, which is the realistic mid-sentence case.
        speech.partialText = "call mom"
        model.tapWell()
        await model.flushPendingSave()
        await model.flushPendingSpeak()

        XCTAssertEqual(model.state, .confirming)
        XCTAssertEqual(model.pendingIntent?.taskText, "call mom")
    }

    func testTapWhileListeningWithNothingSaidReturnsToIdle() async throws {
        let speech = FakeSpeechService()
        let container = try Persistence.makeContainer(inMemory: true)
        let model = CaptureViewModel(
            speech: speech,
            permissions: FakePermissionsService(),
            eventKit: FakeEventKitService(),
            synth: FakeSpeechSynth(),
            modelContext: container.mainContext
        )
        model.applySession(isSignedIn: true)
        model.tapWell()
        await model.flushPendingListen()

        model.tapWell()
        await model.flushPendingSave()

        XCTAssertEqual(model.state, .idle)
        XCTAssertEqual(model.speechFact, SpeechCopy.nothingCaptured)
    }

    func testWaitingForMoreTracksJoiningWords() async throws {
        let speech = FakeSpeechService()
        let container = try Persistence.makeContainer(inMemory: true)
        let model = CaptureViewModel(
            speech: speech,
            permissions: FakePermissionsService(),
            eventKit: FakeEventKitService(),
            synth: FakeSpeechSynth(),
            modelContext: container.mainContext
        )
        model.applySession(isSignedIn: true)
        model.tapWell()
        await model.flushPendingListen()

        speech.partialText = "call mom"
        speech.onTranscriptChange?()
        XCTAssertFalse(model.isWaitingForMore)

        speech.partialText = "call mom and"
        speech.onTranscriptChange?()
        XCTAssertTrue(model.isWaitingForMore)
    }
}

final class CaptureCopyGuidanceTests: XCTestCase {
    func testFootHintTeachesTheJoiningWords() {
        XCTAssertTrue(CaptureCopy.multiHint.contains("and"))
        XCTAssertTrue(CaptureCopy.multiHint.contains("then"))
    }

    func testListeningCaptionTellsYouHowToStop() {
        XCTAssertTrue(CaptureCopy.listeningCaption.lowercased().contains("tap"))
    }

    func testWordmarkIsCapitalised() {
        XCTAssertEqual(Wordmark.text, "Murmur")
    }

    func testCopyStaysQuiet() {
        for line in CaptureCopy.allLines + RoutingCopy.allLines {
            let lower = line.lowercased()
            XCTAssertFalse(line.contains("!"))
            XCTAssertFalse(lower.contains("error"))
            XCTAssertFalse(lower.contains("failed"))
            XCTAssertFalse(lower.contains("invalid"))
            XCTAssertFalse(LoggingPolicy.looksLikeBannedContent(line))
        }
    }
}
