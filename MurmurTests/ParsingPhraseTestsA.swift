import XCTest
@testable import Murmur

/// Session 61 — first half of the parse corpus. Destination/confidence is Session 63.
final class ParsingPhraseTestsA: XCTestCase {
    private let parser = ParsingService()

    func testCorpusA() {
        let cases: [PhraseCase] = [
            PhraseCase("call mom", task: "call mom", hasDate: false, explicitTime: false),
            PhraseCase("walk the dog", task: "walk the dog", hasDate: false, explicitTime: false),
            PhraseCase("pick up dry cleaning", task: "pick up dry cleaning", hasDate: false, explicitTime: false),
            PhraseCase("remind me to call mom", task: "call mom", hasDate: false, explicitTime: false),
            PhraseCase("remember to buy milk", task: "buy milk", hasDate: false, explicitTime: false),
            PhraseCase("remind me to email Dana", task: "email Dana", hasDate: false, explicitTime: false),
            PhraseCase("don't forget to pay rent", task: "pay rent", hasDate: false, explicitTime: false),
            PhraseCase("call mom tomorrow", task: "call mom", hasDate: true, explicitTime: false),
            PhraseCase("buy groceries on Friday", task: "buy groceries", hasDate: true, explicitTime: false),
            PhraseCase("remind me to call mom tomorrow at 5", task: "call mom", hasDate: true, explicitTime: true),
            PhraseCase("call mom at 5:30", task: "call mom", hasDate: true, explicitTime: true),
            PhraseCase("call mom at 5 o'clock", task: "call mom", hasDate: true, explicitTime: true),
            PhraseCase("dentist tomorrow at 9am", task: "dentist", hasDate: true, explicitTime: true),
            PhraseCase("meeting tomorrow at 3pm", task: "meeting", hasDate: true, explicitTime: true),
            PhraseCase("lunch with Sam at noon", task: "lunch with Sam", hasDate: true, explicitTime: true),
            PhraseCase("appointment Friday 2pm", task: "appointment", hasDate: true, explicitTime: true),
            PhraseCase("take out trash tonight", task: "take out trash", hasDate: true, explicitTime: false),
            PhraseCase("tomorrow", task: "", hasDate: true, explicitTime: false, garbled: true),
            PhraseCase("Friday 2-3pm", task: "", hasDate: true, explicitTime: true, garbled: true),
            PhraseCase("Friday or Saturday", task: "", hasDate: true, twoDates: true)
        ]
        XCTAssertEqual(cases.count, 20)
        for item in cases {
            item.assert(using: parser)
        }
    }
}
