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
    @IBOutlet weak var fixedRed: UIView!
    @IBOutlet weak var fixedGreen: UIView!
    @IBOutlet weak var withinKPIView: UIView!
    @IBOutlet weak var inprogressView: UIView!
    @IBOutlet weak var afterKPIView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var withinKPIWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var inprogressWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var afterKPIWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var withinKPILabel: UILabel!
    @IBOutlet weak var inprogressLabel: UILabel!
    @IBOutlet weak var afterKPILabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }
    
}
