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
    
    @Parameter(title: "Advice Content")
    var content: String
    
    @Parameter(title: "Advice Author")
    var author: String?
    
    @Parameter(title: "Advice Source")
    var sourceID: Int
    
    init() {
        self.content = "None"
        self.author = "None"
        self.sourceID = 0
    }
    
    init(content: String, author: String? = nil, sourceID: Int) {
        self.content = content
        self.author = author
        self.sourceID = sourceID
    }
    
    func perform() async throws -> some IntentResult {
        let slip = Snippet(content: content, author: author, sourceID: sourceID)
        await WiseBuddy.shared.toggleSave(snippet: slip)
        return .result()
    }
}
