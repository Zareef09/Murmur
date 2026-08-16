import SwiftUI
import UIKit

/// Murmur color tokens from `docs/design-system/tokens/colors.css`.
/// Ember is the only accent: Light Well (listening) and one primary action per screen.
enum MurmurColor {
    // MARK: Sand (warm neutral, no blue)
    static let sand0 = Color(hex: 0xFFFDFA)
    static let sand50 = Color(hex: 0xFAF6EF)
    static let sand100 = Color(hex: 0xF3EDE3)
    static let sand200 = Color(hex: 0xE8E0D3)
    static let sand300 = Color(hex: 0xD8CEBE)
    static let sand400 = Color(hex: 0xB9AE9C)
    static let sand500 = Color(hex: 0x948977)
    static let sand600 = Color(hex: 0x6E6455)
    static let sand700 = Color(hex: 0x4C4438)
    static let sand800 = Color(hex: 0x332D25)
    static let sand900 = Color(hex: 0x211D18)
    static let sand950 = Color(hex: 0x17140F)
    static let sand1000 = Color(hex: 0x100E0B)

    // MARK: Ember (accent ramp)
    static let ember100 = Color(hex: 0xFBEEDF)
    static let ember200 = Color(hex: 0xF6D9B8)
    static let ember300 = Color(hex: 0xEFBE8B)
    static let ember400 = Color(hex: 0xE5A063)
    static let ember500 = Color(hex: 0xD2803A)
    static let ember600 = Color(hex: 0xB4602A)
    static let ember700 = Color(hex: 0x98481D)
    static let ember800 = Color(hex: 0x77361A)

    // MARK: Moss (Reminder) — always with icon + label
    static let moss300 = Color(hex: 0xBFC79A)
    static let moss400 = Color(hex: 0x9BA778)
    static let moss600 = Color(hex: 0x6C7A4E)
    static let moss700 = Color(hex: 0x55603C)

    // MARK: Plum (Event) — always with icon + label
    static let plum300 = Color(hex: 0xD9AEBA)
    static let plum400 = Color(hex: 0xC08E9D)
    static let plum600 = Color(hex: 0x8E5F6E)
    static let plum700 = Color(hex: 0x714A57)

    // MARK: Leaf / clay
    static let leaf400 = Color(hex: 0x9FBE93)
    static let leaf600 = Color(hex: 0x5E7A55)
    static let clay400 = Color(hex: 0xE0907C)
    static let clay600 = Color(hex: 0xA8503F)

    // MARK: Bloom (breathing well) — blended hues, decorative only, never text or chips
    static let bloomEmber = Color(hex: 0xF2A24C)
    static let bloomRose = Color(hex: 0xEC8F7E)
    static let bloomLilac = Color(hex: 0xB98CC4)
    static let bloomLeaf = Color(hex: 0x86C08D)
    static let bloomSky = Color(hex: 0x6FB6D9)

    /// Decorative blend for the well: warm out to a cool centre and symmetrically back.
    ///
    /// The ramp is a palindrome on purpose. An angular gradient wraps at its start angle, and that
    /// angle drifts as the well turns — a one-way ramp shows a seam there. Mirrored, whatever meets
    /// at the wrap is the same colour on both sides, so there is no edge to find.
    static let bloomBlend: [Color] = [
        bloomEmber,
        bloomRose,
        Color(hex: 0xC98CB4),
        bloomSky,
        Color(hex: 0xC98CB4),
        bloomRose,
        bloomEmber
    ]

    /// Same hues carried deeper, for the light canvas where the pastels have no presence.
    static let bloomBlendDeep: [Color] = [
        Color(hex: 0xC2701F),
        Color(hex: 0xBE5342),
        Color(hex: 0x9A5E86),
        Color(hex: 0x4A6E9B),
        Color(hex: 0x9A5E86),
        Color(hex: 0xBE5342),
        Color(hex: 0xC2701F)
    ]

    // MARK: Semantic (light / dark) — brightened base, Session 96
    static let bgBase = Color(light: sand0, dark: Color(hex: 0x201B15))
    static let bgSunk = Color(light: sand50, dark: Color(hex: 0x171310))
    static let bgRaised = Color(light: Color(hex: 0xFFFFFF), dark: Color(hex: 0x2B251D))
    static let bgOverlay = Color(light: Color(hex: 0x211D18, alpha: 0.28), dark: Color(hex: 0x090806, alpha: 0.58))
    static let bgScrim = Color(light: Color(hex: 0xFAF6EF, alpha: 0.72), dark: Color(hex: 0x100E0B, alpha: 0.74))

    static let textPrimary = Color(light: sand900, dark: Color(hex: 0xF2EBDF))
    static let textSecondary = Color(light: sand600, dark: Color(hex: 0xA9A08F))
    static let textTertiary = Color(light: sand500, dark: Color(hex: 0x7C7365))
    static let textInverse = Color(light: sand50, dark: sand950)
    static let textAccent = Color(light: ember700, dark: ember300)

    static let lineHairline = Color(light: Color(hex: 0x211D18, alpha: 0.07), dark: Color(hex: 0xF2EBDF, alpha: 0.07))
    static let lineSoft = Color(light: Color(hex: 0x211D18, alpha: 0.12), dark: Color(hex: 0xF2EBDF, alpha: 0.13))
    static let lineStrong = Color(light: Color(hex: 0x211D18, alpha: 0.22), dark: Color(hex: 0xF2EBDF, alpha: 0.26))

    static let accent = Color(light: ember600, dark: ember400)
    static let accentHover = Color(light: ember700, dark: ember300)
    static let accentPress = Color(light: ember800, dark: ember500)
    static let accentQuiet = Color(light: ember100, dark: Color(hex: 0xE5A063, alpha: 0.14))
    static let accentOn = Color(light: sand0, dark: Color(hex: 0x241608))
    static let accentGlow = Color(light: Color(hex: 0xE5A063, alpha: 0.42), dark: Color(hex: 0xEFBE8B, alpha: 0.48))
    static let accentGlowFaint = Color(light: Color(hex: 0xE5A063, alpha: 0.16), dark: Color(hex: 0xEFBE8B, alpha: 0.18))

    static let reminderFg = Color(light: moss700, dark: moss300)
    static let reminderBg = Color(light: Color(hex: 0xEDEFE0), dark: Color(hex: 0x9BA778, alpha: 0.15))
    static let reminderLine = Color(light: Color(hex: 0x6C7A4E, alpha: 0.28), dark: Color(hex: 0xBFC79A, alpha: 0.30))

    static let eventFg = Color(light: plum700, dark: plum300)
    static let eventBg = Color(light: Color(hex: 0xF5E7EA), dark: Color(hex: 0xC08E9D, alpha: 0.15))
    static let eventLine = Color(light: Color(hex: 0x8E5F6E, alpha: 0.26), dark: Color(hex: 0xD9AEBA, alpha: 0.28))

    static let successFg = Color(light: Color(hex: 0x4A6642), dark: leaf400)
    static let successBg = Color(light: Color(hex: 0xE7EFE2), dark: Color(hex: 0x9FBE93, alpha: 0.14))
    static let attentionFg = Color(light: clay600, dark: clay400)
    static let attentionBg = Color(light: Color(hex: 0xF8E5DF), dark: Color(hex: 0xE0907C, alpha: 0.15))
}

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }

    init(light: Color, dark: Color) {
        self.init(
            uiColor: UIColor { traits in
                traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
            }
        )
    }
}
