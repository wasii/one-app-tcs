//
//  BinInfoTableCell.swift
//  tcs_one_app
//
//  Created by TCS on 30/07/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class BinInfoTableCell: UITableViewCell {

    override class func description() -> String {
        return "BinInfoCell"
    }
    @IBOutlet weak var sheetNo: UILabel!
    @IBOutlet weak var route: UILabel!
    @IBOutlet weak var station: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
