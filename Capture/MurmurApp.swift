import SwiftUI

@main
struct MurmurApp: App {
    @State private var authService = AuthService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authService)
                .task {
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
