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
    
    func updateTransaction(_ transaction: Transaction) {
        
        guard let index = transactions.firstIndex(
            where: {$0.id == transaction.id}
        ) else {return}
        
        transactions[index] = transaction
    }
    
    func fetchTransaction(with id: UUID) -> Transaction? {
        return transactions.first(where: { $0.id == id })
    }

    func deleteTransaction(with id: UUID) {
        transactions.removeAll {$0.id == id}
    }
}
