//
//  TransactionListVM.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 09/09/26.
//

import Foundation

final class TransactionListVM {

    private let repository: TransactionRepository

    private(set) var allTransactions: [Transaction] = []
    private(set) var displayedTransactions: [Transaction] = []

    private(set) var currentFilter = Filter(
        type: nil,
        category: nil,
        date: nil,
        sortOptions: .newestFirst
    )

    private var currentSearchText: String?

    var onDataUpdated: (() -> Void)?

    init(repository: TransactionRepository) {
        self.repository = repository
    }


    func loadTransactions() {
        allTransactions = repository.fetchTransactions()
        applyFilter()
    }

    // MARK: - Filtering

    func apply(filter: Filter) {
        currentFilter = filter
        applyFilter()
    }

    func resetFilter() {
        currentFilter = Filter(type: nil, category: nil, date: nil, sortOptions: .newestFirst)
        currentSearchText = nil
        applyFilter()
    }

    func updateSearch(text: String?) {
        let trimmed = text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let t = trimmed, !t.isEmpty {
            currentSearchText = t
        } else {
            currentSearchText = nil
        }
        applyFilter()
    }

    private func applyFilter() {
        var result = allTransactions

        // type filter
        if let type = currentFilter.type {
            result = result.filter { $0.type == type }
        }

        // category filter
        if let category = currentFilter.category {
            result = result.filter { $0.category == category }
        }

        if let selectedDate = currentFilter.date {
            let calendar = Calendar.current
            result = result.filter {
                calendar.isDate($0.date, inSameDayAs: selectedDate)
            }
        }

        switch currentFilter.sortOptions {
        case .newestFirst:
            result.sort { $0.date > $1.date }
        case .oldestFirst:
            result.sort { $0.date < $1.date }
        case .highestAmount:
            result.sort { $0.amount > $1.amount }
        case .lowestAmount:
            result.sort { $0.amount < $1.amount }
        }

        // search filter - applied after sorting so sort order preserved, then filtered by search text
        if let search = currentSearchText?.lowercased(), !search.isEmpty {
            result = result.filter { tx in
                let desc = tx.description.lowercased()
                let cat = tx.category.displayName.lowercased()
                let type = tx.type.displayName.lowercased()
                let amountString = String(format: "%.2f", tx.amount)
                let amountInt = String(format: "%.0f", tx.amount)
                let dateString = tx.date.formatted(date: .abbreviated, time: .omitted).lowercased()
                return desc.contains(search)
                    || cat.lowercased().contains(search)
                    || type.lowercased().contains(search)
                    || amountString.contains(search)
                    || amountInt.contains(search)
                    || dateString.contains(search)
                    || tx.category.rawValue.lowercased().contains(search)
                    || tx.type.rawValue.lowercased().contains(search)
            }
        }

        displayedTransactions = result
        onDataUpdated?()
    }

    // MARK: - CRUD

    func numberOfTransactions() -> Int {
        return displayedTransactions.count
    }

    func transaction(at index: Int) -> Transaction {
        return displayedTransactions[index]
    }

    func deleteTransaction(at index: Int) {
        let transaction = displayedTransactions[index]
        repository.deleteTransaction(with: transaction.id)
        loadTransactions()
    }

    var isEmpty: Bool {
        return displayedTransactions.isEmpty
    }

    var isFilterActive: Bool {
        return currentFilter.type != nil
            || currentFilter.category != nil
            || currentFilter.date != nil
            || currentFilter.sortOptions != .newestFirst
            || (currentSearchText != nil && !(currentSearchText?.isEmpty ?? true))
    }

    var currentSearchTextValue: String? { currentSearchText }


    
    func titleForEmptyState() -> String {
        if isFilterActive && displayedTransactions.isEmpty && !allTransactions.isEmpty {
            return "No Results"
        }
        return "No Transactions"
    }

    func subtitleForEmptyState() -> String {
        if isFilterActive {
            return "No transactions match your filters"
        }
        return "Add your first transaction to get started"
    }
}
