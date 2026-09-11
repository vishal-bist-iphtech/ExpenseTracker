//
//  User.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 12/09/26.
//

import Foundation

struct User {

    let id: UUID
    var fullName: String
    var email: String
    var password: String
}

// MARK: - Core Data Mapping

extension User {
    init(entity: UserEntity) {
        self.id = entity.id
        self.fullName = entity.fullName
        self.email = entity.email
        self.password = entity.password
    }

    func update(entity: UserEntity) {
        entity.id = id
        entity.fullName = fullName
        entity.email = email
        entity.password = password
    }
}
