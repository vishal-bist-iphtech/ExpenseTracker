//
//  Filter.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 04/09/26.
//

import Foundation

struct Filter {
    
    var type: TransactionType?
    var category: Category?
    var date: Date?
    var sortOptions: SortOption
}

enum SortOption {
    case newestFirst
    case oldestFirst
    case highestAmount
    case lowestAmount
    
    var displayName: String {
        switch self {
        case .newestFirst: return "Newest First"
        case .oldestFirst: return "Oldest First"
        case .highestAmount: return "Highest Amount"
        case .lowestAmount: return "Lowest Amount"
        }
    }
}
