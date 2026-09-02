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
    
    
    private let vm = DashboardVM(
        repository: AppContainer.shared.transactionRepository
    )
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        vm.loadTransactions()
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showTransactionDetails" {
            guard let destination = segue.destination as? TransactionDetailsViewController else { return }
            
            // Sender is Transaction when triggered via didSelectRowAt performSegue(sender: transaction)
            if let transaction = sender as? Transaction {
                destination.transaction = transaction
                return
            }
            
            // Fallback: if segue ever triggered directly from cell (sender is UITableViewCell), resolve via indexPath
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                destination.transaction = vm.transactions[indexPath.row]
                return
            }
            
            // Last fallback: use selected row
            if let indexPath = tableView.indexPathForSelectedRow {
                destination.transaction = vm.transactions[indexPath.row]
                return
            }
            
            assertionFailure("prepare(for:sender:) failed - sender is not Transaction nor cell, check Main.storyboard: BYZ-38-t0r -> mx2-HX-fTE segue 'showTransactionDetails'")
        }
    }
    
    // no. rows?
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "TransactionCell",
            for: indexPath
        ) as? TransactionTableViewCell else {
            return UITableViewCell()
        }
        
        let transaction = vm.transactions[indexPath.row]
        
        cell.configure(with: transaction)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let transaction = vm.transactions[indexPath.row]
        
        performSegue(withIdentifier: "showTransactionDetails", sender: transaction)
    }


}

