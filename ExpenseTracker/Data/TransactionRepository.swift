//
//  TransactionRepository.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 01/09/26.
//

import Foundation

final class TransactionRepository {
    
    private var transactions: [Transaction] = []
    
    func fetchTransactions() -> [Transaction] {
        return transactions
    }
    
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
    }
    
    func deleteTransaction(with id: UUID) {
        transactions.removeAll {$0.id == id}
    }
}
