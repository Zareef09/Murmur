import Foundation

/// Copy for the Back Tap / Action Button walkthrough. Murmur never writes system Accessibility.
enum BackTapCopy {
    static let navigationTitle = "Hands-free capture"
    static let intro =
        "Murmur cannot turn this on for you. You add Quick capture once, then choose it in Settings."

    /// Back Tap and the Action Button both read from your Shortcuts library, so the shortcut has to
    /// exist before either list will show it.
    static let shortcutHeading = "Add the shortcut"
    static let shortcutSteps = [
        "Open the Shortcuts app.",
        "Tap the plus, then Add Action.",
        "Search for Quick capture, choose it, then tap Done."
    ]

    static let backTapHeading = "Back Tap"
    static let backTapPath = ["Accessibility", "Touch", "Back Tap"]
    static let backTapSteps = [
        "Open Settings on your iPhone.",
        "Go to Accessibility, then Touch, then Back Tap.",
        "Choose Double Tap or Triple Tap, then Quick capture under Shortcuts."
    ]

    static let actionButtonHeading = "Action Button"
    static let actionButtonBody =
        "If your iPhone has an Action Button, open Settings, then Action Button. Choose Shortcut, then the same Quick capture shortcut."

    static let footer = "You can open this again from Settings."
    static let done = "Done"
    static let later = "I'll do this later"

    static let settingsSection = "Hands-free"
    static let settingsRowTitle = "Set up Back Tap"
    static let settingsRowSubtitle = "Or the Action Button · about a minute"

    static let shortcutTitle = "Quick capture"

    static var allLines: [String] {
        [navigationTitle, intro, shortcutHeading] + shortcutSteps + [backTapHeading] + backTapPath + backTapSteps
            + [actionButtonHeading, actionButtonBody, footer, done, later, settingsSection, settingsRowTitle, settingsRowSubtitle, shortcutTitle]
    }
}

enum BackTapSetup {
    /// The app never enables or edits Back Tap, Action Button, or other Accessibility settings.
    static let mutatesSystemAccessibility = false
}
