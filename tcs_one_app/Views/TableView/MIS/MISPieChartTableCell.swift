//
//  MISPieChartTableCell.swift
//  tcs_one_app
//
//  Created by TCS on 29/09/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import Charts

class MISPieChartTableCell: UITableViewCell {
    override class func description() -> String {
        return "MISPieChartTableCell"
    }
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var totalShipmentLabel: UILabel!
    @IBOutlet weak var pieChart: PieChartView!
    var product: String?
    override func awakeFromNib() {
        super.awakeFromNib()
        if let product = product {
            self.headingLabel.text = product
        }
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)

        // Configure the view for the selected state
    }
    
}
