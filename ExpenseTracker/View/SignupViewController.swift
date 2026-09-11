//
//  SignupViewController.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 11/09/26.
//

import UIKit

final class SignupViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var loginLinkButton: UIButton?

    private let vm = AuthVM(
        repository: AppContainer.shared.userRepository
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields()
    }

    private func configureTextFields() {
        nameTextField?.autocapitalizationType = .words
        nameTextField?.textContentType = .name

        emailTextField?.keyboardType = .emailAddress
        emailTextField?.autocapitalizationType = .none
        emailTextField?.autocorrectionType = .no
        emailTextField?.textContentType = .emailAddress

        passwordTextField?.isSecureTextEntry = true
        passwordTextField?.textContentType = .newPassword
        passwordTextField?.autocapitalizationType = .none

        confirmPasswordTextField?.isSecureTextEntry = true
        confirmPasswordTextField?.textContentType = .newPassword
        confirmPasswordTextField?.autocapitalizationType = .none

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func createAccountButtonTapped(_ sender: UIButton) {
        if let errorMessage = vm.signup(
            fullName: nameTextField?.text,
            email: emailTextField?.text,
            password: passwordTextField?.text,
            confirmPassword: confirmPasswordTextField?.text
        ) {
            showAlert(message: errorMessage)
            return
        }

        SceneDelegate.of(self)?.showMain()
    }

    private func showAlert(title: String = "Invalid Input", message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: "OK", style: .default)
        )
        present(alert, animated: true)
    }
}
