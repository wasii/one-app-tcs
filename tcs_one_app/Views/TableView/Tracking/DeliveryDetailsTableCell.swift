//
//  DeliveryDetailsTableCell.swift
//  tcs_one_app
//
//  Created by TCS on 17/02/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class DeliveryDetailsTableCell: UITableViewCell {

    @IBOutlet weak var sheetno: UILabel!
    @IBOutlet weak var slot: UILabel!
    @IBOutlet weak var route: UILabel!
    @IBOutlet weak var courier: UILabel!
    @IBOutlet weak var couriercell: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var receivedBy: UILabel!
    @IBOutlet weak var relation: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var pieces: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
