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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        vm.loadTransactions()
        tableView.reloadData()
        updateEmptyState()
    }
    
    @objc private func refreshTransactions() {
        
        vm.loadTransactions()
        tableView.reloadData()
        updateEmptyState()
        
        refreshControl.endRefreshing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
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
    
    // delegate for editing operations (deleting)
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
                
                // deletes the transaction
                self?.vm.deleteTransaction(at: indexPath.row)
                
                // changes the visible UI
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                
                self?.navigationController?.popViewController(animated: true)
                
                print("Transaction Deleted")

            }
        )
        
        present(alert, animated: true)
        
        }
}

