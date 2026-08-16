import CoreGraphics

/// Spacing, gutters, stacks, and touch targets from `docs/design-system/tokens/spacing.css`.
enum MurmurSpace {
    static let space1: CGFloat = 2
    static let space2: CGFloat = 4
    static let space3: CGFloat = 8
    static let space4: CGFloat = 12
    static let space5: CGFloat = 16
    static let space6: CGFloat = 20
    static let space7: CGFloat = 24
    static let space8: CGFloat = 32
    static let space9: CGFloat = 40
    static let space10: CGFloat = 56
    static let space11: CGFloat = 80
    static let space12: CGFloat = 120

    static let gutterScreen: CGFloat = space7
    static let gutterSheet: CGFloat = space7
    static let stackTight: CGFloat = space3
    static let stackDefault: CGFloat = space5
    static let stackLoose: CGFloat = space8
    static let stackSection: CGFloat = space10

    /// Floor for any control. One-handed, in motion.
    static let hitMin: CGFloat = 44
    static let hitComfort: CGFloat = 56
    static let hitHero: CGFloat = 96
}

/// Corner radii from `docs/design-system/tokens/radius.css`. Nothing sharper than `xs` (8).
enum MurmurRadius {
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 22
    static let xl: CGFloat = 28
    static let xxl: CGFloat = 36
    static let pill: CGFloat = 999
    /// iOS squircle approximation for the app icon (24%).
    static let icon: CGFloat = 0.24

    static let strokeHairline: CGFloat = 1
    static let strokeFocus: CGFloat = 2
}
