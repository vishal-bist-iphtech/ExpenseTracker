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
    
    // Support both storyboard variants: UILabel (old) and UITextField (current storyboard)
    // Keep original UILabel outlets optional to prevent crash when storyboard uses textFields
    @IBOutlet weak var amountLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var categoryLabel: UILabel?
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var typeLabel: UILabel?
    
    // Current storyboard uses UITextField for value display
    @IBOutlet weak var amountTextField: UITextField?
    @IBOutlet weak var descriptionTextField: UITextField?
    @IBOutlet weak var categoryTextField: UITextField?
    @IBOutlet weak var dateTextField: UITextField?
    @IBOutlet weak var typeTextField: UITextField?
  
    
    
    
    
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
        if vm != nil {
            vm.refreshTransaction()
            configureUI()
        }
    }
    
    
    private func configureUI() {
        guard isViewLoaded, vm != nil else { return }

        let amountText = "₹\(vm.transaction.amount)"
        let descText = vm.transaction.description
        let categoryText = vm.transaction.category.displayName
        let dateText = vm.transaction.date.formatted(
            date: .abbreviated,
            time: .omitted
        )
        let typeText = vm.transaction.type.displayName

        // UILabel variants (if storyboard uses labels)
        amountLabel?.text = amountText
        descriptionLabel?.text = descText
        categoryLabel?.text = categoryText
        dateLabel?.text = dateText
        typeLabel?.text = typeText

        // UITextField variants (current storyboard) - make non-editable
        if let tf = amountTextField {
            tf.text = amountText
            tf.isEnabled = false
            tf.isUserInteractionEnabled = false
            tf.borderStyle = .roundedRect
        }
        if let tf = descriptionTextField {
            tf.text = descText
            tf.isEnabled = false
            tf.isUserInteractionEnabled = false
        }
        if let tf = categoryTextField {
            tf.text = categoryText
            tf.isEnabled = false
            tf.isUserInteractionEnabled = false
        }
        if let tf = dateTextField {
            tf.text = dateText
            tf.isEnabled = false
            tf.isUserInteractionEnabled = false
        }
        if let tf = typeTextField {
            tf.text = typeText
            tf.isEnabled = false
            tf.isUserInteractionEnabled = false
        }
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
            } else if vm != nil {
                destination.mode = .edit(vm.transaction)
            }
        }
    }
    
    
    
    @IBAction func editButton(_ sender: UIButton) {
        
        guard vm != nil else { return }
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
