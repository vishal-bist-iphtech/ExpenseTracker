//
//  DashboardVM.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 01/09/26.
//

import Foundation

final class DashboardVM {
    
    private let repository: TransactionRepository
    
    private(set) var transactions: [Transaction] = []
    
    init(repository: TransactionRepository) {
        self.repository = repository
    }
    
    func loadTransactions() {
        transactions = repository.fetchTransactions()
    }
}
