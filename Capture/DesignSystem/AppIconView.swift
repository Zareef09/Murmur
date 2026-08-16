import SwiftUI

/// The Murmur mark: a single letter M, drawn as a path so it never depends on a font being loaded.
///
/// Normalised to a unit square. `Scripts/GenerateAppIcon.swift` draws the same five points in
/// CoreGraphics — keep the two in step.
enum MurmurMark {
    /// Vertical stem, V, vertical stem. Read left to right.
    static let points: [CGPoint] = [
        CGPoint(x: 0.26, y: 0.72),
        CGPoint(x: 0.26, y: 0.29),
        CGPoint(x: 0.50, y: 0.60),
        CGPoint(x: 0.74, y: 0.29),
        CGPoint(x: 0.74, y: 0.72)
    ]

    /// Stroke weight as a fraction of the icon edge.
    static let strokeRatio: CGFloat = 0.105
}

/// The M as a stroked shape, scaled to whatever rect it is given.
struct MurmurMarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let scaled = MurmurMark.points.map { point in
            CGPoint(x: rect.minX + point.x * rect.width, y: rect.minY + point.y * rect.height)
        }
        guard let first = scaled.first else { return path }
        path.move(to: first)
        for point in scaled.dropFirst() {
            path.addLine(to: point)
        }
        return path
    }
}

/// Home Screen icon: warm ground, the letter M. Not a microphone.
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
        ZStack {
            RadialGradient(
                colors: dark
                    ? [Color(hex: 0x2E2820), Color(hex: 0x14110D)]
                    : [Color(hex: 0xFFFDFA), Color(hex: 0xF0E2CD)],
                center: UnitPoint(x: 0.5, y: 0.34),
                startRadius: 0,
                endRadius: size * 0.85
            )
            MurmurMarkShape()
                .stroke(
                    dark ? Color(hex: 0xF6F0E6) : MurmurColor.ember700,
                    style: StrokeStyle(
                        lineWidth: size * MurmurMark.strokeRatio,
                        lineCap: .butt,
                        lineJoin: .miter,
                        miterLimit: 10
                    )
                )
                .shadow(
                    color: dark
                        ? Color(hex: 0xEFBE8B, alpha: 0.22)
                        : Color(hex: 0xD2803A, alpha: 0.18),
                    radius: size * 0.10
                )
        }
        .frame(width: size, height: size)
        .clipShape(iconShape)
        .murmurShadow(.card)
        .accessibilityLabel(Wordmark.text)
    }

    private var resolved: Theme {
        theme ?? (colorScheme == .dark ? .dark : .light)
    }

    private var iconShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: size * MurmurRadius.icon, style: .continuous)
    }
}

#Preview("App icon · light") {
    AppIconView(size: 120, theme: .light)
        .padding(40)
}

#Preview("App icon · dark") {
    AppIconView(size: 120, theme: .dark)
        .padding(40)
}
