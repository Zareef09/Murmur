import Foundation
import Observation
import Security
import CryptoKit
import Supabase

@MainActor
protocol AuthServicing: AnyObject {
    var isSignedIn: Bool { get }
    var userId: UUID? { get }
    var isSessionReady: Bool { get }
    func signInWithApple() async throws
    func restoreSession() async throws
    func signOut() async throws
}

@MainActor
@Observable
final class AuthService: AuthServicing {
    private let appleSignIn = AppleSignInCoordinator()

    private(set) var isSignedIn = false
    private(set) var userId: UUID?
    private(set) var isSessionReady = false

    func signInWithApple() async throws {
        guard let client = SupabaseClientProvider.client else {
            isSignedIn = false
            userId = nil
            throw AuthServiceError.notConfigured
        }

        let rawNonce = try Self.makeRawNonce()
        let hashedNonce = Self.sha256Hex(rawNonce)
        let credential = try await appleSignIn.requestCredential(hashedNonce: hashedNonce)

        guard let tokenData = credential.identityToken,
              let idToken = String(data: tokenData, encoding: .utf8),
              !idToken.isEmpty
        else {
            throw AuthServiceError.missingIdentityToken
        }

        // Raw nonce (pre-hash) to Supabase; hashed nonce already went to Apple. Do not log either.
        _ = try await client.auth.signInWithIdToken(
            credentials: OpenIDConnectCredentials(
                provider: .apple,
                idToken: idToken,
                nonce: rawNonce
            )
        )
        // Do not write Apple name/email into user_metadata. Authorization is auth.uid() only.
        refreshSignedInFlag()
    }

    /// Reloads the Keychain session (refreshes if expired). Missing session is not a throw.
    func restoreSession() async throws {
        defer { isSessionReady = true }
        guard let client = SupabaseClientProvider.client else {
            isSignedIn = false
            userId = nil
            throw AuthServiceError.notConfigured
        }

        do {
            _ = try await client.auth.session
            refreshSignedInFlag()
        } catch {
            if Self.isSessionMissing(error) {
                isSignedIn = false
                userId = nil
                return
            }
            // Offline or Auth unreachable: keep a locally stored session if Keychain has one.
            refreshSignedInFlag()
            if !isSignedIn {
                throw error
            }
        }
    }

    func signOut() async throws {
        defer { refreshSignedInFlag() }
        guard let client = SupabaseClientProvider.client else {
            return
        }
        try await client.auth.signOut()
    }

    func markSessionReadyForPreview() {
        isSessionReady = true
    }

    private func refreshSignedInFlag() {
        let session = SupabaseClientProvider.currentSession
        isSignedIn = session != nil
        userId = session?.user.id
    }

    private static func isSessionMissing(_ error: Error) -> Bool {
        if let authError = error as? AuthError, case .sessionMissing = authError {
            return true
        }
        return false
    }

    private static func makeRawNonce(byteCount: Int = 32) throws -> String {
        var bytes = [UInt8](repeating: 0, count: byteCount)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        guard status == errSecSuccess else {
            throw AuthServiceError.nonceUnavailable
        }
        return Data(bytes).map { String(format: "%02x", $0) }.joined()
    }

    private static func sha256Hex(_ value: String) -> String {
        SHA256.hash(data: Data(value.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}
