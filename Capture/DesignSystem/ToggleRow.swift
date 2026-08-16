import SwiftUI

/// Settings preference. Ember track when on; the label is the meaning, the description is the why.
struct ToggleRow: View {
    var label: String
    var description: String?
    @Binding var isOn: Bool
    var divider: Bool = true
    var isDisabled: Bool = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            HStack(alignment: .center, spacing: MurmurSpace.space5) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(label)
                        .font(MurmurType.body)
                        .tracking(MurmurType.trackingBody)
                        .foregroundStyle(MurmurColor.textPrimary)
                    if let description {
                        Text(description)
                            .font(MurmurType.footnote)
                            .tracking(MurmurType.trackingFootnote)
                            .foregroundStyle(MurmurColor.textTertiary)
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                track
            }
            .padding(.horizontal, MurmurSpace.space5)
            .padding(.vertical, MurmurSpace.space4)
            .frame(minHeight: MurmurSpace.hitComfort)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.38 : 1)
        .overlay(alignment: .bottom) {
            if divider {
                MurmurColor.lineHairline.frame(height: MurmurRadius.strokeHairline)
            }
        }
        .accessibilityLabel(label)
        .accessibilityValue(isOn ? "On" : "Off")
        .accessibilityAddTraits(.isToggle)
        .accessibilityHint(description ?? "")
    }

    private var track: some View {
        Capsule()
            .fill(isOn ? MurmurColor.accent : MurmurColor.lineSoft)
            .frame(width: 52, height: 32)
            .overlay(alignment: isOn ? .trailing : .leading) {
                Circle()
                    .fill(MurmurColor.bgRaised)
                    .frame(width: 26, height: 26)
                    .padding(3)
                    .murmurShadow(.row)
            }
            .animation(
                MurmurMotion.animation(.exhale, .quick, reduceMotion: reduceMotion),
                value: isOn
            )
    }
}
