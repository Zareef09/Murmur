import SwiftData
import XCTest
@testable import Murmur

final class HistoryListFormatTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.locale = Locale(identifier: "en_US")
        return calendar
    }

    private var now: Date {
        calendar.date(from: DateComponents(year: 2026, month: 8, day: 16, hour: 12))!
    }

    func testCopyMatchesKit() {
        XCTAssertEqual(HistoryCopy.title, "History")
        XCTAssertEqual(HistoryCopy.emptyTitle, "Nothing captured yet")
        XCTAssertEqual(HistoryCopy.emptyBody, "Tap the well on the home screen and say the thing you keep almost forgetting.")
        XCTAssertEqual(HistoryCopy.captureAction, "Capture something")
        XCTAssertEqual(HistoryCopy.swipeHint, "Tap a row to swipe it aside, then delete.")
        XCTAssertEqual(HistoryCopy.ttlNote, "Murmur keeps three days here.")
    }

    func testSectionTitleTodayYesterdayAndOlder() {
        XCTAssertEqual(HistoryListFormat.sectionTitle(createdAt: now, now: now, calendar: calendar), HistoryCopy.today)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        XCTAssertEqual(
            HistoryListFormat.sectionTitle(createdAt: yesterday, now: now, calendar: calendar),
            HistoryCopy.yesterday
        )
        let friday = calendar.date(from: DateComponents(year: 2026, month: 8, day: 14, hour: 9))!
        XCTAssertEqual(
            HistoryListFormat.sectionTitle(createdAt: friday, now: now, calendar: calendar),
            "Fri, Aug 14"
        )
    }

    func testRelativeUsesHoursOnTheSameDay() {
        let twoHoursAgo = now.addingTimeInterval(-2 * 60 * 60)
        XCTAssertEqual(HistoryListFormat.relative(createdAt: twoHoursAgo, now: now, calendar: calendar), "2h ago")
        let twelveMinutesAgo = now.addingTimeInterval(-12 * 60)
        XCTAssertEqual(HistoryListFormat.relative(createdAt: twelveMinutesAgo, now: now, calendar: calendar), "12m ago")
        XCTAssertEqual(HistoryListFormat.relative(createdAt: now, now: now, calendar: calendar), HistoryCopy.justNow)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        XCTAssertEqual(
            HistoryListFormat.relative(createdAt: yesterday, now: now, calendar: calendar),
            HistoryCopy.yesterday
        )
    }

    @MainActor
    func testNewestFirstFetchAndDayGroups() throws {
        let container = try Persistence.makeContainer(inMemory: true)
        let context = container.mainContext
        let older = Capture(title: "older", destination: .reminder, createdAt: now.addingTimeInterval(-9 * 60 * 60))
        let newer = Capture(title: "newer", destination: .event, createdAt: now.addingTimeInterval(-2 * 60 * 60))
        let yesterday = Capture(
            title: "yesterday",
            destination: .reminder,
            createdAt: calendar.date(byAdding: .day, value: -1, to: now)!
        )
        context.insert(older)
        context.insert(yesterday)
        context.insert(newer)
        try context.save()

        let descriptor = FetchDescriptor<Capture>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let rows = try context.fetch(descriptor)
        XCTAssertEqual(rows.map(\.title), ["newer", "older", "yesterday"])

        let sections = HistoryListFormat.grouped(rows, now: now, calendar: calendar)
        XCTAssertEqual(sections.map(\.title), [HistoryCopy.today, HistoryCopy.yesterday])
        XCTAssertEqual(sections[0].items.map(\.title), ["newer", "older"])
        XCTAssertEqual(sections[1].items.map(\.title), ["yesterday"])
    }
}
