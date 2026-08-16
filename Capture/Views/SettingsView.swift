import SwiftUI

struct SettingsView: View {
    @Environment(AuthService.self) private var auth
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    var model: CaptureViewModel
    @State private var permissions = PermissionsService()
    @State private var note: String?
    @State private var showHandsFree = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: MurmurSpace.stackSection) {
                    group(SettingsCopy.captureSection) {
                        ToggleRow(
                            label: SettingsCopy.confirmLabel,
                            description: SettingsCopy.confirmDescription,
                            isOn: alwaysConfirmBinding,
                            divider: false,
                            isDisabled: auth.userId == nil
                        )
                    }

                    group(SettingsCopy.permissionsSection) {
                        permissionRow(
                            SettingsCopy.microphone,
                            access: permissions.microphone,
                            hint: SettingsCopy.microphoneHint,
                            kind: .microphone
                        )
                        permissionRow(
                            SettingsCopy.speech,
                            access: permissions.speech,
                            hint: SettingsCopy.speechHint,
                            kind: .speech
                        )
                        permissionRow(
                            SettingsCopy.reminders,
                            access: permissions.reminders,
                            hint: SettingsCopy.remindersHint,
                            kind: .reminders
                        )
                        permissionRow(
                            SettingsCopy.calendar,
                            access: permissions.calendar,
                            hint: SettingsCopy.calendarHint,
                            kind: .calendar,
                            divider: false
                        )
                    }

                    group(BackTapCopy.settingsSection) {
                        handsFreeRow
                    }

                    group(SettingsCopy.accountSection) {
                        accountRow
                    }

                    MurmurButton(
                        title: SettingsCopy.signOut,
                        variant: .ghost,
                        size: .md,
                        fullWidth: true,
                        isDisabled: !auth.isSignedIn,
                        isDestructive: true
                    ) {
                        Task { await signOut() }
                    }

                    if let fact = note ?? model.settingsFact {
                        Text(fact)
                            .font(MurmurType.footnote)
                            .tracking(MurmurType.trackingFootnote)
                            .foregroundStyle(MurmurColor.textTertiary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    Text(SettingsCopy.bundledVersionLine)
                        .font(MurmurType.meta)
                        .foregroundStyle(MurmurColor.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, MurmurSpace.space3)
                }
                .padding(.horizontal, MurmurSpace.gutterScreen)
                .padding(.bottom, MurmurSpace.space8)
            }
            .murmurCanvas(wash: false)
            .navigationTitle(SettingsCopy.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    MurmurIconButton(name: .x, label: SettingsCopy.close) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showHandsFree) {
                BackTapWalkthroughView {
                    showHandsFree = false
                }
            }
            .onAppear { permissions.refresh() }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    permissions.refresh()
                }
            }
        }
    }

    private func permissionRow(
        _ label: String,
        access: PermissionAccess,
        hint: String,
        kind: PermissionKind,
        divider: Bool = true
    ) -> PermissionRow {
        let granted = access == .granted
        return PermissionRow(
            label: label,
            status: granted ? .granted : .needed,
            hint: granted ? nil : hint,
            divider: divider,
            fixTitle: SettingsCopy.openSettings,
            onFix: {
                Task { await openOrRequest(kind) }
            }
        )
    }

    @MainActor
    private func openOrRequest(_ kind: PermissionKind) async {
        await permissions.request(kind)
        if access(for: kind) == .needed {
            permissions.openSystemSettings()
        }
    }

    private func access(for kind: PermissionKind) -> PermissionAccess {
        switch kind {
        case .microphone: permissions.microphone
        case .speech: permissions.speech
        case .reminders: permissions.reminders
        case .calendar: permissions.calendar
        }
    }

    private var handsFreeRow: some View {
        Button {
            showHandsFree = true
        } label: {
            HStack(spacing: MurmurSpace.space4) {
                MurmurIcon(name: .audioLines, size: 19)
                    .foregroundStyle(MurmurColor.textTertiary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(BackTapCopy.settingsRowTitle)
                        .font(MurmurType.body)
                        .tracking(MurmurType.trackingBody)
                        .foregroundStyle(MurmurColor.textPrimary)
                    Text(BackTapCopy.settingsRowSubtitle)
                        .font(MurmurType.footnote)
                        .tracking(MurmurType.trackingFootnote)
                        .foregroundStyle(MurmurColor.textTertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                MurmurIcon(name: .chevronRight, size: 16)
                    .foregroundStyle(MurmurColor.textTertiary)
            }
            .padding(.horizontal, MurmurSpace.space5)
            .padding(.vertical, MurmurSpace.space4)
            .frame(minHeight: MurmurSpace.hitComfort)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(BackTapCopy.settingsRowTitle)
        .accessibilityHint(BackTapCopy.settingsRowSubtitle)
    }

    private var accountRow: some View {
        HStack(spacing: MurmurSpace.space4) {
            MurmurIcon(name: .shieldCheck, size: 19)
                .foregroundStyle(MurmurColor.textTertiary)
            VStack(alignment: .leading, spacing: 2) {
                Text(SettingsCopy.accountTitle)
                    .font(MurmurType.body)
                    .tracking(MurmurType.trackingBody)
                    .foregroundStyle(MurmurColor.textPrimary)
                Text(SettingsCopy.accountSubtitle)
                    .font(MurmurType.footnote)
                    .tracking(MurmurType.trackingFootnote)
                    .foregroundStyle(MurmurColor.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, MurmurSpace.space5)
        .padding(.vertical, MurmurSpace.space4)
        .frame(minHeight: MurmurSpace.hitComfort)
        .accessibilityElement(children: .combine)
    }

    private func group(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: MurmurSpace.space3) {
            Text(title)
                .font(MurmurType.caption)
                .tracking(MurmurType.trackingCaption)
                .textCase(.uppercase)
                .foregroundStyle(MurmurColor.textTertiary)
                .padding(.horizontal, MurmurSpace.space4)
            VStack(spacing: 0) {
                content()
            }
            .background(MurmurColor.bgRaised)
            .overlay {
                RoundedRectangle(cornerRadius: MurmurRadius.md, style: .continuous)
                    .strokeBorder(MurmurColor.lineHairline, lineWidth: MurmurRadius.strokeHairline)
            }
            .clipShape(RoundedRectangle(cornerRadius: MurmurRadius.md, style: .continuous))
            .murmurShadow(.row)
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
            dismiss()
        } catch {
            note = AuthCopy.signOutFact(for: error)
        }
    }
}

#Preview("Settings · light") {
    SettingsView(model: CaptureViewModel())
        .environment(AuthService())
        .preferredColorScheme(.light)
}

#Preview("Settings · dark") {
    SettingsView(model: CaptureViewModel())
        .environment(AuthService())
        .preferredColorScheme(.dark)
}
