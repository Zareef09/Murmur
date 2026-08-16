import SwiftUI

/// Session 20 sign-in screen. Colors from `MurmurColor`.
struct SignInView: View {
    @Environment(AuthService.self) private var auth
    @State private var isWorking = false
    @State private var fact: String?

    init(fact: String? = nil) {
        _fact = State(initialValue: fact)
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            wordmark
                .padding(.bottom, MurmurSpace.stackSection)
            VStack(alignment: .leading, spacing: MurmurSpace.stackTight) {
                Text("Say what you need to remember.")
                    .font(MurmurType.headline)
                    .tracking(MurmurType.trackingHeadline)
                    .foregroundStyle(MurmurColor.textPrimary)
                Text("Murmur files it as a reminder or an event. You can always check before it saves.")
                    .font(MurmurType.body)
                    .tracking(MurmurType.trackingBody)
                    .foregroundStyle(MurmurColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            MurmurButton(
                title: "Continue with Apple",
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
        .murmurCanvas(wash: false)
    }

    private var wordmark: some View {
        HStack(alignment: .center, spacing: 4.5) {
            Text("murmur")
                .font(MurmurType.wordmark)
                .tracking(MurmurType.trackingWordmark)
                .foregroundStyle(MurmurColor.textPrimary)
            Circle()
                .fill(MurmurColor.accent)
                .frame(width: 5, height: 5)
                .offset(x: -1.5, y: 2)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("murmur")
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
