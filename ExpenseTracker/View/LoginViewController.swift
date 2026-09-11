//
//  LoginViewController.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 11/09/26.
//

import UIKit

final class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotButton: UIButton?
    @IBOutlet weak var signupLinkButton: UIButton?

    private let vm = AuthVM(
        repository: AppContainer.shared.userRepository
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields()
    }

    private func configureTextFields() {
        emailTextField?.keyboardType = .emailAddress
        emailTextField?.autocapitalizationType = .none
        emailTextField?.autocorrectionType = .no
        emailTextField?.textContentType = .emailAddress

        passwordTextField?.isSecureTextEntry = true
        passwordTextField?.textContentType = .password
        passwordTextField?.autocapitalizationType = .none

        // Dismiss keyboard on tap outside (same idea as keeping UI in storyboard,
        // little behaviour programmatically)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        if let errorMessage = vm.login(
            email: emailTextField?.text,
            password: passwordTextField?.text
        ) {
            showAlert(message: errorMessage)
            return
        }

        SceneDelegate.of(self)?.showMain()
    }

    @IBAction func forgotButtonTapped(_ sender: UIButton) {
        showAlert(
            title: "Reset Password",
            message: "Password reset is coming soon."
        )
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
