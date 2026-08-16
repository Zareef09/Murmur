import SwiftUI

/// Session 36 DoD: live transcript (settled + partial) and success settle with Undo.
struct CaptureFeedbackCatalog: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MurmurSpace.stackSection) {
                Text("Sentences wrap. Undo is a ghost. The bar is a settle, not a celebration.")
                    .font(MurmurType.footnote)
                    .tracking(MurmurType.trackingFootnote)
                    .foregroundStyle(MurmurColor.textSecondary)

                TranscriptView(placeholder: "I'm listening…")

                TranscriptView(
                    text: "Remind me to call mom",
                    partial: "tomorrow at fi…"
                )

                TranscriptView(
                    text: "Remind me to call mom tomorrow at five",
                    alignment: .leading
                )

                SuccessBar(
                    message: "Saved to Reminders · tomorrow 5:00 PM",
                    destination: .reminder,
                    onUndo: {}
                )

                SuccessBar(
                    message: "Saved to Calendar · Fri 9:30 AM",
                    destination: .event
                )
            }
            .padding(MurmurSpace.gutterScreen)
        }
        .background(MurmurColor.bgBase.ignoresSafeArea())
    }
}

#Preview("Transcript / success · light") {
    CaptureFeedbackCatalog()
        .preferredColorScheme(.light)
}

#Preview("Transcript / success · dark") {
    CaptureFeedbackCatalog()
        .preferredColorScheme(.dark)
}
