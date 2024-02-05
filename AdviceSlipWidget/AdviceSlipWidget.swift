//
//  AdviceSlipWidget.swift
//  AdviceSlipWidget
//
//  Created by Zsolt Kébel on 31/01/2024.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    private let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: Advice.self)
        } catch {
            fatalError("Failed to create the model container: \(error)")
        }
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry.placeholderEntry
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry.placeholderEntry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        /**
         modelContainer.mainContext requires main actor.
         This method returns immediately, but calls the completion handler at the end of the task.
         */
        Task { @MainActor in
            //TODO: refactor this part
            // fetch new advice
            guard let adviceSlip = await WiseBuddy.shared.getAdviceToShow() else {
                // exit if error
                let newEntry = SimpleEntry(date: .now, slip: AdviceSlip(id: 0, advice: "No advice"), saved: false)
                let timeline = Timeline(entries: [newEntry], policy: .never)
                completion(timeline)
                return
            }
            
            // check if it's saved
            var fetchDescriptor = FetchDescriptor(sortBy: [SortDescriptor(\Advice.id, order: .forward)])
            guard let now = WiseBuddy.shared.generatedAt else {
                //TODO: fix logic here
                return
            }
            
            let id = adviceSlip.id
            fetchDescriptor.predicate = #Predicate { $0.id == id }
            if let savedAdvice = try? modelContainer.mainContext.fetch(fetchDescriptor) {
                let isSaved = savedAdvice.first != nil
                let newEntry = SimpleEntry(date: now, slip: adviceSlip, saved: isSaved)
                let nextAdviceDate = Calendar.current.date(
                    byAdding: DateComponents(minute: 15),
                    to: Date()
                )!
                let timeline = Timeline(entries: [newEntry], policy: .after(nextAdviceDate))
                completion(timeline)
                return
            }
            /**
             Return "No Trips" entry with .never policy when there is no upcoming trip.
             The main app triggers a widget update when adding a new trip.
             */
            let newEntry = SimpleEntry(date: .now, slip: AdviceSlip(id: 0, advice: "No advice"), saved: false)
            let timeline = Timeline(entries: [newEntry], policy: .never)
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    
    let slip: AdviceSlip
    let saved: Bool
    
    static var placeholderEntry: SimpleEntry {
        let now = Date()
        return SimpleEntry(date: now, slip: AdviceSlip(id: 0, advice: "If you don't want something to be public, don't post it on the Internet."), saved: false)
    }
}

struct AdviceSlipWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            Spacer(minLength: 0)
            Text(entry.slip.advice)
                .minimumScaleFactor(0.1)
                .font(.title3)
            Spacer(minLength: 10)
            HStack {
                if #available(iOS 17.0, *) {
                    Button(intent: RefreshIntent()) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.bordered)
                }
                if family != .systemSmall {
                    if #available(iOS 17.0, *) {
                        Button(intent: SaveIntent(adviceID: entry.slip.id, adviceText: entry.slip.advice)) {
                            Image(systemName: entry.saved ? "bookmark.fill" : "bookmark")
                        }
                        .buttonStyle(.bordered)
                        .tint(.secondary)
                    }
                }
                Spacer(minLength: 0)
                Text(entry.date, style: .time)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct AdviceSlipWidget: Widget {
    let kind: String = "AdviceSlipWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                AdviceSlipWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                AdviceSlipWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemMedium) {
    AdviceSlipWidget()
} timeline: {
    SimpleEntry.placeholderEntry
}
