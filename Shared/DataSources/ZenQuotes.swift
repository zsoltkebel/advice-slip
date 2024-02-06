//
//  ZenQuotes.swift
//  AdviceSlip
//
//  Created by Zsolt Kébel on 06/02/2024.
//

import Foundation

struct ZenQuotesResponse: APIResponse {
    var q: String
    var a: String
    
    func getContent() -> String { return q }
    
    func getAuthor() -> String? { return a }
}

class ZenQuotesDataSource: APIDataSource {
    func getName() -> String {
        return "Zen Quotes"
    }
    
    func getURL() -> URL? {
        return URL(string: "https://zenquotes.io/api/random")
    }
    
    func decode(from data: Data) throws -> APIResponse {
        let quotes = try JSONDecoder().decode([ZenQuotesResponse].self, from: data)
        return quotes.first!
    }
    
    
}
