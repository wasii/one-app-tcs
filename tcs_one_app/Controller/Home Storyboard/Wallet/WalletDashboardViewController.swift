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
import SDWebImage

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
    
    @IBOutlet weak var xAxisHistory: NSLayoutConstraint!
    @IBOutlet weak var yAxisConstraint: NSLayoutConstraint!
    
    //MARK: Variables
    var floaty = Floaty()
    var selected_query: String?
    var numberOfDays = 7
    
    var startday: String?
    var endday: String?
    
    var tbl_wallet_points: [tbl_wallet_points_summary]?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallet"
        self.selected_query = "Weekly"
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
        setupJSON(numberOfDays: self.numberOfDays, startday: self.startday, endday: self.endday)
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
        self.setupJSON(numberOfDays: numberOfDays, startday: startday, endday: endday)
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Custom Functions
    func layoutFAB() {
        floaty.plusColor = UIColor.white
        floaty.buttonColor = UIColor.nativeRedColor()
        floaty.buttonImage = UIImage(named: "currency")
        floaty.addItem("P2P", icon: UIImage(named: "P2P")) { item in
            let storyboard = UIStoryboard(name: "WalletRedemption", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "WalletBeneficiaryDetailsViewController") as! WalletBeneficiaryDetailsViewController
            self.navigationController?.pushViewController(controller, animated: true)
        }
        floaty.paddingX = (UIApplication.shared.keyWindow?.safeAreaInsets.right ?? 0) + 25
        floaty.paddingY = (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) + 75
        
        self.view.addSubview(floaty)
    }
    
    func setupJSON(numberOfDays: Int, startday: String?, endday: String?) {
        var previousDate = Date()// getPreviousDays(days: -numberOfDays)
        var weekly = String()
        var query = ""
        
        
        if startday == nil && endday == nil {
            previousDate = getPreviousDays(days: -numberOfDays)
            weekly = previousDate.convertDateToString(date: previousDate)
            
            query = "SELECT * FROM \(db_w_pointSummary) WHERE TRANSACTION_DATE >= '\(weekly)' AND TRANSACTION_DATE <= '\(getLocalCurrentDate())' AND EMPLOYEE_ID = '\(CURRENT_USER_LOGGED_IN_ID)'"
            
        } else {
            query = "SELECT * FROM \(db_w_pointSummary) WHERE TRANSACTION_DATE >= '\(startday!)' AND TRANSACTION_DATE <= '\(endday!)' AND EMPLOYEE_ID = '\(CURRENT_USER_LOGGED_IN_ID)'"
        }
        self.tbl_wallet_points = AppDelegate.sharedInstance.db?.read_tbl_wallet_point_summary(query: query)
        print(query)
        
        setupStackBarChart()
        setupCircularView()
    }
    private func setupStackBarChart() {
        barChart.drawBarShadowEnabled = false
        barChart.drawValueAboveBarEnabled = false
        barChart.highlightFullBarEnabled = false
        barChart.pinchZoomEnabled = false
        barChart.doubleTapToZoomEnabled = false

        let leftAxis = barChart.leftAxis
        leftAxis.axisMinimum = 0

        barChart.rightAxis.enabled = false

//        barChart.delegate = self

        let xAxis = barChart.xAxis

        xAxis.labelPosition = .top
        xAxis.granularity = 1.0

        xAxis.labelFont = UIFont.init(name: "Helvetica", size: 10)!
        barChart.legend.form = .empty
        var set = BarChartDataSet()

        var xAxisDates = [String]()
        var barChartEntries = [BarChartDataEntry]()
        
        if let points = tbl_wallet_points {
            for (index,summaryPoints) in points.enumerated() {
                let mature: Double = Double(summaryPoints.MATURE_POINTS)
                let unmature: Double = Double(summaryPoints.UNMATURE_POINTS)
                
                let yVal : [Double] = [mature, unmature]
                
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let tDate = dateFormatter.date(from: summaryPoints.TRANSACTION_DATE.dateOnly)!.monthAsStringAndDay()
                xAxisDates.append(tDate)
                
                let barchart = BarChartDataEntry(x: Double(index), yValues: yVal, data: tDate)
                barChartEntries.append(barchart)
                
            }
        }

        let formatt = CustomFormatter()
        formatt.labels = xAxisDates
        xAxis.valueFormatter = formatt
        set = BarChartDataSet(entries: barChartEntries, label: "")
        set.drawIconsEnabled = false
        set.colors = [UIColor.inprocessColor(), UIColor.approvedColor()]

        let data = BarChartData(dataSet: set)
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumFractionDigits = 0
        formatter.multiplier = 1.0
        formatter.zeroSymbol = ""
        data.setValueFont(.systemFont(ofSize: 1, weight: .light))
        data.setValueTextColor(.white)

        data.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        barChart.fitBars = true
        barChart.data = data
    }
    
    private func setupCircularView() {
        if let points = tbl_wallet_points {
            
            var total = 0
            var mature = 0
            var unmature = 0
            
            for p in points {
                total += p.MATURE_POINTS +  p.UNMATURE_POINTS
                mature += p.MATURE_POINTS
                unmature += p.UNMATURE_POINTS
            }
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
                self.totalPointCircularView.maxValue = CGFloat(total)
                self.totalPointCircularView.value = CGFloat(total)
                UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear, animations: {
                    self.redeemPointCircularView.maxValue = CGFloat(total)
                    self.redeemPointCircularView.value = CGFloat(mature)
                    UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveLinear, animations: {
                        self.remainingPointCircularView.maxValue = CGFloat(total)
                        self.remainingPointCircularView.value = CGFloat(unmature)
                    }, completion: nil)
                }, completion: nil)
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
                self.totalPointCircularView.maxValue = CGFloat(0)
                self.totalPointCircularView.value = CGFloat(0)
                UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear, animations: {
                    self.redeemPointCircularView.maxValue = CGFloat(0)
                    self.redeemPointCircularView.value = CGFloat(0)
                    UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveLinear, animations: {
                        self.remainingPointCircularView.maxValue = CGFloat(0)
                        self.remainingPointCircularView.value = CGFloat(0)
                    }, completion: nil)
                }, completion: nil)
            }, completion: nil)
        }
    }
    
    //MARK: UIButton Tapped
    @IBAction func historyBttnTapped(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "WalletHistoryViewController") as! WalletHistoryViewController
        
        if self.selected_query == "Custom Selection" {
            controller.startday = self.startday
            controller.endday   = self.endday
        }
        controller.numberOfDays = self.numberOfDays
        controller.selected_query = self.selected_query
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func sortingBtnTapped(_ sender: UIButton) {
        sortedImages.forEach { imageview in
            imageview.image = nil
        }
        if sender.tag != 0 {
            if sender.tag == 1 {
                if redeemPointCircularView.value == 0 {
                    return
                }
            } else {
                if remainingPointCircularView.value == 0 {
                    return
                }
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "WalletDetailsViewController") as! WalletDetailsViewController
            controller.points = sender.tag
            if self.selected_query == "Custom Selection" {
                controller.startday = self.startday
                controller.endday   = self.endday
            }
            controller.numberOfDays = self.numberOfDays
            controller.selected_query = self.selected_query
            self.navigationController?.pushViewController(controller, animated: true)
        }
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
        self.setupJSON(numberOfDays: numberOfDays,  startday: startday, endday: endday)
    }
    
    func dateSelection(startDate: String, endDate: String, selected_query: String) {
        self.selected_query = selected_query
        self.thisWeekBtn.setTitle(selected_query, for: .normal)
        
        self.startday = startDate
        self.endday   = endDate
        
        self.setupJSON(numberOfDays: 0, startday: startDate, endday: endDate)
    }
    
    func requestModeSelected(selected_query: String) {}
}
