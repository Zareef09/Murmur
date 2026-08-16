import Foundation
import os
import Supabase

private let settingsLog = Logger(subsystem: "app.murmur.capture", category: "settings")

private struct UserSettingsRow: Decodable, Equatable {
    let userId: UUID
    let alwaysConfirm: Bool

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case alwaysConfirm = "always_confirm"
    }
}

private struct UserSettingsWrite: Encodable {
    let userId: UUID
    let alwaysConfirm: Bool

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case alwaysConfirm = "always_confirm"
    }
}

@MainActor
protocol SettingsSyncing: AnyObject {
    var alwaysConfirm: Bool { get }
    func loadCached()
    func fetchRemote() async throws
    func setAlwaysConfirm(_ value: Bool)
    func cancelPendingUpsert()
}

/// Fetches/upserts `user_settings` as the signed-in user (RLS). Cache is immediate; upserts are debounced.
@MainActor
final class SettingsSyncService: SettingsSyncing {
    private let repository: SettingsRepositorying
    private var upsertTask: Task<Void, Never>?
    private var hasPendingWrite = false

    private(set) var alwaysConfirm: Bool = SettingsRepository.defaultAlwaysConfirm

    init(repository: SettingsRepositorying = SettingsRepository.shared) {
        self.repository = repository
    }

    func loadCached() {
        guard let userId = sessionUserId else {
            alwaysConfirm = SettingsRepository.defaultAlwaysConfirm
            return
        }
        alwaysConfirm = repository.alwaysConfirm(userId: userId)
    }

    func fetchRemote() async throws {
        guard let client = SupabaseClientProvider.client else {
            throw AuthServiceError.notConfigured
        }
        guard let userId = sessionUserId else {
            return
        }

        let row: UserSettingsRow? = try await client
            .from("user_settings")
            .select("user_id, always_confirm")
            .eq("user_id", value: userId)
            .maybeSingle()
            .execute()
            .value

        guard !hasPendingWrite else { return }
        guard let row, row.userId == userId else { return }

        alwaysConfirm = row.alwaysConfirm
        repository.setAlwaysConfirm(row.alwaysConfirm, userId: userId)
    }

    func setAlwaysConfirm(_ value: Bool) {
        guard let userId = sessionUserId else { return }
        alwaysConfirm = value
        repository.setAlwaysConfirm(value, userId: userId)
        hasPendingWrite = true
        upsertTask?.cancel()
        upsertTask = Task { [value, userId] in
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            await self.pushRemote(alwaysConfirm: value, userId: userId)
        }
    }

    func cancelPendingUpsert() {
        upsertTask?.cancel()
        upsertTask = nil
        hasPendingWrite = false
    }

    /// Session uid only. Never a user-id from UI.
    private var sessionUserId: UUID? {
        SupabaseClientProvider.currentSession?.user.id
    }

    private func pushRemote(alwaysConfirm: Bool, userId: UUID) async {
        guard sessionUserId == userId else { return }
        guard let client = SupabaseClientProvider.client else { return }

        do {
            try await client
                .from("user_settings")
                .upsert(
                    UserSettingsWrite(userId: userId, alwaysConfirm: alwaysConfirm),
                    onConflict: "user_id"
                )
                .execute()
            hasPendingWrite = false
            settingsLog.info("settings upsert ok")
        } catch {
            // Keep cache. Capture stays usable offline.
        }
    }
}
