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
    
    @IBOutlet weak var shipmentWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var dsrWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var qsrWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var weightWidthConstraint: NSLayoutConstraint!
    var indexPath: Int = 0
    var tbl_mis_budget_data_detail: tbl_mis_budget_data_details?
    var isDualValue: Bool = false
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        shipmentCollectionViiew.delegate = self
        shipmentCollectionViiew.dataSource = self
        
        dsrCollectionView.delegate = self
        dsrCollectionView.dataSource = self
        
        qsrCollectionView.delegate = self
        dsrCollectionView.dataSource = self
        
        weightCollectionView.dataSource = self
        weightCollectionView.delegate = self
    }

    func setupCell() {
        shipmentCollectionViiew.register(UINib(nibName: MISDetailsCollectionCell.description(), bundle: nil), forCellWithReuseIdentifier: MISDetailsCollectionCell.description())
        dsrCollectionView.register(UINib(nibName: MISDetailsCollectionCell.description(), bundle: nil), forCellWithReuseIdentifier: MISDetailsCollectionCell.description())
        qsrCollectionView.register(UINib(nibName: MISDetailsCollectionCell.description(), bundle: nil), forCellWithReuseIdentifier: MISDetailsCollectionCell.description())
        weightCollectionView.register(UINib(nibName: MISDetailsCollectionCell.description(), bundle: nil), forCellWithReuseIdentifier: MISDetailsCollectionCell.description())
        
        
        
        if let budget_detail = tbl_mis_budget_data_detail {
            if indexPath == 0 {
                dateView.bgColor = UIColor.init(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1)
                dateLabel.text = "Date"
                dateLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
            } else {
                dateView.bgColor = UIColor.white
                dateLabel.text = self.tbl_mis_budget_data_detail!.RPT_DATE.dateOnly
                dateLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
            }
            if budget_detail.IS_WEIGHT_SHOW == "0" {
                weightView.isHidden = true
                weightCollectionView.isHidden = true
            } else {
                if indexPath == 0 {
                    weightView.bgColor = UIColor.init(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1)
                    weightLabel.text = budget_detail.WEIGHT
                    weightLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
                } else {
                    weightView.bgColor = UIColor.white
                    weightLabel.text = budget_detail.WEIGHT
                    weightLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
                }
                
                if isDualValue {
                    if let count = self.tbl_mis_budget_data_detail?.ALL_WEIGHT.split(separator: "*").count {
                        weightWidthConstraint.constant = CGFloat(count) * self.dateView.frame.width
                    }
                    weightView.isHidden = false
                    weightCollectionView.isHidden = false
                    weightCollectionView.reloadData()
                }
            }
            
            if budget_detail.IS_DSR_SHOW == "0" {
                dsrView.isHidden = true
                dsrCollectionView.isHidden = true
            } else {
                if indexPath == 0 {
                    dsrView.bgColor = UIColor.init(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1)
                    dsrLabel.text = budget_detail.DSR
                    dsrLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
                } else {
                    dsrView.bgColor = UIColor.white
                    dsrLabel.text = budget_detail.DSR
                    dsrLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
                }
                
                if isDualValue {
                    if let count = self.tbl_mis_budget_data_detail?.ALL_DSR.split(separator: "*").count {
                        dsrWidthConstraint.constant = CGFloat(count) * self.dateView.frame.width
                    }
                    dsrView.isHidden = false
                    dsrCollectionView.isHidden = false
                    dsrCollectionView.reloadData()
                }
            }
            
            if budget_detail.IS_QSR_SHOW == "0" {
                qsrView.isHidden = true
                qsrCollectionView.isHidden = true
            } else {
                if indexPath == 0 {
                    qsrView.bgColor = UIColor.init(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1)
                    qsrLabel.text = budget_detail.QSR
                    qsrLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
                } else {
                    qsrView.bgColor = UIColor.white
                    qsrLabel.text = budget_detail.QSR
                    qsrLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
                }
                
                if isDualValue {
                    if let count = self.tbl_mis_budget_data_detail?.ALL_QSR.split(separator: "*").count {
                        qsrWidthConstraint.constant = CGFloat(count) * self.dateView.frame.width
                    }
                    
                    qsrView.isHidden = false
                    qsrCollectionView.isHidden = false
                    qsrCollectionView.reloadData()
                }
            }
            
            if budget_detail.IS_SHIP_SHOW == "0" {
                shipmentView.isHidden = true
                shipmentCollectionViiew.isHidden = true
            } else {
                if indexPath == 0 {
                    shipmentView.bgColor = UIColor.init(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1)
                    shipmentLabel.text = budget_detail.SHIP
                    shipmentLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
                } else {
                    shipmentView.bgColor = UIColor.white
                    shipmentLabel.text = budget_detail.SHIP
                    shipmentLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
                }
                if isDualValue {
                    if let count = self.tbl_mis_budget_data_detail?.ALL_SHIP.split(separator: "*").count {
                        shipmentWidthConstraint.constant = CGFloat(count) * self.dateView.frame.width
                    }
                    shipmentView.isHidden = false
                    shipmentCollectionViiew.isHidden = false
                    shipmentCollectionViiew.reloadData()
                }
            }
        }
    }
}



extension MISCollectionCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == shipmentCollectionViiew {
            if let count = self.tbl_mis_budget_data_detail?.ALL_SHIP.split(separator: "*").count {
                shipmentWidthConstraint.constant = CGFloat(count) * self.dateView.frame.width
                return count
            }
            return 0
        }
        if collectionView == dsrCollectionView {
            if let count = self.tbl_mis_budget_data_detail?.ALL_DSR.split(separator: "*").count {
                dsrWidthConstraint.constant = CGFloat(count) * self.dateView.frame.width
                return count
            }
            return 0
        }
        if collectionView == qsrCollectionView {
            if let count = self.tbl_mis_budget_data_detail?.ALL_QSR.split(separator: "*").count {
                qsrWidthConstraint.constant = CGFloat(count) * self.dateView.frame.width
                return count
            }
            return 0
        }
        if collectionView == weightCollectionView {
            if let count = self.tbl_mis_budget_data_detail?.ALL_WEIGHT.split(separator: "*").count {
                return count
            }
            return 0
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MISDetailsCollectionCell.description(), for: indexPath) as? MISDetailsCollectionCell else {
            fatalError()
        }
        
        if collectionView == shipmentCollectionViiew {
            if let heading = self.tbl_mis_budget_data_detail?.ALL_SHIP.split(separator: "*") {
                if self.indexPath > 0 {
                    cell.detail_label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
                    cell.mainView.bgColor = UIColor.white
                } else {
                    cell.mainView.bgColor = UIColor.init(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1)
                    cell.detail_label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
                }
                let h = heading[indexPath.row]
                cell.detail_label.text = String(h)
            }
            return cell
        }
        if collectionView == dsrCollectionView {
            if let heading = self.tbl_mis_budget_data_detail?.ALL_DSR.split(separator: "*") {
                if self.indexPath > 0 {
                    cell.detail_label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
                    cell.mainView.bgColor = UIColor.white
                } else {
                    cell.mainView.bgColor = UIColor.init(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1)
                    cell.detail_label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
                }
                let h = heading[indexPath.row]
                cell.detail_label.text = String(h)
            }
            return cell
        }
        if collectionView == qsrCollectionView {
            if let heading = self.tbl_mis_budget_data_detail?.ALL_QSR.split(separator: "*") {
                if self.indexPath > 0 {
                    cell.detail_label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
                    cell.mainView.bgColor = UIColor.white
                } else {
                    cell.mainView.bgColor = UIColor.init(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1)
                    cell.detail_label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
                }
                let h = heading[indexPath.row]
                cell.detail_label.text = String(h)
            }
            return cell
        }
        if collectionView == weightCollectionView {
            if let heading = self.tbl_mis_budget_data_detail?.ALL_WEIGHT.split(separator: "*") {
                if self.indexPath > 0 {
                    cell.detail_label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
                    cell.mainView.bgColor = UIColor.white
                } else {
                    cell.mainView.bgColor = UIColor.init(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1)
                    cell.detail_label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
                }
                let h = heading[indexPath.row]
                cell.detail_label.text = String(h)
            }
            return cell
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: self.dateView.frame.width, height: 30);
    }
}
