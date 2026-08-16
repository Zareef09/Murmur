import SwiftUI

/// Session 25 DoD: color token swatches in light and dark.
struct ColorTokenCatalog: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MurmurSpace.stackSection) {
                section("Sand") {
                    ramp([
                        ("sand-0", MurmurColor.sand0),
                        ("sand-50", MurmurColor.sand50),
                        ("sand-100", MurmurColor.sand100),
                        ("sand-200", MurmurColor.sand200),
                        ("sand-300", MurmurColor.sand300),
                        ("sand-400", MurmurColor.sand400),
                        ("sand-500", MurmurColor.sand500),
                        ("sand-600", MurmurColor.sand600),
                        ("sand-700", MurmurColor.sand700),
                        ("sand-800", MurmurColor.sand800),
                        ("sand-900", MurmurColor.sand900),
                        ("sand-950", MurmurColor.sand950),
                        ("sand-1000", MurmurColor.sand1000),
                    ])
                }
                section("Ember · well + one primary") {
                    ramp([
                        ("ember-100", MurmurColor.ember100),
                        ("ember-200", MurmurColor.ember200),
                        ("ember-300", MurmurColor.ember300),
                        ("ember-400", MurmurColor.ember400),
                        ("ember-500", MurmurColor.ember500),
                        ("ember-600", MurmurColor.ember600),
                        ("ember-700", MurmurColor.ember700),
                        ("ember-800", MurmurColor.ember800),
                    ])
                }
                section("Moss · reminder") {
                    ramp([
                        ("moss-300", MurmurColor.moss300),
                        ("moss-400", MurmurColor.moss400),
                        ("moss-600", MurmurColor.moss600),
                        ("moss-700", MurmurColor.moss700),
                    ])
                }
                section("Plum · event") {
                    ramp([
                        ("plum-300", MurmurColor.plum300),
                        ("plum-400", MurmurColor.plum400),
                        ("plum-600", MurmurColor.plum600),
                        ("plum-700", MurmurColor.plum700),
                    ])
                }
                section("Leaf · clay") {
                    ramp([
                        ("leaf-400", MurmurColor.leaf400),
                        ("leaf-600", MurmurColor.leaf600),
                        ("clay-400", MurmurColor.clay400),
                        ("clay-600", MurmurColor.clay600),
                    ])
                }
                section("Semantic") {
                    ramp([
                        ("bg-base", MurmurColor.bgBase),
                        ("bg-sunk", MurmurColor.bgSunk),
                        ("bg-raised", MurmurColor.bgRaised),
                        ("text-primary", MurmurColor.textPrimary),
                        ("text-secondary", MurmurColor.textSecondary),
                        ("text-tertiary", MurmurColor.textTertiary),
                        ("accent", MurmurColor.accent),
                        ("accent-on", MurmurColor.accentOn),
                        ("reminder-fg", MurmurColor.reminderFg),
                        ("event-fg", MurmurColor.eventFg),
                        ("success-fg", MurmurColor.successFg),
                        ("attention-fg", MurmurColor.attentionFg),
                    ])
                }
            }
            .padding(MurmurSpace.gutterScreen)
        }
        .background(MurmurColor.bgBase.ignoresSafeArea())
    }

    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: MurmurSpace.space4) {
            Text(title)
                .font(MurmurType.caption)
                .tracking(MurmurType.trackingCaption)
                .foregroundStyle(MurmurColor.textTertiary)
            content()
        }
    }

    private func ramp(_ items: [(String, Color)]) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 88), spacing: MurmurSpace.space3)], spacing: MurmurSpace.space3) {
            ForEach(items, id: \.0) { name, color in
                VStack(alignment: .leading, spacing: MurmurSpace.space2) {
                    RoundedRectangle(cornerRadius: MurmurRadius.xs, style: .continuous)
                        .fill(color)
                        .frame(height: 44)
                        .overlay {
                            RoundedRectangle(cornerRadius: MurmurRadius.xs, style: .continuous)
                                .stroke(MurmurColor.lineSoft, lineWidth: MurmurRadius.strokeHairline)
                        }
                    Text(name)
                        .font(MurmurType.meta)
                        .foregroundStyle(MurmurColor.textTertiary)
                        .lineLimit(1)
                }
            }
        }
    }
}

#Preview("Color tokens · light") {
    ColorTokenCatalog()
        .preferredColorScheme(.light)
}

#Preview("Color tokens · dark") {
    ColorTokenCatalog()
        .preferredColorScheme(.dark)
}
