//
//  MISDetailsCollectionCell.swift
//  tcs_one_app
//
//  Created by TCS on 13/09/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class MISDetailsCollectionCell: UICollectionViewCell {
    override class func description() -> String {
        return "MISDetailsCollectionCell"
    }
    @IBOutlet weak var mainView: CustomView!
    @IBOutlet weak var detail_label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
