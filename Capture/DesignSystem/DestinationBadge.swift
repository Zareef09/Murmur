import SwiftUI

/// Reminder (moss) vs Event (plum). Icon and word always ship together; tint is reinforcement only.
struct DestinationBadge: View {
    enum Variant {
        case chip
        case glyph
        case quiet
    }

    var destination: CaptureDestination = .reminder
    var variant: Variant = .chip

    var body: some View {
        Group {
            switch variant {
            case .glyph:
                glyph
            case .chip, .quiet:
                labeled
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(palette.label)
    }

    private var glyph: some View {
        MurmurIcon(name: palette.icon, size: 18, title: palette.label)
            .foregroundStyle(palette.fg)
            .frame(width: 38, height: 38)
            .background(palette.bg)
            .overlay {
                RoundedRectangle(cornerRadius: MurmurRadius.sm, style: .continuous)
                    .strokeBorder(palette.line, lineWidth: MurmurRadius.strokeHairline)
            }
            .clipShape(RoundedRectangle(cornerRadius: MurmurRadius.sm, style: .continuous))
    }

    private var labeled: some View {
        HStack(spacing: MurmurSpace.space2) {
            MurmurIcon(name: palette.icon, size: 13)
            Text(palette.label)
                .font(MurmurType.caption)
                .tracking(MurmurType.trackingCaption)
        }
        .foregroundStyle(palette.fg)
        .padding(.top, 5)
        .padding(.bottom, 5)
        .padding(.leading, 8)
        .padding(.trailing, 10)
        .background(variant == .quiet ? Color.clear : palette.bg)
        .overlay {
            Capsule()
                .strokeBorder(
                    variant == .quiet ? Color.clear : palette.line,
                    lineWidth: MurmurRadius.strokeHairline
                )
        }
        .clipShape(Capsule())
    }

    private var palette: Palette {
        switch destination {
        case .reminder:
            Palette(
                label: "Reminder",
                icon: .bell,
                fg: MurmurColor.reminderFg,
                bg: MurmurColor.reminderBg,
                line: MurmurColor.reminderLine
            )
        case .event:
            Palette(
                label: "Event",
                icon: .calendar,
                fg: MurmurColor.eventFg,
                bg: MurmurColor.eventBg,
                line: MurmurColor.eventLine
            )
        }
    }

    private struct Palette {
        var label: String
        var icon: MurmurIconName
        var fg: Color
        var bg: Color
        var line: Color
    }
}
