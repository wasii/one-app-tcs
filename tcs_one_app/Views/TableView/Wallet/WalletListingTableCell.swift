//
//  WalletListingTableCell.swift
//  tcs_one_app
//
//  Created by TCS on 16/07/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class WalletListingTableCell: UITableViewCell {

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var pdfButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
