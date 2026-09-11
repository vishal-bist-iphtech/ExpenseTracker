//
//  UserRepository.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 12/09/26.
//

import Foundation
import CoreData

final class UserRepository {

    private let persistence: PersistenceController
    private var viewContext: NSManagedObjectContext { persistence.viewContext }

    init(persistence: PersistenceController = .shared) {
        self.persistence = persistence
    }

    // MARK: - Fetch

    func fetchUser(byEmail email: String) -> User? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "email ==[c] %@",
            UserRepository.normalize(email: email)
        )
        request.fetchLimit = 1
        do {
            if let entity = try viewContext.fetch(request).first {
                return User(entity: entity)
            }
        } catch {
            print("CoreData fetchUser by email error: \(error)")
        }
        return nil
    }

    func fetchUser(with id: UUID) -> User? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        do {
            if let entity = try viewContext.fetch(request).first {
                return User(entity: entity)
            }
        } catch {
            print("CoreData fetchUser by id error: \(error)")
        }
        return nil
    }

    func emailExists(_ email: String) -> Bool {
        fetchUser(byEmail: email) != nil
    }

    // MARK: - Create

    /// Persists a new user. All fields are required (non-optional in the model),
    /// so validate via AuthVM before calling.
    func createUser(_ user: User) {
        let entity = UserEntity(context: viewContext)
        user.update(entity: entity)
        persistence.save()
    }

    // MARK: - Batch Delete (for testing / reset)

    func deleteAllUsers() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserEntity.fetchRequest()
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
            print("CoreData deleteAllUsers error: \(error)")
        }
    }

    // MARK: - Count helper

    var count: Int {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        do {
            return try viewContext.count(for: request)
        } catch {
            return 0
        }
    }

    // MARK: - Helpers

    /// Trim + lowercase so `Test@Mail.com` and `test@mail.com` match.
    static func normalize(email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
