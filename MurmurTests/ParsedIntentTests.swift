import XCTest
@testable import Murmur

final class ParsedIntentTests: XCTestCase {
    func testSpecFieldsRoundTripByValue() {
        let when = Date(timeIntervalSince1970: 1_800_000_000)
        let intent = ParsedIntent(
            rawTranscript: "remind me to call mom tomorrow at five",
            taskText: "call mom",
            date: when,
            hasExplicitTime: true,
            durationMinutes: 60,
            needsClarification: false,
            clarificationKind: nil
        )
        XCTAssertEqual(intent.rawTranscript, "remind me to call mom tomorrow at five")
        XCTAssertEqual(intent.taskText, "call mom")
        XCTAssertEqual(intent.date, when)
        XCTAssertTrue(intent.hasExplicitTime)
        XCTAssertEqual(intent.durationMinutes, 60)
        XCTAssertFalse(intent.needsClarification)
        XCTAssertNil(intent.clarificationKind)
        XCTAssertEqual(intent, intent)
    }

    func testClarificationKindCoversSpecCases() {
        let kinds: [ClarificationKind] = [.date, .time, .destination, .garbled]
        XCTAssertEqual(kinds.count, 4)
        let garbled = ParsedIntent(
            rawTranscript: "",
            needsClarification: true,
            clarificationKind: .garbled
        )
        XCTAssertTrue(garbled.needsClarification)
        XCTAssertEqual(garbled.clarificationKind, .garbled)
        XCTAssertTrue(garbled.taskText.isEmpty)
        XCTAssertNil(garbled.date)
        XCTAssertFalse(garbled.hasExplicitTime)
    }

    func testDestinationIsReminderOrEventOnly() {
        XCTAssertEqual(CaptureDestination.allCases, [.reminder, .event])
        XCTAssertEqual(CaptureDestination.reminder.rawValue, "reminder")
        XCTAssertEqual(CaptureDestination.event.rawValue, "event")
        let encoded = try? JSONEncoder().encode(CaptureDestination.reminder)
        let decoded = encoded.flatMap { try? JSONDecoder().decode(CaptureDestination.self, from: $0) }
        XCTAssertEqual(decoded, .reminder)
    }
}
