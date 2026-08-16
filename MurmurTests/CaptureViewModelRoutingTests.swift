import SwiftData
import XCTest
@testable import Murmur

@MainActor
final class CaptureViewModelRoutingTests: XCTestCase {
    /// The example from the brief: three things in one breath, each routed by hand.
    func testThreePartTurnRoutesEachItemSeparately() async throws {
        let speech = FakeSpeechService()
        let eventKit = FakeEventKitService()
        let container = try Persistence.makeContainer(inMemory: true)
        let model = makeModel(speech: speech, eventKit: eventKit, container: container)

        await speak("Call mom at 5, go to the gym at 7, dinner at 8", on: model, speech: speech)

        XCTAssertEqual(model.state, .routing)
        XCTAssertTrue(model.showsRouting)
        XCTAssertEqual(model.pendingItems.count, 3)

        model.setDestination(.reminder, for: model.pendingItems[0].id)
        model.setDestination(.event, for: model.pendingItems[1].id)
        model.setDestination(.event, for: model.pendingItems[2].id)
        XCTAssertTrue(model.pendingItems.allRouted)

        await model.confirmRoutedSave()

        XCTAssertEqual(eventKit.reminderTitles.count, 1)
        XCTAssertEqual(eventKit.eventTitles.count, 2)
        let rows = try container.mainContext.fetch(FetchDescriptor<Capture>())
        XCTAssertEqual(rows.count, 3)
        XCTAssertEqual(rows.filter { $0.destination == .reminder }.count, 1)
        XCTAssertEqual(rows.filter { $0.destination == .event }.count, 2)
        XCTAssertEqual(model.state, .success)
        XCTAssertEqual(model.successMessage, "Saved 3 things")
        XCTAssertTrue(model.pendingItems.isEmpty)
    }

    func testSingleCaptureStillUsesConfirmation() async throws {
        let speech = FakeSpeechService()
        let container = try Persistence.makeContainer(inMemory: true)
        let model = makeModel(speech: speech, eventKit: FakeEventKitService(), container: container)

        await speak("call mom", on: model, speech: speech)

        XCTAssertEqual(model.state, .confirming)
        XCTAssertFalse(model.showsRouting)
        XCTAssertTrue(model.pendingItems.isEmpty)
    }

    /// Nothing saves while any row is still unrouted.
    func testSaveIsRefusedUntilEveryItemHasAPlace() async throws {
        let speech = FakeSpeechService()
        let eventKit = FakeEventKitService()
        let container = try Persistence.makeContainer(inMemory: true)
        let model = makeModel(speech: speech, eventKit: eventKit, container: container)

        await speak("call mom at 5, gym at 7", on: model, speech: speech)
        XCTAssertEqual(model.state, .routing)

        model.pendingItems[0].destination = nil
        XCTAssertFalse(model.pendingItems.allRouted)

        await model.confirmRoutedSave()

        XCTAssertEqual(model.state, .routing)
        XCTAssertTrue(eventKit.reminderTitles.isEmpty)
        XCTAssertTrue(eventKit.eventTitles.isEmpty)
    }

    func testUndoTakesBackEveryRoutedItem() async throws {
        let speech = FakeSpeechService()
        let eventKit = FakeEventKitService()
        let container = try Persistence.makeContainer(inMemory: true)
        let model = makeModel(speech: speech, eventKit: eventKit, container: container)

        await speak("call mom at 5, gym at 7", on: model, speech: speech)
        for item in model.pendingItems {
            model.setDestination(.reminder, for: item.id)
        }
        await model.confirmRoutedSave()
        XCTAssertEqual(model.state, .success)

        await model.undoSave()

        XCTAssertEqual(eventKit.deletedIdentifiers.count, 2)
        let rows = try container.mainContext.fetch(FetchDescriptor<Capture>())
        XCTAssertTrue(rows.isEmpty)
        XCTAssertEqual(model.state, .idle)
    }

    func testStartOverDropsTheRoutedItems() async throws {
        let speech = FakeSpeechService()
        let container = try Persistence.makeContainer(inMemory: true)
        let model = makeModel(speech: speech, eventKit: FakeEventKitService(), container: container)

        await speak("call mom at 5, gym at 7", on: model, speech: speech)
        XCTAssertEqual(model.state, .routing)

        model.routingCancel()

        XCTAssertEqual(model.state, .idle)
        XCTAssertTrue(model.pendingItems.isEmpty)
        XCTAssertFalse(model.showsRouting)
    }

    private func makeModel(
        speech: FakeSpeechService,
        eventKit: FakeEventKitService,
        container: ModelContainer
    ) -> CaptureViewModel {
        CaptureViewModel(
            speech: speech,
            permissions: FakePermissionsService(),
            eventKit: eventKit,
            synth: FakeSpeechSynth(),
            modelContext: container.mainContext
        )
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
