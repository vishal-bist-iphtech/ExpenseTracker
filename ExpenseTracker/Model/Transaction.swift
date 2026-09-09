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

enum Category: String, CaseIterable, Equatable {
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

    /// Raw value for Core Data persistence; defaults to "other" if unknown
    init(safeRawValue: String?) {
        if let raw = safeRawValue, let value = Category(rawValue: raw) {
            self = value
        } else {
            self = .other
        }
    }

    var rawValueForStore: String { rawValue }
}

enum TransactionType: String, CaseIterable, Equatable {
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

    init(safeRawValue: String?) {
        if let raw = safeRawValue, let value = TransactionType(rawValue: raw) {
            self = value
        } else {
            self = .expense
        }
    }

    var rawValueForStore: String { rawValue }
}

// MARK: - Core Data Mapping

extension Transaction {
    init(entity: TransactionEntity) {
        self.id = entity.id ?? UUID()
        self.amount = entity.amount
        self.description = entity.descText ?? ""
        self.category = Category(safeRawValue: entity.categoryRaw)
        self.type = TransactionType(safeRawValue: entity.typeRaw)
        self.date = entity.date ?? Date()
    }

    func update(entity: TransactionEntity) {
        entity.id = id
        entity.amount = amount
        entity.descText = description
        entity.categoryRaw = category.rawValueForStore
        entity.typeRaw = type.rawValueForStore
        entity.date = date
    }
}
