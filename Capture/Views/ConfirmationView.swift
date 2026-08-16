import SwiftUI

enum ConfirmationEditField: Equatable {
    case title
    case when
    case destination
}

/// Confirmation sheet. Title and destination are inline-editable; When is Session 71.
struct ConfirmationView: View {
    @Binding var intent: ParsedIntent
    var onSave: () -> Void = {}
    var onCancel: () -> Void = {}
    var startsEditing: ConfirmationEditField?

    @State private var editing: ConfirmationEditField?

    private var destination: CaptureDestination {
        intent.destination ?? .reminder
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            MurmurColor.bgOverlay
                .ignoresSafeArea()
                .onTapGesture(perform: onCancel)
                .accessibilityLabel(ConfirmationCopy.cancel)
                .accessibilityAddTraits(.isButton)

            sheet
                .murmurShadow(.sheet)
                .transition(.move(edge: .bottom))
        }
        .accessibilityAddTraits(.isModal)
        .onAppear {
            if editing == nil {
                if startsEditing == .when {
                    beginWhenEdit()
                } else {
                    editing = startsEditing
                }
            }
        }
    }

    private var sheet: some View {
        VStack(spacing: MurmurSpace.space5) {
            Capsule()
                .fill(MurmurColor.lineSoft)
                .frame(width: 40, height: 4)
                .accessibilityHidden(true)

            header

            fieldGroup

            VStack(spacing: MurmurSpace.space3) {
                MurmurButton(
                    title: ConfirmationCopy.saveTitle(for: destination),
                    fullWidth: true,
                    action: save
                )
                MurmurButton(
                    title: ConfirmationCopy.cancel,
                    variant: .ghost,
                    size: .md,
                    fullWidth: true,
                    action: onCancel
                )
            }
        }
        .padding(.top, MurmurSpace.space5)
        .padding(.horizontal, MurmurSpace.gutterSheet)
        .padding(.bottom, MurmurSpace.space5)
        .frame(maxWidth: .infinity)
        .background(MurmurColor.bgBase)
        .clipShape(
            UnevenRoundedRectangle(
                cornerRadii: RectangleCornerRadii(
                    topLeading: MurmurRadius.xl,
                    bottomLeading: 0,
                    bottomTrailing: 0,
                    topTrailing: MurmurRadius.xl
                ),
                style: .continuous
            )
        )
    }

    private var header: some View {
        HStack(alignment: .center, spacing: MurmurSpace.space4) {
            CaptureBloom(state: .done, size: 44)
                .allowsHitTesting(false)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(editing == nil ? ConfirmationCopy.headline : ConfirmationCopy.fixing)
                    .font(MurmurType.headline)
                    .tracking(MurmurType.trackingHeadline)
                    .foregroundStyle(MurmurColor.textPrimary)
                Text(ConfirmationCopy.hint)
                    .font(MurmurType.footnote)
                    .tracking(MurmurType.trackingFootnote)
                    .foregroundStyle(MurmurColor.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }

    private var fieldGroup: some View {
        VStack(spacing: 0) {
            EditableField(
                label: ConfirmationCopy.titleLabel,
                value: $intent.taskText,
                isEditing: editing == .title,
                onPress: { editing = .title }
            )
            divider
            EditableField(
                label: ConfirmationCopy.whenLabel,
                value: .constant(whenValue),
                placeholder: ConfirmationCopy.noDate,
                icon: .clock,
                isEditing: editing == .when,
                onPress: { beginWhenEdit() }
            ) {
                ConfirmationWhenEditor(
                    date: $intent.date,
                    hasExplicitTime: $intent.hasExplicitTime,
                    destination: destination,
                    onCleared: { editing = nil }
                )
            }
            divider
            EditableField(
                label: ConfirmationCopy.goesToLabel,
                value: destinationBinding,
                icon: destination == .event ? .calendar : .bell,
                isEditing: editing == .destination,
                onPress: { editing = .destination }
            ) {
                DestinationToggle(value: destinationToggle, size: .sm)
                    .padding(.top, 6)
            }
        }
        .padding(6)
        .background(MurmurColor.bgRaised)
        .overlay {
            RoundedRectangle(cornerRadius: MurmurRadius.lg, style: .continuous)
                .strokeBorder(MurmurColor.lineHairline, lineWidth: MurmurRadius.strokeHairline)
        }
        .clipShape(RoundedRectangle(cornerRadius: MurmurRadius.lg, style: .continuous))
    }

    private var divider: some View {
        MurmurColor.lineHairline
            .frame(height: MurmurRadius.strokeHairline)
            .padding(.horizontal, MurmurSpace.space5)
    }

    private var whenValue: String {
        ConfirmationWhenFormat.display(
            date: intent.date,
            hasExplicitTime: intent.hasExplicitTime
        )
    }

    private func beginWhenEdit() {
        let seeded = ConfirmationWhenEdit.opening(
            date: intent.date,
            hasExplicitTime: intent.hasExplicitTime,
            destination: destination
        )
        intent.date = seeded.date
        intent.hasExplicitTime = seeded.hasExplicitTime
        editing = .when
    }

    private var destinationBinding: Binding<String> {
        Binding(
            get: { ConfirmationCopy.destinationValue(destination) },
            set: { _ in }
        )
    }

    private var destinationToggle: Binding<CaptureDestination> {
        Binding(
            get: { destination },
            set: { intent.destination = $0 }
        )
    }

    private func save() {
        editing = nil
        intent.taskText = intent.taskText.trimmingCharacters(in: .whitespacesAndNewlines)
        onSave()
    }
}

#Preview("Confirm · reminder · light") {
    ConfirmationPreviewHost(
        intent: ParsedIntent(
            rawTranscript: "call mom",
            taskText: "call mom",
            destination: .reminder,
            confidence: 0.85
        )
    )
    .preferredColorScheme(.light)
}

#Preview("Confirm · reminder · dark") {
    ConfirmationPreviewHost(
        intent: ParsedIntent(
            rawTranscript: "call mom",
            taskText: "call mom",
            destination: .reminder,
            confidence: 0.85
        )
    )
    .preferredColorScheme(.dark)
}

#Preview("Confirm · event · light") {
    let start = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    return ConfirmationPreviewHost(
        intent: ParsedIntent(
            rawTranscript: "lunch with Sam at noon",
            taskText: "lunch with Sam",
            date: start,
            hasExplicitTime: true,
            durationMinutes: 60,
            destination: .event,
            confidence: 0.85
        )
    )
    .preferredColorScheme(.light)
}

#Preview("Confirm · when · light") {
    ConfirmationPreviewHost(
        intent: ParsedIntent(
            rawTranscript: "call mom",
            taskText: "call mom",
            destination: .reminder,
            confidence: 0.85
        ),
        startsEditing: .when
    )
    .preferredColorScheme(.light)
}

#Preview("Confirm · no date · dark") {
    ConfirmationPreviewHost(
        intent: ParsedIntent(
            rawTranscript: "buy milk",
            taskText: "buy milk",
            destination: .reminder,
            confidence: 0.85
        )
    )
    .preferredColorScheme(.dark)
}

private struct ConfirmationPreviewHost: View {
    @State var intent: ParsedIntent
    var startsEditing: ConfirmationEditField?

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear.murmurCanvas(wash: true)
            ConfirmationView(intent: $intent, startsEditing: startsEditing)
        }
    }
}
