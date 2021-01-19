//
//  GrievacneDownloadsTableCell.swift
//  tcs_one_app
//
//  Created by TCS on 19/11/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit

class GrievacneDownloadsTableCell: UITableViewCell {

    
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var uploadedBy: UILabel!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var fileSize: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
