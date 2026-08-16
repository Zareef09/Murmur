import XCTest
@testable import Murmur

final class EdgeCopyTests: XCTestCase {
    func testSpecEdgeCasesHaveQuietCopy() {
        XCTAssertEqual(SpeechCopy.nothingCaptured, "Nothing captured.")
        XCTAssertEqual(SpeechCopy.notAllowedYet, "Not allowed yet")
        XCTAssertEqual(SpeechCopy.unsupportedLocale, "On-device speech isn't available for this language.")
        XCTAssertEqual(AuthCopy.connectionNeededToCreateAccount, "A connection is needed to create the account.")
        XCTAssertEqual(SettingsCopy.usingThisPhone, "Using the last settings on this iPhone.")
        XCTAssertEqual(HistoryCopy.emptyTitle, "Nothing captured yet")
        XCTAssertEqual(HistoryCopy.ttlNote, "Murmur keeps three days here.")
        XCTAssertEqual(EventKitCopy.remindersAccessNeeded, "Reminders access is needed to save this.")
        XCTAssertEqual(EventKitCopy.calendarAccessNeeded, "Calendar access is needed to save this.")
        XCTAssertEqual(ConfirmationCopy.pastDay, "This day has passed.")
        XCTAssertEqual(ClarifyCopy.garbled, "Say that again, or tap to type it.")
        XCTAssertEqual(CaptureCopy.firstRunTitle, "Say what you need to remember.")
    }

    func testEdgeCopyNeverShouts() {
        let lines = [
            SpeechCopy.nothingCaptured,
            SpeechCopy.notAllowedYet,
            SpeechCopy.unsupportedLocale,
            AuthCopy.connectionNeededToCreateAccount,
            AuthCopy.connectionNeededToSignOut,
            SettingsCopy.usingThisPhone,
            HistoryCopy.emptyTitle,
            HistoryCopy.emptyBody,
            HistoryCopy.ttlNote,
            HistoryCopy.deleteNeeded,
            EventKitCopy.remindersAccessNeeded,
            EventKitCopy.calendarAccessNeeded,
            EventKitCopy.nothingToSave,
            EventKitCopy.reminderGone,
            EventKitCopy.eventGone,
            ConfirmationCopy.pastDay,
            ConfirmationCopy.noDate,
            ClarifyCopy.garbled,
            ClarifyCopy.quietHint
        ]
        for line in lines {
            let lower = line.lowercased()
            XCTAssertFalse(line.contains("!"), line)
            XCTAssertFalse(lower.contains("error"), line)
            XCTAssertFalse(lower.contains("failed"), line)
            XCTAssertFalse(lower.contains("invalid"), line)
            XCTAssertFalse(LoggingPolicy.looksLikeBannedContent(line), line)
        }
    }
}

@MainActor
final class CaptureViewModelSettingsFactTests: XCTestCase {
    func testRemoteSettingsMissUsesThisPhoneCopy() async {
        struct Miss: Error {}
        let sync = FakeSettingsSync()
        sync.fetchError = Miss()
        let model = CaptureViewModel(
            settingsSync: sync,
            speech: FakeSpeechService(),
            permissions: FakePermissionsService(),
            eventKit: FakeEventKitService(),
            synth: FakeSpeechSynth()
        )
        model.applySession(isSignedIn: true)
        await model.refreshSettingsFromRemote()
        XCTAssertEqual(model.settingsFact, SettingsCopy.usingThisPhone)
        XCTAssertEqual(model.alwaysConfirm, SettingsRepository.defaultAlwaysConfirm)
    }
}
