import Speech
import XCTest
@testable import Murmur

final class SpeechRecognitionPolicyTests: XCTestCase {
    func testRequestRequiresOnDeviceRecognition() {
        let request = SpeechRecognitionPolicy.makeOnDeviceRequest()
        XCTAssertTrue(request.requiresOnDeviceRecognition)
        XCTAssertTrue(request.shouldReportPartialResults)
    }

    func testUnsupportedLocaleDoesNotProduceACloudRequest() {
        let locale = Locale(identifier: "zz")
        XCTAssertFalse(SpeechLocalePolicy.supportsOnDevice(locale: locale))
        XCTAssertNil(SpeechRecognitionPolicy.makeOnDeviceRequestIfAvailable(locale: locale))
        XCTAssertThrowsError(try SpeechLocalePolicy.onDeviceRecognizer(locale: locale)) { error in
            let speechError = error as? SpeechServiceError
            XCTAssertTrue(speechError == .onDeviceUnavailable || speechError == .recognizerUnavailable)
        }
        let request = SpeechRecognitionPolicy.makeOnDeviceRequest()
        XCTAssertTrue(request.requiresOnDeviceRecognition)
    }
}

final class SpeechCopyTests: XCTestCase {
    func testUnsupportedLocaleCopyIsAFact() {
        let text = SpeechCopy.unsupportedLocale
        XCTAssertFalse(text.localizedCaseInsensitiveContains("error"))
        XCTAssertFalse(text.localizedCaseInsensitiveContains("failed"))
        XCTAssertFalse(text.localizedCaseInsensitiveContains("invalid"))
        XCTAssertFalse(text.contains("!"))
        XCTAssertEqual(SpeechCopy.fact(for: .onDeviceUnavailable), text)
        XCTAssertEqual(SpeechCopy.fact(for: .recognizerUnavailable), text)
        XCTAssertEqual(SpeechCopy.fact(for: .notAuthorized), SpeechCopy.notAllowedYet)
        XCTAssertEqual(SpeechCopy.nothingCaptured, "Nothing captured.")
        XCTAssertFalse(SpeechCopy.nothingCaptured.contains("!"))
    }
}
