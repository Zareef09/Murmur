import XCTest
import SwiftData
@testable import Murmur

@MainActor
final class HistoryPurgeServiceTests: XCTestCase {
    func testPurgeRemovesRowsOlderThan72HoursAndKeepsNewer() throws {
        let container = try Persistence.makeContainer(inMemory: true)
        let context = container.mainContext
        let now = Date(timeIntervalSince1970: 1_800_000_000)

        let stale = Capture(
            title: "stale",
            destination: .reminder,
            eventKitIdentifier: "ek-stale",
            createdAt: now.addingTimeInterval(-HistoryPurgeService.ttl - 1)
        )
        let atCutoff = Capture(
            title: "cutoff",
            destination: .event,
            eventKitIdentifier: "ek-cutoff",
            createdAt: HistoryPurgeService.cutoff(now: now)
        )
        let fresh = Capture(
            title: "fresh",
            destination: .reminder,
            createdAt: now.addingTimeInterval(-71 * 60 * 60)
        )
        context.insert(stale)
        context.insert(atCutoff)
        context.insert(fresh)
        try context.save()

        let spy = EventKitDeleteSpy()
        let removed = try HistoryPurgeService.purgeExpired(in: context, now: now)

        XCTAssertEqual(removed, 1)
        let left = try context.fetch(FetchDescriptor<Capture>())
        XCTAssertEqual(Set(left.map(\.id)), Set([atCutoff.id, fresh.id]))
        XCTAssertEqual(spy.deleteCount, 0)
    }

    func testSaveAndPurgeHistoryDropsExpiredAfterSave() throws {
        let container = try Persistence.makeContainer(inMemory: true)
        let context = container.mainContext
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        context.insert(
            Capture(
                title: "old",
                destination: .reminder,
                createdAt: now.addingTimeInterval(-HistoryPurgeService.ttl - 60)
            )
        )
        try context.saveAndPurgeHistory(now: now)
        XCTAssertTrue(try context.fetch(FetchDescriptor<Capture>()).isEmpty)
    }
}

@MainActor
private final class EventKitDeleteSpy: EventKitServicing {
    var deleteCount = 0

    func createReminder(title: String, due: Date?, hasExplicitTime: Bool) async throws -> String { "" }
    func createEvent(title: String, start: Date, durationMinutes: Int?) async throws -> String { "" }
    func deleteItem(identifier: String) async throws { deleteCount += 1 }
    func openingURL(identifier: String, destination: CaptureDestination) throws -> URL {
        EventKitDeepLink.reminders
    }
}
