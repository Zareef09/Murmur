import SwiftUI

/// Session 37 DoD: wordmark always lowercase; app icon is the well, never a mic.
struct BrandCatalog: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MurmurSpace.stackSection) {
                Text("Always lowercase. Never a microphone. Clear space around the mark is one cap height.")
                    .font(MurmurType.footnote)
                    .tracking(MurmurType.trackingFootnote)
                    .foregroundStyle(MurmurColor.textSecondary)

                Wordmark()
                Wordmark(size: 22, tone: .accent)
                Wordmark(size: 19, showsDot: false)

                HStack(alignment: .bottom, spacing: MurmurSpace.space6) {
                    AppIconView(size: 120)
                    AppIconView(size: 60)
                    AppIconView(size: 40)
                }
            }
            .padding(MurmurSpace.gutterScreen)
        }
        .background(MurmurColor.bgBase.ignoresSafeArea())
    }
}

#Preview("Brand · light") {
    BrandCatalog()
        .preferredColorScheme(.light)
}

#Preview("Brand · dark") {
    BrandCatalog()
        .preferredColorScheme(.dark)
}
