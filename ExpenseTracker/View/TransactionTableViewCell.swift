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
    // Card container for corner radius (storyboard layout) — optional, falls back to contentView styling
    @IBOutlet weak var cardBackgroundView: UIView?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Corner radius is programmatic only (per spec) — storyboard handles layout
        // Card background view (CellBg-001) gets rounded corners
        if let cardView = cardBackgroundView {
            cardView.layer.cornerRadius = 12
            cardView.layer.masksToBounds = true
            cardView.backgroundColor = .systemBackground
        } else {
            // Fallback: style contentView if outlet not connected (old storyboard)
            contentView.layer.cornerRadius = 12
            contentView.layer.masksToBounds = true
        }
        // Circular icon background
        typeImageView.layer.cornerRadius = 20
        typeImageView.layer.masksToBounds = true
        typeImageView.backgroundColor = UIColor.systemGray6
        typeImageView.tintColor = .label

        // Type indicator (left stripe) rounded on left side only
        typeIndicatorView.layer.cornerRadius = 2
        typeIndicatorView.layer.masksToBounds = true

        // Remove default cell background to show card
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure card view keeps corner radius after layout
        cardBackgroundView?.layer.cornerRadius = 12
        // Make image view circular (40pt height -> 20pt radius)
        typeImageView.layer.cornerRadius = typeImageView.bounds.height / 2
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
