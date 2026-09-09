//
//  AppContainer.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 01/09/26.
//

import Foundation
import CoreData

final class AppContainer {
    
    static let shared = AppContainer()
    
    let persistenceController: PersistenceController
    let transactionRepository: TransactionRepository
    
    private init(persistence: PersistenceController = .shared) {
        self.persistenceController = persistence
        self.transactionRepository = TransactionRepository(persistence: persistence)
    }

    /// For tests / previews with in-memory store
    static func makeInMemory() -> AppContainer {
        let persistence = PersistenceController(inMemory: true)
        return AppContainer(persistence: persistence)
    }

    func saveContext() {
        persistenceController.save()
    }
}
