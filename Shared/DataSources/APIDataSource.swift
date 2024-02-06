//
//  APIDataSource.swift
//  AdviceSlip
//
//  Created by Zsolt Kébel on 05/02/2024.
//

import Foundation

protocol APIResponse: Codable {
    func getContent() -> String
}

extension APIResponse {
    func getAuthor() -> String? {
        return nil
    }
}

protocol APIDataSource {
    func getName() -> String
    func getURL() -> URL?
    func decode(from data: Data) throws -> APIResponse
}

extension APIDataSource {
    func fetch() async throws -> APIResponse {
        guard let url = getURL() else { fatalError("Missing URL") }

        // Use the async variant of URLSession to fetch data
        // Code might suspend here
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Parse the JSON data
        let apiQuoteResponse = try decode(from: data)
        
        return apiQuoteResponse
    }
}
