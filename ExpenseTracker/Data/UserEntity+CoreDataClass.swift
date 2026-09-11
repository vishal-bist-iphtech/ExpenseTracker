//
//  UserEntity+CoreDataClass.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 12/09/26.
//

import Foundation
import CoreData

@objc(UserEntity)
public class UserEntity: NSManagedObject {}

extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    // NOTE: attributes are non-optional in the model, so these are
    // non-optional here. Always create users via UserRepository so
    // every field is set before saving.
    @NSManaged public var email: String
    @NSManaged public var fullName: String
    @NSManaged public var id: UUID
    @NSManaged public var password: String
}

extension UserEntity: Identifiable {}
