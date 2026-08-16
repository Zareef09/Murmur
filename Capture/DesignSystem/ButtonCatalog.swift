import SwiftUI

/// Session 31 DoD: primary / secondary / ghost. One ember primary in the live row.
struct ButtonCatalog: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MurmurSpace.stackSection) {
                Text("One primary per screen. Destructive is ghost in attention color, never a red fill.")
                    .font(MurmurType.footnote)
                    .tracking(MurmurType.trackingFootnote)
                    .foregroundStyle(MurmurColor.textSecondary)

                VStack(spacing: MurmurSpace.stackDefault) {
                    MurmurButton(title: "Continue with Apple", systemIcon: "apple.logo", fullWidth: true) {}
                    MurmurButton(title: "Save reminder", variant: .secondary, fullWidth: true) {}
                    MurmurButton(title: "Not now", variant: .ghost) {}
                    MurmurButton(title: "Sign out", variant: .ghost, isDestructive: true) {}
                    MurmurButton(title: "Continue with Apple", fullWidth: true, isDisabled: true) {}
                    HStack(spacing: MurmurSpace.space3) {
                        MurmurButton(title: "Cancel", variant: .ghost, size: .md) {}
                        MurmurButton(title: "Save", variant: .secondary, size: .md, iconAfter: .check) {}
                    }
                }
            }
            .padding(MurmurSpace.gutterScreen)
        }
        .background(MurmurColor.bgBase.ignoresSafeArea())
    }
}

#Preview("Buttons · light") {
    ButtonCatalog()
        .preferredColorScheme(.light)
}

#Preview("Buttons · dark") {
    ButtonCatalog()
        .preferredColorScheme(.dark)
}
