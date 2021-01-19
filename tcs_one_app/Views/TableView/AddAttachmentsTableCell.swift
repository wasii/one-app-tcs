//
//  AddAttachmentsTableCell.swift
//  tcs_one_app
//
//  Created by TCS on 18/11/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit

class AddAttachmentsTableCell: UITableViewCell {

    @IBOutlet weak var attachment_name: UILabel!
    @IBOutlet weak var attachment_uploadBtn: UIButton!
    @IBOutlet weak var attachment_discardBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let image = UIImage(named: "upload-attachments")?.withRenderingMode(.alwaysTemplate)
        attachment_uploadBtn.setImage(image, for: .normal)
        attachment_uploadBtn.tintColor = UIColor.nativeRedColor()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
