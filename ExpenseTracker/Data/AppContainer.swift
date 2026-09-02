//
//  AppContainer.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 01/09/26.
//

import Foundation

final class AppContainer {
    
    static let shared = AppContainer()
    
    let transactionRepository = TransactionRepository()
    
    private init() {}
}
