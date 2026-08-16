import SwiftUI

/// Session 33 DoD: Reminder and Event in chip, glyph, and quiet. Icon + word (or glyph title).
struct DestinationBadgeCatalog: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MurmurSpace.stackSection) {
                Text("Moss and plum reinforce the destination. The icon and the word are the signal.")
                    .font(MurmurType.footnote)
                    .tracking(MurmurType.trackingFootnote)
                    .foregroundStyle(MurmurColor.textSecondary)

                row("chip") {
                    DestinationBadge(destination: .reminder)
                    DestinationBadge(destination: .event)
                }
                row("glyph") {
                    DestinationBadge(destination: .reminder, variant: .glyph)
                    DestinationBadge(destination: .event, variant: .glyph)
                }
                row("quiet") {
                    DestinationBadge(destination: .reminder, variant: .quiet)
                    DestinationBadge(destination: .event, variant: .quiet)
                }
            }
            .padding(MurmurSpace.gutterScreen)
        }
        .background(MurmurColor.bgBase.ignoresSafeArea())
    }

    private func row(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: MurmurSpace.space3) {
            Text(title)
                .font(MurmurType.meta)
                .foregroundStyle(MurmurColor.textTertiary)
            HStack(spacing: MurmurSpace.space4) {
                content()
            }
        }
    }
}

#Preview("Destination badges · light") {
    DestinationBadgeCatalog()
        .preferredColorScheme(.light)
}

#Preview("Destination badges · dark") {
    DestinationBadgeCatalog()
        .preferredColorScheme(.dark)
}
