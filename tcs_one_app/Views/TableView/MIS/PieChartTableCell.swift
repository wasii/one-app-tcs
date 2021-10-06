//
//  PieChartTableCell.swift
//  tcs_one_app
//
//  Created by TCS on 06/10/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class PieChartTableCell: UITableViewCell {
    override class func description() -> String {
        return "PieChartTableCell"
    }
    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }
    
}
