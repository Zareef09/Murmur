import SwiftUI

/// Session 35 DoD: DestinationToggle (two options) and EditableField (rest / edit / empty).
struct FieldsCatalog: View {
    @State private var destination: CaptureDestination = .reminder
    @State private var compactDestination: CaptureDestination = .event
    @State private var title = "Call mom"
    @State private var when = "Tomorrow, 5:00 PM"
    @State private var emptyWhen = ""
    @State private var editing: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MurmurSpace.stackSection) {
                Text("Two destinations only. Color is never the only difference. Empty values stay calm.")
                    .font(MurmurType.footnote)
                    .tracking(MurmurType.trackingFootnote)
                    .foregroundStyle(MurmurColor.textSecondary)

                DestinationToggle(value: $destination)

                EditableField(
                    label: "Title",
                    value: $title,
                    isEditing: editing == "title",
                    onPress: { editing = "title" }
                )
                EditableField(
                    label: "When",
                    value: $when,
                    icon: .clock,
                    isEditing: editing == "when",
                    onPress: { editing = "when" }
                )
                EditableField(
                    label: "When",
                    value: $emptyWhen,
                    placeholder: "No date",
                    icon: .clock,
                    isEditing: false
                )
                EditableField(
                    label: "Goes to",
                    value: Binding(
                        get: { compactDestination == .event ? "Calendar" : "Reminders" },
                        set: { _ in }
                    ),
                    icon: compactDestination == .event ? .calendar : .bell,
                    isEditing: editing == "dest",
                    onPress: { editing = "dest" }
                ) {
                    DestinationToggle(value: $compactDestination, size: .sm)
                        .padding(.top, 6)
                }

                if editing != nil {
                    MurmurButton(title: "Done", variant: .ghost, size: .sm) {
                        editing = nil
                    }
                }
            }
            .padding(MurmurSpace.gutterScreen)
        }
        .background(MurmurColor.bgBase.ignoresSafeArea())
    }
}

#Preview("Fields · light") {
    FieldsCatalog()
        .preferredColorScheme(.light)
}

#Preview("Fields · dark") {
    FieldsCatalog()
        .preferredColorScheme(.dark)
}
