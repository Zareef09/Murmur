import AppIntents

/// Donated Siri / Shortcuts phrases for quick capture. Widget launch is Session 84.
struct CaptureShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: QuickCaptureIntent(),
            phrases: [
                "Quick capture in \(.applicationName)",
                "Capture with \(.applicationName)",
                "Start \(.applicationName)",
                "Listen with \(.applicationName)"
            ],
            shortTitle: "Quick capture",
            systemImageName: "waveform"
        )
    }
}
