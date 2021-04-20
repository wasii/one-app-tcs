//
//  IMSDeliveryDetailsTableCell.swift
//  tcs_one_app
//
//  Created by TCS on 09/04/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class IMSDeliveryDetailsTableCell: UITableViewCell {

    @IBOutlet weak var deliverySheetNo: UILabel!
    @IBOutlet weak var serialNo: UILabel!
    @IBOutlet weak var deliveryRoute: UILabel!
    @IBOutlet weak var courierCode: UILabel!
    @IBOutlet weak var courierName: UILabel!
    @IBOutlet weak var courierMobile: UILabel!
    @IBOutlet weak var courierPhone: UILabel!
    @IBOutlet weak var deliveryDate: UILabel!
    @IBOutlet weak var deliveryTime: UILabel!
    @IBOutlet weak var receiver: UILabel!
    @IBOutlet weak var status: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
