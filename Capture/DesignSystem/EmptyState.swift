import SwiftUI

/// Warm empty History / first-run. Hairline ring echoes the capture well. No illustration.
struct EmptyState<Action: View>: View {
    var icon: MurmurIconName = .audioLines
    var title: String
    var message: String?
    @ViewBuilder var action: () -> Action

    init(
        icon: MurmurIconName = .audioLines,
        title: String,
        message: String? = nil,
        @ViewBuilder action: @escaping () -> Action
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.action = action
    }

    var body: some View {
        VStack(spacing: MurmurSpace.space5) {
            MurmurIcon(name: icon, size: 26)
                .foregroundStyle(MurmurColor.textTertiary)
                .frame(width: 76, height: 76)
                .background(MurmurColor.accentGlowFaint)
                .overlay {
                    Circle()
                        .strokeBorder(MurmurColor.lineSoft, lineWidth: MurmurRadius.strokeHairline)
                }
                .clipShape(Circle())

            VStack(spacing: MurmurSpace.space3) {
                Text(title)
                    .font(MurmurType.headline)
                    .tracking(MurmurType.trackingHeadline)
                    .foregroundStyle(MurmurColor.textPrimary)
                if let message {
                    Text(message)
                        .font(MurmurType.callout)
                        .tracking(MurmurType.trackingCallout)
                        .foregroundStyle(MurmurColor.textSecondary)
                }
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: 28 * 12, alignment: .center)

            action()
        }
        .padding(.vertical, MurmurSpace.space9)
        .padding(.horizontal, MurmurSpace.space7)
        .frame(maxWidth: .infinity)
    }
}

extension EmptyState where Action == EmptyView {
    init(icon: MurmurIconName = .audioLines, title: String, message: String? = nil) {
        self.init(icon: icon, title: title, message: message) { EmptyView() }
    }
}
