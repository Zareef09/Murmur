import SwiftUI

/// One past capture. Title leads; destination and when sit under it; relative time trails.
/// Swipe left reveals delete (clay, never red).
struct HistoryRow: View {
    var title: String
    var destination: CaptureDestination = .reminder
    var when: String?
    var relative: String?
    var divider: Bool = true
    var swiped: Bool = false
    var onPress: (() -> Void)?
    var onSwipe: (() -> Void)?
    var onDelete: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let reveal: CGFloat = 92

    var body: some View {
        ZStack(alignment: .trailing) {
            Button(action: { onDelete?() }) {
                MurmurIcon(name: .trash, size: 19, title: "Delete")
                    .foregroundStyle(MurmurColor.attentionFg)
                    .frame(width: reveal)
                    .frame(maxHeight: .infinity)
                    .frame(minHeight: MurmurSpace.hitComfort)
            }
            .buttonStyle(.plain)
            .background(MurmurColor.attentionBg)
            .accessibilityHidden(!swiped)

            rowContent
                .background(MurmurColor.bgRaised)
                .offset(x: swiped ? -reveal : 0)
                .animation(MurmurMotion.animation(.exhale, .normal, reduceMotion: reduceMotion), value: swiped)
                .gesture(swipeGesture)
                .onTapGesture {
                    if swiped {
                        onSwipe?()
                    } else {
                        onPress?()
                    }
                }
        }
        .frame(minHeight: MurmurSpace.hitComfort)
        .clipped()
        .accessibilityAction(named: HistoryCopy.deleteTitle) {
            onDelete?()
        }
    }

    private var rowContent: some View {
        HStack(alignment: .center, spacing: MurmurSpace.space4) {
            DestinationBadge(destination: destination, variant: .glyph)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(MurmurType.body)
                    .tracking(MurmurType.trackingBody)
                    .foregroundStyle(MurmurColor.textPrimary)
                    .lineLimit(2)
                Text(subtitle)
                    .font(MurmurType.footnote)
                    .tracking(MurmurType.trackingFootnote)
                    .foregroundStyle(MurmurColor.textSecondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let relative, !relative.isEmpty {
                Text(relative)
                    .font(MurmurType.plex(size: 12, relativeTo: .caption, weight: .regular))
                    .foregroundStyle(MurmurColor.textTertiary)
                    .fixedSize()
            }

            MurmurIcon(name: .chevronRight, size: 16)
                .foregroundStyle(MurmurColor.textTertiary)
                .opacity(0.6)
                .accessibilityHidden(true)
        }
        .padding(.vertical, MurmurSpace.space4)
        .padding(.horizontal, MurmurSpace.space5)
        .frame(minHeight: MurmurSpace.hitComfort)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) {
            if divider {
                MurmurColor.lineHairline.frame(height: MurmurRadius.strokeHairline)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(HistoryCopy.openHint(for: destination))
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 24)
            .onEnded { value in
                let horizontal = value.translation.width
                let vertical = value.translation.height
                guard abs(horizontal) > abs(vertical) else { return }
                if horizontal < -40, !swiped {
                    onSwipe?()
                } else if horizontal > 24, swiped {
                    onSwipe?()
                }
            }
    }

    private var subtitle: String {
        let kind = destination == .event ? "Event" : "Reminder"
        if let when, !when.isEmpty {
            return "\(kind) · \(when)"
        }
        return kind
    }
}
