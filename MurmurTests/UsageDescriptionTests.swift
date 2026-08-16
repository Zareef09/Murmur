import XCTest
@testable import Murmur

final class UsageDescriptionTests: XCTestCase {
    func testFourUsageStringsExistAndStayWarm() {
        let keys = [
            "NSMicrophoneUsageDescription",
            "NSSpeechRecognitionUsageDescription",
            "NSRemindersFullAccessUsageDescription",
            "NSCalendarsFullAccessUsageDescription"
        ]
        for key in keys {
            let value = Bundle.main.object(forInfoDictionaryKey: key) as? String
            XCTAssertNotNil(value, key)
            let text = value ?? ""
            XCTAssertFalse(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, key)
            XCTAssertFalse(text.localizedCaseInsensitiveContains("error"), key)
            XCTAssertFalse(text.localizedCaseInsensitiveContains("failed"), key)
            XCTAssertFalse(text.contains("!"), key)
        }
    }
}
