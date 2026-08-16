import XCTest
@testable import Murmur

final class SettingsCopyTests: XCTestCase {
    func testAccountRowHasNoIdentity() {
        XCTAssertEqual(SettingsCopy.accountTitle, "Signed in with Apple")
        XCTAssertFalse(SettingsCopy.accountTitle.lowercased().contains("email"))
        XCTAssertFalse(SettingsCopy.accountSubtitle.lowercased().contains("uuid"))
        XCTAssertFalse(LoggingPolicy.looksLikeBannedContent(SettingsCopy.accountTitle))
        XCTAssertFalse(LoggingPolicy.looksLikeBannedContent(SettingsCopy.accountSubtitle))
    }

    func testVersionLineMatchesKitMeta() {
        XCTAssertEqual(SettingsCopy.versionLine(version: "1.0", build: "12"), "murmur 1.0 (12)")
        XCTAssertEqual(SettingsCopy.usingThisPhone, "Using the last settings on this iPhone.")
        XCTAssertEqual(SettingsCopy.openSettings, "Open Settings")
        XCTAssertEqual(SettingsCopy.permissionsSection, "Permissions")
        XCTAssertEqual(SettingsCopy.microphone, "Microphone")
        XCTAssertEqual(SettingsCopy.speech, "Speech")
        XCTAssertEqual(SettingsCopy.reminders, "Reminders")
        XCTAssertEqual(SettingsCopy.calendar, "Calendar")
        XCTAssertFalse(SettingsCopy.openSettings.contains("!"))
        XCTAssertFalse(SettingsCopy.calendarHint.lowercased().contains("error"))
        XCTAssertTrue(SettingsCopy.calendarHint.lowercased().contains("needed"))
        XCTAssertFalse(LoggingPolicy.looksLikeBannedContent(SettingsCopy.microphoneHint))
        XCTAssertFalse(LoggingPolicy.looksLikeBannedContent(SettingsCopy.speechHint))
    }
}

final class ConfirmationParityTests: XCTestCase {
    func testHeaderBloomIsBriefSize() {
        XCTAssertEqual(ConfirmationCopy.headerBloomSize, 120)
        XCTAssertEqual(ConfirmationCopy.headline, "Does this look right?")
        XCTAssertEqual(ConfirmationCopy.fixing, "Fix it up")
        XCTAssertEqual(ConfirmationCopy.hint, "Tap anything to change it.")
    }
}
