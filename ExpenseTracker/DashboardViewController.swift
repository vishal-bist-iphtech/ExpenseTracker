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
    
    // no. rows?
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TransactionCell",
            for: indexPath
        )
        
        let transaction = vm.transactions[indexPath.row]
        
        cell.textLabel?.text = transaction.description
        
        return cell
    }


}

