//
//  UserProfileViewController.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 11/09/26.
//

import UIKit

final class UserProfileViewController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var balanceBadgeView: UIView!
    @IBOutlet weak var balanceLabel: UILabel!

    @IBOutlet weak var optionsCardView: UIView!
    @IBOutlet weak var bankIconBackgroundView: UIView!
    @IBOutlet weak var budgetIconBackgroundView: UIView!
    @IBOutlet weak var currencyIconBackgroundView: UIView!
    @IBOutlet weak var languageIconBackgroundView: UIView!

    @IBOutlet weak var logoutButton: UIButton!

    private let authVM = AuthVM(
        repository: AppContainer.shared.userRepository
    )
    private let dashboardVM = DashboardVM(
        repository: AppContainer.shared.transactionRepository
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Profile"
        configureCardStyles()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateProfileLabels()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Circular avatar + icon chips (same pattern as Dashboard avatarButton).
        avatarImageView?.layer.cornerRadius = (avatarImageView?.bounds.height ?? 84) / 2
        avatarImageView?.layer.masksToBounds = true

        for chip in [bankIconBackgroundView, budgetIconBackgroundView,
                     currencyIconBackgroundView, languageIconBackgroundView] {
            guard let chip = chip else { continue }
            chip.layer.cornerRadius = chip.bounds.height / 2
            chip.layer.masksToBounds = true
        }

        headerView?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }

    private func configureCardStyles() {
        // Header: navy card with only bottom corners round (same as Dashboard).
        headerView?.layer.cornerRadius = 28
        headerView?.layer.masksToBounds = true
        headerView?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

        // Balance pill on navy header (same as Dashboard growth badge).
        balanceBadgeView?.layer.cornerRadius = 16
        balanceBadgeView?.layer.masksToBounds = true

        // White options card (same radius as transaction cells / table).
        optionsCardView?.layer.cornerRadius = 16
        optionsCardView?.layer.masksToBounds = true

        avatarImageView?.layer.masksToBounds = true
        avatarImageView?.tintColor = .white
        avatarImageView?.backgroundColor = UIColor.white.withAlphaComponent(0.18)

        // Logout is an outlined destructive button in storyboard (like Details Delete);
        // corner comes from the capsule configuration, nothing extra needed here.
    }

    private func updateProfileLabels() {
        dashboardVM.loadTransactions()

        if let user = authVM.currentUser {
            nameLabel?.text = user.fullName
            emailLabel?.text = user.email
        } else {
            nameLabel?.text = "User"
            emailLabel?.text = "user@example.com"
        }
        balanceLabel?.text = "Total Balance  •  \(format(dashboardVM.totalBalance))"
    }

    private func format(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","
        formatter.locale = Locale(identifier: "en_IN")
        return formatter.string(from: NSNumber(value: amount)) ?? "₹0"
    }

    // MARK: - Option rows (placeholders until the features exist)

    @IBAction func bankAccountTapped(_ sender: UIButton) {
        showComingSoon(message: "Add Bank Account is coming soon.")
    }

    @IBAction func budgetTapped(_ sender: UIButton) {
        showComingSoon(message: "Set Monthly Budget is coming soon.")
    }

    @IBAction func currencyTapped(_ sender: UIButton) {
        showComingSoon(message: "Preferred Currency is coming soon.")
    }

    @IBAction func languageTapped(_ sender: UIButton) {
        showComingSoon(message: "Language selection is coming soon.")
    }

    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Logout?",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        present(alert, animated: true)
    }

    private func performLogout() {
        authVM.logout()
        SceneDelegate.of(self)?.showLanding()
    }

    private func showComingSoon(message: String) {
        let alert = UIAlertController(
            title: "Coming Soon",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
