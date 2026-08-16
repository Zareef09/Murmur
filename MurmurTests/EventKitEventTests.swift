import EventKit
import XCTest
@testable import Murmur

final class EventSpanTests: XCTestCase {
    func testDefaultDurationIs60Minutes() {
        let start = Date(timeIntervalSince1970: 1_800_086_400)
        let end = EventSpan.end(start: start, durationMinutes: nil)
        XCTAssertEqual(end.timeIntervalSince(start), 60 * 60)
        XCTAssertEqual(EventSpan.defaultMinutes, 60)
    }

    func testDetectedRangeUsesDurationMinutes() {
        let start = Date(timeIntervalSince1970: 1_800_086_400)
        let end = EventSpan.end(start: start, durationMinutes: 120)
        XCTAssertEqual(end.timeIntervalSince(start), 120 * 60)
    }
}

@MainActor
final class EventKitEventAuthTests: XCTestCase {
    func testCreateEventThrowsWhenNotAuthorized() async {
        let service = EventKitService(eventAuthorization: { .denied })
        do {
            _ = try await service.createEvent(
                title: "Lunch with Sam",
                start: Date(),
                durationMinutes: nil
            )
            XCTFail("expected notAuthorized")
        } catch let error as EventKitServiceError {
            XCTAssertEqual(error, .notAuthorized)
            XCTAssertEqual(EventKitCopy.eventFact(for: error), EventKitCopy.calendarAccessNeeded)
            XCTAssertFalse(EventKitCopy.eventFact(for: error).localizedCaseInsensitiveContains("error"))
        } catch {
            XCTFail("unexpected \(error)")
        }
    }

    func testEmptyTitleDoesNotSaveAnEvent() async {
        let service = EventKitService(eventAuthorization: { .fullAccess })
        do {
            _ = try await service.createEvent(title: " ", start: Date(), durationMinutes: 60)
            XCTFail("expected emptyTitle")
        } catch let error as EventKitServiceError {
            XCTAssertEqual(error, .emptyTitle)
        } catch {
            XCTFail("unexpected \(error)")
        }
    }
}
