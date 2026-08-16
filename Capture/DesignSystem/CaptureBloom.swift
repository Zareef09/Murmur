import SwiftUI

/// Light Well: idle breath, listening bloom, thinking hold, done settle.
/// `level` is 0…1. The well follows with attack/release and ring lag so it reads as breath, not a meter.
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
    var size: CGFloat = 240
    var label: String?
    var isInteractive: Bool = true
    var onTap: () -> Void = {}

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var follow = AmplitudeFollow()
    @State private var breathHold = BreathHold()
    @State private var coreDip: CGFloat = 1

    var body: some View {
        VStack(spacing: MurmurSpace.space6) {
            TimelineView(.animation(minimumInterval: 1 / 30, paused: reduceMotion || state == .done)) { context in
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
            .accessibilityHint(isInteractive && state == .idle ? AccessibilityCopy.wellHint : "")
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

    static func hitSize(visual: CGFloat, interactive: Bool) -> CGFloat {
        interactive ? max(visual, MurmurSpace.hitHero) : visual
    }

    private var hitSize: CGFloat {
        Self.hitSize(visual: size, interactive: isInteractive)
    }

    private func well(at date: Date) -> some View {
        let smoothed = follow.tick(
            target: state == .listening ? level : 0,
            now: date,
            reduceMotion: reduceMotion
        )
        let spin = thinkingSpin(at: date)
        return ZStack {
            bloom(level: smoothed)
            ring(percent: 1.00, weight: 1, date: date, lag: 180, level: smoothed)
            ring(percent: 0.76, weight: 1, date: date, lag: 90, level: smoothed)
            ring(percent: 0.54, weight: 1.5, date: date, lag: 0, level: smoothed)
            thinkingArc(spin: spin)
            core(level: smoothed)
            checkmark
        }
        .frame(width: size, height: size)
        .animation(stateMorph, value: state)
    }

    private var stateMorph: Animation {
        if state == .done {
            MurmurMotion.animation(.settle, .slow, reduceMotion: reduceMotion)
        } else {
            MurmurMotion.animation(.exhale, .slow, reduceMotion: reduceMotion)
        }
    }

    private func bloom(level: CGFloat) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [MurmurColor.accentGlow, MurmurColor.accentGlowFaint, .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: size * 0.68
                )
            )
            .frame(width: size * 1.52, height: size * 1.52)
            .scaleEffect(bloomScale(level))
            .opacity(bloomOpacity(level))
            .blur(radius: 2)
            .allowsHitTesting(false)
    }

    private func ring(percent: CGFloat, weight: CGFloat, date: Date, lag: Double, level: CGFloat) -> some View {
        let inset = size * (1 - percent) / 2
        let lagged = state == .listening ? follow.lagged(lag, at: date) : level
        let hold = breathHold.tick(
            lag: lag,
            live: idleBreath(at: date, lagMs: lag * 4),
            idle: state == .idle
        )
        return Circle()
            .strokeBorder(MurmurColor.accent, lineWidth: weight)
            .padding(inset)
            .scaleEffect(ringScale(lagged) * hold.scale)
            .opacity(ringOpacity(lagged) * hold.opacity)
    }

    private func thinkingArc(spin: Double) -> some View {
        Circle()
            .trim(from: 0, to: 0.22)
            .stroke(MurmurColor.accent, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
            .padding(size * 0.12)
            .rotationEffect(.degrees(spin))
            .opacity(state == .thinking ? 0.85 : 0)
    }

    private func core(level: CGFloat) -> some View {
        Circle()
            .fill(MurmurColor.accent)
            .padding(size * 0.38)
            .scaleEffect(coreScale(level) * coreDip)
            .opacity(coreOpacity(level))
            .murmurShadow(state == .listening ? .listening : .none)
    }

    private var checkmark: some View {
        MurmurIcon(name: .check, size: (size * 0.13).rounded())
            .foregroundStyle(MurmurColor.accentOn)
            .opacity(state == .done ? 1 : 0)
            .animation(
                MurmurMotion.animation(.exhale, .normal, reduceMotion: reduceMotion).delay(
                    reduceMotion ? 0 : MurmurMotion.checkDelay
                ),
                value: state == .done
            )
    }

    private func bloomScale(_ level: CGFloat) -> CGFloat {
        switch state {
        case .idle: 0.8
        case .listening: 0.86 + level * 0.42
        case .thinking: 0.74
        case .done: 0.9
        }
    }

    private func bloomOpacity(_ level: CGFloat) -> Double {
        switch state {
        case .idle: 0.42
        case .listening: 0.55 + Double(level) * 0.45
        case .thinking: 0.6
        case .done: 0.7
        }
    }

    private func ringScale(_ level: CGFloat) -> CGFloat {
        switch state {
        case .listening: 1 + level * 0.10
        case .thinking: 0.94
        case .idle, .done: 1
        }
    }

    private func ringOpacity(_ level: CGFloat) -> Double {
        switch state {
        case .listening: 0.20 + Double(level) * 0.34
        case .thinking: 0.20
        case .idle, .done: 0.16
        }
    }

    private func coreScale(_ level: CGFloat) -> CGFloat {
        switch state {
        case .done: 1.14
        case .listening: 1 + level * 0.06
        case .idle, .thinking: 1
        }
    }

    private func coreOpacity(_ level: CGFloat) -> Double {
        switch state {
        case .idle: 0.26
        case .listening: 0.5 + Double(level) * 0.4
        case .thinking: 0.4
        case .done: 1
        }
    }

    private func dipCore() {
        coreDip = MurmurMotion.coreTapDip
        withAnimation(MurmurMotion.animation(.exhale, .instant, reduceMotion: reduceMotion)) {
            coreDip = 1
        }
    }

    private func idleBreath(at date: Date, lagMs: Double) -> BloomBreath {
        guard state == .idle, !reduceMotion else {
            return BloomBreath(scale: 1, opacity: 1)
        }
        let period = MurmurMotion.seconds(.breath, reduceMotion: false)
        let t = date.timeIntervalSinceReferenceDate - lagMs / 1000
        let wave = (1 - cos(t * 2 * .pi / period)) / 2
        return BloomBreath(scale: 1 + 0.045 * wave, opacity: 0.82 + 0.18 * wave)
    }

    private func thinkingSpin(at date: Date) -> Double {
        guard state == .thinking, !reduceMotion else { return -90 }
        return date.timeIntervalSinceReferenceDate / 2.6 * 360 - 90
    }
}

/// Freeze idle breath when leaving idle so the loop does not snap back.
private struct BloomBreath {
    var scale: CGFloat
    var opacity: Double
}

private final class BreathHold {
    private var held: [Double: BloomBreath] = [:]

    func tick(lag: Double, live: BloomBreath, idle: Bool) -> BloomBreath {
        if idle {
            held[lag] = live
            return live
        }
        return held[lag] ?? BloomBreath(scale: 1, opacity: 1)
    }
}

/// Attack 120ms, release 400ms. Ring lag is sampled from this history.
private final class AmplitudeFollow {
    private var value: CGFloat = 0
    private var lastDate: Date?
    private var history: [(Date, CGFloat)] = []

    @discardableResult
    func tick(target: CGFloat, now: Date, reduceMotion: Bool) -> CGFloat {
        let clamped = min(1, max(0, target))
        if reduceMotion {
            value = clamped
            lastDate = now
            history = [(now, value)]
            return value
        }
        let dt = min(0.05, now.timeIntervalSince(lastDate ?? now))
        lastDate = now
        let tau: TimeInterval = clamped > value ? 0.12 : 0.40
        value += (clamped - value) * (1 - CGFloat(exp(-dt / tau)))
        history.append((now, value))
        history.removeAll { now.timeIntervalSince($0.0) > 0.4 }
        return value
    }

    func lagged(_ milliseconds: Double, at now: Date) -> CGFloat {
        let stamp = now.addingTimeInterval(-milliseconds / 1000)
        if let sample = history.last(where: { $0.0 <= stamp }) {
            return sample.1
        }
        return history.first?.1 ?? value
    }
}
