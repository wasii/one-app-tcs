//
//  MISCollectionCell.swift
//  tcs_one_app
//
//  Created by TCS on 10/09/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class MISCollectionCell: UICollectionViewCell {

    override class func description() -> String {
        return "MISCollectionCell"
    }
    @IBOutlet weak var dateView: CustomView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var shipmentCollectionViiew: UICollectionView!
    @IBOutlet weak var shipmentView: CustomView!
    @IBOutlet weak var shipmentLabel: UILabel!
    @IBOutlet weak var dsrCollectionView: UICollectionView!
    @IBOutlet weak var dsrView: CustomView!
    @IBOutlet weak var dsrLabel: UILabel!
    @IBOutlet weak var qsrCollectionView: UICollectionView!
    @IBOutlet weak var qsrView: CustomView!
    @IBOutlet weak var qsrLabel: UILabel!
    @IBOutlet weak var weightCollectionView: UICollectionView!
    @IBOutlet weak var weightView: CustomView!
    @IBOutlet weak var weightLabel: UILabel!
    
    var indexPath: Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupCell() {
        switch indexPath % 4 {
        case 0:
            shipmentCollectionViiew.isHidden = false
            dsrCollectionView.isHidden = true
            qsrCollectionView.isHidden = true
            weightCollectionView.isHidden = true
            break
        case 1:
            shipmentCollectionViiew.isHidden = true
            dsrCollectionView.isHidden = false
            qsrCollectionView.isHidden = true
            weightCollectionView.isHidden = true
            break
        case 2:
            shipmentCollectionViiew.isHidden = true
            dsrCollectionView.isHidden = true
            qsrCollectionView.isHidden = false
            weightCollectionView.isHidden = true
            break
        case 3:
            shipmentCollectionViiew.isHidden = true
            dsrCollectionView.isHidden = true
            qsrCollectionView.isHidden = true
            weightCollectionView.isHidden = false
            break
        default:
            break
        }
    }
}
