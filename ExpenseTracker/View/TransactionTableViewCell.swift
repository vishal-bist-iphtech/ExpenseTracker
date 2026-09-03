//
//  TransactionTableViewCell.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 02/09/26.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var typeIndicatorView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with transaction: Transaction) {
        
        descriptionLabel.text = transaction.description
        
        dateLabel.text = transaction.date.formatted(
            date: .abbreviated,
            time: .omitted
        )
        
        typeImageView.image = UIImage(
            systemName: transaction.category.iconName
        )
        
       
        amountLabel.text = "\(transaction.type.sign) ₹\(transaction.amount)"
        
        typeIndicatorView.backgroundColor = transaction.type == .income
        ? .systemGreen : .systemRed
            
    }
}
