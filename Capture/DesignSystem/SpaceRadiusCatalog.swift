import SwiftUI

/// Session 26 DoD: spacing, radius, and hit-target layout preview.
struct SpaceRadiusCatalog: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MurmurSpace.stackSection) {
                section("Space") {
                    VStack(alignment: .leading, spacing: MurmurSpace.stackTight) {
                        spaceRow("space-3", MurmurSpace.space3)
                        spaceRow("space-4", MurmurSpace.space4)
                        spaceRow("space-5", MurmurSpace.space5)
                        spaceRow("space-6", MurmurSpace.space6)
                        spaceRow("space-7 · gutter", MurmurSpace.space7)
                        spaceRow("space-8", MurmurSpace.space8)
                        spaceRow("space-10 · section", MurmurSpace.space10)
                    }
                }

                section("Radius · nothing sharper than 8") {
                    HStack(alignment: .bottom, spacing: MurmurSpace.space4) {
                        radiusSwatch("8", MurmurRadius.xs)
                        radiusSwatch("12", MurmurRadius.sm)
                        radiusSwatch("16", MurmurRadius.md)
                        radiusSwatch("22", MurmurRadius.lg)
                        radiusSwatch("28", MurmurRadius.xl)
                        radiusSwatch("36", MurmurRadius.xxl)
                        radiusSwatch("pill", MurmurRadius.pill)
                    }
                }

                section("Hit · 44 min, 56 comfort, 96 hero") {
                    HStack(alignment: .bottom, spacing: MurmurSpace.space5) {
                        hitSwatch("44 · min", MurmurSpace.hitMin)
                        hitSwatch("56 · comfort", MurmurSpace.hitComfort)
                        hitSwatch("96 · hero", MurmurSpace.hitHero)
                    }
                }

                section("Gutters 24 · sections 56") {
                    ZStack {
                        RoundedRectangle(cornerRadius: MurmurRadius.xl, style: .continuous)
                            .fill(MurmurColor.bgRaised)
                            .overlay {
                                RoundedRectangle(cornerRadius: MurmurRadius.xl, style: .continuous)
                                    .stroke(MurmurColor.lineSoft, lineWidth: MurmurRadius.strokeHairline)
                            }
                        HStack(spacing: 0) {
                            MurmurColor.accentGlowFaint.frame(width: MurmurSpace.gutterScreen)
                            VStack(alignment: .leading, spacing: MurmurSpace.stackSection) {
                                capsuleBar(widthFraction: 0.55)
                                capsuleBar(widthFraction: 0.8)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, MurmurSpace.space6)
                            MurmurColor.accentGlowFaint.frame(width: MurmurSpace.gutterScreen)
                        }
                    }
                    .frame(height: 160)
                    Text("24px side margin, 56px between sections, safe areas respected.")
                        .font(MurmurType.footnote)
                        .tracking(MurmurType.trackingFootnote)
                        .foregroundStyle(MurmurColor.textSecondary)
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

    private func spaceRow(_ name: String, _ width: CGFloat) -> some View {
        HStack(spacing: MurmurSpace.space4) {
            Capsule()
                .fill(MurmurColor.accent.opacity(0.55))
                .frame(width: width, height: MurmurSpace.space3)
            Text("\(Int(width))")
                .font(MurmurType.caption)
                .tracking(MurmurType.trackingCaption)
                .foregroundStyle(MurmurColor.textPrimary)
                .frame(width: 28, alignment: .leading)
            Text(name)
                .font(MurmurType.meta)
                .foregroundStyle(MurmurColor.textTertiary)
        }
    }

    private func radiusSwatch(_ label: String, _ radius: CGFloat) -> some View {
        VStack(spacing: MurmurSpace.space2) {
            RoundedRectangle(cornerRadius: min(radius, 28), style: .continuous)
                .fill(MurmurColor.bgRaised)
                .overlay {
                    RoundedRectangle(cornerRadius: min(radius, 28), style: .continuous)
                        .stroke(MurmurColor.lineSoft, lineWidth: MurmurRadius.strokeHairline)
                }
                .frame(width: 40, height: 36)
            Text(label)
                .font(MurmurType.meta)
                .foregroundStyle(MurmurColor.textTertiary)
        }
    }

    private func hitSwatch(_ label: String, _ size: CGFloat) -> some View {
        VStack(spacing: MurmurSpace.space2) {
            RoundedRectangle(cornerRadius: MurmurRadius.md, style: .continuous)
                .fill(MurmurColor.accentQuiet)
                .overlay {
                    RoundedRectangle(cornerRadius: MurmurRadius.md, style: .continuous)
                        .stroke(MurmurColor.accent, lineWidth: MurmurRadius.strokeHairline)
                }
                .frame(width: size, height: size)
            Text(label)
                .font(MurmurType.meta)
                .foregroundStyle(MurmurColor.textTertiary)
        }
    }

    private func capsuleBar(widthFraction: CGFloat) -> some View {
        GeometryReader { geo in
            Capsule()
                .fill(MurmurColor.lineSoft)
                .frame(width: geo.size.width * widthFraction, height: 14)
        }
        .frame(height: 14)
    }
}

#Preview("Space · light") {
    SpaceRadiusCatalog()
        .preferredColorScheme(.light)
}

#Preview("Space · dark") {
    SpaceRadiusCatalog()
        .preferredColorScheme(.dark)
}
