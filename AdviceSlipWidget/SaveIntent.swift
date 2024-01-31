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
    static var title: LocalizedStringResource = "Toggle Advice Bookmark"
    static var description: IntentDescription = "Saves or deletes advice."
    
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
        print("Current advice: #\(adviceID), \(adviceText)")
        await WiseBuddy.shared.toggleSave(adviceID: adviceID, adviceText: adviceText)
        return .result()
    }
}
