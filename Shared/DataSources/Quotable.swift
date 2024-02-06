//
//  Quotable.swift
//  AdviceSlip
//
//  Created by Zsolt Kébel on 05/02/2024.
//

import Foundation

struct QuotableResponse: APIResponse {
    var content: String
    var author: String
    
    func getContent() -> String { return content }
    
    func getAuthor() -> String? { return author }
}

class QuotableDataSource: APIDataSource {
    func getID() -> Int {
        return DataSource.quotable.rawValue
    }
    
    func getName() -> String {
        return "Quotable"
    }
    
    func getURL() -> URL? {
        return URL(string: "https://api.quotable.io/quotes/random")
    }
    
    func decode(from data: Data) throws -> APIResponse {
        let quotes = try JSONDecoder().decode([QuotableResponse].self, from: data)
        return quotes.first!
    }
    
    
}
