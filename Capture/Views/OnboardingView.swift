import SwiftUI

enum OnboardingCopy {
    static let skip = "Skip"
    static let next = "Next"
    static let allowAccess = "Allow access"
    static let setItUp = "Set it up"

    static let slide1Title = "Say it once. It’s kept."
    static let slide1Body =
        "Speak a thought the way you’d say it to a person. Murmur files it as a reminder or an event."

    static let slide2Title = "Two things to allow"
    static let slide2Body =
        "Your microphone, so Murmur can hear you. Reminders and Calendar, so it has somewhere to put things. Nothing leaves your phone unasked."

    static let slide3Title = "One press, hands free"
    static let slide3Body =
        "Put Murmur on the Action Button and capture without looking. You can set this up later in Settings."

    static let continueTitle = "Continue"
    static let microphone = "Microphone"
    static let reminders = "Reminders"
    static let calendar = "Calendar"
    static let microphoneHint = "So Murmur can hear you"
    static let remindersHint = "Somewhere to keep tasks"
    static let calendarHint = "Somewhere to keep events"
}

/// Kit slide 2 primes microphone, Reminders, and Calendar. Speech is requested with Allow access.
enum OnboardingAccess {
    @MainActor
    static func primingKindsGranted(_ permissions: PermissionsServicing) -> Bool {
        permissions.microphone == .granted
            && permissions.reminders == .granted
            && permissions.calendar == .granted
    }

    static func slide2CTA(granted: Bool, didAsk: Bool) -> String {
        if granted { return OnboardingCopy.next }
        if didAsk { return OnboardingCopy.continueTitle }
        return OnboardingCopy.allowAccess
    }
}

/// Three slides. First-launch gate and Apple are Session 50. Set it up opens the Back Tap walkthrough.
struct OnboardingView: View {
    var pageCount: Int = 3
    var startPage: Int = 0
    var onSkip: () -> Void = {}
    var onSetUpHandsFree: () -> Void = {}

    @State private var page = 0
    @State private var showHandsFree = false
    @State private var didAskPermissions = false
    @State private var permissions = PermissionsService()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                MurmurButton(title: OnboardingCopy.skip, variant: .ghost, size: .sm, action: onSkip)
            }
            .padding(.horizontal, MurmurSpace.space4)

            Spacer(minLength: 0)

            VStack(spacing: MurmurSpace.space9) {
                hero
                    .frame(maxWidth: .infinity, minHeight: 220)

                VStack(alignment: .leading, spacing: MurmurSpace.space4) {
                    Text(title)
                        .font(MurmurType.display)
                        .tracking(MurmurType.trackingDisplay)
                        .foregroundStyle(MurmurColor.textPrimary)
                        .frame(maxWidth: 16 * 20, alignment: .leading)
                    Text(bodyCopy)
                        .font(MurmurType.callout)
                        .tracking(MurmurType.trackingCallout)
                        .foregroundStyle(MurmurColor.textSecondary)
                        .frame(maxWidth: 30 * 10, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .animation(
                MurmurMotion.animation(.exhale, .normal, reduceMotion: reduceMotion),
                value: page
            )
            .padding(.horizontal, MurmurSpace.gutterScreen)

            Spacer(minLength: 0)

            VStack(spacing: MurmurSpace.space5) {
                pageDots
                MurmurButton(title: ctaTitle, fullWidth: true) {
                    Task { await advance() }
                }
            }
            .padding(.horizontal, MurmurSpace.gutterScreen)
            .padding(.bottom, MurmurSpace.space5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .murmurCanvas(wash: true)
        .onAppear {
            page = min(max(startPage, 0), pageCount - 1)
            permissions.refresh()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                permissions.refresh()
            }
        }
        .sheet(isPresented: $showHandsFree, onDismiss: onSetUpHandsFree) {
            BackTapWalkthroughView {
                showHandsFree = false
            }
        }
    }

    @ViewBuilder
    private var hero: some View {
        switch page {
        case 0:
            CaptureBloom(state: .idle, size: 196, isInteractive: false)
                .frame(maxWidth: .infinity)
        case 1:
            permissionCard
        default:
            AppIconView(size: 132)
                .frame(maxWidth: .infinity)
        }
    }

    private var permissionCard: some View {
        VStack(spacing: 0) {
            primingRow(
                OnboardingCopy.microphone,
                access: permissions.microphone,
                hint: OnboardingCopy.microphoneHint,
                kind: .microphone
            )
            primingRow(
                OnboardingCopy.reminders,
                access: permissions.reminders,
                hint: OnboardingCopy.remindersHint,
                kind: .reminders
            )
            primingRow(
                OnboardingCopy.calendar,
                access: permissions.calendar,
                hint: OnboardingCopy.calendarHint,
                kind: .calendar,
                divider: false
            )
        }
        .background(MurmurColor.bgRaised)
        .overlay {
            RoundedRectangle(cornerRadius: MurmurRadius.lg, style: .continuous)
                .strokeBorder(MurmurColor.lineHairline, lineWidth: MurmurRadius.strokeHairline)
        }
        .clipShape(RoundedRectangle(cornerRadius: MurmurRadius.lg, style: .continuous))
    }

    private var title: String {
        switch page {
        case 0: OnboardingCopy.slide1Title
        case 1: OnboardingCopy.slide2Title
        default: OnboardingCopy.slide3Title
        }
    }

    private var bodyCopy: String {
        switch page {
        case 0: OnboardingCopy.slide1Body
        case 1: OnboardingCopy.slide2Body
        default: OnboardingCopy.slide3Body
        }
    }

    private var ctaTitle: String {
        switch page {
        case 0: OnboardingCopy.next
        case 1:
            OnboardingAccess.slide2CTA(granted: primingGranted, didAsk: didAskPermissions)
        default: OnboardingCopy.setItUp
        }
    }

    private var primingGranted: Bool {
        OnboardingAccess.primingKindsGranted(permissions)
    }

    private var pageDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(index == page ? MurmurColor.accent : MurmurColor.lineSoft)
                    .frame(width: index == page ? 20 : 6, height: 6)
                    .animation(
                        MurmurMotion.animation(.exhale, .normal, reduceMotion: reduceMotion),
                        value: page
                    )
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(page + 1) of \(pageCount)")
    }

    private func primingRow(
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
            onFix: granted
                ? nil
                : {
                    Task { await openOrRequest(kind) }
                }
        )
    }

    @MainActor
    private func openOrRequest(_ kind: PermissionKind) async {
        didAskPermissions = true
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

    @MainActor
    private func advance() async {
        switch page {
        case 0:
            page = 1
            permissions.refresh()
        case 1:
            await advanceFromPermissions()
        default:
            showHandsFree = true
        }
    }

    @MainActor
    private func advanceFromPermissions() async {
        if primingGranted {
            page = 2
            return
        }
        if didAskPermissions {
            page = 2
            return
        }
        didAskPermissions = true
        await permissions.requestAll()
        if primingGranted {
            page = 2
        }
    }
}

#Preview("Onboarding · slide 1 · light") {
    OnboardingView()
        .preferredColorScheme(.light)
}

#Preview("Onboarding · slide 1 · dark") {
    OnboardingView()
        .preferredColorScheme(.dark)
}

#Preview("Onboarding · slide 2 · light") {
    OnboardingView(startPage: 1)
        .preferredColorScheme(.light)
}

#Preview("Onboarding · slide 2 · dark") {
    OnboardingView(startPage: 1)
        .preferredColorScheme(.dark)
}

#Preview("Onboarding · slide 3 · light") {
    OnboardingView(startPage: 2)
        .preferredColorScheme(.light)
}

#Preview("Onboarding · slide 3 · dark") {
    OnboardingView(startPage: 2)
        .preferredColorScheme(.dark)
}
