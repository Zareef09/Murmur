import SwiftUI

/// Sign in with Apple. Kit voice; no email, no celebration.
struct SignInView: View {
    @Environment(AuthService.self) private var auth
    @State private var isWorking = false
    @State private var fact: String?

    init(fact: String? = nil) {
        _fact = State(initialValue: fact)
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            VStack(spacing: MurmurSpace.space8) {
                AppIconView(size: 84)
                Wordmark()
            }
            .padding(.bottom, MurmurSpace.stackSection)

            VStack(alignment: .leading, spacing: MurmurSpace.stackTight) {
                Text(CaptureCopy.firstRunTitle)
                    .font(MurmurType.title)
                    .tracking(MurmurType.trackingTitle)
                    .foregroundStyle(MurmurColor.textPrimary)
                Text(CaptureCopy.firstRunFootnote)
                    .font(MurmurType.callout)
                    .tracking(MurmurType.trackingCallout)
                    .foregroundStyle(MurmurColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer(minLength: 0)
            MurmurButton(
                title: AuthCopy.continueWithApple,
                systemIcon: "apple.logo",
                fullWidth: true,
                isDisabled: isWorking
            ) {
                Task { await continueWithApple() }
            }
            if let fact {
                Text(fact)
                    .font(MurmurType.footnote)
                    .tracking(MurmurType.trackingFootnote)
                    .foregroundStyle(MurmurColor.textTertiary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
            }
        }
        .padding(.horizontal, MurmurSpace.gutterScreen)
        .padding(.bottom, MurmurSpace.stackLoose)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .murmurCanvas(wash: true)
    }

    @MainActor
    private func continueWithApple() async {
        fact = nil
        isWorking = true
        defer { isWorking = false }
        do {
            try await auth.signInWithApple()
        } catch {
            fact = AuthCopy.signInFact(for: error)
        }
    }
}

#Preview("Sign in · light") {
    SignInView()
        .environment(AuthService())
        .preferredColorScheme(.light)
}

#Preview("Sign in · dark") {
    SignInView()
        .environment(AuthService())
        .preferredColorScheme(.dark)
}

#Preview("Sign in · not now") {
    SignInView(fact: AuthCopy.notNow)
        .environment(AuthService())
        .preferredColorScheme(.light)
}

#Preview("Sign in · connection needed") {
    SignInView(fact: AuthCopy.connectionNeededToCreateAccount)
        .environment(AuthService())
        .preferredColorScheme(.light)
}
