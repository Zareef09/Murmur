import Foundation

/// User-facing auth facts. Sentence case, no “error” / “failed” / “invalid” / “!”.
enum AuthCopy {
    static let notNow = "Not now"
    static let connectionNeededToCreateAccount = "A connection is needed to create the account."
    static let connectionNeededToSignOut = "A connection is needed to sign out."
    static let continueWithApple = "Continue with Apple"
    static let signedOut = "Signed out"

    static func signInFact(for error: Error) -> String? {
        if let authError = error as? AuthServiceError, authError == .canceled {
            return notNow
        }
        return connectionNeededToCreateAccount
    }

    static func signOutFact(for error: Error) -> String {
        _ = error
        return connectionNeededToSignOut
    }
}
