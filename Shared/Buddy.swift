//
//  Buddy.swift
//  AdviceSlip
//
//  Created by Zsolt Kébel on 31/01/2024.
//

import Foundation
import SwiftData

// The Advice Manager
class Buddy {
    static let shared = Buddy(frequency: DateComponents(minute: 15))
    
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
        guard let fetchDate = generatedAt, let adviceSlip = advice else {
            print("1")
            let r = try? await fetchAdvice()
            return r
        }
        
        guard let refreshDate = Calendar.current.date(byAdding: frequency, to: fetchDate) else {
            print("2")
            let r = try? await fetchAdvice()
            return r
        }
        
        if refreshDate.compare(Date()) == .orderedDescending {
            print("yes im aright")
            return adviceSlip
        }
        
        print("3")
        let r = try? await fetchAdvice()
        return r
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
    
    @MainActor func loadAdvice(adviceID: Int, completion: @escaping (Advice?) -> ()) {
        // check if it's saved
        var fetchDescriptor = FetchDescriptor(sortBy: [SortDescriptor(\Advice.id, order: .forward)])
        let now = Date.now
        fetchDescriptor.predicate = #Predicate { $0.id == adviceID }
        if let savedAdvice = try? modelContainer.mainContext.fetch(fetchDescriptor) {
            completion(savedAdvice.first)
        }
        
        completion(nil)
    }
    
    func save() {
        if let advice = advice {
            let newAdvice = Advice(id: advice.id, advice: advice.advice)
            let modelContext = ModelContext(modelContainer)
            modelContext.insert(newAdvice)
            
        }
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
    
//    func isSaved() async -> Bool {
//        guard let adviceSlip = advice else {
//            return false
//        }
//        
//        let res = try? dataManager.getAdvice(id: adviceSlip.id)
//        return res != nil
//    }
//    
//    func num() async -> Int {
//        return try! dataManager.getAdviceNum()
//    }
//    
}

