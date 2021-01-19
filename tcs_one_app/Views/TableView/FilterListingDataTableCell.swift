//
//  FilterListingDataTableCell.swift
//  tcs_one_app
//
//  Created by ibs on 19/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit

class FilterListingDataTableCell: UITableViewCell {

    @IBOutlet weak var title_Label: UILabel!
    @IBOutlet weak var selected_Image: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
