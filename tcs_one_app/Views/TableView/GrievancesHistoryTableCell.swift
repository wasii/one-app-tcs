//
//  GrievancesHistoryTableCell.swift
//  tcs_one_app
//
//  Created by TCS on 19/11/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit

class GrievancesHistoryTableCell: UITableViewCell {

    @IBOutlet weak var roleManager: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptions: UILabel!
    @IBOutlet weak var closure_remarksLabel: UILabel!
    @IBOutlet weak var openAttachments: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
