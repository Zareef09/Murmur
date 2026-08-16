import SwiftUI

/// Circular icon-only control. Hit area never below 44. Accent tone is reserved (not on capture home).
struct MurmurIconButton: View {
    enum Tone {
        case quiet
        case surface
        case accent
    }

    var name: MurmurIconName
    var label: String
    var size: CGFloat = MurmurSpace.hitMin
    var tone: Tone = .quiet
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            MurmurIcon(name: name, size: (max(size, MurmurSpace.hitMin) * 0.45).rounded())
        }
        .buttonStyle(
            MurmurIconButtonStyle(
                size: max(size, MurmurSpace.hitMin),
                tone: tone
            )
        )
        .accessibilityLabel(label)
    }
}

private struct MurmurIconButtonStyle: ButtonStyle {
    var size: CGFloat
    var tone: MurmurIconButton.Tone
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        configuration.label
            .foregroundStyle(foreground)
            .frame(width: size, height: size)
            .background(fill(pressed: pressed))
            .clipShape(Circle())
            .murmurShadow(tone == .surface ? .row : .none)
            .scaleEffect(pressed ? 0.94 : 1)
            .animation(
                MurmurMotion.animation(.exhale, .instant, reduceMotion: reduceMotion),
                value: pressed
            )
            .animation(
                MurmurMotion.animation(.exhale, .quick, reduceMotion: reduceMotion),
                value: pressed
            )
    }

    private var foreground: Color {
        switch tone {
        case .quiet, .surface: return MurmurColor.textSecondary
        case .accent: return MurmurColor.accentOn
        }
    }

    private func fill(pressed: Bool) -> Color {
        switch tone {
        case .quiet:
            return pressed ? MurmurColor.bgSunk : .clear
        case .surface:
            return MurmurColor.bgRaised
        case .accent:
            return pressed ? MurmurColor.accentPress : MurmurColor.accent
        }
    }
}
