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
}

/// Three slides. First-launch gate and Apple are Session 50. Action Button walkthrough is Session 87.
struct OnboardingView: View {
    var pageCount: Int = 3
    var startPage: Int = 0
    var onSkip: () -> Void = {}
    var onSetUpHandsFree: () -> Void = {}

    @State private var page = 0
    @State private var permissions = PermissionsService()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
                    .frame(minHeight: 220)

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
        .onAppear { page = min(max(startPage, 0), pageCount - 1) }
    }

    @ViewBuilder
    private var hero: some View {
        switch page {
        case 0:
            CaptureBloom(state: .idle, size: 196)
        case 1:
            permissionCard
        default:
            AppIconView(size: 132)
        }
    }

    private var permissionCard: some View {
        VStack(spacing: 0) {
            PermissionRow(
                label: "Microphone",
                status: rowStatus(permissions.microphone),
                hint: "So Murmur can hear you"
            )
            PermissionRow(
                label: "Reminders",
                status: rowStatus(permissions.reminders),
                hint: "Somewhere to keep tasks"
            )
            PermissionRow(
                label: "Calendar",
                status: rowStatus(permissions.calendar),
                hint: "Somewhere to keep events",
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
        case 1: OnboardingCopy.allowAccess
        default: OnboardingCopy.setItUp
        }
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

    private func rowStatus(_ access: PermissionAccess) -> PermissionRow.Status {
        access == .granted ? .granted : .needed
    }

    @MainActor
    private func advance() async {
        if page == 0 {
            page = 1
            return
        }
        if page == 1 {
            await permissions.requestAll()
            page = 2
            return
        }
        onSetUpHandsFree()
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
