import XCTest
@testable import Murmur

final class ClarificationMergeTests: XCTestCase {
    private let parser = ParsingService()

    func testDestinationRemindersAndCalendar() {
        let pending = ParsedIntent(
            rawTranscript: "buy groceries on Friday",
            taskText: "buy groceries",
            date: Date(),
            needsClarification: true,
            clarificationKind: .destination
        )
        let reminders = ClarificationMerge.merging("Reminders", into: pending, parser: parser)
        XCTAssertEqual(reminders.destination, .reminder)
        XCTAssertEqual(reminders.taskText, "buy groceries")
        XCTAssertFalse(reminders.needsClarification)

        let calendar = ClarificationMerge.merging("Calendar", into: pending, parser: parser)
        XCTAssertEqual(calendar.destination, .event)
    }

    func testDateAnswerFillsDateAndKeepsTitle() {
        let pending = ParsedIntent(
            rawTranscript: "call mom later",
            taskText: "call mom later",
            needsClarification: true,
            clarificationKind: .date
        )
        let merged = ClarificationMerge.merging("tomorrow", into: pending, parser: parser)
        XCTAssertEqual(merged.taskText, "call mom later")
        XCTAssertNotNil(merged.date)
        XCTAssertFalse(merged.hasExplicitTime)
        XCTAssertTrue(isTomorrow(merged.date))
    }

    func testTimeAnswerOverlaysClockOnExistingDay() {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date()))!
        let pending = ParsedIntent(
            rawTranscript: "meeting tomorrow",
            taskText: "meeting",
            date: tomorrow,
            needsClarification: true,
            clarificationKind: .time,
            destination: .event
        )
        let merged = ClarificationMerge.merging("3pm", into: pending, parser: parser)
        XCTAssertTrue(merged.hasExplicitTime)
        XCTAssertEqual(merged.destination, .event)
        XCTAssertTrue(calendar.isDate(merged.date ?? Date.distantPast, inSameDayAs: tomorrow))
        XCTAssertEqual(calendar.component(.hour, from: merged.date ?? Date.distantPast), 15)
    }

    func testGarbledAnswerReplacesTheUtterance() {
        let pending = ParsedIntent(
            rawTranscript: "",
            taskText: "",
            needsClarification: true,
            clarificationKind: .garbled
        )
        let merged = ClarificationMerge.merging("call mom", into: pending, parser: parser)
        XCTAssertEqual(merged.taskText.lowercased(), "call mom")
        XCTAssertNil(merged.date)
    }

    private func isTomorrow(_ date: Date?) -> Bool {
        guard let date else { return false }
        let calendar = Calendar.current
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) else { return false }
        return calendar.isDate(date, inSameDayAs: tomorrow)
    }
}
