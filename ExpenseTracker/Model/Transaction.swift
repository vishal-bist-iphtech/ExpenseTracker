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

enum Category {
    case food
    case shopping
    case travel
    case bills
    case salary
    case other
}

enum TransactionType {
    case income
    case expense
}
