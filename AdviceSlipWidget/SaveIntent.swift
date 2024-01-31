//
//  NextAdviceIntent.swift
//  AdviceSlip
//
//  Created by Zsolt Kébel on 31/01/2024.
//

import AppIntents
import SwiftData

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct SaveIntent: AppIntent {
    static var title: LocalizedStringResource = "NextAdviceIntent"
    static var description: IntentDescription = "SAves an "
    
    @Parameter(title: "Advice ID")
    var adviceID: Int
    
    @Parameter(title: "Advice")
    var adviceText: String
    
    init() {
        self.adviceID = 0
        self.adviceText = "None"
    }
    
    init(adviceID: Int, adviceText: String) {
        self.adviceID = adviceID
        self.adviceText = adviceText
    }
    
    func perform() async throws -> some IntentResult {
//        guard let modelContainer = try? ModelContainer(for: Advice.self) else {
//            return .result()
//        }
//        let descriptor = FetchDescriptor<Advice>(predicate: #Predicate { advice in
//            advice.id == adviceID
//        })
//        let advices = try? await modelContainer.mainContext.fetch(descriptor)
//        
//        if let advice = advices?.first {
//            // Advice was already saved, delete it
//            await modelContainer.mainContext.delete(advice)
//        } else {
//            // Advice needs to be saved
//            let newAdvice = Advice(id: adviceID, advice: adviceText)
//            await modelContainer.mainContext.insert(newAdvice)
//        }
        
        print("Current advice: #\(adviceID), \(adviceText)")
        await Buddy.shared.toggleSave(adviceID: adviceID, adviceText: adviceText)
        return .result()
    }
}
