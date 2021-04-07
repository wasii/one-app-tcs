//
//  FulfilmentDashboardViewController.swift
//  tcs_one_app
//
//  Created by TCS on 25/03/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import Charts
import MBCircularProgressBar

class FulfilmentDashboardViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var this_week: UIButton!
    @IBOutlet weak var barChart: BarChartView!
    
    @IBOutlet var sortedImages: [UIImageView]!
    @IBOutlet weak var pending_circular_view: MBCircularProgressBarView!
    @IBOutlet weak var inprocess_circular_view: MBCircularProgressBarView!
    @IBOutlet weak var readytodeliver_circular_view: MBCircularProgressBarView!
    
    var ticket_status: String = "Pending"
    var number_of_days: String = "7"
    
    var start_day: String = ""
    var end_day: String = ""
    
    
    var conditions = ""
    var selected_query: String?
    
    var DateLabels: [String] = []
    
    var fulfilment_orders: [tbl_fulfilments_order]?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Fulfilment"
        addDoubleNavigationButtons()
        self.makeTopCornersRounded(roundView: self.mainView)
        self.selected_query = "Weekly"
    }
    override func viewDidAppear(_ animated: Bool) {
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
        setupJSON()
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
        self.setupJSON()
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupJSON() {
        var query = ""
        
        var pendingCounter :Double = 0
        var inProcessCounter :Double = 0
        var readyToSubmitCounter :Double = 0
        var numberOfOrders = 0
        var orderIdQuery = ""
        if start_day == "" && end_day == "" {
            let previousDate = getPreviousDays(days: -Int(number_of_days)!)
            let weekly = previousDate.convertDateToString(date: previousDate)
            orderIdQuery = "SELECT DISTINCT ORDER_ID FROM \(db_fulfilment_orders) WHERE CREATE_AT >= '\(weekly)' AND CREATE_AT <= '\(getLocalCurrentDate())' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
        } else {
            orderIdQuery = "SELECT DISTINCT ORDER_ID FROM \(db_fulfilment_orders) WHERE CREATE_AT >= '\(start_day)' AND CREATE_AT <= '\(end_day)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
        }
        if let idCount = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orderId(query: orderIdQuery)?.count {
            numberOfOrders = idCount
        }
        if let ids = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orderId(query: orderIdQuery) {
            for id in ids {
                if start_day == "" && end_day == "" {
                    let previousDate = getPreviousDays(days: -Int(number_of_days)!)
                    let weekly = previousDate.convertDateToString(date: previousDate)
                    
                    query = "SELECT * FROM \(db_fulfilment_orders) WHERE CREATE_AT >= '\(weekly)' AND CREATE_AT <= '\(getLocalCurrentDate())' AND ORDER_ID = '\(id)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
                } else {
                    query = "SELECT * FROM \(db_fulfilment_orders) WHERE CREATE_AT >= '\(start_day)' AND CREATE_AT <= '\(end_day)' AND ORDER_ID = '\(id)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
                }
                let orders = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orders(query: query)
                var p = 0
                var r = 0
                let count = orders?.count
                for order in orders! {
                    switch order.ITEM_STATUS {
                    case "Pending":
                        p += 1
                    case "Received":
                        r += 1
                        break
                    default:
                        break
                    }
                }
                if p == count {
                    pendingCounter += 1
                } else if r == count {
                    readyToSubmitCounter += 1
                } else {
                    inProcessCounter += 1
                }
            }
            setupCircularViews(totalOrders: numberOfOrders,
                               pCounter: pendingCounter,
                               rCounter: readyToSubmitCounter,
                               iCounter: inProcessCounter)
            setupStackBarChart()
            self.fulfilment_orders = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orders(query: "SELECT * FROM \(db_fulfilment_orders) WHERE CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'")
        } else {
            self.fulfilment_orders = nil
        }
    }
    
    private func setupCircularViews(totalOrders: Int, pCounter: Double, rCounter: Double, iCounter: Double) {
        self.pending_circular_view.maxValue = CGFloat(totalOrders)
        self.inprocess_circular_view.maxValue = CGFloat(totalOrders)
        self.readytodeliver_circular_view.maxValue = CGFloat(totalOrders)
        
        UIView.animate(withDuration: 0.5) {
            self.pending_circular_view.value = CGFloat(pCounter)
            self.inprocess_circular_view.value = CGFloat(iCounter)
            self.readytodeliver_circular_view.value = CGFloat(rCounter)
        }
    }
    private func setupStackBarChart() {
        var getTicketsAccordingDates = ""
        var query = ""
        var orderIdQuery = ""
        if start_day == "" && end_day == "" {
            let previousDate = getPreviousDays(days: -Int(number_of_days)!)
            let weekly = previousDate.convertDateToString(date: previousDate)
            query = "SELECT strftime('%Y-%m-%d',CREATE_AT) as date FROM \(db_fulfilment_orders) WHERE CREATE_AT >= '\(weekly)' AND CREATE_AT <= '\(getLocalCurrentDate())' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' group by strftime('%Y-%m-%d',CREATE_AT)"
            
            orderIdQuery = "SELECT DISTINCT ORDER_ID FROM \(db_fulfilment_orders) WHERE CREATE_AT >= '\(weekly)' AND CREATE_AT <= '\(getLocalCurrentDate())' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
        } else {
            query = "SELECT strftime('%Y-%m-%d',CREATE_AT) as date FROM \(db_fulfilment_orders) WHERE CREATE_AT >= '\(start_day)' AND CREATE_AT <= '\(end_day))' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' group by strftime('%Y-%m-%d',CREATE_AT)"
            
            orderIdQuery = "SELECT DISTINCT ORDER_ID FROM \(db_fulfilment_orders) WHERE CREATE_AT >= '\(start_day)' AND CREATE_AT <= '\(end_day))' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
        }
        
        if var ticket_dates = AppDelegate.sharedInstance.db?.getDates(query: query) {
            ticket_dates = ticket_dates.sorted(by: { (d1, d2) -> Bool in
                d1 < d2
            })
            
            if let ids = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orderId(query: orderIdQuery) {
                var xAxisDates = [String]()
                var pendingCounter :Double = 0
                var inProcessCounter :Double = 0
                var readyToSubmitCounter :Double = 0
                var barChartEntries = [BarChartDataEntry]()
                let xAxis = barChart.xAxis
                var set = BarChartDataSet()
                
                barChart.drawBarShadowEnabled = false
                barChart.drawValueAboveBarEnabled = false
                barChart.highlightFullBarEnabled = false
                barChart.pinchZoomEnabled = false
                barChart.doubleTapToZoomEnabled = false
                
                let leftAxis = barChart.leftAxis
                leftAxis.axisMinimum = 0
                
                barChart.rightAxis.enabled = false
                
                xAxis.labelPosition = .top
                xAxis.granularity = 1.0
                
                xAxis.labelFont = UIFont.init(name: "Helvetica", size: 10)!
                barChart.legend.form = .empty
                
                for (index,date) in ticket_dates.enumerated() {
                    for id in ids {
                        var p = 0
                        var r = 0
                        
                        getTicketsAccordingDates = "SELECT * FROM \(db_fulfilment_orders) WHERE strftime('%Y-%m-%d',CREATE_AT) = '\(date)' AND  ORDER_ID = '\(id)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
                        if let orders = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orders(query: getTicketsAccordingDates) {
                            if orders.count > 0 {
                                let count = orders.count
                                for o in orders {
                                    switch o.ITEM_STATUS {
                                    case "Pending":
                                        p += 1
                                    case "Received":
                                        r += 1
                                        break
                                    default:
                                        break
                                    }
                                }
                                if p == count {
                                    pendingCounter += 1
                                } else if r == count {
                                    readyToSubmitCounter += 1
                                } else {
                                    inProcessCounter += 1
                                }
                            }
                        }
                    }
                    let yVal : [Double] = [Double(pendingCounter), Double(inProcessCounter), Double(readyToSubmitCounter)]
                    
                    let barchart = BarChartDataEntry(x: Double(index), yValues: yVal, data: date)
                    barChartEntries.append(barchart)
                    pendingCounter = 0
                    readyToSubmitCounter = 0
                    inProcessCounter = 0
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let tDate = dateFormatter.date(from: date)!.monthAsStringAndDay()
                    xAxisDates.append(tDate)
                }
                let formatt = CustomFormatter()
                formatt.labels = xAxisDates
                xAxis.valueFormatter = formatt
                set = BarChartDataSet(entries: barChartEntries, label: "")
                set.drawIconsEnabled = false
                set.colors = [UIColor.pendingColor(), UIColor.inprocessColor(), UIColor.approvedColor()]
                
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
        }
    }
    
    @IBAction func scanBarCodeTapped(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "scanNavController") as! UINavigationController
        (controller.children.first as! ScanFulfillmentViewController).fulfilment_orders = self.fulfilment_orders

        (controller.children.first as! ScanFulfillmentViewController).delegate = self
        (controller.children.first as! ScanFulfillmentViewController).start_day = start_day
        (controller.children.first as! ScanFulfillmentViewController).end_day = end_day
        (controller.children.first as! ScanFulfillmentViewController).numberOfDays = number_of_days
        
        controller.modalTransitionStyle = .crossDissolve
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        present(controller, animated: true, completion: nil)
    }
    @IBAction func openListing(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "FulfilmentListingViewController") as! FulfilmentListingViewController
        controller.numberOfDays = self.number_of_days
        if self.number_of_days == "7" {
            
        }
        switch self.number_of_days {
        case "7":
            controller.numberOfDaysSorting = "This Week"
            break
        case "15":
            controller.numberOfDaysSorting = "15 Days"
            break
        case "30":
            controller.numberOfDaysSorting = "Monthly"
            break
        case "0":
            controller.numberOfDaysSorting = "Custom Selection"
            controller.start_day = self.start_day
            controller.end_day = self.end_day
            break
        default:
            break
        }
        
        switch sender.tag {
        case 0:
            controller.ticket_status = "Pending"
            controller.ticket_status_sorting = "Pending"
            break
        case 1:
            controller.ticket_status = "In Process"
            controller.ticket_status_sorting = "Received"
            break
        case 2:
            controller.ticket_status = "Ready to Deliver"
            controller.ticket_status_sorting = ""
            break
        default:
            break
        }
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func this_weekTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Popups", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "FilterDataPopupViewController") as! FilterDataPopupViewController
        
        if self.selected_query == "Custom Selection" {
            controller.fromdate = self.start_day
            controller.todate   = self.end_day
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


//MARK: DateSelection Delegate
extension FulfilmentDashboardViewController: DateSelectionDelegate {
    func dateSelection(numberOfDays: Int, selected_query: String) {
        self.selected_query = selected_query
        self.this_week.setTitle(selected_query, for: .normal)
        
        self.start_day = ""
        self.end_day = ""
        
        self.number_of_days = "\(numberOfDays)"
        self.setupJSON()
    }
    
    func dateSelection(startDate: String, endDate: String, selected_query: String) {
        self.selected_query = selected_query
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss"
        let sDate = dateFormatter.date(from: startDate)
        let eDate = dateFormatter.date(from: endDate)
        
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        let sDateS = dateFormatter.string(from: sDate ?? Date())
        let eDateS = dateFormatter.string(from: eDate ?? Date())
        
        self.this_week.setTitle("\(sDateS) TO \(eDateS)", for: .normal)
        
        self.start_day = startDate
        self.end_day   = endDate
        
        self.number_of_days = "0"
        self.setupJSON()
    }
    
    func requestModeSelected(selected_query: String) {}
}




extension FulfilmentDashboardViewController: ScanFulfillmentProtocol {
    func didScanCode(code: String, isBucket: Bool, CN: String) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "FulfilmentOrderDetailViewController") as! FulfilmentOrderDetailViewController
        
        
        controller.orderId = code
        controller.isNavigateFromDashboard = true
        controller.cnsg_no = CN
        self.navigationController?.pushViewController(controller, animated: true)
    }
    func didScanOrder(orders: [tbl_fulfilments_order]) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "FulfilmentOrderDetailViewController") as! FulfilmentOrderDetailViewController
        controller.fulfilment_orders = orders
        controller.isNavigateFromDashboard = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
