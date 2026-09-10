//
//  DashboardVM.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 01/09/26.
//

import Foundation

final class DashboardVM {
    
    private let repository: TransactionRepository
    
    private(set) var allTransactions: [Transaction] = []
    private(set) var displayedTransactions: [Transaction] = []
    
    private(set) var currentFilter = Filter(
        type: nil,
        category: nil,
        date: nil,
        sortOptions: .newestFirst
    )

    
    init(repository: TransactionRepository) {
        self.repository = repository
    }
    
    func loadTransactions() {
        allTransactions = repository.fetchTransactions()
        
        applyFilter()
    }
    
    func apply(filter: Filter) {
        
        currentFilter = filter
        
        applyFilter()
    }
    
    private func applyFilter() {
        
        var result = allTransactions
        
        // type filter
        if let type = currentFilter.type {
            result = result.filter {
                $0.type == type
            }
        }
        
        // category filter
        if let category = currentFilter.category {
            result = result.filter {
                $0.category == category
            }
        }
        
        // date filter
        if let selectedDate = currentFilter.date {
            
            let calendar = Calendar.current
            
            result = result.filter {
                calendar.isDate(
                    $0.date,
                    inSameDayAs: selectedDate
                )
            }
        }
        
        switch currentFilter.sortOptions {

        case .newestFirst:

            result.sort {
                $0.date > $1.date
            }

        case .oldestFirst:

            result.sort {
                $0.date < $1.date
            }

        case .highestAmount:

            result.sort {
                $0.amount > $1.amount
            }

        case .lowestAmount:

            result.sort {
                $0.amount < $1.amount
            }
        }
        
        displayedTransactions = result
    }
    
    /// Dashboard shows only the 5 most recent (filtered) transactions
    var recentTransactions: [Transaction] {
        Array(displayedTransactions.prefix(5))
    }
    
    func deleteTransaction(at index: Int) {
        guard displayedTransactions.indices.contains(index) else { return }
        let transaction = displayedTransactions[index]
        
        repository.deleteTransaction(with: transaction.id)
            
        loadTransactions()
    }
    
    func deleteRecentTransaction(at index: Int) {
        guard recentTransactions.indices.contains(index) else { return }
        let transaction = recentTransactions[index]
        repository.deleteTransaction(with: transaction.id)
        loadTransactions()
    }
    
    // MARK: - Totals (derived from allTransactions for global balance)
    
    /// Sum of all income transaction amounts; 0 if none.
    var totalIncome: Double {
        allTransactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }
    
    /// Sum of all expense transaction amounts; 0 if none.
    var totalExpense: Double {
        allTransactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }
    
    /// Net balance = income - expense, clamped to >=0 per spec ("positive otherwise 0").
    var totalBalance: Double {
        max(0, totalIncome - totalExpense)
    }
    
    // Optional: filtered totals if you want balances to reflect current filter
    var filteredIncome: Double {
        displayedTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    var filteredExpense: Double {
        displayedTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    var filteredBalance: Double {
        max(0, filteredIncome - filteredExpense)
    }
}
