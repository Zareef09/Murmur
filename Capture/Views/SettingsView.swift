import SwiftUI

struct SettingsView: View {
    @Environment(AuthService.self) private var auth
    var model: CaptureViewModel
    @State private var note: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ToggleRow(
                        label: "Always confirm before saving",
                        description: "Glance at what Murmur heard before it files it.",
                        isOn: alwaysConfirmBinding,
                        divider: false,
                        isDisabled: auth.userId == nil
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                Section {
                    Button("Sign out", role: .destructive) {
                        Task { await signOut() }
                    }
                    .disabled(!auth.isSignedIn)
                } footer: {
                    if let note {
                        Text(note)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var alwaysConfirmBinding: Binding<Bool> {
        Binding(
            get: { model.alwaysConfirm },
            set: { newValue in
                model.setAlwaysConfirm(newValue)
            }
        )
    }

    @MainActor
    private func signOut() async {
        do {
            try await auth.signOut()
            note = AuthCopy.signedOut
        } catch {
            note = AuthCopy.signOutFact(for: error)
        }
    }
}

#Preview {
    SettingsView(model: CaptureViewModel())
        .environment(AuthService())
}
