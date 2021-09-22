//
//  WalletBeneficiaryListingTableCell.swift
//  tcs_one_app
//
//  Created by TCS on 22/09/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class WalletBeneficiaryListingTableCell: UITableViewCell {
    override class func description() -> String {
        return "WalletBeneficiaryListingTableCell"
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var empIdLabel: UILabel!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var redemptionBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }
    
}
