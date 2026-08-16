import SwiftUI

/// Session 30 DoD: SF Symbol mapping for every kit icon, light and dark.
struct IconCatalog: View {
    private let columns = [GridItem(.adaptive(minimum: 96), spacing: MurmurSpace.space4)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MurmurSpace.stackSection) {
                Text("SF Symbols in the app. Lucide stays in the design-system folder. Mic is not used on capture home.")
                    .font(MurmurType.footnote)
                    .tracking(MurmurType.trackingFootnote)
                    .foregroundStyle(MurmurColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                LazyVGrid(columns: columns, spacing: MurmurSpace.space5) {
                    ForEach(MurmurIconName.allCases, id: \.self) { name in
                        VStack(spacing: MurmurSpace.space3) {
                            MurmurIcon(name: name, size: 24, title: name.rawValue)
                                .foregroundStyle(MurmurColor.textPrimary)
                                .frame(width: MurmurSpace.hitMin, height: MurmurSpace.hitMin)
                            Text(name.rawValue)
                                .font(MurmurType.meta)
                                .foregroundStyle(MurmurColor.textTertiary)
                                .lineLimit(1)
                            Text(name.systemName)
                                .font(MurmurType.caption)
                                .tracking(MurmurType.trackingCaption)
                                .foregroundStyle(MurmurColor.textTertiary)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .padding(MurmurSpace.gutterScreen)
        }
        .background(MurmurColor.bgBase.ignoresSafeArea())
    }
}

#Preview("Icons · light") {
    IconCatalog()
        .preferredColorScheme(.light)
}

#Preview("Icons · dark") {
    IconCatalog()
        .preferredColorScheme(.dark)
}
