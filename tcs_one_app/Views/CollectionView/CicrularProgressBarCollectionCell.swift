//
//  CicrularProgressBarCollectionCell.swift
//  tcs_one_app
//
//  Created by ibs on 20/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import MBCircularProgressBar

class CicrularProgressBarCollectionCell: UICollectionViewCell {

    @IBOutlet weak var circularView: MBCircularProgressBarView!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
