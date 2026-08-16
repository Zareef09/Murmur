import XCTest
@testable import Murmur

/// Session 62 — second half of the parse corpus. Destination/confidence is Session 63.
final class ParsingPhraseTestsB: XCTestCase {
    private let parser = ParsingService()

    func testCorpusB() {
        let cases: [PhraseCase] = [
            PhraseCase("call the bank", task: "call the bank", hasDate: false, explicitTime: false),
            PhraseCase("text Jordan", task: "text Jordan", hasDate: false, explicitTime: false),
            PhraseCase("please buy stamps", task: "buy stamps", hasDate: false, explicitTime: false),
            PhraseCase("water the plants", task: "water the plants", hasDate: false, explicitTime: false),
            PhraseCase("submit the invoice", task: "submit the invoice", hasDate: false, explicitTime: false),
            PhraseCase("cancel the dentist", task: "cancel the dentist", hasDate: false, explicitTime: false),
            PhraseCase("remind me tomorrow to call mom", task: "call mom", hasDate: true, explicitTime: false),
            PhraseCase("wake up at 6am", task: "wake up", hasDate: true, explicitTime: true),
            PhraseCase("call mom at noon", task: "call mom", hasDate: true, explicitTime: true),
            PhraseCase("yoga at 7am", task: "yoga", hasDate: true, explicitTime: true),
            PhraseCase("pick up kids at 3:15", task: "pick up kids", hasDate: true, explicitTime: true),
            PhraseCase("haircut next Friday at 11", task: "haircut", hasDate: true, explicitTime: true),
            PhraseCase("birthday party Saturday at 2", task: "birthday party", hasDate: true, explicitTime: true),
            PhraseCase("book a table for 7pm", task: "book a table", hasDate: true, explicitTime: true),
            PhraseCase("call mom on Monday", task: "call mom", hasDate: true, explicitTime: false),
            PhraseCase("drop off the keys tonight", task: "drop off the keys", hasDate: true, explicitTime: false),
            PhraseCase("mom's birthday on March 3", task: "mom's birthday", hasDate: true, explicitTime: false),
            PhraseCase("flight lands at 6pm", task: "flight lands", hasDate: true, explicitTime: true),
            PhraseCase("Sunday", task: "", hasDate: true, explicitTime: false, garbled: true),
            PhraseCase("Saturday at midnight", task: "", hasDate: true, explicitTime: true, garbled: true)
        ]
        XCTAssertEqual(cases.count, 20)
        for item in cases {
            item.assert(using: parser)
        }
    }

    func testEmptyTranscriptIsGarbled() {
        let intent = parser.parse("")
        XCTAssertTrue(intent.taskText.isEmpty)
        XCTAssertTrue(intent.needsClarification)
        XCTAssertEqual(intent.clarificationKind, .garbled)
        XCTAssertNil(intent.date)
    }
}
