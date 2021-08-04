//
//  ReportToTableCell.swift
//  tcs_one_app
//
//  Created by TCS on 04/08/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class ReportToTableCell: UITableViewCell {

    @IBOutlet weak var isselected: UIImageView!
    @IBOutlet weak var heading: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
