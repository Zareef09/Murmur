import XCTest
@testable import Murmur

/// Session 64 — wider §6.3 table. Date-only / no-keyword still asks destination.
final class ClassificationTableTests: XCTestCase {
    private let parser = ParsingService()
    private let classify = ClassificationService()
    private let day = Date(timeIntervalSince1970: 1_800_086_400)

    func testKeywordTable() {
        XCTAssertFalse(EventKeyword.contains("call mom"))
        XCTAssertTrue(EventKeyword.contains("call with dana"))
        XCTAssertTrue(EventKeyword.contains("lunch with sam"))
        XCTAssertTrue(EventKeyword.contains("dinner with alex"))
        XCTAssertTrue(EventKeyword.contains("the meeting"))
        XCTAssertTrue(EventKeyword.contains("dentist appointment"))
        XCTAssertTrue(EventKeyword.contains("interview at noon"))
        XCTAssertFalse(EventKeyword.contains("buy milk"))
    }

    func testVagueTable() {
        XCTAssertTrue(VagueTime.contains("call mom later"))
        XCTAssertTrue(VagueTime.contains("do this soon"))
        XCTAssertTrue(VagueTime.contains("sometime"))
        XCTAssertTrue(VagueTime.contains("this week"))
        XCTAssertTrue(VagueTime.contains("next week"))
        XCTAssertFalse(VagueTime.contains("this friday"))
        XCTAssertFalse(VagueTime.contains("call mom tomorrow"))
    }

    func testConstructedRows() {
        let rows: [(ParsedIntent, CaptureDestination?, ClarificationKind?)] = [
            (ParsedIntent(rawTranscript: "walk the dog", taskText: "walk the dog"), .reminder, nil),
            (ParsedIntent(rawTranscript: "pay rent", taskText: "pay rent"), .reminder, nil),
            (ParsedIntent(rawTranscript: "email Dana", taskText: "email Dana"), .reminder, nil),
            (
                ParsedIntent(
                    rawTranscript: "dentist tomorrow at 9am",
                    taskText: "dentist",
                    date: day,
                    hasExplicitTime: true
                ),
                .event,
                nil
            ),
            (
                ParsedIntent(
                    rawTranscript: "lunch with Sam at noon",
                    taskText: "lunch with Sam",
                    date: day,
                    hasExplicitTime: true
                ),
                .event,
                nil
            ),
            (
                ParsedIntent(
                    rawTranscript: "call with Alex tomorrow at 4",
                    taskText: "call with Alex",
                    date: day,
                    hasExplicitTime: true
                ),
                .event,
                nil
            ),
            (
                ParsedIntent(
                    rawTranscript: "appointment Friday 2pm",
                    taskText: "appointment",
                    date: day,
                    hasExplicitTime: true
                ),
                .event,
                nil
            ),
            (
                ParsedIntent(
                    rawTranscript: "interview tomorrow",
                    taskText: "interview",
                    date: day,
                    hasExplicitTime: false
                ),
                .event,
                .time
            ),
            (
                ParsedIntent(
                    rawTranscript: "dinner with Sam",
                    taskText: "dinner with Sam",
                    hasExplicitTime: false
                ),
                .event,
                .time
            ),
            (
                ParsedIntent(
                    rawTranscript: "coffee with Jordan Friday",
                    taskText: "coffee with Jordan",
                    date: day,
                    hasExplicitTime: false
                ),
                .event,
                .time
            ),
            (
                ParsedIntent(
                    rawTranscript: "call mom tomorrow",
                    taskText: "call mom",
                    date: day,
                    hasExplicitTime: false
                ),
                nil,
                .destination
            ),
            (
                ParsedIntent(
                    rawTranscript: "take out trash tonight",
                    taskText: "take out trash",
                    date: day,
                    hasExplicitTime: false
                ),
                nil,
                .destination
            ),
            (ParsedIntent(rawTranscript: "call mom soon", taskText: "call mom soon"), nil, .date),
            (ParsedIntent(rawTranscript: "file this sometime", taskText: "file this sometime"), nil, .date),
            (ParsedIntent(rawTranscript: "next week", taskText: "week"), nil, .date),
            (ParsedIntent(rawTranscript: "", taskText: "", needsClarification: true, clarificationKind: .garbled), nil, .garbled)
        ]

        for (input, destination, kind) in rows {
            let out = classify.classify(input)
            XCTAssertEqual(out.destination, destination, input.rawTranscript)
            XCTAssertEqual(out.clarificationKind, kind, input.rawTranscript)
            XCTAssertEqual(out.needsClarification, kind != nil, input.rawTranscript)
            if kind == nil {
                XCTAssertGreaterThanOrEqual(out.confidence, 0.8, input.rawTranscript)
            } else {
                XCTAssertLessThan(out.confidence, 0.5, input.rawTranscript)
            }
        }
    }

    func testParseThenClassifySpokenPhrases() {
        let spoken: [(String, CaptureDestination?, ClarificationKind?)] = [
            ("call mom", .reminder, nil),
            ("walk the dog", .reminder, nil),
            ("remind me to call mom tomorrow at 5", .event, nil),
            ("lunch with Sam at noon", .event, nil),
            ("meeting tomorrow at 3pm", .event, nil),
            ("meeting tomorrow", .event, .time),
            ("buy groceries on Friday", nil, .destination),
            ("call mom tomorrow", nil, .destination),
            ("call mom later", nil, .date),
            ("Friday or Saturday", nil, .date),
            ("tomorrow", nil, .garbled)
        ]
        for (phrase, destination, kind) in spoken {
            let out = classify.classify(parser.parse(phrase))
            XCTAssertEqual(out.destination, destination, phrase)
            XCTAssertEqual(out.clarificationKind, kind, phrase)
            XCTAssertEqual(out.needsClarification, kind != nil, phrase)
        }
    }
}
