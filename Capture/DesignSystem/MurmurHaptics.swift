import UIKit

/// Storyboard haptics. Soft tap on the well; a light tick when a save lands. No sound.
enum MurmurHaptics {
    static func wellTap() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    static func saved() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
