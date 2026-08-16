import SwiftData
import XCTest
@testable import Murmur

@MainActor
final class HistoryDeleteTests: XCTestCase {
    func testCopyMatchesSpec() {
        XCTAssertEqual(HistoryCopy.murmurOnly, "Delete from Murmur only")
        XCTAssertEqual(HistoryCopy.alsoExternal(for: .reminder), "Also delete the reminder")
        XCTAssertEqual(HistoryCopy.alsoExternal(for: .event), "Also delete the event")
        XCTAssertFalse(HistoryCopy.murmurOnly.localizedCaseInsensitiveContains("error"))
        XCTAssertFalse(HistoryCopy.deleteNeeded.localizedCaseInsensitiveContains("error"))
    }

    func testMurmurOnlyLeavesEventKitUntouched() async throws {
        let container = try Persistence.makeContainer(inMemory: true)
        let context = container.mainContext
        let eventKit = FakeEventKitService()
        let row = Capture(
            title: "Call mom",
            destination: .reminder,
            eventKitIdentifier: "stored-reminder"
        )
        context.insert(row)
        try context.save()

        try await HistoryDelete.apply(row, scope: .murmurOnly, context: context, eventKit: eventKit)

        XCTAssertTrue(eventKit.deletedIdentifiers.isEmpty)
        XCTAssertTrue(try context.fetch(FetchDescriptor<Capture>()).isEmpty)
    }

    func testAlsoExternalDeletesEventKitThenTheRow() async throws {
        let container = try Persistence.makeContainer(inMemory: true)
        let context = container.mainContext
        let eventKit = FakeEventKitService()
        let row = Capture(
            title: "Lunch",
            destination: .event,
            eventKitIdentifier: "stored-event"
        )
        context.insert(row)
        try context.save()

        try await HistoryDelete.apply(row, scope: .alsoExternal, context: context, eventKit: eventKit)

        XCTAssertEqual(eventKit.deletedIdentifiers, ["stored-event"])
        XCTAssertTrue(try context.fetch(FetchDescriptor<Capture>()).isEmpty)
    }

    func testAlsoExternalFailureLeavesTheRow() async throws {
        let container = try Persistence.makeContainer(inMemory: true)
        let context = container.mainContext
        let eventKit = FakeEventKitService()
        eventKit.deleteError = .notAuthorized
        let row = Capture(
            title: "Call mom",
            destination: .reminder,
            eventKitIdentifier: "stored-reminder"
        )
        context.insert(row)
        try context.save()

        do {
            try await HistoryDelete.apply(row, scope: .alsoExternal, context: context, eventKit: eventKit)
            XCTFail("expected notAuthorized")
        } catch let error as EventKitServiceError {
            XCTAssertEqual(error, .notAuthorized)
        }

        XCTAssertEqual(try context.fetch(FetchDescriptor<Capture>()).count, 1)
    }

    func testAlsoExternalWithNoIdentifierOnlyRemovesTheRow() async throws {
        let container = try Persistence.makeContainer(inMemory: true)
        let context = container.mainContext
        let eventKit = FakeEventKitService()
        let row = Capture(title: "Buy milk", destination: .reminder)
        context.insert(row)
        try context.save()

        try await HistoryDelete.apply(row, scope: .alsoExternal, context: context, eventKit: eventKit)

        XCTAssertTrue(eventKit.deletedIdentifiers.isEmpty)
        XCTAssertTrue(try context.fetch(FetchDescriptor<Capture>()).isEmpty)
    }
}
