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
    
    @IBOutlet var sortedImages: [UIImageView]!
    @IBOutlet var sortedButton: [UIButton]!
    
    
    //MARK: Variables
    var floaty = Floaty()
    var selected_query: String?
    var numberOfDays = 7
    
    var startday: String?
    var endday: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallet"
        self.makeTopCornersRounded(roundView: self.mainView)
        layoutFAB()
        addDoubleNavigationButtons()
    }
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(upload_pending_request), name: .networkRefreshed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshedView(notification:)), name: .refreshedViews, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigateThroughtNotify(notification:)), name: .navigateThroughNotification, object: nil)
        self.navigationItem.rightBarButtonItems = nil
        addDoubleNavigationButtons()
        
        if let btn = self.navigationItem.rightBarButtonItems?.first {
            let count = getNotificationCounts()
            if count > 0 {
                btn.addBadge(num: count)
            } else {
                btn.removeBadge()
            }
        }
//        setupJSON(numberOfDays: self.numberOfDays, startday: self.startday, endday: self.endday)
    }
    @objc func refreshedView(notification: Notification) {
        self.navigationItem.rightBarButtonItems = nil
        addDoubleNavigationButtons()
        
        
        if let btn = self.navigationItem.rightBarButtonItems?.first {
            let count = getNotificationCounts()
            if count > 0 {
                btn.addBadge(num: count)
            } else {
                btn.removeBadge()
            }
        }
//        self.setupJSON(numberOfDays: numberOfDays, startday: startday, endday: endday)
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func layoutFAB() {
        floaty.plusColor = UIColor.white
        floaty.buttonColor = UIColor.nativeRedColor()
        floaty.buttonImage = UIImage(named: "currency")
        
        
        floaty.paddingX = (UIApplication.shared.keyWindow?.safeAreaInsets.right ?? 0) + 25
        floaty.paddingY = (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) + 75
        
        self.view.addSubview(floaty)
    }
    
    @IBAction func historyBttnTapped(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "WalletHistoryViewController") as! WalletHistoryViewController
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func sortingBtnTapped(_ sender: UIButton) {
        sortedImages.forEach { imageview in
            imageview.image = nil
        }
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "WalletDetailsViewController") as! WalletDetailsViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func thisWeekBtnTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Popups", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "FilterDataPopupViewController") as! FilterDataPopupViewController
        
        if self.selected_query == "Custom Selection" {
            controller.fromdate = self.startday
            controller.todate   = self.endday
        }
        controller.selected_query = self.selected_query
        controller.delegate = self
        controller.modalTransitionStyle = .crossDissolve
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        
        Helper.topMostController().present(controller, animated: true, completion: nil)
    }
}


extension WalletDashboardViewController: DateSelectionDelegate {
    func dateSelection(numberOfDays: Int, selected_query: String) {
        self.selected_query = selected_query
        self.thisWeekBtn.setTitle(selected_query, for: .normal)
        
        self.startday = nil
        self.endday = nil
        
        self.numberOfDays = numberOfDays
//        self.setupJSON(numberOfDays: numberOfDays,  startday: startday, endday: endday)
    }
    
    func dateSelection(startDate: String, endDate: String, selected_query: String) {
        self.selected_query = selected_query
        self.thisWeekBtn.setTitle(selected_query, for: .normal)
        
        self.startday = startDate
        self.endday   = endDate
        
//        self.setupJSON(numberOfDays: 0, startday: startDate, endday: endDate)
    }
    
    func requestModeSelected(selected_query: String) {}
}
