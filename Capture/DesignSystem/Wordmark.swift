import SwiftUI

/// Always lowercase `murmur`, Hanken Grotesk light, tracked 0.13em. Never bold, never another family.
struct Wordmark: View {
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

    private var cap: CGFloat { max(size, 18) }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: cap * 0.16) {
            Text("murmur")
                .font(MurmurType.core(size: cap, relativeTo: .title, weight: .light))
                .tracking(cap * 0.13)
                .foregroundStyle(color)
            if showsDot {
                Circle()
                    .fill(MurmurColor.accent)
                    .frame(width: dotSize, height: dotSize)
                    .offset(x: -cap * 0.05)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("murmur")
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
