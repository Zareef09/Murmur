import SwiftUI

/// One primary per screen. Ember fill for primary; hairline secondary; bare ghost. Press settles, no spring.
struct MurmurButton: View {
    enum Variant {
        case primary
        case secondary
        case ghost
    }

    enum Size {
        case sm
        case md
        case lg

        var minHeight: CGFloat {
            switch self {
            case .sm: 40
            case .md: 52
            case .lg: 60
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .sm: MurmurSpace.space5
            case .md: 22
            case .lg: 28
            }
        }

        var ghostHorizontalPadding: CGFloat {
            self == .sm ? 10 : 14
        }

        var iconSize: CGFloat {
            self == .sm ? 16 : 19
        }
    }

    var title: String
    var variant: Variant = .primary
    var size: Size = .lg
    var icon: MurmurIconName?
    var iconAfter: MurmurIconName?
    var systemIcon: String?
    var fullWidth: Bool = false
    var isDisabled: Bool = false
    /// Ghost + attention color. No red fill.
    var isDestructive: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: MurmurSpace.space3) {
                if let systemIcon {
                    Image(systemName: systemIcon)
                        .font(.system(size: size.iconSize * 0.9, weight: .medium))
                }
                if let icon {
                    MurmurIcon(name: icon, size: size.iconSize)
                }
                Text(title)
                if let iconAfter {
                    MurmurIcon(name: iconAfter, size: size.iconSize)
                }
            }
            .font(size == .sm ? MurmurType.subhead : MurmurType.bodyEm)
        }
        .buttonStyle(
            MurmurButtonStyle(
                variant: variant,
                size: size,
                fullWidth: fullWidth,
                isDisabled: isDisabled,
                isDestructive: isDestructive
            )
        )
        .disabled(isDisabled)
        .accessibilityLabel(title)
    }
}

private struct MurmurButtonStyle: ButtonStyle {
    var variant: MurmurButton.Variant
    var size: MurmurButton.Size
    var fullWidth: Bool
    var isDisabled: Bool
    var isDestructive: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed && !isDisabled
        configuration.label
            .foregroundStyle(foreground)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(minHeight: size.minHeight)
            .padding(.horizontal, horizontalPadding)
            .background(fill(pressed: pressed))
            .overlay {
                Capsule()
                    .strokeBorder(borderColor(pressed: pressed), lineWidth: MurmurRadius.strokeHairline)
            }
            .clipShape(Capsule())
            .opacity(isDisabled ? 0.38 : 1)
            .scaleEffect(pressed ? MurmurMotion.pressScale : 1)
            .animation(
                MurmurMotion.animation(.exhale, .instant, reduceMotion: reduceMotion),
                value: pressed
            )
            .animation(
                MurmurMotion.animation(.exhale, .quick, reduceMotion: reduceMotion),
                value: pressed
            )
    }

    private var horizontalPadding: CGFloat {
        variant == .ghost ? size.ghostHorizontalPadding : size.horizontalPadding
    }

    private var foreground: Color {
        if isDestructive { return MurmurColor.attentionFg }
        switch variant {
        case .primary: return MurmurColor.accentOn
        case .secondary: return MurmurColor.textPrimary
        case .ghost: return MurmurColor.textAccent
        }
    }

    private func fill(pressed: Bool) -> Color {
        switch variant {
        case .primary:
            return pressed ? MurmurColor.accentPress : MurmurColor.accent
        case .secondary:
            return .clear
        case .ghost:
            return pressed ? MurmurColor.accentQuiet : .clear
        }
    }

    private func borderColor(pressed: Bool) -> Color {
        switch variant {
        case .primary, .ghost:
            return .clear
        case .secondary:
            return pressed ? MurmurColor.lineStrong : MurmurColor.lineSoft
        }
    }
}
