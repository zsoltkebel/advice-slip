//
//  Buddy.swift
//  AdviceSlip
//
//  Created by Zsolt Kébel on 31/01/2024.
//

import Foundation
import SwiftData

// The Advice Manager
class WiseBuddy {
    static let shared = WiseBuddy(frequency: DateComponents(minute: 15))
    
    var generatedAt: Date?
    var advice: Snippet?
    var source: DataSource? // which API provided the snippet
    var frequency: DateComponents
    
    let modelContainer: ModelContainer
        
    init(frequency: DateComponents) {
        self.frequency = frequency
//        self.dataSource = AdviceSlipDataSource()
        
        do {
            modelContainer = try ModelContainer(for: Snippet.self)
        } catch {
            fatalError("Failed to create the model container: \(error)")
        }
    }
    
    func getAdviceToShow() async -> Snippet? {
        if let generatedAt = generatedAt,
           let advice = advice,
           let _ = source,
           let refreshDate = Calendar.current.date(byAdding: frequency, to: generatedAt)
        {
            if refreshDate.compare(Date()) == .orderedDescending {
                // Refresh time has not been passed, do not fetch new advice
                return advice
            }
        }
        
        if let newAdvice = try? await fetchAdvice() {
            return newAdvice
        }
        
        return advice
    }
    
    /// Fetch advice slip
    func fetchAdvice() async throws -> Snippet {
        // Retrieve saved data source
        let rawValue = UserDefaults.shared?.integer(forKey: "dataSource") ?? 0
        source = DataSource(rawValue: rawValue) ?? .adviceSlip
        let dataSource = source!.getAPIDataSource()
        print("Retrieving data from: \(String(describing: dataSource.getURL()))")
        
        let response = try await dataSource.fetch()
        
        generatedAt = Date()
        advice = Snippet(from: response, sourceID: dataSource.getID())
        
        return advice!
    }
    
    @MainActor
    func toggleSave(snippet: Snippet) {
        guard let modelContainer = try? ModelContainer(for: Snippet.self) else {
            return
        }
        let targetContent = snippet.content
        let descriptor = FetchDescriptor<Snippet>(predicate: #Predicate { advice in
            advice.content == targetContent //TODO: compare all attributes in future?
        })
        let advices = try? modelContainer.mainContext.fetch(descriptor)
        
        if let advice = advices?.first {
            print("first")

            // Advice was already saved, delete it
            modelContainer.mainContext.delete(advice)
        } else {
            print("here")
            // Advice needs to be saved
            let newSnippet = Snippet(content: snippet.content, author: snippet.author, sourceID: snippet.sourceID)
            modelContainer.mainContext.insert(newSnippet)
        }
    }
}
