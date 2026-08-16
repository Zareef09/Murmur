import SwiftUI

/// System date picker, wheel style. Reminders may be date-only or cleared; events always carry a clock.
struct ConfirmationWhenEditor: View {
    @Binding var date: Date?
    @Binding var hasExplicitTime: Bool
    var destination: CaptureDestination
    var onCleared: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: MurmurSpace.space3) {
            DatePicker(
                ConfirmationCopy.whenLabel,
                selection: pickerDate,
                displayedComponents: showsTime ? [.date, .hourAndMinute] : [.date]
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .tint(MurmurColor.accent)
            .frame(maxHeight: 132)
            .clipped()

            if destination == .reminder {
                HStack(spacing: MurmurSpace.space3) {
                    MurmurButton(
                        title: hasExplicitTime ? ConfirmationCopy.dateOnly : ConfirmationCopy.includeTime,
                        variant: .ghost,
                        size: .sm,
                        action: toggleClock
                    )
                    MurmurButton(
                        title: ConfirmationCopy.noDate,
                        variant: .ghost,
                        size: .sm,
                        action: clearDate
                    )
                }
            }
        }
        .padding(.top, MurmurSpace.space2)
    }

    private var showsTime: Bool {
        destination == .event || hasExplicitTime
    }

    private var pickerDate: Binding<Date> {
        Binding(
            get: { date ?? Date() },
            set: { newValue in
                if showsTime {
                    date = newValue
                    hasExplicitTime = true
                } else {
                    date = ConfirmationWhenEdit.strippingClock(newValue)
                    hasExplicitTime = false
                }
            }
        )
    }

    private func toggleClock() {
        let current = date ?? Date()
        if hasExplicitTime {
            date = ConfirmationWhenEdit.strippingClock(current)
            hasExplicitTime = false
        } else {
            date = ConfirmationWhenEdit.addingClock(to: current)
            hasExplicitTime = true
        }
    }

    private func clearDate() {
        date = nil
        hasExplicitTime = false
        onCleared()
    }
}
