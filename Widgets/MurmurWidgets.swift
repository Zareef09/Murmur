import AppIntents
import SwiftUI
import WidgetKit

struct QuickCaptureEntry: TimelineEntry {
    let date: Date
}

struct QuickCaptureProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickCaptureEntry {
        QuickCaptureEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (QuickCaptureEntry) -> Void) {
        completion(QuickCaptureEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickCaptureEntry>) -> Void) {
        completion(Timeline(entries: [QuickCaptureEntry(date: Date())], policy: .never))
    }
}

/// Tap launches Quick capture (app foreground; lock screen unlocks first).
struct QuickCaptureWidget: Widget {
    let kind = "QuickCaptureWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuickCaptureProvider()) { _ in
            QuickCaptureWidgetView()
        }
        .configurationDisplayName("Murmur")
        .description("Open Murmur and start listening.")
        .supportedFamilies(QuickCaptureWidgetSupport.families)
    }
}

struct QuickCaptureWidgetView: View {
    @Environment(\.widgetFamily) private var family

    var body: some View {
        Button(intent: QuickCaptureIntent()) {
            label
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Quick capture")
        .containerBackground(for: .widget) {
            if family == .systemSmall {
                Color.clear
            }
        }
    }

    @ViewBuilder
    private var label: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                Image(systemName: "waveform")
                    .font(.system(size: 22, weight: .regular))
                    .widgetAccentable()
            }
        case .accessoryInline:
            Label("Quick capture", systemImage: "waveform")
                .widgetAccentable()
        case .accessoryRectangular:
            HStack(spacing: 8) {
                Image(systemName: "waveform")
                    .widgetAccentable()
                Text("Quick capture")
            }
        default:
            VStack(spacing: 8) {
                Image(systemName: "waveform")
                    .font(.title2)
                Text("Murmur")
                    .font(.headline)
            }
        }
    }
}

@main
struct MurmurWidgets: WidgetBundle {
    var body: some Widget {
        QuickCaptureWidget()
        if #available(iOSApplicationExtension 18.0, *) {
            QuickCaptureControl()
        }
    }
}

#Preview("Lock screen · circular", as: .accessoryCircular) {
    QuickCaptureWidget()
} timeline: {
    QuickCaptureEntry(date: .now)
}

#Preview("Lock screen · inline", as: .accessoryInline) {
    QuickCaptureWidget()
} timeline: {
    QuickCaptureEntry(date: .now)
}

#Preview("Lock screen · rectangular", as: .accessoryRectangular) {
    QuickCaptureWidget()
} timeline: {
    QuickCaptureEntry(date: .now)
}
