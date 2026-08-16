import SwiftUI
import SwiftData

@main
struct MurmurApp: App {
    @State private var authService = AuthService()
    @State private var onboardingGate = OnboardingGate()
    private let container = Persistence.container

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authService)
                .environment(onboardingGate)
                .modelContainer(container)
                .task {
                    Persistence.proveStoreThenRemove(container)
                    try? HistoryPurgeService.purgeExpired(in: container.mainContext)
                    do {
                        try await authService.restoreSession()
                    } catch AuthServiceError.notConfigured {
                        // Fail closed: stay signed out; app still launches.
                    } catch {
                        // Restore already kept a Keychain session when one exists.
                    }
                }
        }
    }
}
