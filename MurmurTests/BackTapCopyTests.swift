import AppIntents
import XCTest
@testable import Murmur

final class BackTapCopyTests: XCTestCase {
    func testPathIsAccessibilityThenTouchThenBackTap() {
        XCTAssertEqual(BackTapCopy.backTapPath, ["Accessibility", "Touch", "Back Tap"])
        XCTAssertEqual(BackTapCopy.backTapSteps.count, 3)
        XCTAssertTrue(BackTapCopy.backTapSteps[1].contains("Accessibility"))
        XCTAssertTrue(BackTapCopy.backTapSteps[1].contains("Touch"))
        XCTAssertTrue(BackTapCopy.backTapSteps[1].contains("Back Tap"))
    }

    /// Back Tap only lists shortcuts already in the library, so the walkthrough has to build one first.
    func testShortcutIsAddedBeforeBackTap() {
        XCTAssertEqual(BackTapCopy.shortcutSteps.count, 3)
        XCTAssertTrue(BackTapCopy.shortcutSteps[0].contains("Shortcuts"))
        XCTAssertTrue(BackTapCopy.shortcutSteps[1].contains("Add Action"))
        XCTAssertTrue(BackTapCopy.shortcutSteps[2].contains(BackTapCopy.shortcutTitle))
        XCTAssertTrue(BackTapCopy.backTapSteps[2].contains("Shortcuts"))
        XCTAssertTrue(BackTapCopy.allLines.contains(BackTapCopy.shortcutHeading))
    }

    func testWalkthroughWrapsQuickCaptureShortcut() {
        XCTAssertEqual(BackTapCopy.shortcutTitle, "Quick capture")
        XCTAssertEqual(QuickCaptureIntent.title, "Quick capture")
        XCTAssertTrue(BackTapCopy.backTapSteps[2].contains(BackTapCopy.shortcutTitle))
        XCTAssertTrue(BackTapCopy.actionButtonBody.contains(BackTapCopy.shortcutTitle))
        XCTAssertTrue(BackTapCopy.intro.contains(BackTapCopy.shortcutTitle))
    }

    func testAppDoesNotMutateSystemAccessibility() {
        XCTAssertFalse(BackTapSetup.mutatesSystemAccessibility)
        XCTAssertFalse(BackTapCopy.intro.contains("prefs:root"))
        XCTAssertTrue(BackTapCopy.intro.contains("cannot turn this on for you"))
    }

    func testCopyStaysQuiet() {
        for line in BackTapCopy.allLines {
            let lower = line.lowercased()
            XCTAssertFalse(line.contains("!"))
            XCTAssertFalse(lower.contains("error"))
            XCTAssertFalse(lower.contains("failed"))
            XCTAssertFalse(lower.contains("invalid"))
            XCTAssertFalse(LoggingPolicy.looksLikeBannedContent(line))
        }
    }
}
