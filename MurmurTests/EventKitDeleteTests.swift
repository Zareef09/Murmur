import XCTest
@testable import Murmur

@MainActor
final class EventKitDeleteTests: XCTestCase {
    func testEmptyIdentifierDoesNotScanTheLibrary() async {
        let service = EventKitService(
            reminderAuthorization: { .fullAccess },
            eventAuthorization: { .fullAccess }
        )
        do {
            try await service.deleteItem(identifier: "  ")
            XCTFail("expected missingIdentifier")
        } catch let error as EventKitServiceError {
            XCTAssertEqual(error, .missingIdentifier)
            let fact = EventKitCopy.reminderFact(for: error)
            XCTAssertEqual(fact, EventKitCopy.nothingToRemove)
            XCTAssertFalse(fact.localizedCaseInsensitiveContains("error"))
            XCTAssertFalse(LoggingPolicy.looksLikeBannedContent(LoggingPolicy.message(for: .itemDeleted)))
        } catch {
            XCTFail("unexpected \(error)")
        }
    }

    func testUnknownIdentifierIsIdempotent() async {
        let service = EventKitService(
            reminderAuthorization: { .denied },
            eventAuthorization: { .denied }
        )
        do {
            try await service.deleteItem(identifier: "not-a-stored-item")
        } catch {
            XCTFail("missing item should not throw \(error)")
        }
    }
}
