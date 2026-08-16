import SwiftUI

/// Session 32 DoD: quiet / surface / accent icon buttons. Accent is reserved off capture home.
struct IconButtonCatalog: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MurmurSpace.stackSection) {
                Text("Hit area 44 or above. Accent tone is reserved — capture home already owns Ember.")
                    .font(MurmurType.footnote)
                    .tracking(MurmurType.trackingFootnote)
                    .foregroundStyle(MurmurColor.textSecondary)

                HStack(spacing: MurmurSpace.space6) {
                    labeled("quiet") {
                        MurmurIconButton(name: .list, label: "History") {}
                    }
                    labeled("surface") {
                        MurmurIconButton(name: .x, label: "Close", tone: .surface) {}
                    }
                    labeled("accent · reserved") {
                        MurmurIconButton(name: .settings, label: "Settings", tone: .accent) {}
                    }
                }

                HStack(spacing: MurmurSpace.space4) {
                    MurmurIconButton(name: .chevronLeft, label: "Back") {}
                    MurmurIconButton(name: .settings, label: "Settings") {}
                    MurmurIconButton(name: .list, label: "History") {}
                }
            }
            .padding(MurmurSpace.gutterScreen)
        }
        .background(MurmurColor.bgBase.ignoresSafeArea())
    }

    private func labeled(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(spacing: MurmurSpace.space3) {
            content()
            Text(title)
                .font(MurmurType.meta)
                .foregroundStyle(MurmurColor.textTertiary)
        }
    }
}

#Preview("Icon buttons · light") {
    IconButtonCatalog()
        .preferredColorScheme(.light)
}

#Preview("Icon buttons · dark") {
    IconButtonCatalog()
        .preferredColorScheme(.dark)
}
