//
//  LeadershipListingViewController.swift
//  tcs_one_app
//
//  Created by TCS on 25/02/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import Charts
import MBCircularProgressBar

class LeadershipListingViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var search_textfield: UITextField!
    
    @IBOutlet weak var this_week_btn: UIButton!
    @IBOutlet weak var barChartView: BarChartView!
    
    @IBOutlet weak var pending_circular_view: MBCircularProgressBarView!
    @IBOutlet weak var approved_circular_view: MBCircularProgressBarView!
    @IBOutlet weak var rejected_circular_view: MBCircularProgressBarView!
    
    @IBOutlet var sortedImages: [UIImageView]!
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filteredTableView: UITableView!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var filteredTableviewHeightConstraint: NSLayoutConstraint!
    
    //MARK: Variables
    var isFiltered = false
    
    var isLoadFilteredData = false
    
    var user_permission_table_list: [UserPermssionsTableList]?
    var tbl_request_logs: [tbl_Hr_Request_Logs]?
    var filtered_data: [tbl_Hr_Request_Logs]?
    var date_specific_tbl_request_logs: [tbl_Hr_Request_Logs]?
    
    
    var conditions = ""
    var selected_query: String?
    var numberOfDays = 7
    var filterType = "Self"
    var indexPath: IndexPath?
    var startday: String?
    var endday: String?
    var DateLabels: [String] = []
    
    var stackBarChartDate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeTopCornersRounded(roundView: self.mainView)
        self.title = "Leadership Connect"
        self.selected_query = "Weekly"
        self.tableView.register(UINib(nibName: "RequestListingTableCell", bundle: nil), forCellReuseIdentifier: "RequestListingCell")
        self.tableView.rowHeight = 80
        
        self.filteredTableView.register(UINib(nibName: "RequestListingTableCell", bundle: nil), forCellReuseIdentifier: "RequestListingCell")
        self.filteredTableView.rowHeight = 80
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
    
    
    private func setupJSON(numberOfDays: Int, startday: String?, endday: String?) {
        var query = ""
        
        if startday == nil && endday == nil {
            let previousDate = getPreviousDays(days: -numberOfDays)
            let weekly = previousDate.convertDateToString(date: previousDate)
            
            
            query = "SELECT * FROM REQUEST_LOGS WHERE CREATED_DATE >= '\(weekly)' AND CREATED_DATE <= '\(getLocalCurrentDate())' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' order by CREATED_DATE DESC LIMIT 0,50"
        } else {
            query = "SELECT * FROM REQUEST_LOGS WHERE CREATED_DATE >= '\(startday!)' AND CREATED_DATE <= '\(endday!)' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = \(CURRENT_USER_LOGGED_IN_ID) order by CREATED_DATE DESC LIMIT 0,50"
        }
        
        tbl_request_logs = AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: query)
        setupStackBarChart()
        setupCircularView()
        self.tableView.reloadData()
        self.filteredTableView.reloadData()
        
        if self.filteredTableviewHeightConstraint.constant != 0 {
            self.mainViewHeightConstraint.constant -= self.filteredTableviewHeightConstraint.constant
            self.filteredTableviewHeightConstraint.constant = 0
            self.getDateSpecificWiseRecords(date: self.stackBarChartDate)
        }
        
        
        self.mainViewHeightConstraint.constant -= self.tableViewHeightConstraint.constant
        self.tableViewHeightConstraint.constant = 0
        self.tableViewHeightConstraint.constant = CGFloat((self.tbl_request_logs!.count * 80) + 50)
        self.mainViewHeightConstraint.constant +=  self.tableViewHeightConstraint.constant
    }
    func setupCircularView() {
        if let data = self.tbl_request_logs {
            let pendingCount = data.filter({ (logs) -> Bool in
                logs.TICKET_STATUS == "Pending" || logs.TICKET_STATUS == "pending"
                }).count
            let approvedCount = data.filter({ (logs) -> Bool in
                logs.TICKET_STATUS == "Approved" || logs.TICKET_STATUS == "approved"
            }).count
            let rejectedCount = data.filter({ (logs) -> Bool in
                logs.TICKET_STATUS == "Rejected" || logs.TICKET_STATUS == "rejected"
            }).count
            
            self.pending_circular_view.maxValue = CGFloat(data.count)
            self.approved_circular_view.maxValue = CGFloat(data.count)
            self.rejected_circular_view.maxValue = CGFloat(data.count)
            UIView.animate(withDuration: 0.5) {
            self.pending_circular_view.value = CGFloat(pendingCount)
            self.approved_circular_view.value = CGFloat(approvedCount)
            self.rejected_circular_view.value = CGFloat(rejectedCount)
            }
        }
    }
    func setupStackBarChart() {
        var previousDate = Date()// getPreviousDays(days: -numberOfDays)
        var weekly = String()
        var getDatesQuery = ""
        var getTicketsAccordingDates = ""
        
        if startday == nil && endday == nil {
            previousDate = getPreviousDays(days: -numberOfDays)
            weekly = previousDate.convertDateToString(date: previousDate)
            
            getDatesQuery = "SELECT strftime('%Y-%m-%d',CREATED_DATE) as date FROM \(db_hr_request) WHERE  CREATED_DATE >= '\(weekly)' AND CREATED_DATE <= '\(getLocalCurrentDate())' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' group by strftime('%Y-%m-%d',CREATED_DATE)"
            
            getTicketsAccordingDates = "SELECT TICKET_STATUS , count(ID) as totalCount, strftime('%Y-%m-%d',CREATED_DATE) as date FROM \(db_hr_request) WHERE  CREATED_DATE >= '\(weekly)' AND CREATED_DATE <= '\(getLocalCurrentDate())' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' group by  ticket_status , date"
        } else {
            getDatesQuery = "SELECT strftime('%Y-%m-%d',CREATED_DATE) as date FROM \(db_hr_request) WHERE  CREATED_DATE >= '\(self.startday!)' AND CREATED_DATE <= '\(self.endday!)' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' group by strftime('%Y-%m-%d',CREATED_DATE)"
            
            getTicketsAccordingDates = "SELECT TICKET_STATUS , count(ID) as totalCount, strftime('%Y-%m-%d',CREATED_DATE) as date FROM \(db_hr_request) WHERE  CREATED_DATE >= '\(self.startday!)' AND CREATED_DATE <= '\(self.endday!)' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' group by  ticket_status , date"
        }
        
        let dates = AppDelegate.sharedInstance.db?.getDates(query: getDatesQuery).sorted(by: { (date1, date2) -> Bool in
            date1 > date2
        })
        let tickets = AppDelegate.sharedInstance.db?.getBarGraphCounts(query: getTicketsAccordingDates).sorted(by: { (g1, g2) -> Bool in
            g1.ticket_date! > g2.ticket_date!
        })
        
        barChartView.drawBarShadowEnabled = false
        barChartView.drawValueAboveBarEnabled = false
        barChartView.highlightFullBarEnabled = false
        barChartView.pinchZoomEnabled = false
        barChartView.doubleTapToZoomEnabled = false
        
        let leftAxis = barChartView.leftAxis
        leftAxis.axisMinimum = 0
        
        barChartView.rightAxis.enabled = false
        barChartView.delegate = self
        
        let xAxis = barChartView.xAxis
        
        xAxis.labelPosition = .top
        xAxis.granularity = 1.0
        
        xAxis.labelFont = UIFont.init(name: "Helvetica", size: 10)!
        barChartView.legend.form = .empty
        var set = BarChartDataSet()

        var xAxisDates = [String]()
        
        
        var pendingCounter = 0
        var approvedCounter = 0
        var rejectedCounter = 0
        var barChartEntries = [BarChartDataEntry]()
        for (index,date) in dates!.enumerated() {
            let ticket = tickets?.filter({ (GraphTotalCount) -> Bool in
                GraphTotalCount.ticket_date == date
            })
            for t in ticket! {
                switch t.ticket_status {
                case "Pending", "pending":
                    pendingCounter += Int(t.ticket_total!)!
                    break
                case "Approved", "approved":
                    approvedCounter += Int(t.ticket_total!)!
                    break
                case "Rejected", "rejected":
                    rejectedCounter += Int(t.ticket_total!)!
                    break
                default:
                    break
                }
            }
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let tDate = dateFormatter.date(from: date)!.monthAsStringAndDay()
            xAxisDates.append(tDate)
            let yVal : [Double] = [Double(pendingCounter), Double(approvedCounter), Double(rejectedCounter)]

            let barchart = BarChartDataEntry(x: Double(index), yValues: yVal, data: date)
            barChartEntries.append(barchart)
            pendingCounter = 0
            approvedCounter = 0
            rejectedCounter = 0
        }
        
        let formatt = CustomFormatter()
        formatt.labels = xAxisDates
        xAxis.valueFormatter = formatt
        set = BarChartDataSet(entries: barChartEntries, label: nil)
        set.drawIconsEnabled = false
        set.colors = [UIColor.pendingColor(), UIColor.approvedColor(), UIColor.rejectedColor()]
        
        let data = BarChartData(dataSet: set)
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumFractionDigits = 0
        formatter.multiplier = 1.0
        formatter.zeroSymbol = ""
        data.setValueFont(.systemFont(ofSize: 1, weight: .light))
        data.setValueTextColor(.white)
        
        data.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        barChartView.fitBars = true
        barChartView.data = data
    }
    //MARK: Custom Functions ENDS
    
    
    @IBAction func thisWeekBtn_Tapped(_ sender: Any) {
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
    @IBAction func newRequestTapped(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "NewRequestLeadershipAwazViewController") as! NewRequestLeadershipAwazViewController
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension LeadershipListingViewController: DateSelectionDelegate {
    func requestModeSelected(selected_query: String) {}
    
    func dateSelection(numberOfDays: Int, selected_query: String) {
        self.selected_query = selected_query
        self.numberOfDays = numberOfDays
        self.this_week_btn.setTitle(selected_query, for: .normal)
        
        self.startday = nil
        self.endday = nil
        
        self.setupJSON(numberOfDays: numberOfDays,  startday: nil, endday: nil)
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
        
        
        self.this_week_btn.setTitle("\(sDateS) TO \(eDateS)", for: .normal)
        
        self.startday = startDate
        self.endday = endDate
        self.setupJSON(numberOfDays: 0, startday: startDate, endday: endDate)
    }
}

extension LeadershipListingViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(highlight)
        NSLog("chartValueSelected");
        
        let date = entry.data as! String
        self.stackBarChartDate = date
        self.getDateSpecificWiseRecords(date: date)
    }
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: Highlight) {
        print("Bar selected")
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        NSLog("chartValueNothingSelected");
        self.mainViewHeightConstraint.constant -= self.filteredTableviewHeightConstraint.constant
        self.filteredTableviewHeightConstraint.constant = 0
        self.stackBarChartDate = ""
    }
    
    func getDateSpecificWiseRecords(date: String) {
        let query = "SELECT * FROM REQUEST_LOGS WHERE CREATED_DATE >= '\(date)T00:00:00' AND CREATED_DATE <= '\(date)T23:59:59' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' order by CREATED_DATE DESC LIMIT 0,50"
        self.date_specific_tbl_request_logs = AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: query).filter({ (logs) -> Bool in
            logs.MODULE_ID! == CONSTANT_MODULE_ID
        })
        isLoadFilteredData = true
        
        if self.filteredTableviewHeightConstraint.constant != 0 {
            self.mainViewHeightConstraint.constant -= self.filteredTableviewHeightConstraint.constant
        }
        
        self.filteredTableView.reloadData()
        
        self.filteredTableviewHeightConstraint.constant = 0
        self.filteredTableviewHeightConstraint.constant = CGFloat(self.date_specific_tbl_request_logs!.count * 80) + 10
        self.mainViewHeightConstraint.constant += self.filteredTableviewHeightConstraint.constant
    }
}




extension LeadershipListingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            if isFiltered {
                if let count = self.filtered_data?.count {
                    return count
                }
                return 0
            } else {
                if let count = tbl_request_logs?.count {
                    return count
                }
                return 0
            }
        } else {
            if isLoadFilteredData {
                if let count = date_specific_tbl_request_logs?.count {
                    return count
                }
                return 0
            }
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoadFilteredData {
            if tableView == self.filteredTableView {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RequestListingCell") as! RequestListingTableCell
                let data = self.date_specific_tbl_request_logs![indexPath.row]
                cell.mainHeading.text = data.REQ_REMARKS!
                cell.subHeading.text = data.HR_REMARKS!
                cell.date.text = data.CREATED_DATE?.dateSeperateWithT ?? ""
                
                if data.TICKET_STATUS == "Pending" || data.TICKET_STATUS == "pending" {
                    cell.status.text = "Pending"
                    cell.status.textColor = UIColor.pendingColor()
                } else if data.TICKET_STATUS == "Approved" || data.TICKET_STATUS == "approved" {
                    cell.status.text = "Completed"
                    cell.status.textColor = UIColor.approvedColor()
                } else {
                    cell.status.text = "Rejected"
                    cell.status.textColor = UIColor.rejectedColor()
                }
                
                cell.type.text = "Leadership Awaz"
                return cell
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestListingCell") as! RequestListingTableCell
        
        var data : tbl_Hr_Request_Logs?
        
        if isFiltered {
            data = self.filtered_data![indexPath.row]
        } else {
            data = self.tbl_request_logs![indexPath.row]
        }
        cell.mainHeading.text = data!.REQ_REMARKS!
        cell.subHeading.text = data!.HR_REMARKS!
        cell.date.text = data!.CREATED_DATE?.dateSeperateWithT ?? ""
        
        if data!.TICKET_STATUS == "Pending" || data!.TICKET_STATUS == "pending" {
            cell.status.text = "Pending"
            cell.status.textColor = UIColor.pendingColor()
        } else if data!.TICKET_STATUS == "Approved" || data!.TICKET_STATUS == "approved" {
            cell.status.text = "Completed"
            cell.status.textColor = UIColor.approvedColor()
        } else {
            cell.status.text = "Rejected"
            cell.status.textColor = UIColor.rejectedColor()
        }
        
        cell.type.text = "Leadership Awaz"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.indexPath = indexPath
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "NewRequestLeadershipAwazViewController") as! NewRequestLeadershipAwazViewController
        var data: tbl_Hr_Request_Logs?
        
        if isFiltered {
            data = self.filtered_data![indexPath.row]
        } else {
            data = self.tbl_request_logs![indexPath.row]
        }
        
        controller.ticket_id = data!.SERVER_ID_PK
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
