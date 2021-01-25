//
//  RequestListingTableCell.swift
//  tcs_one_app
//
//  Created by ibs on 19/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit

class RequestListingTableCell: UITableViewCell {

    @IBOutlet weak var mainView: CustomView!
    @IBOutlet weak var ticketID: UILabel!
    @IBOutlet weak var mainHeading: UILabel!
    @IBOutlet weak var subHeading: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var status: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
