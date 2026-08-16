import Foundation
import Supabase

/// Fail-closed Supabase client. Missing URL/key, empty strings, or a `service_role` key → no client.
/// Session 17: read ``currentSession`` only (nil when signed out). Do not use the throwing ``session`` getter at launch.
enum SupabaseClientProvider {
    static let client: SupabaseClient? = makeClient()

    /// Stored session if any. Never throws; nil when unsigned-in or when the client was not created.
    static var currentSession: Session? {
        client?.auth.currentSession
    }

    private static func makeClient() -> SupabaseClient? {
        guard let urlString = plistString("SUPABASE_URL"),
              let key = plistString("SUPABASE_ANON_KEY"),
              jwtRole(key) != "service_role",
              let url = URL(string: urlString),
              isAllowedSupabaseURL(url)
        else {
            return nil
        }

        let options = SupabaseClientOptions(
            auth: .init(
                storage: KeychainLocalStorage(
                    service: "app.murmur.capture.auth",
                    accessGroup: nil
                )
            )
        )
        return SupabaseClient(supabaseURL: url, supabaseKey: key, options: options)
    }

    private static func plistString(_ key: String) -> String? {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            return nil
        }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmed.hasPrefix("$(") else {
            return nil
        }
        return trimmed
    }

    private static func isAllowedSupabaseURL(_ url: URL) -> Bool {
        guard let scheme = url.scheme?.lowercased(), let host = url.host?.lowercased() else {
            return false
        }
        if scheme == "https" {
            return true
        }
        // Local `supabase start` only. Not an extra ATS domain exception.
        if scheme == "http" {
            if host == "127.0.0.1" || host == "localhost" || host == "::1" {
                return true
            }
            #if DEBUG
            return isPrivateIPv4(host)
            #else
            return false
            #endif
        }
        return false
    }

    /// JWT `role` claim when the key is a JWT; nil for publishable keys (`sb_publishable_…`).
    private static func jwtRole(_ key: String) -> String? {
        let parts = key.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 3 else { return nil }
        var payload = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let pad = payload.count % 4
        if pad != 0 {
            payload.append(String(repeating: "=", count: 4 - pad))
        }
        guard let data = Data(base64Encoded: payload),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return nil
        }
        return object["role"] as? String
    }

    #if DEBUG
    /// Lets a physical device reach `supabase start` on the Mac (Session 18). Release stays HTTPS-only.
    private static func isPrivateIPv4(_ host: String) -> Bool {
        let parts = host.split(separator: ".").compactMap { Int($0) }
        guard parts.count == 4, parts.allSatisfy({ (0...255).contains($0) }) else {
            return false
        }
        let a = parts[0], b = parts[1]
        return a == 10
            || (a == 172 && (16...31).contains(b))
            || (a == 192 && b == 168)
    }
    #endif
}
