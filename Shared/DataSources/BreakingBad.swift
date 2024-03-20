//
//  Waltuh.swift
//  AdviceSlip
//
//  Created by Jack on 20/03/2024.
//

import Foundation

struct BreakingBadResponse: APIResponse {
    var quote: String
    var author: String
    
    func getContent() -> String { return quote }
    
    func getAuthor() -> String? { return author }
}

class BreakingBadDataSource: APIDataSource {
    func getID() -> Int {
        return DataSource.breakingBadQuotes.rawValue
    }
    
    func getName() -> String {
        return "Breaking Bad Quotes"
    }
    
    func getURL() -> URL? {
        return URL(string: "https://api.breakingbadquotes.xyz/v1/quotes")
    }
    
    func decode(from data: Data) throws -> APIResponse {
        let quotes = try JSONDecoder().decode([BreakingBadResponse].self, from: data)
        return quotes.first!
    }
}
