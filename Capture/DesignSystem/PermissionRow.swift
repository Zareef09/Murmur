import SwiftUI

/// Permission status. Granted is quiet; needed is clay, never red.
struct PermissionRow: View {
    enum Status {
        case granted
        case needed
    }

    var label: String
    var status: Status = .granted
    var hint: String?
    var divider: Bool = true
    var onFix: (() -> Void)?

    var body: some View {
        HStack(alignment: .center, spacing: MurmurSpace.space4) {
            statusMark
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(MurmurType.body)
                    .tracking(MurmurType.trackingBody)
                    .foregroundStyle(MurmurColor.textPrimary)
                Text(subline)
                    .font(MurmurType.footnote)
                    .tracking(MurmurType.trackingFootnote)
                    .foregroundStyle(isGranted ? MurmurColor.textTertiary : MurmurColor.attentionFg)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if !isGranted, onFix != nil {
                Button("Allow", action: { onFix?() })
                    .font(MurmurType.footnote)
                    .tracking(MurmurType.trackingFootnote)
                    .foregroundStyle(MurmurColor.textPrimary)
                    .padding(.horizontal, MurmurSpace.space5)
                    .frame(minHeight: MurmurSpace.hitMin)
                    .overlay {
                        Capsule()
                            .strokeBorder(MurmurColor.lineSoft, lineWidth: MurmurRadius.strokeHairline)
                    }
                    .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, MurmurSpace.space5)
        .padding(.vertical, MurmurSpace.space4)
        .frame(minHeight: MurmurSpace.hitComfort)
        .overlay(alignment: .bottom) {
            if divider {
                MurmurColor.lineHairline.frame(height: MurmurRadius.strokeHairline)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var isGranted: Bool { status == .granted }

    private var subline: String {
        hint ?? (isGranted ? "Allowed" : "Not allowed yet")
    }

    private var statusMark: some View {
        MurmurIcon(
            name: isGranted ? .check : .circleAlert,
            size: 14,
            title: isGranted ? "Granted" : "Needs attention"
        )
        .foregroundStyle(isGranted ? MurmurColor.successFg : MurmurColor.attentionFg)
        .frame(width: 26, height: 26)
        .background(isGranted ? MurmurColor.successBg : MurmurColor.attentionBg)
        .clipShape(Circle())
    }
}
