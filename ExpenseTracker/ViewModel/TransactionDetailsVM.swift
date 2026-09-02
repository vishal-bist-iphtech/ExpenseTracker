//
//  TransactionDetailsVM.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 02/09/26.
//

import Foundation

final class TransactionDetailsVM {
    
    private let repository: TransactionRepository
    
    let transaction: Transaction
    
    init(
        transaction: Transaction,
        repository: TransactionRepository
    ) {
        self.transaction = transaction
        self.repository = repository
    }
    
    func deleteTransaction() {
        repository.deleteTransaction(with: transaction.id)
    }
}
