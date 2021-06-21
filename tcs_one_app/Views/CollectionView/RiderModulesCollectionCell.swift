//
//  RiderModulesCollectionCell.swift
//  tcs_one_app
//
//  Created by TCS on 21/06/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class RiderModulesCollectionCell: UICollectionViewCell {

    override class func description() -> String {
        return "RiderModulesCollectionCell"
    }
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var moduleTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
