//
//  BookingDetailsTableCell.swift
//  tcs_one_app
//
//  Created by TCS on 17/02/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class BookingDetailsTableCell: UITableViewCell {

    @IBOutlet weak var cgsnNo: UILabel!
    @IBOutlet weak var bookingdate: UILabel!
    @IBOutlet weak var pieces: UILabel!
    @IBOutlet weak var origin: UILabel!
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var route: UILabel!
    @IBOutlet weak var services: UILabel!
    @IBOutlet weak var product: UILabel!
    @IBOutlet weak var bookingweight: UILabel!
    
    @IBOutlet weak var handlingInstructions: UILabel!
    @IBOutlet weak var codStatus: UILabel!
    
    
    
    
    @IBOutlet weak var courierno: UILabel!
    
    
    
    @IBOutlet weak var routeNo: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var callNo: UILabel!
    
    @IBOutlet weak var customerNumber: UILabel!
    @IBOutlet weak var customerName: UILabel!
    @IBOutlet weak var customerAddress1: UILabel!
    @IBOutlet weak var customerAddress2: UILabel!
    @IBOutlet weak var customerAddress3: UILabel!
    @IBOutlet weak var customerPhone: UILabel!
    @IBOutlet weak var customerFax: UILabel!
    
    
    
    @IBOutlet weak var consigneeName: UILabel!
    @IBOutlet weak var deliveryKPI: UILabel!
    @IBOutlet weak var consigneeAddress1: UILabel!
    @IBOutlet weak var consigneeAddress2: UILabel!
    @IBOutlet weak var consigneeAddress3: UILabel!
    @IBOutlet weak var consigneePhone: UILabel!
    @IBOutlet weak var consigneeFax: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
