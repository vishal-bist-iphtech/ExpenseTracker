//
//  TransactionEntity+CoreDataClass.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 09/09/26.
//

import Foundation
import CoreData

@objc(TransactionEntity)
public class TransactionEntity: NSManagedObject {}

extension TransactionEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TransactionEntity> {
        return NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
    }

    @NSManaged public var amount: Double
    @NSManaged public var categoryRaw: String?
    @NSManaged public var date: Date?
    @NSManaged public var descText: String?
    @NSManaged public var id: UUID?
    @NSManaged public var typeRaw: String?
}

extension TransactionEntity: Identifiable {}
