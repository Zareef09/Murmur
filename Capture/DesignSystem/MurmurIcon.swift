import SwiftUI

/// Lucide stems from the design kit, mapped to SF Symbols for shipping.
/// Listening on capture home is the Light Well, never `mic`.
enum MurmurIconName: String, CaseIterable, Sendable {
    case plus
    case bell
    case calendar
    case calendarDays = "calendar-days"
    case clock
    case pencil
    case trash = "trash-2"
    case check
    case circleCheck = "circle-check"
    case circleAlert = "circle-alert"
    case chevronRight = "chevron-right"
    case chevronLeft = "chevron-left"
    case arrowRight = "arrow-right"
    case x
    case list
    case settings
    case undo = "undo-2"
    case mic
    case volume = "volume-2"
    case audioLines = "audio-lines"
    case ellipsis
    case sun
    case moon
    case shieldCheck = "shield-check"

    var systemName: String {
        switch self {
        case .plus: "plus"
        case .bell: "bell"
        case .calendar, .calendarDays: "calendar"
        case .clock: "clock"
        case .pencil: "pencil"
        case .trash: "trash"
        case .check: "checkmark"
        case .circleCheck: "checkmark.circle"
        case .circleAlert: "exclamationmark.circle"
        case .chevronRight: "chevron.right"
        case .chevronLeft: "chevron.left"
        case .arrowRight: "arrow.right"
        case .x: "xmark"
        case .list: "list.bullet"
        case .settings: "gearshape"
        case .undo: "arrow.uturn.backward"
        case .mic: "mic"
        case .volume: "speaker.wave.2"
        case .audioLines: "waveform"
        case .ellipsis: "ellipsis"
        case .sun: "sun.max"
        case .moon: "moon"
        case .shieldCheck: "checkmark.shield"
        }
    }
}

/// Monochrome glyph. Inherits `foregroundStyle` (kit `currentColor`). Lucide SVGs stay in `docs/design-system/`.
struct MurmurIcon: View {
    var name: MurmurIconName
    var size: CGFloat = 20
    var strokeScale: CGFloat = 1
    var title: String?

    var body: some View {
        Image(systemName: name.systemName)
            .font(.system(size: size * 0.72 * strokeScale, weight: .regular))
            .frame(width: size, height: size)
            .accessibilityLabel(title ?? "")
            .accessibilityHidden(title == nil)
    }
}
