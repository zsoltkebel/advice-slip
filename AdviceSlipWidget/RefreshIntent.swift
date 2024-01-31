//
//  RefreshIntent.swift
//  AdviceSlipWidgetExtension
//
//  Created by Zsolt Kébel on 31/01/2024.
//

import AppIntents
import SwiftData

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct RefreshIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Advice"
    static var description: IntentDescription = "Presents a new advice on the widgets."
   
    func perform() async throws -> some IntentResult {
        let _ = try await WiseBuddy.shared.fetchAdvice()
        return .result()
    }
}
