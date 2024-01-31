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
    
    init(frequency: DateComponents) {
        self.frequency = frequency
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
        guard let url = URL(string: "https://api.adviceslip.com/advice") else { fatalError("Missing URL") }

        // Use the async variant of URLSession to fetch data
        // Code might suspend here
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Parse the JSON data
        let adviceSlipResult = try JSONDecoder().decode(AdviceSlipResponse.self, from: data)
        
        generatedAt = Date()
        advice = adviceSlipResult.slip
        return adviceSlipResult.slip
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
