//
//  FulfilmentOrderDetailTableCell.swift
//  tcs_one_app
//
//  Created by TCS on 26/03/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class FulfilmentOrderDetailTableCell: UITableViewCell {

    @IBOutlet weak var orderID: UILabel!
    @IBOutlet weak var bucketBarcode: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var resetBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
