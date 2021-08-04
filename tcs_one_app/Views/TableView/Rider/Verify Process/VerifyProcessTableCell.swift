//
//  VerifyProcessTableCell.swift
//  tcs_one_app
//
//  Created by TCS on 03/08/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class VerifyProcessTableCell: UITableViewCell {
    override class func description() -> String {
        return "VerifyProcessTableCell"
    }
    @IBOutlet weak var MainView: CustomView!
    @IBOutlet weak var CNNumber: UILabel!
    @IBOutlet weak var SheetNumber: UILabel!
    @IBOutlet weak var CustomerName: UILabel!
    @IBOutlet weak var EditBtn: UIButton!
    @IBOutlet weak var VerifyLabel: UILabel!
    @IBOutlet weak var ReportTo: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
