import SwiftUI

/// Soft settle after a save. Undo is a ghost action. Parent owns the 5s window.
struct SuccessBar: View {
    var message: String = "Saved"
    var destination: CaptureDestination = .reminder
    var onUndo: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    var body: some View {
        HStack(spacing: MurmurSpace.space4) {
            glyph
            Text(message)
                .font(MurmurType.subhead)
                .foregroundStyle(MurmurColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)

            if let onUndo {
                Button(action: onUndo) {
                    HStack(spacing: 6) {
                        MurmurIcon(name: .undo, size: 15)
                        Text("Undo")
                            .font(MurmurType.subhead)
                    }
                    .foregroundStyle(MurmurColor.textAccent)
                    .padding(.horizontal, 4)
                    .frame(minHeight: MurmurSpace.hitMin)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Undo")
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, MurmurSpace.space5)
        .background(MurmurColor.bgRaised)
        .overlay {
            Capsule()
                .strokeBorder(MurmurColor.lineHairline, lineWidth: MurmurRadius.strokeHairline)
        }
        .clipShape(Capsule())
        .murmurShadow(.card)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .onAppear {
            withAnimation(MurmurMotion.animation(.settle, .normal, reduceMotion: reduceMotion)) {
                appeared = true
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.updatesFrequently)
        .accessibilityLabel(message)
    }

    private var glyph: some View {
        MurmurIcon(
            name: destination == .event ? .calendar : .bell,
            size: 15,
            title: destination == .event ? "Event" : "Reminder"
        )
        .foregroundStyle(destination == .event ? MurmurColor.eventFg : MurmurColor.reminderFg)
        .frame(width: 28, height: 28)
        .background(destination == .event ? MurmurColor.eventBg : MurmurColor.reminderBg)
        .clipShape(Circle())
    }
}
