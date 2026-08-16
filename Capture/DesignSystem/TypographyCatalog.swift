import SwiftUI

/// Session 27 DoD: type scale in Hanken Grotesk + IBM Plex Mono, light and dark.
struct TypographyCatalog: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MurmurSpace.stackSection) {
                sample("display · 40 / 200", font: MurmurType.display, tracking: MurmurType.trackingDisplay, text: "Say it once.")
                sample("title · 30 / 300", font: MurmurType.title, tracking: MurmurType.trackingTitle, text: "Say what you need to remember.")
                sample("headline · 22 / 400", font: MurmurType.headline, tracking: MurmurType.trackingHeadline, text: "Say what you need to remember.")
                sample("body · 17 / 400", font: MurmurType.body, tracking: MurmurType.trackingBody, text: "Murmur files it as a reminder or an event.")
                sample("body-em · 17 / 500", font: MurmurType.bodyEm, tracking: MurmurType.trackingBody, text: "Continue with Apple")
                sample("callout · 16 / 400", font: MurmurType.callout, tracking: MurmurType.trackingCallout, text: "Always confirm before saving")
                sample("subhead · 15 / 500", font: MurmurType.subhead, tracking: MurmurType.trackingSubhead, text: "Saved to Reminders")
                sample("footnote · 13 / 400", font: MurmurType.footnote, tracking: MurmurType.trackingFootnote, text: "A connection is needed to create the account.")
                sample("caption · 12 / 500", font: MurmurType.caption, tracking: MurmurType.trackingCaption, text: "WHEN")
                sample("meta · plex 13 / 400", font: MurmurType.meta, tracking: MurmurType.trackingFootnote, text: "tomorrow 5:00 PM")
                sample("transcript · 26 / 300", font: MurmurType.transcript, tracking: MurmurType.trackingTranscript, text: "Remind me to call Sam Friday")
                sample("wordmark · 28 / 300", font: MurmurType.wordmark, tracking: MurmurType.trackingWordmark, text: "murmur")
            }
            .padding(MurmurSpace.gutterScreen)
        }
        .background(MurmurColor.bgBase.ignoresSafeArea())
    }

    private func sample(_ role: String, font: Font, tracking: CGFloat, text: String) -> some View {
        VStack(alignment: .leading, spacing: MurmurSpace.space2) {
            Text(role)
                .font(MurmurType.meta)
                .foregroundStyle(MurmurColor.textTertiary)
            Text(text)
                .font(font)
                .tracking(tracking)
                .foregroundStyle(MurmurColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview("Type · light") {
    TypographyCatalog()
        .preferredColorScheme(.light)
}

#Preview("Type · dark") {
    TypographyCatalog()
        .preferredColorScheme(.dark)
}
