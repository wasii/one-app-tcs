//
//  AttendanceDetailsTableCell.swift
//  tcs_one_app
//
//  Created by TCS on 11/03/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class AttendanceDetailsTableCell: UITableViewCell {

    @IBOutlet weak var dayName: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var timeIn: UILabel!
    @IBOutlet weak var timeOut: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
