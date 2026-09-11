//
//  AuthVM.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 12/09/26.
//

import Foundation

final class AuthVM {

    private let repository: UserRepository
    private let sessionKey = "ExpenseTracker.currentUserId"

    init(repository: UserRepository) {
        self.repository = repository
    }

    // MARK: - Session

    /// The logged-in user's id, or nil when logged out.
    var currentUserId: UUID? {
        get {
            guard let stored = UserDefaults.standard.string(forKey: sessionKey) else {
                return nil
            }
            return UUID(uuidString: stored)
        }
        set {
            if let id = newValue {
                UserDefaults.standard.set(id.uuidString, forKey: sessionKey)
            } else {
                UserDefaults.standard.removeObject(forKey: sessionKey)
            }
        }
    }

    /// The logged-in user, or nil when logged out (or the session is stale).
    var currentUser: User? {
        guard let id = currentUserId else { return nil }
        guard let user = repository.fetchUser(with: id) else {
            // Session points to a user that no longer exists — clear it.
            currentUserId = nil
            return nil
        }
        return user
    }

    var isLoggedIn: Bool {
        currentUser != nil
    }

    // MARK: - Signup

    /// Validates + creates the account and logs the user in.
    /// Returns an error message, or nil on success (same pattern as AddTransactionVM).
    func signup(
        fullName: String?,
        email: String?,
        password: String?,
        confirmPassword: String?
    ) -> String? {
        let name = fullName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let normalizedEmail = UserRepository.normalize(email: email ?? "")
        let password = password ?? ""
        let confirm = confirmPassword ?? ""

        guard !name.isEmpty else {
            return "Please enter your full name."
        }
        guard !normalizedEmail.isEmpty else {
            return "Please enter your email address."
        }
        guard Self.isValidEmail(normalizedEmail) else {
            return "Please enter a valid email address."
        }
        guard !password.isEmpty else {
            return "Please enter a password."
        }
        guard password.count >= 6 else {
            return "Password must be at least 6 characters."
        }
        guard !confirm.isEmpty else {
            return "Please confirm your password."
        }
        guard password == confirm else {
            return "Passwords do not match."
        }
        guard !repository.emailExists(normalizedEmail) else {
            return "An account with this email already exists."
        }

        let user = User(
            id: UUID(),
            fullName: name,
            email: normalizedEmail,
            password: password
        )
        repository.createUser(user)
        currentUserId = user.id
        return nil
    }

    // MARK: - Login

    /// Validates credentials and logs the user in.
    /// Returns an error message, or nil on success.
    func login(email: String?, password: String?) -> String? {
        let normalizedEmail = UserRepository.normalize(email: email ?? "")
        let password = password ?? ""

        guard !normalizedEmail.isEmpty else {
            return "Please enter your email address."
        }
        guard Self.isValidEmail(normalizedEmail) else {
            return "Please enter a valid email address."
        }
        guard !password.isEmpty else {
            return "Please enter your password."
        }

        guard let user = repository.fetchUser(byEmail: normalizedEmail),
              user.password == password else {
            return "Invalid email or password."
        }

        currentUserId = user.id
        return nil
    }

    // MARK: - Logout

    func logout() {
        currentUserId = nil
    }

    // MARK: - Helpers

    /// Same rule the auth screens used before Core Data: must contain "@" and ".".
    private static func isValidEmail(_ email: String) -> Bool {
        email.contains("@") && email.contains(".")
    }
}
