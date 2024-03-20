//
//  DataSource.swift
//  AdviceSlip
//
//  Created by Zsolt Kébel on 05/02/2024.
//

import Foundation

enum DataSource: Int, CaseIterable, Identifiable {
    // Order matters!
    case random, adviceSlip, kanyeRest, quotable, zenQuotes, breakingBadQuotes

    var id: Int { return self.rawValue }
    
    func getName() -> String {
        if self == .random {
            return "Random"
        }
        return getAPIDataSource().getName()
    }
    
    func getAPIDataSource() -> APIDataSource {
        switch self {
        case .random:
            return [AdviceSlipDataSource(), KanyeDataSource(), QuotableDataSource(), ZenQuotesDataSource(), BreakingBadDataSource()].randomElement() as! APIDataSource
        case .adviceSlip:
            return AdviceSlipDataSource()
        case .kanyeRest:
            return KanyeDataSource()
        case .quotable:
            return QuotableDataSource()
        case .zenQuotes:
            return ZenQuotesDataSource()
        case .breakingBadQuotes:
            return BreakingBadDataSource()
        }
    }
}

extension UserDefaults {
    static var shared: UserDefaults? {
        return UserDefaults(suiteName: "group.com.zk.AdviceSlip")
    }
}
