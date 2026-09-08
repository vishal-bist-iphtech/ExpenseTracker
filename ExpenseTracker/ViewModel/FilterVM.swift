//
//  FilterVM.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 07/09/26.
//

import Foundation

final class FilterVM {

    private(set) var filter: Filter

    init(
        filter: Filter
    ) {
        self.filter = filter
    }

    func makeFilter(
        type: TransactionType?,
        category: Category?,
        date: Date?,
        sortOption: SortOption
    ) -> Filter {

        Filter(
            type: type,
            category: category,
            date: date,
            sortOptions: sortOption
        )
    }
}
