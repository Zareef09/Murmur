import SwiftUI

/// Murmur's signature interaction: a bead of iridescent glass held inside a guilloché lattice,
/// ringed by a progress arc. Ported from `docs/design-system/components/capture/CaptureBloom.jsx`.
///
/// Three parts, each doing one job:
///   - **glass** wide iridescent gradients turning at incommensurable rates behind a spherical
///     shade, so the surface reads as light on a film
///   - **lattice** a procedural rosette (28 circles on an offset orbit) counter-turning in two
///     layers — the listening field, brightening with voice
///   - **arc** a single ember→violet sweep on the rim: the only progress signal
struct CaptureBloom: View {
    enum BloomState {
        case idle
        case listening
        case thinking
        case done
    }

    var state: BloomState = .idle
    /// Normalised amplitude. Smoothed inside (≈120ms attack, ≈400ms release).
    var level: CGFloat = 0
    var size: CGFloat = 244
    var label: String?
    var isInteractive: Bool = true
    var onTap: () -> Void = {}

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @State private var follow = AmplitudeFollow()
    @State private var coreDip: CGFloat = 1

    var body: some View {
        VStack(spacing: MurmurSpace.space6) {
            TimelineView(.animation(minimumInterval: 1 / 60, paused: reduceMotion)) { context in
                well(at: context.date)
            }
            .frame(width: size, height: size)
            .frame(width: hitSize, height: hitSize)
            .contentShape(Circle())
            .onTapGesture {
                guard isInteractive else { return }
                dipCore()
                MurmurHaptics.wellTap()
                onTap()
            }
            .accessibilityElement()
            .accessibilityLabel(label ?? AccessibilityCopy.captureWell)
            .accessibilityHint(voiceOverHint)
            .accessibilityAddTraits(isInteractive ? .isButton : [])
            .accessibilityHidden(!isInteractive && label == nil)

            if let label {
                Text(label)
                    .font(MurmurType.subhead)
                    .tracking(0.3)
                    .foregroundStyle(MurmurColor.textTertiary)
                    .accessibilityHidden(true)
            }
        }
    }

    /// Listening announces the tap as a stop, since that is what the second tap does.
    private var voiceOverHint: String {
        guard isInteractive else { return "" }
        switch state {
        case .idle: return AccessibilityCopy.wellHint
        case .listening: return AccessibilityCopy.wellStopHint
        case .thinking, .done: return ""
        }
    }

    static func hitSize(visual: CGFloat, interactive: Bool) -> CGFloat {
        interactive ? max(visual, MurmurSpace.hitHero) : visual
    }

    private var hitSize: CGFloat {
        Self.hitSize(visual: size, interactive: isInteractive)
    }

    // MARK: Geometry
    //
    // Every layer carries an explicit frame. Gradients and shapes are flexible views: left to
    // themselves they fill whatever the stack offers, which is not the same as the kit's `inset`.

    /// Kit: glass body sits at inset 7% of the button.
    private var glassSize: CGFloat { size * 0.86 }
    /// Kit: the bead sits at inset 17% of the glass body.
    private var beadSize: CGFloat { glassSize * 0.66 }

    // MARK: Composition

    private func well(at date: Date) -> some View {
        let amp = follow.tick(
            target: state == .listening ? level : 0,
            now: date,
            reduceMotion: reduceMotion
        )
        let t = reduceMotion ? 0 : date.timeIntervalSinceReferenceDate

        return ZStack {
            spill(amp: amp, t: t)
            track
            arc(amp: amp, t: t)
            glass(amp: amp, t: t)
            checkmark
        }
        .frame(width: size, height: size)
        .animation(stateMorph, value: state)
    }

    private var stateMorph: Animation {
        state == .done
            ? MurmurMotion.animation(.settle, .slow, reduceMotion: reduceMotion)
            : MurmurMotion.animation(.exhale, .slow, reduceMotion: reduceMotion)
    }

    /// Ambient spill: warm on one side, violet on the other, like the rim light.
    private func spill(amp: CGFloat, t: TimeInterval) -> some View {
        ZStack {
            RadialGradient(
                colors: [MurmurColor.accentGlow, .clear],
                center: UnitPoint(x: 0.32, y: 0.62),
                startRadius: 0,
                endRadius: size * 0.52
            )
            RadialGradient(
                colors: [MurmurColor.irisViolet.opacity(0.30), .clear],
                center: UnitPoint(x: 0.68, y: 0.34),
                startRadius: 0,
                endRadius: size * 0.54
            )
        }
        .frame(width: size * 1.68, height: size * 1.68)
        .blur(radius: size * 0.09)
        .scaleEffect(spillScale(amp))
        .opacity(spillOpacity(amp))
        .allowsHitTesting(false)
    }

    /// Faint full track behind the arc, so the ring always closes visually.
    private var track: some View {
        Circle()
            .strokeBorder(MurmurColor.lineSoft, lineWidth: 1)
            .frame(width: size, height: size)
            .opacity(0.7)
            .allowsHitTesting(false)
    }

    /// The rim arc — ember → violet, round caps, one clean sweep. The only progress signal.
    private func arc(amp: CGFloat, t: TimeInterval) -> some View {
        let sweep = sweepFraction(amp)
        return Circle()
            .trim(from: 0, to: sweep)
            .stroke(
                // Kit: a linear ramp across the box, 2%/62% → 98%/38%. Not an angular sweep.
                LinearGradient(
                    stops: [
                        .init(color: MurmurColor.irisArcFrom, location: 0),
                        .init(color: MurmurColor.irisBlush, location: 0.46),
                        .init(color: MurmurColor.irisArcTo, location: 1)
                    ],
                    startPoint: UnitPoint(x: 0.02, y: 0.62),
                    endPoint: UnitPoint(x: 0.98, y: 0.38)
                ),
                style: StrokeStyle(lineWidth: size * 0.015, lineCap: .round)
            )
            .frame(width: size * 0.968, height: size * 0.968)
            .rotationEffect(.degrees(-108 + driftDegrees(t)))
            .shadow(color: MurmurColor.irisViolet.opacity(0.55), radius: size * 0.028)
            .allowsHitTesting(false)
    }

    /// The glass body and its lattice, breathing together.
    private func glass(amp: CGFloat, t: TimeInterval) -> some View {
        ZStack {
            lattice(amp: amp, t: t)
            bead(amp: amp, t: t)
            veil(amp: amp)
        }
        .frame(width: glassSize, height: glassSize)
        .scaleEffect(breathScale(t))
        .allowsHitTesting(false)
    }

    /// Guilloché rosette: 28 circles on an offset orbit, two counter-turning layers.
    private func lattice(amp: CGFloat, t: TimeInterval) -> some View {
        ZStack {
            LatticeShape(count: 28, orbit: 0.17, radius: 0.27)
                .stroke(MurmurColor.irisBlush.opacity(0.75), lineWidth: max(0.5, size * 0.003))
                .rotationEffect(.degrees(turn(t, period: 74)))
            LatticeShape(count: 14, orbit: 0.17, radius: 0.30)
                .stroke(MurmurColor.irisViolet.opacity(0.60), lineWidth: max(0.5, size * 0.0026))
                .rotationEffect(.degrees(-turn(t, period: 96)))
        }
        .frame(width: glassSize, height: glassSize)
        .opacity(latticeOpacity(amp))
        .shadow(color: MurmurColor.irisViolet.opacity(0.6), radius: size * 0.012)
    }

    /// The bead: iridescent film inside a sphere, lit from the upper left.
    private func bead(amp: CGFloat, t: TimeInterval) -> some View {
        ZStack {
            AngularGradient(colors: MurmurColor.irisFilm, center: .center, angle: .degrees(turn(t, period: 26)))
                .blur(radius: beadSize * 0.07)
                .scaleEffect(1.18)

            // Kit blends this layer with `screen`, so it lifts the film rather than covering it.
            // Plain alpha at 0.85 flattened the whole bead to one colour.
            AngularGradient(
                colors: [
                    .clear, MurmurColor.irisMint, .clear,
                    MurmurColor.irisBlush, .clear
                ],
                center: .center,
                angle: .degrees(140 - turn(t, period: 37))
            )
            .blur(radius: beadSize * 0.09)
            .scaleEffect(1.24)
            .blendMode(.screen)
            .opacity(0.85)

            // Spherical shade: light from upper-left, terminator lower-right.
            //
            // Both radii are fractions of the *bead*, matching the kit's 28% and 52%. Scaling them
            // off the button instead made the terminator far too tight — a dark blob sitting in the
            // middle of the glass rather than a shaded side.
            RadialGradient(
                colors: [.white.opacity(0.42), .clear],
                center: UnitPoint(x: 0.34, y: 0.28),
                startRadius: 0,
                endRadius: beadSize * 0.28
            )
            RadialGradient(
                stops: [
                    .init(color: MurmurColor.irisShade, location: 0),
                    .init(color: MurmurColor.irisShade.opacity(0.35), location: 0.45),
                    .init(color: .clear, location: 1)
                ],
                center: UnitPoint(x: 0.80, y: 0.84),
                startRadius: 0,
                endRadius: beadSize * 0.62
            )

            specular(t: t)
        }
        .frame(width: beadSize, height: beadSize)
        // Contains the screen blend to the bead, so it cannot composite against the page.
        .compositingGroup()
        .clipShape(Circle())
        .overlay {
            Circle()
                .strokeBorder(.white.opacity(0.35), lineWidth: 1)
                .frame(width: beadSize, height: beadSize)
        }
        .saturation(1.05)
        .scaleEffect(beadScale(amp) * coreDip)
        .shadow(color: MurmurColor.irisViolet.opacity(0.5), radius: size * 0.10)
    }

    /// Kit: 34% × 22% of the bead, at 18%/14% from its top-left.
    private func specular(t: TimeInterval) -> some View {
        let wobble = sin(phase(t, period: 13) * 2 * .pi)
        return Ellipse()
            .fill(
                RadialGradient(
                    colors: [.white.opacity(0.92), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: beadSize * 0.20
                )
            )
            .frame(width: beadSize * 0.34, height: beadSize * 0.22)
            .blur(radius: beadSize * 0.05)
            .offset(
                x: -beadSize * 0.15 + wobble * beadSize * 0.02,
                y: -beadSize * 0.25 - wobble * beadSize * 0.02
            )
            .opacity(0.5 + 0.35 * (wobble + 1) / 2)
    }

    /// Dim veil when the glass is at rest, so idle stays quiet.
    private func veil(amp: CGFloat) -> some View {
        Circle()
            .fill(MurmurColor.bgBase)
            .frame(width: beadSize, height: beadSize)
            .opacity(veilOpacity(amp))
    }

    private var checkmark: some View {
        MurmurIcon(name: .check, size: (size * 0.13).rounded())
            .foregroundStyle(MurmurColor.accentOnLit)
            .opacity(state == .done ? 1 : 0)
            .animation(
                MurmurMotion.animation(.exhale, .normal, reduceMotion: reduceMotion).delay(
                    reduceMotion ? 0 : MurmurMotion.checkDelay
                ),
                value: state == .done
            )
    }

    // MARK: Motion

    /// Degrees for a loop of `period` seconds, wrapped to one turn.
    ///
    /// `t` is seconds since 2001, so a raw `t / period * 360` reaches ~1e10 degrees. At that
    /// magnitude a gradient's per-pixel angle variation falls below float resolution and every
    /// pixel samples the same stop — the film renders as one flat colour. Wrap first.
    private func turn(_ t: TimeInterval, period: TimeInterval) -> Double {
        guard period > 0 else { return 0 }
        return t.truncatingRemainder(dividingBy: period) / period * 360
    }

    /// 0…1 position within a loop, for wobbles that need a phase rather than an angle.
    private func phase(_ t: TimeInterval, period: TimeInterval) -> Double {
        guard period > 0 else { return 0 }
        return t.truncatingRemainder(dividingBy: period) / period
    }

    /// Short inhale, held top, long exhale — matches `mm-glass-breathe`.
    private func breathScale(_ t: TimeInterval) -> CGFloat {
        guard !reduceMotion, state == .idle || state == .listening else { return 1 }
        let period = MurmurMotion.seconds(.breath, reduceMotion: false)
        let phase = (t.truncatingRemainder(dividingBy: period)) / period
        let wave = (1 - cos(phase * 2 * .pi)) / 2
        let eased = wave * wave * (3 - 2 * wave)
        return 0.975 + CGFloat(eased) * 0.06
    }

    /// Thinking detaches the arc into a short travelling sweep.
    private func driftDegrees(_ t: TimeInterval) -> Double {
        guard !reduceMotion, state == .thinking else { return 0 }
        return turn(t, period: 2.4)
    }

    private func sweepFraction(_ amp: CGFloat) -> CGFloat {
        switch state {
        case .idle: 124.0 / 360
        case .listening: (120 + amp * 210) / 360
        case .thinking: 108.0 / 360
        case .done: 1
        }
    }

    private func spillScale(_ amp: CGFloat) -> CGFloat {
        switch state {
        case .idle: 0.96
        case .listening: 1 + amp * 0.16
        case .thinking: 0.90
        case .done: 1.10
        }
    }

    private func spillOpacity(_ amp: CGFloat) -> Double {
        switch state {
        case .idle: 0.62
        case .listening: 0.90 + Double(amp) * 0.10
        case .thinking: 0.62
        case .done: 1
        }
    }

    private func latticeOpacity(_ amp: CGFloat) -> Double {
        switch state {
        case .idle: 0.60
        case .listening: 0.68 + Double(amp) * 0.32
        case .thinking: 0.55
        case .done: 0.60
        }
    }

    private func beadScale(_ amp: CGFloat) -> CGFloat {
        switch state {
        case .idle: 1
        case .listening: 1 + amp * 0.07
        case .thinking: 0.90
        case .done: 1.10
        }
    }

    private func veilOpacity(_ amp: CGFloat) -> Double {
        let veil = colorScheme == .dark ? MurmurColor.irisVeilDark : MurmurColor.irisVeilLight
        switch state {
        case .idle: return veil
        case .listening: return veil * Double(1 - amp)
        case .thinking: return veil * 1.25
        case .done: return 0
        }
    }

    private func dipCore() {
        coreDip = MurmurMotion.coreTapDip
        withAnimation(MurmurMotion.animation(.exhale, .instant, reduceMotion: reduceMotion)) {
            coreDip = 1
        }
    }
}

/// The rosette: `count` circles of `radius` placed on an orbit of `orbit`, all as unit fractions
/// of the shape's width. Overlapping strokes make the guilloché.
struct LatticeShape: Shape {
    var count: Int
    var orbit: CGFloat
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let side = min(rect.width, rect.height)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let step = count == 0 ? 1 : count
        for index in 0..<step {
            let angle = (CGFloat(index) / CGFloat(step)) * 2 * .pi
            let dot = CGPoint(
                x: center.x + orbit * side * cos(angle),
                y: center.y + orbit * side * sin(angle)
            )
            let r = radius * side
            path.addEllipse(in: CGRect(x: dot.x - r, y: dot.y - r, width: r * 2, height: r * 2))
        }
        return path
    }
}

/// Attack 120ms, release 400ms, so the well follows the voice as breath rather than as a meter.
private final class AmplitudeFollow {
    private var value: CGFloat = 0
    private var lastDate: Date?

    @discardableResult
    func tick(target: CGFloat, now: Date, reduceMotion: Bool) -> CGFloat {
        let clamped = min(1, max(0, target))
        if reduceMotion {
            value = clamped
            lastDate = now
            return value
        }
        let dt = min(0.05, now.timeIntervalSince(lastDate ?? now))
        lastDate = now
        let tau: TimeInterval = clamped > value ? 0.12 : 0.40
        value += (clamped - value) * (1 - CGFloat(exp(-dt / tau)))
        return value
    }
}
