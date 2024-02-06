//
//  KanyeRest.swift
//  AdviceSlip
//
//  Created by Zsolt Kébel on 05/02/2024.
//

import Foundation

struct KanyeResponse: APIResponse {
    var quote: String

    func getContent() -> String { return quote }
}

class KanyeDataSource: APIDataSource {
    func getName() -> String {
        return "Kanye Rest"
    }
    
    func getURL() -> URL? {
        return URL(string: "https://api.kanye.rest")
    }
    
    func decode(from data: Data) throws -> APIResponse {
        return try JSONDecoder().decode(KanyeResponse.self, from: data)
    }
}
