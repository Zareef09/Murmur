import SwiftUI

/// In-app steps only. The user installs Back Tap or Action Button; Murmur does not change Accessibility.
struct BackTapWalkthroughView: View {
    var onFinished: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: MurmurSpace.space6) {
                Text(BackTapCopy.navigationTitle)
                    .font(MurmurType.headline)
                    .tracking(MurmurType.trackingHeadline)
                    .foregroundStyle(MurmurColor.textPrimary)

                Text(BackTapCopy.intro)
                    .font(MurmurType.callout)
                    .tracking(MurmurType.trackingCallout)
                    .foregroundStyle(MurmurColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                stepGroup(title: BackTapCopy.shortcutHeading, steps: BackTapCopy.shortcutSteps)

                stepGroup(title: BackTapCopy.backTapHeading, steps: BackTapCopy.backTapSteps)

                VStack(alignment: .leading, spacing: MurmurSpace.space3) {
                    Text(BackTapCopy.actionButtonHeading)
                        .font(MurmurType.subhead)
                        .tracking(MurmurType.trackingSubhead)
                        .foregroundStyle(MurmurColor.textPrimary)
                    Text(BackTapCopy.actionButtonBody)
                        .font(MurmurType.callout)
                        .tracking(MurmurType.trackingCallout)
                        .foregroundStyle(MurmurColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text(BackTapCopy.footer)
                    .font(MurmurType.footnote)
                    .tracking(MurmurType.trackingFootnote)
                    .foregroundStyle(MurmurColor.textTertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, MurmurSpace.gutterScreen)
                .padding(.top, MurmurSpace.space8)
                .padding(.bottom, MurmurSpace.space6)
            }
            .scrollBounceBehavior(.basedOnSize)

            VStack(spacing: MurmurSpace.space4) {
                MurmurButton(title: BackTapCopy.done, fullWidth: true, action: onFinished)
                MurmurButton(
                    title: BackTapCopy.later,
                    variant: .ghost,
                    size: .md,
                    fullWidth: true,
                    action: onFinished
                )
            }
            .padding(.horizontal, MurmurSpace.gutterScreen)
            .padding(.bottom, MurmurSpace.space5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .murmurCanvas(wash: true)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(BackTapCopy.navigationTitle)
    }

    private func stepGroup(title: String, steps: [String]) -> some View {
        VStack(alignment: .leading, spacing: MurmurSpace.space4) {
            Text(title)
                .font(MurmurType.subhead)
                .tracking(MurmurType.trackingSubhead)
                .foregroundStyle(MurmurColor.textPrimary)

            VStack(alignment: .leading, spacing: MurmurSpace.space4) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: MurmurSpace.space4) {
                        Text("\(index + 1)")
                            .font(MurmurType.caption)
                            .tracking(MurmurType.trackingCaption)
                            .foregroundStyle(MurmurColor.textTertiary)
                            .frame(width: 22, height: 22)
                            .background(MurmurColor.bgRaised)
                            .clipShape(Circle())
                            .accessibilityHidden(true)
                        Text(step)
                            .font(MurmurType.callout)
                            .tracking(MurmurType.trackingCallout)
                            .foregroundStyle(MurmurColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Step \(index + 1). \(step)")
                }
            }
        }
    }
}

#Preview("Back Tap walkthrough · light") {
    BackTapWalkthroughView()
        .preferredColorScheme(.light)
}

#Preview("Back Tap walkthrough · dark") {
    BackTapWalkthroughView()
        .preferredColorScheme(.dark)
}
