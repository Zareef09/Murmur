import SwiftUI

/// Session 29 DoD: theme canvas with and without light wash, both modes.
struct ThemeCatalog: View {
    var body: some View {
        VStack(spacing: MurmurSpace.stackDefault) {
            labeledPreview("Base · no wash", wash: false)
            labeledPreview("Capture · light wash", wash: true)
        }
        .padding(MurmurSpace.gutterScreen)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MurmurColor.bgSunk.ignoresSafeArea())
    }

    private func labeledPreview(_ title: String, wash: Bool) -> some View {
        VStack(alignment: .leading, spacing: MurmurSpace.space3) {
            Text(title)
                .font(MurmurType.caption)
                .tracking(MurmurType.trackingCaption)
                .foregroundStyle(MurmurColor.textTertiary)
            RoundedRectangle(cornerRadius: MurmurRadius.xl, style: .continuous)
                .fill(.clear)
                .overlay {
                    Text("murmur")
                        .font(MurmurType.wordmark)
                        .tracking(MurmurType.trackingWordmark)
                        .foregroundStyle(MurmurColor.textPrimary)
                }
                .murmurCanvas(wash: wash)
                .clipShape(RoundedRectangle(cornerRadius: MurmurRadius.xl, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: MurmurRadius.xl, style: .continuous)
                        .stroke(MurmurColor.lineSoft, lineWidth: MurmurRadius.strokeHairline)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 220)
        }
    }
}

#Preview("Theme · light") {
    ThemeCatalog()
        .preferredColorScheme(.light)
}

#Preview("Theme · dark") {
    ThemeCatalog()
        .preferredColorScheme(.dark)
}
