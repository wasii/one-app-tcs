//
//  MISDetailTableCell.swift
//  tcs_one_app
//
//  Created by TCS on 11/08/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class MISDetailTableCell: UITableViewCell {
    override class func description() -> String {
        return "MISDetailTableCell"
    }
    
    @IBOutlet weak var weightView: CustomView!
    @IBOutlet weak var qsrView: CustomView!
    @IBOutlet weak var dsrView: CustomView!
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var shipmentBookedLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var qsrLabel: UILabel!
    @IBOutlet weak var dsrLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }
    
}
