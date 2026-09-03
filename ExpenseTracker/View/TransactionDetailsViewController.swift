//
//  TransactionDetailsViewController.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 02/09/26.
//

import UIKit

final class TransactionDetailsViewController: UIViewController {
    
    var transaction: Transaction?
    
    private var vm: TransactionDetailsVM!
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
 
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let transaction = transaction else {
            assertionFailure("TransactionDetailsViewController: transaction not set in prepare(for:sender:) - check segue identifier 'showTransactionDetails' from DashboardViewController")
            return
        }
        
        vm = TransactionDetailsVM(
            transaction: transaction,
            repository: AppContainer.shared.transactionRepository
        )
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh from repository in case transaction was edited
        vm.refreshTransaction()
        configureUI()
    }
    
    
    private func configureUI() {
        guard isViewLoaded, amountLabel != nil else { return }

        amountLabel.text = "₹\(vm.transaction.amount)"
        descriptionLabel.text = vm.transaction.description

        categoryLabel.text = vm.transaction.category.displayName

        dateLabel.text = vm.transaction.date.formatted(
            date: .abbreviated,
            time: .omitted
        )

        typeLabel.text = vm.transaction.type.displayName
    }
    
    
    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {
        
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "editTransaction" {
            
            guard let destination = segue.destination as? AddTransactionViewController else { return }
            
            // sender is expected to be Transaction via editButton(_:), fallback to vm.transaction for safety
            if let transaction = sender as? Transaction {
                destination.mode = .edit(transaction)
            } else {
                destination.mode = .edit(vm.transaction)
            }
        }
    }
    
    
    
    @IBAction func editButton(_ sender: UIButton) {
        
        performSegue(withIdentifier: "editTransaction", sender: vm.transaction)
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        
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
                    
                self?.vm.deleteTransaction()
                
                self?.navigationController?.popViewController(animated: true)
            }
        )
        
        present(alert, animated: true)
    }
   
}
