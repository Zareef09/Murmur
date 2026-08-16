import XCTest
@testable import Murmur

final class LoggingPolicyTests: XCTestCase {
    func testAllowedEventsDoNotIncludeBannedPayloads() {
        let samples: [LoggingPolicy.Event] = [
            .captureState(.listening),
            .settingsUpsertOK,
            .httpStatus(401),
            .persistenceReady,
            .historyPurged(removed: 3),
            .authSignedIn(true),
            .notConfigured,
            .permission(.microphone, .needed),
            .audioMode(.recording),
            .speechOnDeviceRequest,
            .speechStream,
            .speechSilenceStop,
            .speechOnDeviceUnavailable,
            .speechSynth,
            .reminderCreated,
            .eventCreated,
            .itemDeleted,
            .itemOpened
        ]
        for event in samples {
            let message = LoggingPolicy.message(for: event)
            XCTAssertFalse(LoggingPolicy.looksLikeBannedContent(message), message)
            XCTAssertFalse(message.contains("eyJ"))
            XCTAssertFalse(message.contains("ek-"))
        }
    }

    func testRedactedUserContentIsNotTheOriginal() {
        XCTAssertEqual(LoggingPolicy.redactedUserContent(), "<redacted>")
        XCTAssertNotEqual(LoggingPolicy.redactedUserContent(), "Call mom")
    }

    func testLooksLikeBannedContentCatchesJWTAndEventKitIds() {
        XCTAssertTrue(
            LoggingPolicy.looksLikeBannedContent(
                "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0In0.signaturepaddingxx"
            )
        )
        XCTAssertTrue(LoggingPolicy.looksLikeBannedContent("ek-ABC123"))
        XCTAssertFalse(LoggingPolicy.looksLikeBannedContent("settings upsert ok"))
        XCTAssertFalse(LoggingPolicy.looksLikeBannedContent("state listening"))
    }
}
