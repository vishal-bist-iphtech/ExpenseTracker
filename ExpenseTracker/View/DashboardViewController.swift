//
//  DashboardViewController.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 01/09/26.
//

import UIKit

class DashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var balanceTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var totalBalanceStackView: UIStackView!
    
    
    @IBOutlet weak var totalBalanceLabel: UILabel!

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var visaCardView: UIView!
    @IBOutlet weak var depositButton: UIButton!
    @IBOutlet weak var withdrawButton: UIButton!
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var growthBadgeView: UIView!
    @IBOutlet weak var depositeStack: UIStackView!
    @IBOutlet weak var filterButton: UIButton!
    
    
    private let vm = DashboardVM(
        repository: AppContainer.shared.transactionRepository
    )
    
    
    private let refreshControl = UIRefreshControl()

    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyStateView.isHidden = true
        
        refreshControl.addTarget(
            self,
            action: #selector(refreshTransactions),
            for: .valueChanged
        )
        tableView.refreshControl = refreshControl
        tableView.dataSource = self
        tableView.delegate = self
        
        configureCardStyles()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       
        // hide the nav bar
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        vm.loadTransactions()
        tableView.reloadData()
        updateEmptyState()
        updateBalanceLabels()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        avatarButton?.layer.cornerRadius = (avatarButton?.bounds.height ?? 40) / 2
        avatarButton?.layer.masksToBounds = true
        notificationButton?.layer.cornerRadius = (notificationButton?.bounds.height ?? 36) / 2
        notificationButton?.layer.masksToBounds = true

    
        headerView?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    
    private func configureCardStyles() {

        headerView?.layer.cornerRadius = 28
        headerView?.layer.masksToBounds = true
        // only bottom corners should be round
        headerView?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]


        visaCardView?.layer.cornerRadius = 16
        visaCardView?.layer.masksToBounds = true
        visaCardView?.layer.borderWidth = 1
        visaCardView?.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor

        growthBadgeView?.layer.cornerRadius = 14
        growthBadgeView?.layer.masksToBounds = true


        depositButton.layer.cornerRadius = 12
        depositButton.layer.masksToBounds = true
        depositButton.layer.borderWidth = 1
        depositButton.layer.borderColor = UIColor.lightGray.cgColor
        
        
        filterButton.layer.cornerRadius = 40
        filterButton.layer.masksToBounds = true
        filterButton.layer.borderWidth = 1
        filterButton.layer.borderColor = UIColor.lightGray.cgColor
        
        withdrawButton.layer.cornerRadius = 12
        withdrawButton.layer.masksToBounds = true
        withdrawButton.layer.borderWidth = 1
        withdrawButton.layer.borderColor = UIColor.lightGray.cgColor

        emptyStateView?.layer.cornerRadius = 12
        emptyStateView?.layer.masksToBounds = true

        tableView.layer.cornerRadius = 12
        tableView.layer.masksToBounds = true
        tableView.backgroundColor = .clear

        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false


        avatarButton?.layer.masksToBounds = true
        notificationButton?.layer.masksToBounds = true
        
        depositButton?.layer.masksToBounds = true
        withdrawButton?.layer.masksToBounds = true
    }
    
    @objc private func refreshTransactions() {
        
        vm.loadTransactions()
        tableView.reloadData()
        updateEmptyState()
        updateBalanceLabels()
        
        refreshControl.endRefreshing()
    }
    
    private func updateBalanceLabels() {
        

        let income = vm.totalIncome
        let expense = vm.totalExpense
        let balance = vm.totalBalance
        

        func format(_ amount: Double) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencySymbol = "₹"
            formatter.maximumFractionDigits = 0
            formatter.groupingSeparator = ","
            formatter.locale = Locale(identifier: "en_IN")
            return formatter.string(from: NSNumber(value: amount)) ?? "₹0"
        }
        
        totalBalanceLabel.text = format(balance)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showFilters" {
            guard let destination = segue.destination as? FilterViewController else { return }
            destination.viewModel = FilterVM(filter: vm.currentFilter)
            destination.delegate = self
            return
        }
        
        if segue.identifier == "showTransactionDetails" {
            guard let destination = segue.destination as? TransactionDetailsViewController else { return }
            
            if let transaction = sender as? Transaction {
                destination.transaction = transaction
                return
            }
            
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                destination.transaction = vm.displayedTransactions[indexPath.row]
                return
            }
            
            if let indexPath = tableView.indexPathForSelectedRow {
                destination.transaction = vm.displayedTransactions[indexPath.row]
                return
            }
        }
    }
    
    
    private func updateEmptyState() {
        
        let isEmpty = vm.displayedTransactions.isEmpty
        
        tableView.isHidden = isEmpty
        emptyStateView.isHidden = !isEmpty
    }
    
    // no. rows?
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.displayedTransactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "TransactionCell",
            for: indexPath
        ) as? TransactionTableViewCell else {
            return UITableViewCell()
        }
        
        let transaction = vm.displayedTransactions[indexPath.row]
        
        cell.configure(with: transaction)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let transaction = vm.displayedTransactions[indexPath.row]
        
        performSegue(withIdentifier: "showTransactionDetails", sender: transaction)
    }
    

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard editingStyle == .delete else {return}
        
        let alert = UIAlertController(
            title: "Delete Transaction?",
            message: "Are you sure you want to delete this transaction?",
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Delete",
                style: .destructive
            ) { [weak self] _ in
                

                self?.vm.deleteTransaction(at: indexPath.row)
                

                self?.updateBalanceLabels()
                self?.updateEmptyState()

                self?.tableView.reloadData()
                
                print("Transaction Deleted")

            }
        )
        
        present(alert, animated: true)
        
        }
}


extension DashboardViewController: FilterViewControllerDelegate {

    func filterViewController(
        _ controller: FilterViewController,
        didApply filter: Filter
    ) {
        vm.apply(filter: filter)
        tableView.reloadData()
        updateEmptyState()
        updateBalanceLabels()
    }
}

