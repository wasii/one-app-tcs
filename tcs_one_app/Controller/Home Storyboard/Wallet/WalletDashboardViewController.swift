//
//  WalletDashboardViewController.swift
//  tcs_one_app
//
//  Created by TCS on 16/06/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import MBCircularProgressBar
import Charts
import Floaty

class WalletDashboardViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var thisWeekBtn: UIButton!
    
    @IBOutlet weak var totalPointCircularView: MBCircularProgressBarView!
    @IBOutlet weak var redeemPointCircularView: MBCircularProgressBarView!
    @IBOutlet weak var remainingPointCircularView: MBCircularProgressBarView!
    
    @IBOutlet weak var matureView: UIView!
    @IBOutlet weak var matureDate: UILabel!
    @IBOutlet weak var maturePoints: UILabel!
    
    @IBOutlet weak var unmatureView: UIView!
    @IBOutlet weak var unmatureDate: UILabel!
    @IBOutlet weak var unmaturePoints: UILabel!
    
    @IBOutlet var sortedImages: [UIImageView]!
    @IBOutlet var sortedButton: [UIButton]!
    var floaty = Floaty()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallet"
        self.makeTopCornersRounded(roundView: self.mainView)
        layoutFAB()
    }
    
    func layoutFAB() {
        floaty.plusColor = UIColor.white
        floaty.buttonColor = UIColor.nativeRedColor()
        floaty.buttonImage = UIImage(named: "currency")
        
        
        floaty.paddingX = (UIApplication.shared.keyWindow?.safeAreaInsets.right ?? 0) + 25
        floaty.paddingY = (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) + 75
        
        self.view.addSubview(floaty)
    }
    
    @IBAction func sortingBtnTapped(_ sender: UIButton) {
        sortedImages.forEach { imageview in
            imageview.image = nil
        }
        self.matureView.isHidden = true
        self.unmatureView.isHidden = true
        switch sender.tag {
        case 0:
            if sender.isSelected {
                sortedImages[0].image = UIImage(named: "rightY")
                self.matureView.isHidden = false
                self.unmatureView.isHidden = false
            } else {
                self.matureView.isHidden = true
                self.unmatureView.isHidden = true
            }
            return
        case 1:
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "WalletDetailsViewController") as! WalletDetailsViewController
            self.navigationController?.pushViewController(controller, animated: true)
            break
        case 2:
            break
        default:
            break
        }
    }
    
}
