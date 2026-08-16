import SwiftData
import XCTest
@testable import Murmur

@MainActor
final class CaptureViewModelSaveTests: XCTestCase {
    func testCallMomSavesReminderThenHistory() async throws {
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
        await speak("call mom", on: model, speech: speech)

        XCTAssertEqual(model.state, .confirming)
        XCTAssertTrue(eventKit.reminderTitles.isEmpty)
        XCTAssertTrue(try container.mainContext.fetch(FetchDescriptor<Capture>()).isEmpty)

        await model.confirmSave()
        await model.flushPendingSave()

        XCTAssertEqual(eventKit.reminderTitles, ["call mom"])
        XCTAssertTrue(eventKit.eventTitles.isEmpty)
        let rows = try container.mainContext.fetch(FetchDescriptor<Capture>())
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].title, "call mom")
        XCTAssertEqual(rows[0].destination, .reminder)
        XCTAssertEqual(rows[0].eventKitIdentifier, "stored-reminder")
        XCTAssertEqual(model.state, .success)
        XCTAssertEqual(model.successMessage, "Saved to Reminders")
        XCTAssertNil(model.pendingIntent)
        XCTAssertNil(model.speechFact)
    }

    func testCancelLeavesNoHistoryRow() async throws {
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
        await speak("call mom", on: model, speech: speech)
        model.confirmCancel()

        XCTAssertTrue(eventKit.reminderTitles.isEmpty)
        XCTAssertTrue(try container.mainContext.fetch(FetchDescriptor<Capture>()).isEmpty)
        XCTAssertEqual(model.state, .idle)
        XCTAssertNil(model.pendingIntent)
        XCTAssertTrue(model.transcriptText.isEmpty)
    }

    func testDateOnlyAsksDestinationAndDoesNotSave() async throws {
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
        await speak("buy groceries on Friday", on: model, speech: speech)

        XCTAssertTrue(eventKit.reminderTitles.isEmpty)
        XCTAssertTrue(eventKit.eventTitles.isEmpty)
        XCTAssertTrue(try container.mainContext.fetch(FetchDescriptor<Capture>()).isEmpty)
        XCTAssertEqual(model.speechFact, ClarifyCopy.destination)
        XCTAssertEqual(model.state, .listening)
        XCTAssertEqual(model.pendingIntent?.clarificationKind, .destination)
    }

    func testEventKitFailureLeavesNoHistoryRow() async throws {
        let speech = FakeSpeechService()
        let eventKit = FakeEventKitService()
        eventKit.createError = .notAuthorized
        let container = try Persistence.makeContainer(inMemory: true)
        let model = CaptureViewModel(
            speech: speech,
            permissions: FakePermissionsService(),
            eventKit: eventKit,
            synth: FakeSpeechSynth(),
            modelContext: container.mainContext
        )
        await speak("call mom", on: model, speech: speech)
        await model.confirmSave()
        await model.flushPendingSave()

        XCTAssertTrue(try container.mainContext.fetch(FetchDescriptor<Capture>()).isEmpty)
        XCTAssertEqual(model.speechFact, EventKitCopy.remindersAccessNeeded)
        XCTAssertEqual(model.state, .idle)
        XCTAssertNil(model.pendingIntent)
    }

    func testClockTimeSavesCalendarEvent() async throws {
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
        await speak("lunch with Sam at noon", on: model, speech: speech)
        XCTAssertEqual(model.state, .confirming)
        XCTAssertEqual(model.pendingIntent?.destination, .event)

        await model.confirmSave()
        await model.flushPendingSave()

        XCTAssertEqual(eventKit.eventTitles.map { $0.lowercased() }, ["lunch with sam"])
        XCTAssertTrue(eventKit.reminderTitles.isEmpty)
        let rows = try container.mainContext.fetch(FetchDescriptor<Capture>())
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].destination, .event)
        XCTAssertEqual(rows[0].eventKitIdentifier, "stored-event")
        XCTAssertTrue(rows[0].hasExplicitTime)
    }

    func testEditedTitleSavesReminder() async throws {
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
        await speak("call mom", on: model, speech: speech)
        model.pendingIntent?.taskText = "call dad"

        await model.confirmSave()

        XCTAssertEqual(eventKit.reminderTitles, ["call dad"])
        let rows = try container.mainContext.fetch(FetchDescriptor<Capture>())
        XCTAssertEqual(rows[0].title, "call dad")
        XCTAssertEqual(rows[0].destination, .reminder)
    }

    func testDestinationOverrideSavesReminderInsteadOfEvent() async throws {
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
        await speak("lunch with Sam at noon", on: model, speech: speech)
        XCTAssertEqual(model.pendingIntent?.destination, .event)
        model.pendingIntent?.destination = .reminder

        await model.confirmSave()

        XCTAssertEqual(eventKit.reminderTitles.map { $0.lowercased() }, ["lunch with sam"])
        XCTAssertTrue(eventKit.eventTitles.isEmpty)
        let rows = try container.mainContext.fetch(FetchDescriptor<Capture>())
        XCTAssertEqual(rows[0].destination, .reminder)
    }

    func testEditedDateOnlySavesReminderDue() async throws {
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
        await speak("call mom", on: model, speech: speech)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let due = calendar.startOfDay(
            for: calendar.date(from: DateComponents(year: 2026, month: 8, day: 17))!
        )
        model.pendingIntent?.date = due
        model.pendingIntent?.hasExplicitTime = false

        await model.confirmSave()

        XCTAssertEqual(eventKit.reminderDues.count, 1)
        XCTAssertEqual(eventKit.reminderDues[0].0, due)
        XCTAssertFalse(eventKit.reminderDues[0].1)
        let rows = try container.mainContext.fetch(FetchDescriptor<Capture>())
        XCTAssertEqual(rows[0].startDate, due)
        XCTAssertFalse(rows[0].hasExplicitTime)
    }

    func testEditedClockTimeSavesEventStart() async throws {
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
        await speak("lunch with Sam at noon", on: model, speech: speech)
        let start = Date(timeIntervalSince1970: 1_800_000_000)
        model.pendingIntent?.date = start
        model.pendingIntent?.hasExplicitTime = true

        await model.confirmSave()

        XCTAssertEqual(eventKit.eventStarts, [start])
        let rows = try container.mainContext.fetch(FetchDescriptor<Capture>())
        XCTAssertEqual(rows[0].startDate, start)
        XCTAssertTrue(rows[0].hasExplicitTime)
    }

    func testAlwaysConfirmOffSkipsSheetAndSaves() async throws {
        let speech = FakeSpeechService()
        let eventKit = FakeEventKitService()
        let settings = FakeSettingsSync()
        settings.alwaysConfirm = false
        let container = try Persistence.makeContainer(inMemory: true)
        let model = CaptureViewModel(
            settingsSync: settings,
            speech: speech,
            permissions: FakePermissionsService(),
            eventKit: eventKit,
            synth: FakeSpeechSynth(),
            modelContext: container.mainContext
        )
        await speak("call mom", on: model, speech: speech)

        XCTAssertEqual(model.state, .success)
        XCTAssertNil(model.pendingIntent)
        XCTAssertEqual(eventKit.reminderTitles, ["call mom"])
        XCTAssertEqual(try container.mainContext.fetch(FetchDescriptor<Capture>()).count, 1)
    }

    func testAlwaysConfirmOffStillAsksWhenUnsure() async throws {
        let speech = FakeSpeechService()
        let eventKit = FakeEventKitService()
        let settings = FakeSettingsSync()
        settings.alwaysConfirm = false
        let container = try Persistence.makeContainer(inMemory: true)
        let model = CaptureViewModel(
            settingsSync: settings,
            speech: speech,
            permissions: FakePermissionsService(),
            eventKit: eventKit,
            synth: FakeSpeechSynth(),
            modelContext: container.mainContext
        )
        await speak("buy groceries on Friday", on: model, speech: speech)

        XCTAssertEqual(model.state, .listening)
        XCTAssertEqual(model.speechFact, ClarifyCopy.destination)
        XCTAssertTrue(eventKit.reminderTitles.isEmpty)
        XCTAssertTrue(try container.mainContext.fetch(FetchDescriptor<Capture>()).isEmpty)
    }

    func testVagueTimeEntersClarifyingWithWhenQuestion() async throws {
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
        await speak("call mom later", on: model, speech: speech)

        XCTAssertEqual(model.state, .listening)
        XCTAssertEqual(model.speechFact, ClarifyCopy.when)
        XCTAssertEqual(model.pendingIntent?.clarificationKind, .date)
        XCTAssertTrue(eventKit.reminderTitles.isEmpty)
    }

    func testSetAlwaysConfirmWritesThroughSettingsSync() {
        let settings = FakeSettingsSync()
        let model = CaptureViewModel(
            settingsSync: settings,
            speech: FakeSpeechService(),
            permissions: FakePermissionsService(),
            eventKit: FakeEventKitService(),
            synth: FakeSpeechSynth()
        )
        model.applySession(isSignedIn: true)
        XCTAssertTrue(model.alwaysConfirm)

        model.setAlwaysConfirm(false)
        XCTAssertFalse(model.alwaysConfirm)
        XCTAssertFalse(settings.alwaysConfirm)
        XCTAssertEqual(settings.setCount, 1)
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
