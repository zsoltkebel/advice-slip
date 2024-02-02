//
//  ContentView.swift
//  AdviceSlip
//
//  Created by Zsolt Kébel on 31/01/2024.
//

import SwiftUI
import SwiftData
import WidgetKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Advice.id, order: .forward)
    var advices: [Advice]
    
    var body: some View {
        //TODO: could use NavigationSplitView here
        NavigationView {
            List {
                ForEach(advices) { advice in
                    AdviceListItem(advice: advice)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteAdvice(advice)
                                WidgetCenter.shared.reloadTimelines(ofKind: "AdviceSlipWidget")
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .overlay {
                if advices.isEmpty {
                    ContentUnavailableView {
                        Label("No Advices", systemImage: "tray")
                    } description: {
                        Text("Your bookmarked advices will appear here.")
                    }
                }
            }
            .navigationTitle("Saved Advices")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Total: \(advices.count)")
                }
            }
        }
    }
    
    private func deleteAdvice(_ advice: Advice) {
        //TODO: if selection is implemented need to deselect it
        modelContext.delete(advice)
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewSampleData.container)
}
