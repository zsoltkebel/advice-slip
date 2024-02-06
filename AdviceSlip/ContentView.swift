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
    
    @Query(sort: \Snippet.sourceID, order: .forward)
    var advices: [Snippet]
    
    @AppStorage("dataSource", store: UserDefaults.shared) private var selectedDataSource: DataSource = .adviceSlip
    
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
            .navigationTitle("Saved Snippets")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Total: \(advices.count)")
                }
                ToolbarItem {
                    Menu("Menu", systemImage: "ellipsis.circle") {
                        Button("Show Source Info", systemImage: "info.circle") {
                            //TODO: implement sheet
                            print("Show info")
                        }
                        Picker(selection: $selectedDataSource) {
                            ForEach(DataSource.allCases) { source in
                                Text(source.getName()).tag(source)
                            }
                        } label: {
                            Button(action: {}, label: {
                                Text("Source")
                                Text(selectedDataSource.getName())
                                Image(systemName: "network")
                            })
                        }
                        .pickerStyle(.menu)
                    }
                }
            }
        }
    }
    
    private func deleteAdvice(_ advice: Snippet) {
        //TODO: if selection is implemented need to deselect it
        modelContext.delete(advice)
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewSampleData.container)
}
