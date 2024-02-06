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
    var advice: AdviceSlip?
    var frequency: DateComponents
    
    let modelContainer: ModelContainer
    
    let dataSource: APIDataSource
    
    init(frequency: DateComponents) {
        self.frequency = frequency
//        self.dataSource = AdviceSlipDataSource()
        
        // Retrieve saved data source
        let rawValue = UserDefaults.shared?.integer(forKey: "dataSource") ?? 0
        let source = DataSource(rawValue: rawValue) ?? .adviceSlip
        self.dataSource = source.getAPIDataSource()
        
        do {
            modelContainer = try ModelContainer(for: Advice.self)
        } catch {
            fatalError("Failed to create the model container: \(error)")
        }
    }
    
    func getAdviceToShow() async -> AdviceSlip? {
        if let generatedAt = generatedAt,
           let advice = advice,
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
    func fetchAdvice() async throws -> AdviceSlip {
        // Retrieve saved data source
        let rawValue = UserDefaults.shared?.integer(forKey: "dataSource") ?? 0
        let source = DataSource(rawValue: rawValue) ?? .adviceSlip
        let dataSource = source.getAPIDataSource()
        print("Retrieving data from: \(String(describing: dataSource.getURL()))")
        
        let response = try await dataSource.fetch()
        
        generatedAt = Date()
        advice = AdviceSlip(id: 0, advice: response.getContent())
        
        return advice!
    }
    
    @MainActor
    func toggleSave(adviceID: Int, adviceText: String) {
        guard let modelContainer = try? ModelContainer(for: Advice.self) else {
            return
        }
        let descriptor = FetchDescriptor<Advice>(predicate: #Predicate { advice in
            advice.id == adviceID
        })
        let advices = try? modelContainer.mainContext.fetch(descriptor)
        
        if let advice = advices?.first {
            // Advice was already saved, delete it
            modelContainer.mainContext.delete(advice)
        } else {
            // Advice needs to be saved
            let newAdvice = Advice(id: adviceID, advice: adviceText)
            modelContainer.mainContext.insert(newAdvice)
        }
    }
}
