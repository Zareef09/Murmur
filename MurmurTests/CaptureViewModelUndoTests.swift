import SwiftData
import XCTest
@testable import Murmur

final class SuccessCopyTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.locale = Locale(identifier: "en_US")
        return calendar
    }

    private var now: Date {
        calendar.date(from: DateComponents(year: 2026, month: 8, day: 16, hour: 12))!
    }

    func testSavedToRemindersWithoutADate() {
        XCTAssertEqual(
            SuccessCopy.message(destination: .reminder, date: nil, hasExplicitTime: false),
            "Saved to Reminders"
        )
        XCTAssertEqual(SuccessCopy.caption, "Saved")
        XCTAssertEqual(SuccessCopy.undo, "Undo")
        XCTAssertEqual(MurmurMotion.undoWindow, 5)
        XCTAssertFalse(SuccessCopy.caption.localizedCaseInsensitiveContains("done"))
        XCTAssertFalse(SuccessCopy.caption.contains("!"))
    }

    func testSavedToCalendarIncludesWhen() {
        let start = calendar.date(from: DateComponents(year: 2026, month: 8, day: 17, hour: 17))!
        let text = SuccessCopy.message(
            destination: .event,
            date: start,
            hasExplicitTime: true,
            now: now,
            calendar: calendar
        )
        XCTAssertTrue(text.hasPrefix("Saved to Calendar · "))
        XCTAssertTrue(text.contains("Tomorrow"))
    }
}

@MainActor
final class CaptureViewModelUndoTests: XCTestCase {
    func testSaveLandsOnSuccessThenIdleAfterTheWindow() async throws {
        let speech = FakeSpeechService()
        let eventKit = FakeEventKitService()
        let container = try Persistence.makeContainer(inMemory: true)
        let model = CaptureViewModel(
            speech: speech,
            permissions: FakePermissionsService(),
            eventKit: eventKit,
            synth: FakeSpeechSynth(),
            modelContext: container.mainContext,
            undoWindow: 0.05
        )
        await speak("call mom", on: model, speech: speech)
        await model.confirmSave()
        await model.flushPendingSave()

        XCTAssertEqual(model.state, .success)
        XCTAssertEqual(model.successMessage, "Saved to Reminders")

        await model.flushPendingSuccess()

        XCTAssertEqual(model.state, .idle)
        XCTAssertNil(model.successMessage)
        XCTAssertEqual(eventKit.deletedIdentifiers, [])
        XCTAssertEqual(try container.mainContext.fetch(FetchDescriptor<Capture>()).count, 1)
    }

    func testUndoRemovesEventKitAndHistory() async throws {
        let speech = FakeSpeechService()
        let eventKit = FakeEventKitService()
        let container = try Persistence.makeContainer(inMemory: true)
        let model = CaptureViewModel(
            speech: speech,
            permissions: FakePermissionsService(),
            eventKit: eventKit,
            synth: FakeSpeechSynth(),
            modelContext: container.mainContext,
            undoWindow: 30
        )
        await speak("call mom", on: model, speech: speech)
        await model.confirmSave()
        await model.flushPendingSave()

        await model.undoSave()

        XCTAssertEqual(model.state, .idle)
        XCTAssertEqual(eventKit.deletedIdentifiers, ["stored-reminder"])
        XCTAssertTrue(try container.mainContext.fetch(FetchDescriptor<Capture>()).isEmpty)
        XCTAssertNil(model.successMessage)
    }

    private func speak(
        _ text: String,
        on model: CaptureViewModel,
        speech: FakeSpeechService
    ) async {
        model.applySession(isSignedIn: true)
        model.tapWell()
        await model.flushPendingListen()
        speech.committedText = text
        speech.onTurnEnded?()
        await model.flushPendingSave()
        await model.flushPendingSpeak()
    }
}
