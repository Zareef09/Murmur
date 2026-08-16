import SwiftUI

struct ContentView: View {
    @Environment(AuthService.self) private var auth
    @Environment(OnboardingGate.self) private var onboarding
    @Environment(\.scenePhase) private var scenePhase
    @State private var model = CaptureViewModel()

    var body: some View {
        Group {
            if !auth.isSessionReady {
                MurmurColor.bgBase.ignoresSafeArea()
            } else if auth.isSignedIn {
                captureStack
            } else if !onboarding.isComplete {
                OnboardingView(
                    onSkip: { onboarding.complete() },
                    onSetUpHandsFree: { onboarding.complete() }
                )
            } else {
                SignInView()
            }
        }
        .onAppear {
            model.applySession(isSignedIn: auth.isSignedIn)
            if auth.isSignedIn {
                Task { await model.refreshSettingsFromRemote() }
            }
            model.applyQuickCaptureIfPending()
        }
        .onChange(of: auth.isSessionReady) { _, ready in
            guard ready else { return }
            model.applySession(isSignedIn: auth.isSignedIn)
            model.applyQuickCaptureIfPending()
        }
        .onChange(of: auth.isSignedIn) { _, signedIn in
            model.applySession(isSignedIn: signedIn)
            if signedIn {
                Task { await model.refreshSettingsFromRemote() }
            }
            model.applyQuickCaptureIfPending()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                model.applyQuickCaptureIfPending()
            }
        }
        .onChange(of: model.state) { _, _ in
            model.applyQuickCaptureIfPending()
        }
        .onReceive(NotificationCenter.default.publisher(for: QuickCaptureFlag.didArm)) { _ in
            model.applyQuickCaptureIfPending()
        }
    }

    private var captureStack: some View {
        NavigationStack {
            CaptureView(model: model)
        }
    }
}

#Preview("Onboarding · light") {
    ContentView()
        .environment(previewAuth())
        .environment(OnboardingGate(isComplete: false))
        .preferredColorScheme(.light)
}

#Preview("Signed out · light") {
    ContentView()
        .environment(previewAuth())
        .environment(OnboardingGate(isComplete: true))
        .preferredColorScheme(.light)
}

#Preview("Signed out · dark") {
    ContentView()
        .environment(previewAuth())
        .environment(OnboardingGate(isComplete: true))
        .preferredColorScheme(.dark)
}

@MainActor
private func previewAuth() -> AuthService {
    let auth = AuthService()
    auth.markSessionReadyForPreview()
    return auth
}
