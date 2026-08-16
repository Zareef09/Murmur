import SwiftUI

/// One turn, several captures. Each row keeps its own destination so a single sentence can send
/// some things to Reminders and others to Calendar.
struct RoutingView: View {
    @Bindable var model: CaptureViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var remaining: Int {
        model.pendingItems.count - model.pendingItems.readyCount
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(spacing: MurmurSpace.space4) {
                    ForEach(model.pendingItems) { item in
                        row(for: item)
                    }
                }
                .padding(.horizontal, MurmurSpace.gutterScreen)
                .padding(.top, MurmurSpace.space5)
                .padding(.bottom, MurmurSpace.space6)
            }
            .scrollBounceBehavior(.basedOnSize)
            footer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .murmurCanvas(wash: true)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: MurmurSpace.space3) {
            Text(RoutingCopy.title)
                .font(MurmurType.headline)
                .tracking(MurmurType.trackingHeadline)
                .foregroundStyle(MurmurColor.textPrimary)
                .accessibilityAddTraits(.isHeader)

            Text(RoutingCopy.subtitle)
                .font(MurmurType.callout)
                .tracking(MurmurType.trackingCallout)
                .foregroundStyle(MurmurColor.textSecondary)

            Text(RoutingCopy.heard(model.pendingItems.count))
                .font(MurmurType.footnote)
                .tracking(MurmurType.trackingFootnote)
                .foregroundStyle(MurmurColor.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, MurmurSpace.gutterScreen)
        .padding(.top, MurmurSpace.space8)
    }

    private func row(for item: RoutedItem) -> some View {
        VStack(alignment: .leading, spacing: MurmurSpace.space4) {
            VStack(alignment: .leading, spacing: MurmurSpace.space2) {
                Text(item.title)
                    .font(MurmurType.subhead)
                    .tracking(MurmurType.trackingSubhead)
                    .foregroundStyle(MurmurColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(whenText(for: item))
                    .font(MurmurType.footnote)
                    .tracking(MurmurType.trackingFootnote)
                    .foregroundStyle(MurmurColor.textTertiary)
            }

            DestinationToggle(value: destinationBinding(for: item), size: .sm)
        }
        .padding(MurmurSpace.space5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MurmurColor.bgRaised)
        .clipShape(RoundedRectangle(cornerRadius: MurmurRadius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: MurmurRadius.lg, style: .continuous)
                .strokeBorder(MurmurColor.lineHairline, lineWidth: MurmurRadius.strokeHairline)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(item.title). \(whenText(for: item))")
    }

    private var footer: some View {
        VStack(spacing: MurmurSpace.space3) {
            if remaining > 0 {
                Text(RoutingCopy.remaining(remaining))
                    .font(MurmurType.footnote)
                    .tracking(MurmurType.trackingFootnote)
                    .foregroundStyle(MurmurColor.textTertiary)
            }
            MurmurButton(
                title: RoutingCopy.save,
                fullWidth: true,
                isDisabled: !model.pendingItems.allRouted
            ) {
                Task { await model.confirmRoutedSave() }
            }
            MurmurButton(
                title: RoutingCopy.cancel,
                variant: .ghost,
                size: .md,
                fullWidth: true
            ) {
                model.routingCancel()
            }
        }
        .padding(.horizontal, MurmurSpace.gutterScreen)
        .padding(.bottom, MurmurSpace.space5)
        .animation(
            MurmurMotion.animation(.exhale, .quick, reduceMotion: reduceMotion),
            value: remaining
        )
    }

    private func whenText(for item: RoutedItem) -> String {
        let when = item.when()
        return when.isEmpty ? RoutingCopy.noTime : when
    }

    private func destinationBinding(for item: RoutedItem) -> Binding<CaptureDestination> {
        Binding(
            get: {
                model.pendingItems.first(where: { $0.id == item.id })?.destination ?? .reminder
            },
            set: { model.setDestination($0, for: item.id) }
        )
    }
}
