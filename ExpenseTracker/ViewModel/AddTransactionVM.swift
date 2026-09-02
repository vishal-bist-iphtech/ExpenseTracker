//
//  AddTransactionVM.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 01/09/26.
//

import Foundation

final class AddTransactionVM {
    
    private let repository: TransactionRepository
    
    init(repository: TransactionRepository) {
        self.repository = repository
    }
    
    
    func validate(
        amountText: String?,
        descriptionText: String?
    ) -> String? {
        
        guard let amountText = amountText,
              !amountText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "Amount is required!"
        }
        
        guard Double(amountText) != nil else {
            return "Amount must be a valid number!"
        }
        
        guard let descriptionText = descriptionText,
              !descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "Description is required!"
        }
        
        return nil
    }
    
    func saveTransaction(
        amount: Double,
        description: String,
        category: Category,
        type: TransactionType,
        date: Date
    ) {
        let transaction = Transaction(
            id: UUID(),
            amount: amount,
            description: description,
            category: category,
            type: type,
            date: date
        )
        
        repository.addTransaction(transaction)
    }
}
