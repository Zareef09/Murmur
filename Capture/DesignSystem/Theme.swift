import SwiftUI

/// App chrome: linen canvas and the one permitted gradient (off-centre ember wash).
enum Theme {
    /// Kit: 50% 12% — slightly above centre so the well sits in thumb reach later.
    static let washUnitPoint = UnitPoint(x: 0.5, y: 0.12)
}

/// Radial ember at 12% opacity-class (`accent-glow-faint`) over `bg-base`. Capture / confirm / clarify / onboarding.
struct MurmurLightWash: View {
    var isOn: Bool

    var body: some View {
        GeometryReader { geo in
            ZStack {
                MurmurColor.bgBase
                if isOn {
                    RadialGradient(
                        colors: [MurmurColor.accentGlowFaint, Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: min(geo.size.width, geo.size.height) * 0.62
                    )
                    .frame(width: geo.size.width * 1.20, height: geo.size.height * 0.68)
                    .position(
                        x: geo.size.width * Theme.washUnitPoint.x,
                        y: geo.size.height * Theme.washUnitPoint.y
                    )
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                }
            }
        }
        .ignoresSafeArea()
    }
}

private struct MurmurCanvasModifier: ViewModifier {
    var wash: Bool

    func body(content: Content) -> some View {
        content.background {
            MurmurLightWash(isOn: wash)
        }
    }
}

extension View {
    /// Linen canvas. `wash` is the capture-family ambient light only.
    func murmurCanvas(wash: Bool = false) -> some View {
        modifier(MurmurCanvasModifier(wash: wash))
    }
}
