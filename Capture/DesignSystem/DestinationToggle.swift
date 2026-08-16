import SwiftUI

/// Reminder or Event only. Selected option always carries icon, word, tint, and hairline.
struct DestinationToggle: View {
    enum Size {
        case sm
        case md

        var minHeight: CGFloat {
            switch self {
            case .sm: MurmurSpace.hitMin
            case .md: 46
            }
        }
    }

    @Binding var value: CaptureDestination
    var size: Size = .md
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: MurmurSpace.space2) {
            option(.reminder, label: "Reminder", icon: .bell)
            option(.event, label: "Event", icon: .calendar)
        }
        .padding(MurmurSpace.space1)
        .background(MurmurColor.bgSunk)
        .clipShape(Capsule())
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Goes to")
    }

    private func option(_ destination: CaptureDestination, label: String, icon: MurmurIconName) -> some View {
        let on = value == destination
        let palette = DestinationTogglePalette(destination)
        return Button {
            value = destination
        } label: {
            HStack(spacing: MurmurSpace.space3) {
                MurmurIcon(name: icon, size: 16)
                Text(label)
                    .font(on ? MurmurType.subhead : MurmurType.callout)
            }
            .foregroundStyle(on ? palette.fg : MurmurColor.textSecondary)
            .frame(maxWidth: .infinity)
            .frame(minHeight: size.minHeight)
            .padding(.horizontal, MurmurSpace.space5)
            .background(on ? palette.bg : Color.clear)
            .overlay {
                Capsule()
                    .strokeBorder(on ? palette.fg : Color.clear, lineWidth: MurmurRadius.strokeHairline)
            }
            .clipShape(Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(
            MurmurMotion.animation(.exhale, .quick, reduceMotion: reduceMotion),
            value: on
        )
        .accessibilityLabel(label)
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(on ? .isSelected : [])
    }
}

private struct DestinationTogglePalette {
    var fg: Color
    var bg: Color

    init(_ destination: CaptureDestination) {
        switch destination {
        case .reminder:
            fg = MurmurColor.reminderFg
            bg = MurmurColor.reminderBg
        case .event:
            fg = MurmurColor.eventFg
            bg = MurmurColor.eventBg
        }
    }
}
