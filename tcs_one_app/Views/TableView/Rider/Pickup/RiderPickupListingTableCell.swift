//
//  RiderPickupListingTableCell.swift
//  tcs_one_app
//
//  Created by TCS on 22/06/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class RiderPickupListingTableCell: UITableViewCell {
    override class func description() -> String {
        return "RiderPickupListingTableCell"
    }
    @IBOutlet weak var mainView: CustomView!
    @IBOutlet weak var CNNumber: UILabel!
    @IBOutlet weak var CODAmount: UILabel!
    @IBOutlet weak var Description: UILabel!
    @IBOutlet weak var StatusLabel: UILabel!
    @IBOutlet weak var OptionsStackView: UIStackView!
    @IBOutlet weak var CameraBtn: UIButton!
    @IBOutlet weak var EditBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
