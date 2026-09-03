//
//  TransactionDetailsVM.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 02/09/26.
//

import Foundation

final class TransactionDetailsVM {
    
    private let repository: TransactionRepository
    
    private(set) var transaction: Transaction
    
    init(
        transaction: Transaction,
        repository: TransactionRepository
    ) {
        self.transaction = transaction
        self.repository = repository
    }
    
    func refreshTransaction() {
        if let updated = repository.fetchTransaction(with: transaction.id) {
            transaction = updated
        }
    }
    
    func deleteTransaction() {
        repository.deleteTransaction(with: transaction.id)
    }
}
