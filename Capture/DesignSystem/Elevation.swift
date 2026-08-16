import SwiftUI

/// Elevation from `docs/design-system/tokens/elevation.css`.
/// Warm, low-opacity shadows. Never stack two (listening glow is the exception).
enum MurmurElevation {
    static let blurScrim: CGFloat = 20

    enum Kind {
        case none
        case row
        case card
        case sheet
        case lift
        case listening
    }

    static func shadow(_ kind: Kind, colorScheme: ColorScheme) -> (color: Color, radius: CGFloat, y: CGFloat) {
        let dark = colorScheme == .dark
        switch kind {
        case .none:
            return (.clear, 0, 0)
        case .row:
            return (
                dark ? Color(hex: 0x000000, alpha: 0.32) : Color(hex: 0x3A2D1E, alpha: 0.04),
                1,
                1
            )
        case .card:
            return (
                dark ? Color(hex: 0x000000, alpha: 0.38) : Color(hex: 0x3A2D1E, alpha: 0.05),
                dark ? 6 : 5,
                2
            )
        case .sheet:
            return (
                dark ? Color(hex: 0x000000, alpha: 0.52) : Color(hex: 0x2D2216, alpha: 0.10),
                dark ? 22 : 20,
                -8
            )
        case .lift:
            return (
                dark ? Color(hex: 0x000000, alpha: 0.46) : Color(hex: 0x2D2216, alpha: 0.09),
                dark ? 16 : 14,
                dark ? 10 : 8
            )
        case .listening:
            return (MurmurColor.accentGlow, 32, 0)
        }
    }
}

extension View {
    func murmurShadow(_ kind: MurmurElevation.Kind) -> some View {
        modifier(MurmurShadowModifier(kind: kind))
    }
}

private struct MurmurShadowModifier: ViewModifier {
    let kind: MurmurElevation.Kind
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        let shadow = MurmurElevation.shadow(kind, colorScheme: colorScheme)
        content.shadow(color: shadow.color, radius: shadow.radius, x: 0, y: shadow.y)
    }
}
