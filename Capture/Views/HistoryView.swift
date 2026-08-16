import SwiftData
import SwiftUI

/// On-device captures from the last three days. Newest first.
struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Capture.createdAt, order: .reverse) private var captures: [Capture]
    var eventKit: EventKitServicing = EventKitService()
    @State private var openFact: String?
    @State private var swipedID: UUID?
    @State private var pendingID: UUID?

    var body: some View {
        Group {
            if captures.isEmpty {
                empty
            } else {
                list
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .murmurCanvas(wash: false)
        .toolbar(.visible, for: .navigationBar)
        .navigationTitle(HistoryCopy.title)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            HistoryCopy.deleteTitle,
            isPresented: pendingPresented,
            titleVisibility: .visible
        ) {
            Button(HistoryCopy.murmurOnly) {
                Task { await deletePending(.murmurOnly) }
            }
            Button(alsoExternalTitle, role: .destructive) {
                Task { await deletePending(.alsoExternal) }
            }
            Button(HistoryCopy.cancel, role: .cancel) {
                pendingID = nil
            }
        }
    }

    private var pendingPresented: Binding<Bool> {
        Binding(
            get: { pendingID != nil },
            set: { if !$0 { pendingID = nil } }
        )
    }

    private var alsoExternalTitle: String {
        let destination = captures.first(where: { $0.id == pendingID })?.destination ?? .reminder
        return HistoryCopy.alsoExternal(for: destination)
    }

    private var empty: some View {
        VStack(spacing: MurmurSpace.space5) {
            EmptyState(
                icon: .list,
                title: HistoryCopy.emptyTitle,
                message: HistoryCopy.emptyBody
            ) {
                MurmurButton(
                    title: HistoryCopy.captureAction,
                    variant: .secondary,
                    size: .md
                ) {
                    dismiss()
                }
            }
            Text(HistoryCopy.ttlNote)
                .font(MurmurType.footnote)
                .tracking(MurmurType.trackingFootnote)
                .foregroundStyle(MurmurColor.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, MurmurSpace.gutterScreen)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var list: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: MurmurSpace.space7) {
                ForEach(HistoryListFormat.grouped(captures), id: \.title) { section in
                    dayGroup(title: section.title, items: section.items)
                }
            }
            .padding(.horizontal, MurmurSpace.gutterScreen)
            .padding(.bottom, MurmurSpace.space8)
        }
        .safeAreaInset(edge: .bottom) {
            Text(openFact ?? HistoryCopy.swipeHint)
                .font(MurmurType.footnote)
                .tracking(MurmurType.trackingFootnote)
                .foregroundStyle(MurmurColor.textTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, MurmurSpace.gutterScreen)
                .padding(.bottom, MurmurSpace.space4)
        }
    }

    private func dayGroup(title: String, items: [Capture]) -> some View {
        VStack(alignment: .leading, spacing: MurmurSpace.space3) {
            Text(title)
                .font(MurmurType.caption)
                .tracking(MurmurType.trackingCaption)
                .textCase(.uppercase)
                .foregroundStyle(MurmurColor.textTertiary)
                .padding(.horizontal, MurmurSpace.space4)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, capture in
                    HistoryRow(
                        title: capture.title,
                        destination: capture.destination,
                        when: ConfirmationWhenFormat.display(
                            date: capture.startDate,
                            hasExplicitTime: capture.hasExplicitTime
                        ),
                        relative: HistoryListFormat.relative(createdAt: capture.createdAt),
                        divider: index < items.count - 1,
                        swiped: swipedID == capture.id,
                        onPress: { open(capture) },
                        onSwipe: { toggleSwipe(capture.id) },
                        onDelete: { pendingID = capture.id }
                    )
                }
            }
            .background(MurmurColor.bgRaised)
            .overlay {
                RoundedRectangle(cornerRadius: MurmurRadius.lg, style: .continuous)
                    .strokeBorder(MurmurColor.lineHairline, lineWidth: MurmurRadius.strokeHairline)
            }
            .clipShape(RoundedRectangle(cornerRadius: MurmurRadius.lg, style: .continuous))
            .murmurShadow(.row)
        }
    }

    private func toggleSwipe(_ id: UUID) {
        swipedID = swipedID == id ? nil : id
    }

    private func deletePending(_ scope: HistoryDeleteScope) async {
        let id = pendingID
        pendingID = nil
        swipedID = nil
        guard let id, let capture = captures.first(where: { $0.id == id }) else { return }
        do {
            try await HistoryDelete.apply(
                capture,
                scope: scope,
                context: modelContext,
                eventKit: eventKit
            )
            openFact = nil
        } catch let error as EventKitServiceError {
            openFact = EventKitCopy.openFact(for: error, destination: capture.destination)
        } catch {
            openFact = HistoryCopy.deleteNeeded
        }
    }

    private func open(_ capture: Capture) {
        swipedID = nil
        openFact = nil
        let identifier = capture.eventKitIdentifier?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !identifier.isEmpty else {
            openFact = EventKitCopy.nothingToOpen
            return
        }
        do {
            let url = try eventKit.openingURL(identifier: identifier, destination: capture.destination)
            openURL(url)
        } catch let error as EventKitServiceError {
            openFact = EventKitCopy.openFact(for: error, destination: capture.destination)
        } catch {
            openFact = capture.destination == .event ? EventKitCopy.eventGone : EventKitCopy.reminderGone
        }
    }
}

#Preview("History · empty · light") {
    NavigationStack {
        HistoryView()
    }
    .modelContainer(for: Capture.self, inMemory: true)
    .preferredColorScheme(.light)
}

#Preview("History · empty · dark") {
    NavigationStack {
        HistoryView()
    }
    .modelContainer(for: Capture.self, inMemory: true)
    .preferredColorScheme(.dark)
}

#Preview("History · populated · light") {
    NavigationStack {
        HistoryView()
    }
    .modelContainer(historyPreviewContainer())
    .preferredColorScheme(.light)
}

#Preview("History · populated · dark") {
    NavigationStack {
        HistoryView()
    }
    .modelContainer(historyPreviewContainer())
    .preferredColorScheme(.dark)
}

@MainActor
private func historyPreviewContainer() -> ModelContainer {
    let container = try! Persistence.makeContainer(inMemory: true)
    let now = Date()
    let calendar = Calendar.current
    let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
    container.mainContext.insert(
        Capture(
            title: "Call mom",
            destination: .reminder,
            startDate: tomorrow,
            hasExplicitTime: true,
            createdAt: now.addingTimeInterval(-2 * 60 * 60)
        )
    )
    container.mainContext.insert(
        Capture(
            title: "Coffee with Ana",
            destination: .event,
            startDate: now,
            hasExplicitTime: true,
            createdAt: now.addingTimeInterval(-5 * 60 * 60)
        )
    )
    container.mainContext.insert(
        Capture(
            title: "Buy cat food",
            destination: .reminder,
            createdAt: now.addingTimeInterval(-9 * 60 * 60)
        )
    )
    container.mainContext.insert(
        Capture(
            title: "Dentist",
            destination: .event,
            startDate: calendar.date(byAdding: .day, value: 2, to: now),
            hasExplicitTime: true,
            createdAt: yesterday
        )
    )
    return container
}
