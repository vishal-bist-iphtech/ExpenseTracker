//
//  AddTransactionViewController.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 01/09/26.
//

import UIKit

class AddTransactionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var amountTextfield: UITextField!
    @IBOutlet weak var descriptionTextfield: UITextField!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    @IBOutlet weak var typeSegmentControl: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    private let vm = AddTransactionVM(
        repository: AppContainer.shared.transactionRepository
    )
    
    
    private let categories: [Category] = [
        .food,
        .shopping,
        .travel,
        .bills,
        .salary,
        .other
    ]
    
    
    private var selectedCategory: Category = .food
    private var selectedTransactionType: TransactionType = .expense

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        amountTextfield.keyboardType = .decimalPad
        
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
    }
    
    
    // no. columns?
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // no. rows?
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    // what each row shows?
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch categories[row] {
        case .food:
            return "Food"
        case .shopping:
            return "Shopping"
        case .travel:
            return "Travel"
        case .bills:
            return "Bills"
        case .salary:
            return "Salary"
        case .other:
            return "Other"
        }
    }
    // selected row?
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = categories[row]
    }
    
  
    @IBAction func transactionTypeChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            selectedTransactionType = .income
        } else {
            selectedTransactionType = .expense
        }
    }
    
    
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        
        if let errorMessage = vm.validate(amountText: amountTextfield.text, descriptionText: descriptionTextfield.text) {
            showAlert(message: errorMessage)
            return
        }
        
        guard let amountText = amountTextfield.text,
              let amount = Double(amountText),
              let description = descriptionTextfield.text else {return}
        
        vm.saveTransaction(
            amount: amount,
            description: description,
            category: selectedCategory,
            type: selectedTransactionType,
            date: datePicker.date
        )
        
        print("Transaction Saved")
        
        navigationController?.popViewController(animated: true)
    }
    
    
    // Helper functions
    
    private func showAlert(message: String) {
        
        let alert = UIAlertController(
            title: "Invalid Input",
            message: message,
            preferredStyle: .alert
            )
        
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            )
        )
        present(alert, animated: true)
    }
    
}
