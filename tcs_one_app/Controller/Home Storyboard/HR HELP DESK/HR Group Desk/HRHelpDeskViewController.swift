//
//  HRHelpDeskViewController.swift
//  tcs_one_app
//
//  Created by ibs on 19/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import Floaty
import Charts
import MBCircularProgressBar

class HRHelpDeskViewController: BaseViewController, ChartViewDelegate {
//RequestType View
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var requestTypeView: CustomView!
    @IBOutlet weak var allRequestBtn: UIButton!
    
    //tableviews
    @IBOutlet weak var filteredTableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var permissionsTableView: UITableView!
    
    //height constraints
    @IBOutlet weak var requestTypeBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var permissionTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var filteredViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var stackBarChart: BarChartView!
    @IBOutlet weak var pendingCircularView: MBCircularProgressBarView!
    @IBOutlet weak var acceptedCircularView: MBCircularProgressBarView!
    @IBOutlet weak var rejectedCircularView: MBCircularProgressBarView!
    
    @IBOutlet weak var filter_btn: UIButton!
    
   
    @IBOutlet var sortingBtnsHighlighter : [UIImageView]!
    
    
    var floaty = Floaty()
    var isLoadFilteredData = false
    
    var isFiltered = false
    var selected_query: String?
    var numberOfDays = 7
    var filterType = "Self"
    
    var user_permission_table_list: [UserPermssionsTableList]?
    var tbl_request_logs: [tbl_Hr_Request_Logs]?
    var filtered_data: [tbl_Hr_Request_Logs]?
    var date_specific_tbl_request_logs: [tbl_Hr_Request_Logs]?
    
    
    
    var conditions = ""
    var tempConstantHeight: CGFloat = 730.0
    
    var indexPath: IndexPath?
    
    var startday: String?
    var endday: String?
    
    
    var DateLabels: [String] = []
    
    var stackBarChartDate = ""
    override func viewDidAppear(_ animated: Bool) {
        if indexPath != nil {
            self.tableView.deselectRow(at: indexPath!, animated: true)
        }
        self.tempConstantHeight = self.mainViewHeightConstraint.constant
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "HR Help Desk"

        self.makeTopCornersRounded(roundView: self.mainView)
        
        self.searchTextField.delegate = self
        
        self.selected_query = "Weekly"
        setupPermissions()

        self.tableView.register(UINib(nibName: "RequestListingTableCell", bundle: nil), forCellReuseIdentifier: "RequestListingCell")
        self.tableView.rowHeight = 100
        
        self.filteredTableView.register(UINib(nibName: "RequestListingTableCell", bundle: nil), forCellReuseIdentifier: "RequestListingCell")
        self.filteredTableView.rowHeight = 100
        
        self.permissionsTableView.register(UINib(nibName: "ModulePermissionsTableCell", bundle: nil), forCellReuseIdentifier: "ModulePermissionsCell")
        self.permissionsTableView.rowHeight = 70
        
        self.searchTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
    }
    
    
    @objc func textFieldDidChange(textField: UITextField) {
        if textField.text!.count == 0 {
            self.mainViewHeightConstraint.constant = self.tempConstantHeight
            self.setupJSON(numberOfDays: numberOfDays, startday: startday, endday: endday)
        }
    }
    
    func setupPermissions() {
        let listing_all_filter_count = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: PERMISSION_HR_LISTING_ALL_FILTER).count
        let listing_responsible_bar_count = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: PERMISSION_HR_LISTING_RESPONSIBLE_BAR).count
        let listing_management_bar_count  = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: PERMISSION_HR_LISTING_MANAGEMENT_BAR).count
        
        
        user_permission_table_list = [UserPermssionsTableList]()
        if listing_all_filter_count! > 0 {
            self.filterType = "All"
            self.allRequestBtn.setTitle("All Requests", for: .normal)
            requestTypeBottomConstraint.constant = 70
            requestTypeView.isHidden = false
        }
        
        //HRMOnitoring -> NewChartListing
        
        if listing_responsible_bar_count! > 0 && listing_management_bar_count! > 0 {
            user_permission_table_list?.append(UserPermssionsTableList(title: "HR Help Desk", imageName: "helpdesk"))
            user_permission_table_list?.append(UserPermssionsTableList(title: "Help Desk Monitoring", imageName: "helpdesk"))
        }
        
        if listing_responsible_bar_count! > 0 {
            user_permission_table_list?.append(UserPermssionsTableList(title: "HR Help Desk", imageName: "helpdesk"))
//            requestTypeBottomConstraint.constant = 70
//            requestTypeView.isHidden = false
        }
        
        if listing_management_bar_count! > 0 {
            user_permission_table_list?.append(UserPermssionsTableList(title: "Help Desk Monitoring", imageName: "helpdesk"))
        }
        
        if let _ = self.user_permission_table_list {
            self.permissionsTableView.reloadData()
            self.permissionTableViewHeightConstraint.constant = CGFloat(self.user_permission_table_list!.count * 70) + 10// self.permissionsTableView.contentSize.height
            self.mainViewHeightConstraint.constant += self.permissionTableViewHeightConstraint.constant
        }
    }
    
    
    func setupJSON(numberOfDays: Int, startday: String?, endday: String?) {
        var previousDate = Date()// getPreviousDays(days: -numberOfDays)
        var weekly = String()
        var query = ""
        
        
        if startday == nil && endday == nil {
            previousDate = getPreviousDays(days: -numberOfDays)
            weekly = previousDate.convertDateToString(date: previousDate)
            
            query = "SELECT * FROM REQUEST_LOGS WHERE CREATED_DATE >= '\(weekly)' AND CREATED_DATE <= '\(getLocalCurrentDate())' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'\(getFilterType()) order by CREATED_DATE DESC LIMIT 0,50"
        } else {
            query = "SELECT * FROM REQUEST_LOGS WHERE CREATED_DATE >= '\(startday!)' AND CREATED_DATE <= '\(endday!)' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = \(CURRENT_USER_LOGGED_IN_ID)\(getFilterType()) order by CREATED_DATE DESC LIMIT 0,50"
        }
        
        tbl_request_logs = AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: query)
        setupStackBarChart()
        setupCircularView()
        
        self.tableView.reloadData()
        self.filteredTableView.reloadData()
        
        if self.filteredViewHeightConstraint.constant != 0 {
            self.mainViewHeightConstraint.constant -= self.filteredViewHeightConstraint.constant
            self.filteredViewHeightConstraint.constant = 0
            self.getDateSpecificWiseRecords(date: self.stackBarChartDate)
        }
        
        setupHeightView()
        
    }
    func setupHeightView() {
        self.mainViewHeightConstraint.constant -= self.tableViewHeightConstraint.constant
        self.tableViewHeightConstraint.constant = 0
        self.tableViewHeightConstraint.constant = CGFloat((self.tbl_request_logs!.count * 100) + 20)
        self.mainViewHeightConstraint.constant +=  self.tableViewHeightConstraint.constant
        
        switch UIDevice().type {
        case .iPhone5, .iPhone5S, .iPhone5C, .iPhoneSE:
            if self.mainViewHeightConstraint.constant < 585 {
                self.mainViewHeightConstraint.constant = 585
            }
            break
        case .iPhone6, .iPhone6S, .iPhone7, .iPhone8, .iPhoneSE2:
            if self.mainViewHeightConstraint.constant < 690 {
                self.mainViewHeightConstraint.constant = 690
            }
            
            break
        case .iPhone6Plus, .iPhone7Plus, .iPhone8Plus:
            if self.mainViewHeightConstraint.constant < 755 {
                self.mainViewHeightConstraint.constant = 755
            }
            break
        case .iPhoneX, .iPhoneXR, .iPhoneXS, .iPhone11Pro, .iPhone12, .iPhone12Pro:
            if self.mainViewHeightConstraint.constant < 820 {
                self.mainViewHeightConstraint.constant = 820
            }
            break
        case .iPhone11, .iPhoneXSMax, .iPhone11ProMax:
            if self.mainViewHeightConstraint.constant < 870 {
                self.mainViewHeightConstraint.constant = 870
            }
            break
        case .iPhone12ProMax:
            if self.mainViewHeightConstraint.constant < 880 {
                self.mainViewHeightConstraint.constant = 880
            }
            break
        case .iPhone12Mini:
            if self.mainViewHeightConstraint.constant < 770 {
                self.mainViewHeightConstraint.constant = 770
            }
            break
        default:
            break
        }
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
            
            self.pendingCircularView.maxValue = CGFloat(data.count)
            self.acceptedCircularView.maxValue = CGFloat(data.count)
            self.rejectedCircularView.maxValue = CGFloat(data.count)
            UIView.animate(withDuration: 0.5) {
            self.pendingCircularView.value = CGFloat(pendingCount)
            self.acceptedCircularView.value = CGFloat(approvedCount)
            self.rejectedCircularView.value = CGFloat(rejectedCount)
            }
        }
    }
    
    func getFilterType() -> String {
        switch self.filterType {
        case "All":
            self.conditions = " AND (LOGIN_ID = '\(CURRENT_USER_LOGGED_IN_ID)' OR REQ_ID = '\(CURRENT_USER_LOGGED_IN_ID)')"
            break
        case "Self":
            self.conditions = " AND REQ_ID = '\(CURRENT_USER_LOGGED_IN_ID)'"
            break
        case "Others":
            self.conditions = " AND (LOGIN_ID = '\(CURRENT_USER_LOGGED_IN_ID)' AND REQ_ID != '\(CURRENT_USER_LOGGED_IN_ID)')"
            break
        default:
            break
        }
        return conditions
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
            
            getTicketsAccordingDates = "SELECT TICKET_STATUS , count(ID) as totalCount, strftime('%Y-%m-%d',CREATED_DATE) as date FROM \(db_hr_request) WHERE  CREATED_DATE >= '\(weekly)' AND CREATED_DATE <= '\(getLocalCurrentDate())' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' \(getFilterType()) group by  ticket_status , date"
        } else {
            getDatesQuery = "SELECT strftime('%Y-%m-%d',CREATED_DATE) as date FROM \(db_hr_request) WHERE  CREATED_DATE >= '\(self.startday!)' AND CREATED_DATE <= '\(self.endday!)' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' group by strftime('%Y-%m-%d',CREATED_DATE)"
            
            getTicketsAccordingDates = "SELECT TICKET_STATUS , count(ID) as totalCount, strftime('%Y-%m-%d',CREATED_DATE) as date FROM \(db_hr_request) WHERE  CREATED_DATE >= '\(self.startday!)' AND CREATED_DATE <= '\(self.endday!)' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' \(getFilterType()) group by  ticket_status , date"
        }
        
        let dates = AppDelegate.sharedInstance.db?.getDates(query: getDatesQuery).sorted(by: { (date1, date2) -> Bool in
            date1 > date2
        })
        let tickets = AppDelegate.sharedInstance.db?.getBarGraphCounts(query: getTicketsAccordingDates).sorted(by: { (g1, g2) -> Bool in
            g1.ticket_date! > g2.ticket_date!
        })
        
        stackBarChart.drawBarShadowEnabled = false
        stackBarChart.drawValueAboveBarEnabled = false
        stackBarChart.highlightFullBarEnabled = false
        stackBarChart.pinchZoomEnabled = false
        stackBarChart.doubleTapToZoomEnabled = false
        
//        stackBarChart.gestureRecognizers
        let leftAxis = stackBarChart.leftAxis
        leftAxis.axisMinimum = 0
        
        stackBarChart.rightAxis.enabled = false
        stackBarChart.delegate = self
        
        let xAxis = stackBarChart.xAxis
        
        xAxis.labelPosition = .top
        xAxis.granularity = 1.0
        
        xAxis.labelFont = UIFont.init(name: "Helvetica", size: 10)!
        stackBarChart.legend.form = .empty
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
//
//            if pendingCounter > 0 {
//                yVal.append(Double(pendingCounter))
//            }
//            if approvedCounter > 0 {
//                yVal.append(Double(approvedCounter))
//            }
//            if rejectedCounter > 0 {
//                yVal.append(Double(rejectedCounter))
//            }
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
        stackBarChart.fitBars = true
        stackBarChart.data = data
    }
    
    @IBAction func addRequestTapped(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "NewRequestViewController") as! NewRequestViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func requestBtn_Tapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Popups", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "RequestModePopupViewController") as! RequestModePopupViewController
        
        
        controller.selected_option = self.filterType
        controller.delegate = self
        controller.modalTransitionStyle = .crossDissolve
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        
        Helper.topMostController().present(controller, animated: true, completion: nil)
    }
    @IBAction func filterData_Tapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Popups", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "FilterDataPopupViewController") as! FilterDataPopupViewController
        
        
        controller.selected_query = self.selected_query
        if self.selected_query == "Custom Selection" {
            controller.fromdate = self.startday
            controller.todate   = self.endday
        }
        controller.delegate = self
        controller.modalTransitionStyle = .crossDissolve
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        
        Helper.topMostController().present(controller, animated: true, completion: nil)
    }
    
    @IBAction func sortingBtn_Tapped(_ sender: UIButton) {
        //0:PENDING
        //1:APPROVED
        //2:REJECTED
        if self.sortingBtnsHighlighter[sender.tag].image != nil {
            self.sortingBtnsHighlighter[sender.tag].image = nil
            
            isFiltered = false
            
            self.tableView.reloadData()
            
            self.mainViewHeightConstraint.constant -= self.tableViewHeightConstraint.constant
            self.tableViewHeightConstraint.constant = 0
            self.tableViewHeightConstraint.constant = CGFloat((self.tbl_request_logs!.count * 100) + 50)
            self.mainViewHeightConstraint.constant +=  self.tableViewHeightConstraint.constant
            
            return
        } else {
            self.sortingBtnsHighlighter.forEach { (UIImageView) in
                UIImageView.image = nil
            }
            switch sender.tag {
            case 0:
                self.sortingBtnsHighlighter[0].image = UIImage(named: "rightY")
                self.filteredData(status: "Pending,pending")
                break
            case 1:
                self.sortingBtnsHighlighter[1].image = UIImage(named: "rightG")
                self.filteredData(status: "Approved,approved")
                break
            case 2:
                self.sortingBtnsHighlighter[2].image = UIImage(named: "rightR")
                self.filteredData(status: "Rejected,rejected")
                break
            default:
                break
            }
        }
    }
    func filteredData(status: String) {
        self.filtered_data = self.tbl_request_logs?.filter({ (logs) -> Bool in
            logs.TICKET_STATUS == String(status.split(separator: ",").first!) || logs.TICKET_STATUS == String(status.split(separator: ",").last!)
        })
        self.isFiltered = true
        self.tableView.reloadData()
        
        self.mainViewHeightConstraint.constant -= self.tableViewHeightConstraint.constant
        self.tableViewHeightConstraint.constant = 0
        self.tableViewHeightConstraint.constant = CGFloat((self.filtered_data!.count * 100) + 50)
        self.mainViewHeightConstraint.constant +=  self.tableViewHeightConstraint.constant
    }
    
    @IBAction func hrHelpDesk_Tapped(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "HRHelpDeskRequestViewController") as! HRHelpDeskRequestViewController
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
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
        self.mainViewHeightConstraint.constant -= self.filteredViewHeightConstraint.constant
        self.filteredViewHeightConstraint.constant = 0
        self.stackBarChartDate = ""
    }
    
    
    
    func getDateSpecificWiseRecords(date: String) {
//        let query = "SELECT * FROM \(db_hr_request) WHERE CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' AND CREATED_DATE <= '\(date)T23:59:59' AND CREATED_DATE >= '\(date)T00:00:00' AND REQ_ID = '\(CURRENT_USER_LOGGED_IN_ID)'"
        
//        let query = "SELECT * FROM \(db_hr_request) WHERE CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' AND CREATED_DATE <= '\(date)T23:59:59' AND CREATED_DATE >= '\(date)T00:00:00'\(getFilterType())"
        let query = "SELECT * FROM REQUEST_LOGS WHERE CREATED_DATE >= '\(date)T00:00:00' AND CREATED_DATE <= '\(date)T23:59:59' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'\(getFilterType()) order by CREATED_DATE DESC LIMIT 0,50"
        self.date_specific_tbl_request_logs = AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: query).filter({ (logs) -> Bool in
            logs.MODULE_ID! == CONSTANT_MODULE_ID
        })
        isLoadFilteredData = true
        
        if self.filteredViewHeightConstraint.constant != 0 {
            self.mainViewHeightConstraint.constant -= self.filteredViewHeightConstraint.constant
        }
        
        
        
        self.filteredTableView.reloadData()
        
        self.filteredViewHeightConstraint.constant = 0
        self.filteredViewHeightConstraint.constant = CGFloat(self.date_specific_tbl_request_logs!.count * 100) + 10
        self.mainViewHeightConstraint.constant += self.filteredViewHeightConstraint.constant
    }
}



extension HRHelpDeskViewController: UITableViewDataSource, UITableViewDelegate {
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
        } else if tableView == self.permissionsTableView {
            if let count = self.user_permission_table_list?.count {
                return count
            }
            return 0
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
        
        if tableView == self.permissionsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ModulePermissionsCell") as! ModulePermissionsTableCell
            
            let data = self.user_permission_table_list![indexPath.row]
            cell.titleLabel.text = "\(data.title!)"
            cell.sampleImage.image = UIImage(named: "\(data.imageName!)")
            
            return cell
        } else {
            if isLoadFilteredData {
                if tableView == self.filteredTableView {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "RequestListingCell") as! RequestListingTableCell
                    let data = self.date_specific_tbl_request_logs![indexPath.row]
                    cell.mainHeading.text = data.MASTER_QUERY!
                    cell.subHeading.text = data.DETAIL_QUERY!
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
                    
                    //HR FEEDBACK
                    cell.ticketID.text = "\(data.SERVER_ID_PK!)"
                    //HR FEEDBACK
                    cell.type.text = "HR"
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
            cell.mainHeading.text = data!.MASTER_QUERY!
            cell.subHeading.text = data!.DETAIL_QUERY!
            cell.date.text = data!.CREATED_DATE?.dateSeperateWithT ?? ""
            
            //HR FEEDBACK
            cell.ticketID.text = "\(data!.SERVER_ID_PK!)"
            //HR FEEDBACK
            
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
            
            cell.type.text = "HR"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.indexPath = indexPath
        if tableView == permissionsTableView {
            self.permissionsTableView.deselectRow(at: indexPath, animated: true)
            switch self.user_permission_table_list![indexPath.row].title {
                case "HR Help Desk":
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "HRHelpDeskRequestViewController") as! HRHelpDeskRequestViewController
                    
                    self.navigationController?.pushViewController(controller, animated: true)
                    break
                case "Help Desk Monitoring":
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "NewChartListingViewController") as! NewChartListingViewController
                    controller.title = "Dashboard"
                    self.navigationController?.pushViewController(controller, animated: true)
                    break
                default:
                    break
            }
        } else {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "NewRequestViewController") as! NewRequestViewController
            let updateController = self.storyboard?.instantiateViewController(withIdentifier: "UpdateRequestViewController") as! UpdateRequestViewController
            if isLoadFilteredData {
                if tableView == self.tableView {
                    if isFiltered {
                        if self.filtered_data![indexPath.row].TICKET_STATUS == "Pending" {
                            if self.filtered_data![indexPath.row].RESPONSIBLE_EMPNO == Int(CURRENT_USER_LOGGED_IN_ID) {
                                updateController.request_log = self.filtered_data![indexPath.row]
                                self.navigationController?.pushViewController(updateController, animated: true)
                            } else {
                                controller.ticket_id = self.filtered_data![indexPath.row].SERVER_ID_PK
                                self.navigationController?.pushViewController(controller, animated: true)
                            }
                        } else {
                            controller.ticket_id = self.tbl_request_logs![indexPath.row].SERVER_ID_PK
                                self.navigationController?.pushViewController(controller, animated: true)
                        }
                    } else {
                        controller.ticket_id = self.tbl_request_logs![indexPath.row].SERVER_ID_PK
                            self.navigationController?.pushViewController(controller, animated: true)

                    }
                } else {
                    if self.date_specific_tbl_request_logs![indexPath.row].TICKET_STATUS == "Pending" {
                        if self.date_specific_tbl_request_logs![indexPath.row].RESPONSIBLE_EMPNO == Int(CURRENT_USER_LOGGED_IN_ID) {
                            updateController.request_log = self.date_specific_tbl_request_logs![indexPath.row]
                            self.navigationController?.pushViewController(updateController, animated: true)
                        } else {
                            controller.ticket_id = self.date_specific_tbl_request_logs![indexPath.row].SERVER_ID_PK
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
                    } else {
                        updateController.request_log = self.date_specific_tbl_request_logs![indexPath.row]
                        self.navigationController?.pushViewController(updateController, animated: true)
                    }
                }
            } else {
                if isFiltered {
                    if self.filtered_data![indexPath.row].TICKET_STATUS == "Pending" {
                        if self.filtered_data![indexPath.row].RESPONSIBLE_EMPNO == Int(CURRENT_USER_LOGGED_IN_ID) {
                            updateController.request_log = self.filtered_data![indexPath.row]
                            self.navigationController?.pushViewController(updateController, animated: true)
                        } else {
                            controller.ticket_id = self.filtered_data![indexPath.row].SERVER_ID_PK
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
                    } else {
                        updateController.request_log = self.filtered_data![indexPath.row]
                        self.navigationController?.pushViewController(updateController, animated: true)
                    }
                } else {
                    if self.tbl_request_logs![indexPath.row].TICKET_STATUS == "Pending" {
                        if self.tbl_request_logs![indexPath.row].RESPONSIBLE_EMPNO == Int(CURRENT_USER_LOGGED_IN_ID) {
                            updateController.request_log = self.tbl_request_logs![indexPath.row]
                            self.navigationController?.pushViewController(updateController, animated: true)
                        } else {
                            controller.ticket_id = self.tbl_request_logs![indexPath.row].SERVER_ID_PK
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
                        
                    } else {
                        updateController.request_log = self.tbl_request_logs![indexPath.row]
                        self.navigationController?.pushViewController(updateController, animated: true)
                    }
                }
            }
        }
    }
}



extension HRHelpDeskViewController: DateSelectionDelegate {
    func dateSelection(numberOfDays: Int, selected_query: String) {
        self.selected_query = selected_query
        self.filter_btn.setTitle(selected_query, for: .normal)
        self.numberOfDays = numberOfDays
        
        
        self.startday = nil
        self.endday = nil
        self.setupJSON(numberOfDays: numberOfDays,  startday: startday, endday: endday)
    }
    func dateSelection(startDate: String, endDate: String, selected_query: String) {
        self.selected_query = selected_query
        self.filter_btn.setTitle(selected_query, for: .normal)
        
        self.startday = startDate
        self.endday   = endDate
        
        self.setupJSON(numberOfDays: 0, startday: startDate, endday: endDate)
    }
    
    func requestModeSelected(selected_query: String) {
        self.allRequestBtn.setTitle(selected_query, for: .normal)
        self.filterType = selected_query
        self.setupJSON(numberOfDays: self.numberOfDays, startday: self.startday, endday: self.endday)
    }
}


final class CustomFormatter: IAxisValueFormatter {

    
    var labels: [String] = []
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {

        let count = self.labels.count

        guard let axis = axis, count > 0 else {
            return ""
        }

        let factor = axis.axisMaximum / Double(count)

        let index = Int((value / factor).rounded())

        if index >= 0 && index < count {
            return self.labels[index]
        }

        return ""
    }
}




extension HRHelpDeskViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        searchQueryTimer?.invalidate()
        
        let currentText = textField.text ?? ""
        print(currentText)
        if (currentText as NSString).replacingCharacters(in: range, with: string).count >= 3 {
            searchQueryTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(performSearch), userInfo: nil, repeats: false)
        }
        return true
    }
    @objc func performSearch() {
        var previousDate = Date()
        var weekly = String()
        let module_id = AppDelegate.sharedInstance.db?.read_tbl_UserModule(query: "SELECT * FROM \(db_user_module) WHERE TAGNAME = '\(MODULE_TAG_HR)';").first
        var query = ""
        
        
        if startday == nil && endday == nil {
            previousDate = getPreviousDays(days: -numberOfDays)
            weekly = previousDate.convertDateToString(date: previousDate)
            
            query = "SELECT * FROM \(db_hr_request) WHERE CREATED_DATE >= '\(weekly)' AND CREATED_DATE <= '\(getLocalCurrentDate())' AND MODULE_ID = '\(module_id!.SERVER_ID_PK)' AND CURRENT_USER = \(CURRENT_USER_LOGGED_IN_ID)\(getFilterType())\(getKeywords()) ORDER BY CREATED_DATE DESC LIMIT 0,50"
        } else {
            query = "SELECT * FROM REQUEST_LOGS WHERE CREATED_DATE >= '\(self.startday!)' AND CREATED_DATE <= '\(self.endday!)' AND MODULE_ID = '\(module_id!.SERVER_ID_PK)' AND CURRENT_USER = \(CURRENT_USER_LOGGED_IN_ID)\(getFilterType())\(getKeywords()) ORDER BY CREATED_DATE DESC LIMIT 0,50"
        }
        
        tbl_request_logs = AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: query)
        setupStackBarChart()
        setupCircularView()
        self.tableView.reloadData()
    }
    
    
    func getKeywords() -> String {
        let text = self.searchTextField.text!
        return " AND (EMP_NAME LIKE '%\(text)%' OR MASTER_QUERY LIKE '%\(text)%' OR SERVER_ID_PK LIKE '%\(text)%' OR REF_ID LIKE '%\(text)%' OR RESPONSIBILITY LIKE '%\(text)%' OR RESPONSIBLE_EMPNO LIKE '%\(text)%' OR DETAIL_QUERY LIKE '%\(text)%' OR LOGIN_ID LIKE '%\(text)%' OR REQ_ID LIKE '%\(text)%')"
    }
}




struct UserPermssionsTableList {
    var title: String?
    var imageName: String?
}
