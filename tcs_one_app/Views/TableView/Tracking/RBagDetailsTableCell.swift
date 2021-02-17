//
//  RBagDetailsTableCell.swift
//  tcs_one_app
//
//  Created by TCS on 17/02/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class RBagDetailsTableCell: UITableViewCell {

    @IBOutlet weak var rBagManifest: UILabel!
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var transdate: UILabel!
    @IBOutlet weak var rBageNo: UILabel!
    @IBOutlet weak var rbagSeal: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
