import SwiftUI

/// Motion tokens from `docs/design-system/tokens/motion.css`.
/// No springs, overshoot, bounce, or confetti. Reduce Motion collapses timed motion to 1ms
/// (press `instant` and the Undo window stay as designed).
enum MurmurMotion {
    static let undoWindow: TimeInterval = 5

    static let pressScale: CGFloat = 0.982

    enum Curve {
        case exhale
        case inhale
        case settle
        case exit
    }

    enum Duration {
        case instant
        case quick
        case normal
        case slow
        case breath
    }

    static func seconds(_ duration: Duration, reduceMotion: Bool) -> TimeInterval {
        switch duration {
        case .instant:
            return 0.120
        case .quick:
            return reduceMotion ? 0.001 : 0.220
        case .normal:
            return reduceMotion ? 0.001 : 0.380
        case .slow:
            return reduceMotion ? 0.001 : 0.620
        case .breath:
            return reduceMotion ? 0.001 : 3.800
        }
    }

    static func animation(_ curve: Curve, _ duration: Duration, reduceMotion: Bool) -> Animation {
        let time = seconds(duration, reduceMotion: reduceMotion)
        switch curve {
        case .exhale:
            return .timingCurve(0.22, 0.61, 0.24, 1, duration: time)
        case .inhale:
            return .timingCurve(0.42, 0, 0.58, 1, duration: time)
        case .settle:
            return .timingCurve(0.16, 0.84, 0.28, 1, duration: time)
        case .exit:
            return .timingCurve(0.4, 0, 0.7, 0.3, duration: time)
        }
    }
}
