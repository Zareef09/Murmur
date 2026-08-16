import SwiftUI

/// Session 34 DoD: EmptyState, PermissionRow, ToggleRow in both modes.
struct SettingsDataCatalog: View {
    @State private var confirm = true
    @State private var speak = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MurmurSpace.stackSection) {
                EmptyState(
                    icon: .list,
                    title: "Nothing captured yet",
                    message: "Everything you speak will land here."
                ) {
                    MurmurButton(title: "Capture something", variant: .secondary, size: .md) {}
                }

                group("Permissions") {
                    PermissionRow(label: "Microphone", status: .granted)
                    PermissionRow(
                        label: "Calendar",
                        status: .needed,
                        hint: "Needed to save events",
                        divider: false,
                        onFix: {}
                    )
                }

                group("Capture") {
                    ToggleRow(
                        label: "Always confirm before saving",
                        description: "Glance at what Murmur heard before it files it.",
                        isOn: $confirm
                    )
                    ToggleRow(
                        label: "Speak questions aloud",
                        description: "When something's unclear, Murmur asks out loud.",
                        isOn: $speak,
                        divider: false
                    )
                }
            }
            .padding(MurmurSpace.gutterScreen)
        }
        .background(MurmurColor.bgBase.ignoresSafeArea())
    }

    private func group(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: MurmurSpace.space3) {
            Text(title)
                .font(MurmurType.caption)
                .foregroundStyle(MurmurColor.textTertiary)
                .padding(.horizontal, MurmurSpace.space4)
            VStack(spacing: 0) {
                content()
            }
            .background(MurmurColor.bgRaised)
            .clipShape(RoundedRectangle(cornerRadius: MurmurRadius.md, style: .continuous))
            .murmurShadow(.row)
        }
    }
}

#Preview("Empty / permission / toggle · light") {
    SettingsDataCatalog()
        .preferredColorScheme(.light)
}

#Preview("Empty / permission / toggle · dark") {
    SettingsDataCatalog()
        .preferredColorScheme(.dark)
}
