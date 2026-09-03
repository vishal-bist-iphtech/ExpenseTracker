//
//  Transaction.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 01/09/26.
//

import Foundation

struct Transaction {
    
    let id: UUID
    var amount: Double
    var description: String
    var category: Category
    var type: TransactionType
    var date: Date
}

enum Category: Equatable {
    case food
    case shopping
    case travel
    case bills
    case salary
    case other
    
    var displayName: String {
        switch self {
            
        case .food: return "Food"
        case .shopping: return "Shopping"
        case .travel: return "Travel"
        case .bills: return "Bills"
        case .salary: return "Salary"
        case .other: return "Other"
            
        }
    }
    
    var iconName: String {
        
        switch self {
            
        case .food: return "fork.knife"
        case .shopping: return "bag"
        case .travel: return "airplane"
        case .bills: return "doc.text"
        case .salary: return "banknote"
        case .other: return "ellipsis.circle"
            
        }
    }
}

enum TransactionType: Equatable {
    case income
    case expense
    
    var displayName: String {
        switch self {
            
        case .income: return "Income"
        case .expense: return "Expense"
            
        }
    }
    
    var sign: String {
        switch self {
            
        case .income: return "+"
        case .expense: return "-"
        }
    }
}
