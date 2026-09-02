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
        
        switch transaction.category {
            
        case .food:
            typeImageView.image = UIImage(
                systemName: "fork.knife"
            )
            
        case .shopping:
            typeImageView.image = UIImage(
                systemName: "bag"
            )
            
        case .travel:
            typeImageView.image = UIImage(
                systemName: "airplane"
            )
            
        case .bills:
            typeImageView.image = UIImage(
                systemName: "doc.text"
            )
            
        case .salary:
            typeImageView.image = UIImage(
                systemName: "banknote"
            )
            
        case .other:
            typeImageView.image = UIImage(
                systemName: "ellipsis.circle"
            )
        }
        
        switch transaction.type {
            
        case .income:
            amountLabel.text = "+ ₹\(transaction.amount)"
            typeIndicatorView.backgroundColor = .systemGreen
            
        case .expense:
            amountLabel.text = "- ₹\(transaction.amount)"
            typeIndicatorView.backgroundColor = .systemRed
        }
    }
}
