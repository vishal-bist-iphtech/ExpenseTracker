//
//  FilterViewController.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 04/09/26.
//

import UIKit

protocol FilterViewControllerDelegate: AnyObject {

    func filterViewController(
        _ controller: FilterViewController,
        didApply filter: Filter
    )
}

class FilterViewController: UIViewController {

    weak var delegate: FilterViewControllerDelegate?

    // Injected VM - set in Dashboard prepare(for:sender:)
    var viewModel: FilterVM!

    // Backwards-compat alias so any existing code using `filterViewModel` still compiles
    var filterViewModel: FilterVM! {
        get { viewModel }
        set { viewModel = newValue }
    }

    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateFilterSwitch: UISwitch? // Optional to prevent crash when outlet not connected
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!

    private let categories: [Category?] = [
        nil,
        .food,
        .shopping,
        .travel,
        .bills,
        .salary,
        .other
    ]

    private let sortOptions: [SortOption] = [
        .newestFirst,
        .oldestFirst,
        .highestAmount,
        .lowestAmount
    ]

    private var selectedSortOption: SortOption = .newestFirst

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Fallback VM if segue not configured (prevents crash during storyboard preview)
        if viewModel == nil {
            viewModel = FilterVM(
                filter: Filter(type: nil, category: nil, date: nil, sortOptions: .newestFirst)
            )
        }

        categoryPickerView?.delegate = self
        categoryPickerView?.dataSource = self

        configureInitialState()
    }

    private func configureInitialState() {
        // Type: 0=All, 1=Income, 2=Expense
        // Use optional chaining to avoid crash if outlet not connected
        switch viewModel.filter.type {
        case .income:
            typeSegmentedControl?.selectedSegmentIndex = 1
        case .expense:
            typeSegmentedControl?.selectedSegmentIndex = 2
        default:
            typeSegmentedControl?.selectedSegmentIndex = 0
        }

        // Category picker: 0=All, else match
        if let category = viewModel.filter.category,
           let index = categories.firstIndex(where: { $0 == category }) {
            categoryPickerView?.selectRow(index, inComponent: 0, animated: false)
        } else {
            categoryPickerView?.selectRow(0, inComponent: 0, animated: false)
        }

        // Date filter switch + picker - safely handle missing switch outlet
        if let date = viewModel.filter.date {
            dateFilterSwitch?.isOn = true
            datePicker?.date = date
            datePicker?.isEnabled = true
        } else {
            dateFilterSwitch?.isOn = false
            datePicker?.isEnabled = dateFilterSwitch == nil ? true : false
            // If switch is missing, keep datePicker enabled so user can still pick date
            if dateFilterSwitch == nil {
                datePicker?.isEnabled = true
            }
        }

        // Sort: map Filter.sortOptions -> segmented index
        if let index = sortOptions.firstIndex(of: viewModel.filter.sortOptions) {
            selectedSortOption = viewModel.filter.sortOptions
            // Ensure segmented control has enough segments; fallback to 0 if out of bounds
            if let segments = sortSegmentedControl?.numberOfSegments, index < segments {
                sortSegmentedControl?.selectedSegmentIndex = index
            } else if sortSegmentedControl == nil {
                // no control, keep selectedSortOption in memory
            } else {
                sortSegmentedControl?.selectedSegmentIndex = 0
                selectedSortOption = sortOptions[0]
            }
        } else {
            sortSegmentedControl?.selectedSegmentIndex = 0
            selectedSortOption = sortOptions[0]
        }
    }

    // MARK: - Actions

    @IBAction func dateFilterSwitchChanged(_ sender: UISwitch) {
        datePicker?.isEnabled = sender.isOn
    }

    @IBAction func sortSegmentChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        guard sortOptions.indices.contains(index) else { return }
        selectedSortOption = sortOptions[index]
    }

    @IBAction func clearButtonTapped(_ sender: UIButton) {
        // Reset UI to defaults - use optional chaining for safety
        typeSegmentedControl?.selectedSegmentIndex = 0
        categoryPickerView?.selectRow(0, inComponent: 0, animated: true)
        dateFilterSwitch?.setOn(false, animated: true)
        if dateFilterSwitch != nil {
            datePicker?.isEnabled = false
        }
        sortSegmentedControl?.selectedSegmentIndex = 0
        selectedSortOption = .newestFirst

        let filter = viewModel.makeFilter(
            type: nil,
            category: nil,
            date: nil,
            sortOption: .newestFirst
        )

        delegate?.filterViewController(self, didApply: filter)
        navigationController?.popViewController(animated: true)
    }

    @IBAction func applyButtonTapped(_ sender: UIButton) {

        let type: TransactionType?

        switch typeSegmentedControl?.selectedSegmentIndex ?? 0 {
        case 1:
            type = .income
        case 2:
            type = .expense
        default:
            type = nil
        }

        let categoryRow = categoryPickerView?.selectedRow(inComponent: 0) ?? 0
        let category: Category? = categories.indices.contains(categoryRow) ? categories[categoryRow] : nil

        // If switch is nil (outlet not connected), treat date as nil or use picker date if enabled
        let date: Date? = {
            if let switchControl = dateFilterSwitch {
                return switchControl.isOn ? datePicker?.date : nil
            } else {
                // Fallback when switch missing: if datePicker is enabled, use its date only if viewModel had date
                // To preserve existing behavior, return nil when switch absent and no date filter needed
                // User can still filter by date if we assume date filter is enabled when switch missing
                return nil
            }
        }()

        // Keep selectedSortOption in sync if user didn't trigger valueChanged
        if let idx = sortSegmentedControl?.selectedSegmentIndex, sortOptions.indices.contains(idx) {
            selectedSortOption = sortOptions[idx]
        }

        let filter = viewModel.makeFilter(
            type: type,
            category: category,
            date: date,
            sortOption: selectedSortOption
        )

        delegate?.filterViewController(self, didApply: filter)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UIPickerViewDataSource & Delegate

extension FilterViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let category = categories[row] else { return "All" }
        return category.displayName
    }
}
