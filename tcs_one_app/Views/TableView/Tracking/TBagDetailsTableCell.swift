//
//  TBagDetailsTableCell.swift
//  tcs_one_app
//
//  Created by TCS on 17/02/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class TBagDetailsTableCell: UITableViewCell {

    @IBOutlet weak var transitManifest: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var origin: UILabel!
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var courier: UILabel!
    @IBOutlet weak var manifesttype: UILabel!
    @IBOutlet weak var remarksflight: UILabel!
    @IBOutlet weak var truck: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
