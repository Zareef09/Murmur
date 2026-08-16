import SwiftUI

/// The well breathes continuously and blends its colours as it turns. Listening deepens the same
/// breath rather than switching to a different animation, so the loop never snaps between states.
/// `level` is 0…1 and is smoothed inside (≈120ms attack, ≈400ms release).
struct CaptureBloom: View {
    enum BloomState {
        case idle
        case listening
        case thinking
        case done
    }

    var state: BloomState = .idle
    var level: CGFloat = 0
    var size: CGFloat = 240
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

    // MARK: Composition

    private func well(at date: Date) -> some View {
        let amp = follow.tick(
            target: state == .listening ? level : 0,
            now: date,
            reduceMotion: reduceMotion
        )
        let breath = breathWave(at: date)
        let spin = spin(at: date)
        let swell = swell(breath: breath, amp: amp)

        // No drawingGroup and no plusLighter here on purpose: both composite a rectangular buffer,
        // which shows up as a hard box behind the glow.
        return ZStack {
            haze(spin: spin, swell: swell, amp: amp)
            halo(spin: spin, swell: swell, amp: amp)
            core(spin: spin, swell: swell, amp: amp)
            checkmark
        }
        .frame(width: size, height: size)
        .animation(stateMorph, value: state)
    }

    /// Every layer fades to clear at its own edge, so the well has no boundary anywhere.
    private var softEdge: RadialGradient {
        RadialGradient(
            colors: [.white, .white.opacity(0.45), .clear],
            center: .center,
            startRadius: 0,
            endRadius: size * 0.58
        )
    }

    private var stateMorph: Animation {
        state == .done
            ? MurmurMotion.animation(.settle, .slow, reduceMotion: reduceMotion)
            : MurmurMotion.animation(.exhale, .slow, reduceMotion: reduceMotion)
    }

    /// Wide soft cloud. Carries the colour, masked to nothing at its rim so it never reads as a disc.
    private func haze(spin: Double, swell: CGFloat, amp: CGFloat) -> some View {
        Circle()
            .fill(blend(spin: spin))
            .frame(width: size * 1.12, height: size * 1.12)
            .mask(softEdge)
            .blur(radius: size * 0.03)
            .scaleEffect(swell)
            .opacity(lit(hazeOpacity(amp)))
            .allowsHitTesting(false)
    }

    /// The readable edge of the well. Breathes slightly behind the haze so the motion reads as depth.
    private func halo(spin: Double, swell: CGFloat, amp: CGFloat) -> some View {
        Circle()
            .strokeBorder(blend(spin: -spin * 0.6), lineWidth: size * 0.022)
            .frame(width: size * 0.80, height: size * 0.80)
            .scaleEffect(swell * 0.99)
            .opacity(lit(haloOpacity(amp)))
            .allowsHitTesting(false)
    }

    /// Bright centre. Keeps a warm heart so the blend never reads as a cold grey.
    private func core(spin: Double, swell: CGFloat, amp: CGFloat) -> some View {
        Circle()
            .fill(blend(spin: spin * 1.4))
            .frame(width: size * 0.42, height: size * 0.42)
            .mask(
                RadialGradient(
                    colors: [.white, .white, .white.opacity(0.9), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: size * 0.21
                )
            )
            .scaleEffect(swell * coreDip)
            .opacity(lit(coreOpacity(amp)))
            .allowsHitTesting(false)
    }

    private var checkmark: some View {
        MurmurIcon(name: .check, size: (size * 0.15).rounded())
            .foregroundStyle(MurmurColor.textInverse)
            .opacity(state == .done ? 1 : 0)
            .animation(
                MurmurMotion.animation(.exhale, .normal, reduceMotion: reduceMotion).delay(
                    reduceMotion ? 0 : MurmurMotion.checkDelay
                ),
                value: state == .done
            )
    }

    /// Light canvases need the deeper hues; the pastels vanish against near-white.
    private func blend(spin: Double) -> AngularGradient {
        AngularGradient(
            colors: colorScheme == .dark ? MurmurColor.bloomBlend : MurmurColor.bloomBlendDeep,
            center: .center,
            angle: .degrees(spin)
        )
    }

    // MARK: Motion

    /// 0…1 continuous breath. Frozen mid-cycle under Reduce Motion so the well still reads as lit.
    ///
    /// A raw cosine spends most of its time mid-stroke, which reads as a hum. Smoothstep pushes the
    /// curve toward its ends, so the well holds full and holds empty and moves decisively between —
    /// the shape of a breath rather than a wobble.
    private func breathWave(at date: Date) -> CGFloat {
        guard !reduceMotion, state != .done else { return 0.5 }
        let period = MurmurMotion.seconds(.breath, reduceMotion: false)
        let t = date.timeIntervalSinceReferenceDate
        let raw = CGFloat((1 - cos(t * 2 * .pi / period)) / 2)
        return raw * raw * (3 - 2 * raw)
    }

    /// Colour rotation. Thinking spins faster; everything else drifts.
    private func spin(at date: Date) -> Double {
        guard !reduceMotion else { return 0 }
        let t = date.timeIntervalSinceReferenceDate
        return state == .thinking ? t / 2.2 * 360 : t / 14 * 360
    }

    private func swell(breath: CGFloat, amp: CGFloat) -> CGFloat {
        switch state {
        case .idle: 0.88 + breath * 0.12
        case .listening: 0.94 + breath * 0.08 + amp * 0.24
        case .thinking: 0.86 + breath * 0.06
        case .done: 1.06
        }
    }

    /// Light mode needs more ink for the same presence: the canvas is nearly white.
    private var toneBoost: Double {
        colorScheme == .dark ? 1 : 1.4
    }

    private func lit(_ value: Double) -> Double {
        min(1, value * toneBoost)
    }

    // Translucent throughout: the canvas reads through every layer.
    private func hazeOpacity(_ amp: CGFloat) -> Double {
        switch state {
        case .idle: 0.30
        case .listening: 0.38 + Double(amp) * 0.22
        case .thinking: 0.32
        case .done: 0.40
        }
    }

    private func haloOpacity(_ amp: CGFloat) -> Double {
        switch state {
        case .idle: 0.45
        case .listening: 0.58 + Double(amp) * 0.28
        case .thinking: 0.50
        case .done: 0.62
        }
    }

    private func coreOpacity(_ amp: CGFloat) -> Double {
        switch state {
        case .idle: 0.55
        case .listening: 0.68 + Double(amp) * 0.26
        case .thinking: 0.58
        case .done: 0.85
        }
    }

    private func dipCore() {
        coreDip = MurmurMotion.coreTapDip
        withAnimation(MurmurMotion.animation(.exhale, .instant, reduceMotion: reduceMotion)) {
            coreDip = 1
        }
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
