import SwiftUI

/// `Murmur` in Hanken Grotesk light, tracked 0.13em. Never bold, never another family.
struct Wordmark: View {
    static let text = "Murmur"

    enum Tone {
        case primary
        case inverse
        case accent
        /// Capture chrome. Ember stays on the Light Well.
        case tertiary
    }

    var size: CGFloat = 28
    var tone: Tone = .primary
    var showsDot: Bool = true
    /// Em units. Capture chrome uses 0.16; elsewhere 0.13.
    var trackingEm: CGFloat = 0.13

    private var cap: CGFloat { max(size, 18) }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: cap * 0.16) {
            Text(Self.text)
                .font(MurmurType.core(size: cap, relativeTo: .title, weight: .light))
                .tracking(cap * trackingEm)
                .foregroundStyle(color)
            if showsDot {
                Circle()
                    .fill(MurmurColor.accent)
                    .frame(width: dotSize, height: dotSize)
                    .offset(x: -cap * 0.05)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Self.text)
    }

    private var dotSize: CGFloat { max(4, cap * 0.145) }

    private var color: Color {
        switch tone {
        case .primary: MurmurColor.textPrimary
        case .inverse: MurmurColor.textInverse
        case .accent: MurmurColor.textAccent
        case .tertiary: MurmurColor.textTertiary
        }
    }
}
