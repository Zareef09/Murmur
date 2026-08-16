import SwiftUI

/// Bundled OFL families. No CDN at runtime.
enum MurmurFont {
    static let core = "Hanken Grotesk"
    static let meta = "IBM Plex Mono"
}

/// Type roles from `docs/design-system/tokens/typography.css`. Weight ceiling 600. Floor 12pt.
enum MurmurType {
    static var display: Font { core(size: 40, relativeTo: .largeTitle, weight: .thin) }
    static var title: Font { core(size: 30, relativeTo: .title, weight: .light) }
    static var headline: Font { core(size: 22, relativeTo: .title2, weight: .regular) }
    static var body: Font { core(size: 17, relativeTo: .body, weight: .regular) }
    static var bodyEm: Font { core(size: 17, relativeTo: .body, weight: .medium) }
    static var callout: Font { core(size: 16, relativeTo: .callout, weight: .regular) }
    static var subhead: Font { core(size: 15, relativeTo: .subheadline, weight: .medium) }
    static var footnote: Font { core(size: 13, relativeTo: .footnote, weight: .regular) }
    static var caption: Font { core(size: 12, relativeTo: .caption, weight: .medium) }
    static var meta: Font { plex(size: 13, relativeTo: .footnote, weight: .regular) }
    static var transcript: Font { core(size: 26, relativeTo: .title2, weight: .light) }
    static var wordmark: Font { core(size: 28, relativeTo: .title, weight: .light) }

    static let trackingDisplay: CGFloat = 40 * -0.022
    static let trackingTitle: CGFloat = 30 * -0.018
    static let trackingHeadline: CGFloat = 22 * -0.012
    static let trackingBody: CGFloat = 17 * -0.004
    static let trackingCallout: CGFloat = 0
    static let trackingSubhead: CGFloat = 0
    static let trackingFootnote: CGFloat = 13 * 0.004
    static let trackingCaption: CGFloat = 12 * 0.02
    static let trackingTranscript: CGFloat = 26 * -0.014
    static let trackingWordmark: CGFloat = 28 * 0.13

    static func core(size: CGFloat, relativeTo textStyle: Font.TextStyle, weight: Font.Weight) -> Font {
        Font.custom(MurmurFont.core, size: size, relativeTo: textStyle).weight(weight)
    }

    static func plex(size: CGFloat, relativeTo textStyle: Font.TextStyle, weight: Font.Weight) -> Font {
        Font.custom(MurmurFont.meta, size: size, relativeTo: textStyle).weight(weight)
    }
}
