//
//  IMSBookingDetailTableCell.swift
//  tcs_one_app
//
//  Created by TCS on 09/04/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class IMSBookingDetailTableCell: UITableViewCell {

    @IBOutlet weak var booking_date: UILabel!
    @IBOutlet weak var booking_time: UILabel!
    @IBOutlet weak var product: UILabel!
    @IBOutlet weak var service: UILabel!
    @IBOutlet weak var account_no: UILabel!
    @IBOutlet weak var shipper_name: UILabel!
    @IBOutlet weak var origin: UILabel!
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var payment_mode: UILabel!
    @IBOutlet weak var cod_amount: UILabel!
    @IBOutlet weak var consignee_name: UILabel!
    @IBOutlet weak var courier_code: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
