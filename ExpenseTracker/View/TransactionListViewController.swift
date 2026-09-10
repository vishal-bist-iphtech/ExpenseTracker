//
//  TransactionListViewController.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 09/09/26.
//

import UIKit

final class TransactionListViewController: UIViewController {


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var filterButton: UIButton?
    @IBOutlet weak var addButton: UIButton?
    @IBOutlet weak var searchBar: UISearchBar?
    // MARK: - ViewModel

    private let vm = TransactionListVM(
        repository: AppContainer.shared.transactionRepository
    )

    private let refreshControl = UIRefreshControl()


    override func viewDidLoad() {
        super.viewDidLoad()

        title = ""
        navigationItem.largeTitleDisplayMode = .never

        // Bind VM updates
        vm.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView?.reloadData()
            }
        }

        setupTableView()
        setupEmptyState()
        setupSearchBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vm.loadTransactions()
        tableView?.reloadData()
    }


    private func setupTableView() {
       
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = 68
        tableView.estimatedRowHeight = 68
        tableView.separatorStyle = .none
        
        // Make background clear / same as screen background per requirement
        view.backgroundColor = .systemBackground
        tableView.backgroundColor = .clear
        tableView.backgroundView = nil
        if let bg = tableView.backgroundView {
            bg.backgroundColor = .clear
        }
        
        tableView.refreshControl = refreshControl
        tableView.showsVerticalScrollIndicator = false

        refreshControl.addTarget(self, action: #selector(refreshTransactions), for: .valueChanged)
       
        // Registering would overwrite prototype and break outlets
    }

    private func setupSearchBar() {
        searchBar?.delegate = self
        searchBar?.placeholder = "Search transactions"
        searchBar?.searchBarStyle = .minimal
        searchBar?.barTintColor = .clear
        searchBar?.backgroundColor = .clear
        searchBar?.isTranslucent = true
        searchBar?.showsCancelButton = false
        // Ensure background matches screen
        if let textField = searchBar?.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .secondarySystemBackground
        }
    }

    private func setupEmptyState() {
        if emptyStateView == nil {
            emptyStateView = view.subviews.first(where: { $0.restorationIdentifier == "EmptyStateView" })
            if emptyStateView == nil {
                // Try to find by scanning for view with 2 labels
                for sub in view.subviews where sub.subviews.contains(where: { $0 is UILabel }) {
                    emptyStateView = sub
                    break
                }
            }
        }
        emptyStateView?.layer.cornerRadius = 12
        emptyStateView?.layer.masksToBounds = true
    }




    @objc private func refreshTransactions() {
        vm.loadTransactions()
        tableView?.reloadData()
        refreshControl.endRefreshing()
    }

    // MARK: - Actions

    @IBAction func filterButtonTapped(_ sender: Any? = nil) {
        // Perform segue defined in storyboard: showFilterTransaction or showFilters

        if hasSegue(withIdentifier: "showFilterTransaction") {
            performSegue(withIdentifier: "showFilterTransaction", sender: nil)
        } else if hasSegue(withIdentifier: "showFilters") {
            performSegue(withIdentifier: "showFilters", sender: nil)
        } else {
            // Fallback: instantiate FilterViewController programmatically
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let filterVC = storyboard.instantiateViewController(withIdentifier: "FilterViewController") as? FilterViewController {
                filterVC.viewModel = FilterVM(filter: vm.currentFilter)
                filterVC.delegate = self
                navigationController?.pushViewController(filterVC, animated: true)
            }
        }
    }

    @IBAction func addButtonTapped(_ sender: Any? = nil) {
        if hasSegue(withIdentifier: "showAddTransaction") {
            performSegue(withIdentifier: "showAddTransaction", sender: nil)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let addVC = storyboard.instantiateViewController(withIdentifier: "AddTransactionViewController") as? AddTransactionViewController {
                navigationController?.pushViewController(addVC, animated: true)
            } else {
                performSegue(withIdentifier: "showAddTransaction", sender: nil)
            }
        }
    }

    private func hasSegue(withIdentifier identifier: String) -> Bool {
       
        let knownSegues = ["showFilterTransaction", "showFilters", "showAddTransaction", "showTransactionDetails"]
        if knownSegues.contains(identifier) { return true }
        // Fallback: try KVC introspection but avoid crash via performing selector safely
        // If identifier not in known set, assume no segue to trigger fallback code path
        return false
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue.identifier == "showFilterTransaction" || segue.identifier == "showFilters" {
            guard let destination = segue.destination as? FilterViewController else { return }
            destination.viewModel = FilterVM(filter: vm.currentFilter)
            destination.delegate = self
            return
        }

        if segue.identifier == "showAddTransaction" {
            guard let destination = segue.destination as? AddTransactionViewController else { return }
            destination.mode = .add
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
}

// MARK: - UITableViewDataSource & Delegate

extension TransactionListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.displayedTransactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Try dequeue with storyboard prototype identifier
        let identifier = "TransactionCell"
        var cell: TransactionTableViewCell?

        if let dequeued = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? TransactionTableViewCell {
            cell = dequeued
        } else if let dequeued = tableView.dequeueReusableCell(withIdentifier: identifier) as? TransactionTableViewCell {
            cell = dequeued
        }

        // Fallback: create manually if nil or not of correct type
        guard let transactionCell = cell else {
            // Create a plain cell as fallback
            let fallback = UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
            let transaction = vm.displayedTransactions[indexPath.row]
            fallback.textLabel?.text = transaction.description
            fallback.detailTextLabel?.text = transaction.date.formatted(date: .abbreviated, time: .omitted)
            return fallback
        }

        let transaction = vm.displayedTransactions[indexPath.row]
        transactionCell.configure(with: transaction)
        return transactionCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let transaction = vm.displayedTransactions[indexPath.row]
        performSegue(withIdentifier: "showTransactionDetails", sender: transaction)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        let alert = UIAlertController(
            title: "Delete Transaction?",
            message: "Are you sure you want to delete this transaction?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.vm.deleteTransaction(at: indexPath.row)
            self?.tableView?.reloadData()
        })
        present(alert, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
}

// MARK: - FilterViewControllerDelegate

extension TransactionListViewController: FilterViewControllerDelegate {

    func filterViewController(_ controller: FilterViewController, didApply filter: Filter) {
        vm.apply(filter: filter)
        tableView?.reloadData()
    }
}

// MARK: - UISearchBarDelegate

extension TransactionListViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        vm.updateSearch(text: searchText)
        tableView?.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        vm.updateSearch(text: nil)
        tableView?.reloadData()
        searchBar.resignFirstResponder()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
}
