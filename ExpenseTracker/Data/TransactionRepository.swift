//
//  TransactionRepository.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 01/09/26.
//

import Foundation
import CoreData

final class TransactionRepository {
    
    private let persistence: PersistenceController
    private var viewContext: NSManagedObjectContext { persistence.viewContext }
    
    init(persistence: PersistenceController = .shared) {
        self.persistence = persistence
    }
    
    // MARK: - Fetch
    
    func fetchTransactions() -> [Transaction] {
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            let entities = try viewContext.fetch(request)
            return entities.map { Transaction(entity: $0) }
        } catch {
            print("CoreData fetchTransactions error: \(error)")
            return []
        }
    }
    
    /// Fetch with optional predicate/sort for internal use
    func fetchTransactions(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) -> [Transaction] {
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        do {
            let entities = try viewContext.fetch(request)
            return entities.map { Transaction(entity: $0) }
        } catch {
            print("CoreData fetch error: \(error)")
            return []
        }
    }
    
    func fetchTransaction(with id: UUID) -> Transaction? {
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        do {
            if let entity = try viewContext.fetch(request).first {
                return Transaction(entity: entity)
            }
        } catch {
            print("CoreData fetchTransaction error: \(error)")
        }
        return nil
    }
    
    // MARK: - Add
    
    func addTransaction(_ transaction: Transaction) {
        let entity = TransactionEntity(context: viewContext)
        entity.id = transaction.id
        entity.amount = transaction.amount
        entity.descText = transaction.description
        entity.categoryRaw = transaction.category.rawValueForStore
        entity.typeRaw = transaction.type.rawValueForStore
        entity.date = transaction.date
        persistence.save()
    }
    
    // MARK: - Update
    
    func updateTransaction(_ transaction: Transaction) {
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", transaction.id as CVarArg)
        request.fetchLimit = 1
        do {
            if let entity = try viewContext.fetch(request).first {
                entity.amount = transaction.amount
                entity.descText = transaction.description
                entity.categoryRaw = transaction.category.rawValueForStore
                entity.typeRaw = transaction.type.rawValueForStore
                entity.date = transaction.date
                persistence.save()
            } else {
                // If not found, create it (upsert)
                addTransaction(transaction)
            }
        } catch {
            print("CoreData updateTransaction fetch error: \(error)")
        }
    }
    
    // MARK: - Delete
    
    func deleteTransaction(with id: UUID) {
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        do {
            if let entity = try viewContext.fetch(request).first {
                viewContext.delete(entity)
                persistence.save()
            }
        } catch {
            print("CoreData deleteTransaction fetch error: \(error)")
        }
    }

    // MARK: - Batch Delete (for testing / reset)

    func deleteAllTransactions() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TransactionEntity.fetchRequest()
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDelete.resultType = .resultTypeObjectIDs
        do {
            let result = try viewContext.execute(batchDelete) as? NSBatchDeleteResult
            if let objectIDs = result?.result as? [NSManagedObjectID] {
                NSManagedObjectContext.mergeChanges(
                    fromRemoteContextSave: [NSDeletedObjectsKey: objectIDs],
                    into: [viewContext]
                )
            }
            persistence.save()
        } catch {
            print("CoreData deleteAll error: \(error)")
        }
    }

    // MARK: - Count helper

    var count: Int {
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        do {
            return try viewContext.count(for: request)
        } catch {
            return 0
        }
    }
}
