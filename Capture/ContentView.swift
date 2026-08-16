import SwiftUI

struct ContentView: View {
    @Environment(AuthService.self) private var auth
    @State private var model = CaptureViewModel()
    @State private var showSettings = false

    var body: some View {
        Group {
            if auth.isSignedIn {
                captureStack
            } else {
                SignInView()
            }
        }
        .onAppear {
            model.applySession(isSignedIn: auth.isSignedIn)
            if auth.isSignedIn {
                Task { await model.refreshSettingsFromRemote() }
            }
        }
        .onChange(of: auth.isSignedIn) { _, signedIn in
            model.applySession(isSignedIn: signedIn)
            if signedIn {
                Task { await model.refreshSettingsFromRemote() }
            } else {
                showSettings = false
            }
        }
    }

    private var captureStack: some View {
        NavigationStack {
            CaptureView(model: model)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        MurmurIconButton(name: .settings, label: "Settings") {
                            showSettings = true
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView(model: model)
                }
        }
    }
}

#Preview("Signed out · light") {
    ContentView()
        .environment(AuthService())
        .preferredColorScheme(.light)
}

#Preview("Signed out · dark") {
    ContentView()
        .environment(AuthService())
        .preferredColorScheme(.dark)
}
