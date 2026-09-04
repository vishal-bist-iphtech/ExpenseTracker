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
    
    func deleteTransaction(at index: Int) {
        
        let transaction = displayedTransactions[index]
        
        repository.deleteTransaction(with: transaction.id)
            
        loadTransactions()
    }
}
