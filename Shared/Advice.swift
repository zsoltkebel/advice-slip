//
//  Advice.swift
//  AdviceSlip
//
//  Created by Zsolt Kébel on 31/01/2024.
//

import Foundation
import SwiftUI
import SwiftData
import AppIntents

@Model final class Advice {
    var id: Int
    var advice: String
    // var sourceID: Int // corresponding to DataSource enum's rawValue
    
    init(id: Int, advice: String) {
        self.id = id
        self.advice = advice
    }
    
//    init(from: APIResponse, sourceID: Int) {
//        self.advice = from.getContent()
//        self.author = from.getAuthor()
//        self.sourceID = sourceID
//    }
}

extension Advice {
    @Transient
    var color: Color {
        let seed = advice.hashValue
        var generator: RandomNumberGenerator = SeededRandomGenerator(seed: seed)
        return .random(using: &generator)
    }
    
    @Transient
    var displayAdvice: String {
        advice.isEmpty ? "Can't find advice" : advice
    }
    
    static var preview: Advice {
        Advice(id: 0, advice: "If you don't want something to be public, don't post it on the Internet.")
    }
}

private struct SeededRandomGenerator: RandomNumberGenerator {
    init(seed: Int) {
        srand48(seed)
    }
    
    func next() -> UInt64 {
        UInt64(drand48() * Double(UInt64.max))
    }
}

private extension Color {
    static var random: Color {
        var generator: RandomNumberGenerator = SystemRandomNumberGenerator()
        return random(using: &generator)
    }
    
    static func random(using generator: inout RandomNumberGenerator) -> Color {
        let red = Double.random(in: 0..<1, using: &generator)
        let green = Double.random(in: 0..<1, using: &generator)
        let blue = Double.random(in: 0..<1, using: &generator)
        return Color(red: red, green: green, blue: blue)
    }
}
