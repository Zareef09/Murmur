import XCTest
@testable import Murmur

struct PhraseCase {
    var spoken: String
    var task: String
    var hasDate: Bool
    var explicitTime: Bool
    var garbled: Bool
    var twoDates: Bool

    init(
        _ spoken: String,
        task: String,
        hasDate: Bool,
        explicitTime: Bool = false,
        garbled: Bool = false,
        twoDates: Bool = false
    ) {
        self.spoken = spoken
        self.task = task
        self.hasDate = hasDate
        self.explicitTime = explicitTime
        self.garbled = garbled
        self.twoDates = twoDates
    }

    func assert(using parser: ParsingService, file: StaticString = #filePath, line: UInt = #line) {
        let intent = parser.parse(spoken)
        XCTAssertEqual(intent.taskText.lowercased(), task.lowercased(), spoken, file: file, line: line)
        XCTAssertEqual(intent.date != nil, hasDate, "date \(spoken)", file: file, line: line)
        XCTAssertEqual(intent.hasExplicitTime, explicitTime, "time \(spoken)", file: file, line: line)
        if garbled {
            XCTAssertTrue(intent.needsClarification, "garbled \(spoken)", file: file, line: line)
            XCTAssertEqual(intent.clarificationKind, .garbled, spoken, file: file, line: line)
        }
        if twoDates {
            XCTAssertTrue(intent.needsClarification, "two dates \(spoken)", file: file, line: line)
            XCTAssertEqual(intent.clarificationKind, .date, spoken, file: file, line: line)
        }
    }
}
