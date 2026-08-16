import SwiftUI

/// Capture well at Home Screen scale: warm ground, two rings, ember core. Not a microphone.
struct AppIconView: View {
    enum Theme {
        case light
        case dark
    }

    var size: CGFloat = 120
    var theme: Theme?

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let dark = resolved == .dark
        let weight = max(1, size * 0.008)
        ZStack {
            RadialGradient(
                colors: dark
                    ? [Color(hex: 0x34291D), Color(hex: 0x17130E)]
                    : [Color(hex: 0xFDF3E4), Color(hex: 0xF0E2CD)],
                center: UnitPoint(x: 0.5, y: 0.34),
                startRadius: 0,
                endRadius: size * 0.85
            )
            ring(percent: 0.78, alpha: dark ? 0.30 : 0.22, weight: weight, dark: dark)
            ring(percent: 0.54, alpha: dark ? 0.42 : 0.30, weight: weight, dark: dark)
            Circle()
                .fill(dark ? MurmurColor.ember400 : MurmurColor.ember600)
                .padding(size * 0.38)
                .shadow(
                    color: dark ? Color(hex: 0xEFBE8B, alpha: 0.50) : Color(hex: 0xD2803A, alpha: 0.42),
                    radius: size * 0.22,
                    x: 0,
                    y: 0
                )
        }
        .frame(width: size, height: size)
        .clipShape(iconShape)
        .murmurShadow(.card)
        .accessibilityLabel("murmur")
    }

    private var resolved: Theme {
        theme ?? (colorScheme == .dark ? .dark : .light)
    }

    private var iconShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: size * MurmurRadius.icon, style: .continuous)
    }

    private func ring(percent: CGFloat, alpha: Double, weight: CGFloat, dark: Bool) -> some View {
        let inset = size * (1 - percent) / 2
        return Circle()
            .strokeBorder(
                (dark ? Color(hex: 0xEFBE8B) : Color(hex: 0x98481D)).opacity(alpha),
                lineWidth: weight
            )
            .padding(inset)
    }
}
