//
//  DManDetailsTableCell.swift
//  tcs_one_app
//
//  Created by TCS on 17/02/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class DManDetailsTableCell: UITableViewCell {

    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var hub: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
