//
//  ModulesCollectionCell.swift
//  tcs_one_app
//
//  Created by ibs on 18/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit

class ModulesCollectionCell: UICollectionViewCell {

    @IBOutlet weak var mainView: CustomView!
    @IBOutlet weak var icon_imageView: UIImageView!
    @IBOutlet weak var title_Label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        mainView.layoutMarginsGuide.topAnchor.constraint(equalTo: label.topAnchor).isActive = true
//        mainView.layoutMarginsGuide.leadingAnchor.constraint(equalTo: label.leadingAnchor).isActive = true
//        mainView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: label.trailingAnchor).isActive = true
//        mainView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
    }

}
