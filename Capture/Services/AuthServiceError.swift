import Foundation

enum AuthServiceError: Error, Equatable {
    /// URL or anon key missing; client was not created.
    case notConfigured
    /// User dismissed the Apple sheet.
    case canceled
    /// Apple returned a credential that is not an Apple ID credential.
    case invalidCredential
    /// Apple did not return an identity token string.
    case missingIdentityToken
    /// The system could not generate a nonce.
    case nonceUnavailable
}
