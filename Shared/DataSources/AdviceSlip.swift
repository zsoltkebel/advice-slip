//
//  AdviceSlip.swift
//  AdviceSlip
//
//  Created by Zsolt Kébel on 05/02/2024.
//

import Foundation

/// http response object
struct AdviceSlipResponse: APIResponse {
    let slip: AdviceSlip
    
    func getContent() -> String { return slip.advice }
}
/// http response object
struct AdviceSlip: Codable, Hashable {
    let id: Int
    let advice: String
}

class AdviceSlipDataSource: APIDataSource {
    func getID() -> Int {
        return DataSource.adviceSlip.rawValue
    }
    
    func getName() -> String {
        "Advice Slip"
    }
    
    func getURL() -> URL? {
        return URL(string: "https://api.adviceslip.com/advice")
    }
    
    func decode(from data: Data) throws -> APIResponse {
        return try JSONDecoder().decode(AdviceSlipResponse.self, from: data)
    }
}
