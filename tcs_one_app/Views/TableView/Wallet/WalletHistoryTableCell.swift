//
//  WalletHistoryTableCell.swift
//  tcs_one_app
//
//  Created by TCS on 17/06/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class WalletHistoryTableCell: UITableViewCell {
    override class func description() -> String {
        return "WalletHistoryTableCell"
    }
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
