import SwiftUI

/// Session 28 DoD: motion (including Reduce Motion) and elevation in both modes.
struct MotionElevationCatalog: View {
    var forceReduceMotion: Bool?
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @State private var lifted = false

    private var reduceMotion: Bool {
        forceReduceMotion ?? systemReduceMotion
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MurmurSpace.stackSection) {
                section("Motion") {
                    VStack(alignment: .leading, spacing: MurmurSpace.stackTight) {
                        Text(reduceMotion ? "Reduce motion on · timed motion is 1ms" : "Reduce motion off · full durations")
                            .font(MurmurType.footnote)
                            .tracking(MurmurType.trackingFootnote)
                            .foregroundStyle(MurmurColor.textSecondary)
                        durationRow("instant · press", .instant)
                        durationRow("quick · controls", .quick)
                        durationRow("normal · sheets", .normal)
                        durationRow("slow · morphs", .slow)
                        durationRow("breath · idle", .breath)
                        Text("Undo window · \(Int(MurmurMotion.undoWindow)) seconds")
                            .font(MurmurType.meta)
                            .foregroundStyle(MurmurColor.textTertiary)
                    }
                }

                section("Press settle · no spring") {
                    Button {
                        lifted.toggle()
                    } label: {
                        Text(lifted ? "Settled" : "Press")
                            .font(MurmurType.bodyEm)
                            .foregroundStyle(MurmurColor.accentOn)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: MurmurSpace.hitComfort)
                            .background(MurmurColor.accent)
                            .clipShape(Capsule())
                            .scaleEffect(lifted ? MurmurMotion.pressScale : 1)
                            .animation(
                                MurmurMotion.animation(.exhale, .instant, reduceMotion: reduceMotion),
                                value: lifted
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Press")
                }

                section("Elevation · one shadow") {
                    VStack(spacing: MurmurSpace.stackDefault) {
                        elevationCard("row", .row)
                        elevationCard("card", .card)
                        elevationCard("lift", .lift)
                        elevationCard("sheet", .sheet)
                    }
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

    private func durationRow(_ label: String, _ duration: MurmurMotion.Duration) -> some View {
        let seconds = MurmurMotion.seconds(duration, reduceMotion: reduceMotion)
        let display = seconds < 0.01 ? "1ms" : (seconds >= 1 ? "\(seconds)s" : "\(Int(seconds * 1000))ms")
        return HStack {
            Text(label)
                .font(MurmurType.footnote)
                .foregroundStyle(MurmurColor.textPrimary)
            Spacer()
            Text(display)
                .font(MurmurType.meta)
                .foregroundStyle(MurmurColor.textTertiary)
        }
    }

    private func elevationCard(_ label: String, _ kind: MurmurElevation.Kind) -> some View {
        Text(label)
            .font(MurmurType.subhead)
            .foregroundStyle(MurmurColor.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(MurmurSpace.space5)
            .background(MurmurColor.bgRaised)
            .clipShape(RoundedRectangle(cornerRadius: MurmurRadius.lg, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: MurmurRadius.lg, style: .continuous)
                    .stroke(MurmurColor.lineHairline, lineWidth: MurmurRadius.strokeHairline)
            }
            .murmurShadow(kind)
    }
}

#Preview("Motion · light") {
    MotionElevationCatalog()
        .preferredColorScheme(.light)
}

#Preview("Motion · dark") {
    MotionElevationCatalog()
        .preferredColorScheme(.dark)
}

#Preview("Motion · reduced") {
    MotionElevationCatalog(forceReduceMotion: true)
        .preferredColorScheme(.light)
}
