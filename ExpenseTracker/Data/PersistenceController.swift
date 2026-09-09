//
//  PersistenceController.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 09/09/26.
//

import CoreData

final class PersistenceController {

    static let shared = PersistenceController()

    let container: NSPersistentContainer
    var viewContext: NSManagedObjectContext { container.viewContext }

    // For SwiftUI previews / unit tests
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext

        // Optional: create sample data for preview
        for i in 0..<3 {
            let entity = TransactionEntity(context: viewContext)
            entity.id = UUID()
            entity.amount = Double((i + 1) * 100)
            entity.descText = "Sample \(i + 1)"
            entity.categoryRaw = Category.food.rawValue
            entity.typeRaw = (i % 2 == 0) ? TransactionType.expense.rawValue : TransactionType.income.rawValue
            entity.date = Date()
        }
        do {
            try viewContext.save()
        } catch {
            fatalError("PersistenceController preview save failed: \(error)")
        }
        return controller
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ExpenseTracker")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        // Enable lightweight migration
        container.persistentStoreDescriptions.forEach { desc in
            desc.shouldMigrateStoreAutomatically = true
            desc.shouldInferMappingModelAutomatically = true
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved CoreData error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func save() {
        let context = viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            assertionFailure("CoreData save error \(nserror), \(nserror.userInfo)")
            // In production you might log to analytics
        }
    }

    /// Saves given context if it has changes
    func save(context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            assertionFailure("CoreData save error \(nserror), \(nserror.userInfo)")
        }
    }

    /// Use background context for heavy operations
    func newBackgroundContext() -> NSManagedObjectContext {
        let ctx = container.newBackgroundContext()
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return ctx
    }
}
