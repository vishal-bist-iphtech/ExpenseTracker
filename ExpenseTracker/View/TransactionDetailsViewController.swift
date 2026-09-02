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
        
        vm = TransactionDetailsVM(
            transaction: transaction!,
            repository: AppContainer.shared.transactionRepository
        )
        
        configureUI()

        guard let transaction = transaction else {
            assertionFailure("TransactionDetailsViewController: transaction not set in prepare(for:sender:) - check segue identifier 'showTransactionDetails' from DashboardViewController")
            return
        }
        

        
        guard amountLabel != nil, descriptionLabel != nil, categoryLabel != nil, dateLabel != nil, typeLabel != nil else {
            assertionFailure("TransactionDetailsViewController: outlet nil")
            return
        }

        amountLabel.text = "₹\(transaction.amount)"
        descriptionLabel.text = transaction.description

        switch transaction.category {
        case .food:
            categoryLabel.text = "Food"
        case .shopping:
            categoryLabel.text = "Shopping"
        case .travel:
            categoryLabel.text = "Travel"
        case .bills:
            categoryLabel.text = "Bills"
        case .salary:
            categoryLabel.text = "Salary"
        case .other:
            categoryLabel.text = "Other"
        }

        dateLabel.text = transaction.date.formatted(
            date: .abbreviated,
            time: .omitted
        )

        switch transaction.type {
        case .income:
            typeLabel.text = "Income"
        case .expense:
            typeLabel.text = "Expense"
        }
    }
    
    
    private func configureUI() {

        amountLabel.text = "₹\(vm.transaction.amount)"
        descriptionLabel.text = vm.transaction.description

        switch vm.transaction.category {

        case .food:
            categoryLabel.text = "Food"

        case .shopping:
            categoryLabel.text = "Shopping"

        case .travel:
            categoryLabel.text = "Travel"

        case .bills:
            categoryLabel.text = "Bills"

        case .salary:
            categoryLabel.text = "Salary"

        case .other:
            categoryLabel.text = "Other"
        }

        dateLabel.text = vm.transaction.date.formatted(
            date: .abbreviated,
            time: .omitted
        )

        switch vm.transaction.type {

        case .income:
            typeLabel.text = "Income"

        case .expense:
            typeLabel.text = "Expense"
        }
    }
    
    
    
    @IBAction func editButton(_ sender: UIButton) {
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        
        vm.deleteTransaction()
        
        navigationController?.popViewController(animated: true)
    }
   
}
