//
//  RiderDashboardTableCell.swift
//  tcs_one_app
//
//  Created by TCS on 21/06/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class RiderDashboardTableCell: UITableViewCell {

    override class func description() -> String {
        return "RiderDashboardTableCell"
    }
    @IBOutlet weak var cnNumber: UILabel!
    @IBOutlet weak var sheetNumber: UILabel!
    @IBOutlet weak var customerName: UILabel!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var googlePin: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
