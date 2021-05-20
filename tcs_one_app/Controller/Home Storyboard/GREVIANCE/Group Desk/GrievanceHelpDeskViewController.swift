//
//  GrievanceHelpDeskViewController.swift
//  tcs_one_app
//
//  Created by TCS on 13/11/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import Charts
import MBCircularProgressBar

class GrievanceHelpDeskViewController: BaseViewController {

    //MARK: IBOutlets
    @IBOutlet weak var request_type_view: CustomView!
    @IBOutlet weak var mainView: CustomView!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var stackBarChart: BarChartView!
    
    @IBOutlet weak var filterView: CustomView!
    @IBOutlet weak var permissionTableView: UITableView!
    @IBOutlet weak var filterTableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet var sortedImages: [UIImageView]!
    @IBOutlet weak var submittedProgressView: MBCircularProgressBarView!
    @IBOutlet weak var inReviewProgressView: MBCircularProgressBarView!
    @IBOutlet weak var closedProgressView: MBCircularProgressBarView!
    
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var filter_type_btn_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var permissionTableViewHeightContraint: NSLayoutConstraint!
    
    
    
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
    var user_permission = [tbl_UserPermission]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mainViewHeightConstraint.constant = 600.0
        self.title = "Awaz Help Desk"
        makeTopCornersRounded(roundView: self.mainView)
        
        self.selected_query = "Weekly"
        
        self.tableView.register(UINib(nibName: "RequestListingTableCell", bundle: nil), forCellReuseIdentifier: "RequestListingCell")
//        self.tableView.rowHeight = 80
        self.tableView.rowHeight = 100
        
        self.filterTableView.register(UINib(nibName: "RequestListingTableCell", bundle: nil), forCellReuseIdentifier: "RequestListingCell")
//        self.filterTableView.rowHeight = 80
        self.filterTableView.rowHeight = 100
        
        self.permissionTableView.register(UINib(nibName: "ModulePermissionsTableCell", bundle: nil), forCellReuseIdentifier: "ModulePermissionsCell")
        self.permissionTableView.rowHeight = 70
        
        
        setupPermission()
        user_permission = AppDelegate.sharedInstance.db!.read_tbl_UserPermission()
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
    
    //MARK: IBActions
    @IBAction func filterBtn_Tapped(_ sender: Any) {
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
    @IBAction func allRequestBtn_Tapped(_ sender: Any) {
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
    
    
    @IBAction func addNewReqTapped(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "GrievanceNewRequestViewController") as! GrievanceNewRequestViewController
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func sortingBtn_Tapped(_ sender: UIButton) {
        if self.sortedImages[sender.tag].image != nil {
            self.sortedImages[sender.tag].image = nil
            
            isFiltered = false
            self.tableView.reloadData()
            
            self.mainViewHeightConstraint.constant -= self.tableViewHeightConstraint.constant
            self.tableViewHeightConstraint.constant = 0
            self.tableViewHeightConstraint.constant = CGFloat((self.tbl_request_logs!.count * 100) + 50)
            self.mainViewHeightConstraint.constant +=  self.tableViewHeightConstraint.constant
            return
        } else {
            self.sortedImages.forEach { (UIImageView) in
                UIImageView.image = nil
            }
            switch sender.tag {
            case 0:
                self.sortedImages[0].image = UIImage(named: "rightY")
                self.filteredData(status: "Submitted")
                break
            case 1:
                self.sortedImages[1].image = UIImage(named: "rightG")
                self.filteredData(status: INREVIEW)
                break
            case 2:
                self.sortedImages[2].image = UIImage(named: "rightR")
                self.filteredData(status: "Closed")
                break
            default:
                break
            }
        }
    }
    
    //MARK: Custom Functions
    private func filteredData(status: String) {
        if status == INREVIEW {
            self.filtered_data = self.tbl_request_logs?.filter({ (logs) -> Bool in
                logs.TICKET_STATUS == "Inprogress-Er" || logs.TICKET_STATUS == "Inprogress-S" || logs.TICKET_STATUS == "Responded" || logs.TICKET_STATUS == "Investigating" || logs.TICKET_STATUS == "Inprogress-Srhrbp" || logs.TICKET_STATUS == "Inprogess-Ceo"
            })
            self.filtered_data = self.filtered_data?.sorted(by: { (logs1, logs2) -> Bool in
                logs1.CREATED_DATE! < logs2.CREATED_DATE!
            })
        } else {
            self.filtered_data = self.tbl_request_logs?.filter({ (logs) -> Bool in
                logs.TICKET_STATUS == status
            })
            if status == "Closed" {
                self.filtered_data = self.filtered_data?.sorted(by: { (logs1, logs2) -> Bool in
                    logs1.CREATED_DATE! > logs2.CREATED_DATE!
                })
            } else {
                self.filtered_data = self.filtered_data?.sorted(by: { (logs1, logs2) -> Bool in
                    logs1.CREATED_DATE! > logs2.CREATED_DATE!
                })
            }
        }
        self.isFiltered = true
        self.tableView.reloadData()
        
        self.mainViewHeightConstraint.constant -= self.tableViewHeightConstraint.constant
        self.tableViewHeightConstraint.constant = 0
        self.tableViewHeightConstraint.constant = CGFloat((self.filtered_data!.count * 100) + 50)
        self.mainViewHeightConstraint.constant +=  self.tableViewHeightConstraint.constant
    }
    
    
    private func setupPermission() {
        let listing_all_filter_count = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: PERMISSION_GRIEVENCE_LISTING_ALL_FILTER).count
        let listing_responsible_bar_count = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: PERMISSION_GRIEVENCE_LISTING_RESPONSIBLE_BAR).count
        let listing_management_bar_count  = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: PERMISSION_GRIEVENCE_LISTING_MANAGEMENT_BAR).count
        
        user_permission_table_list = [UserPermssionsTableList]()
        if listing_all_filter_count! > 0 {
            self.filterType = "All"
            filter_type_btn_top_constraint.constant = 70
            request_type_view.isHidden = false
        }
        
        if listing_responsible_bar_count! > 0 {
            user_permission_table_list?.append(UserPermssionsTableList(title: "Awaz Requests", imageName: "helpdesk"))
        }
        
        if listing_management_bar_count! > 0 {
            user_permission_table_list?.append(UserPermssionsTableList(title: "Awaz Monitoring", imageName: "helpdesk"))
        }
        
        if let _ = self.user_permission_table_list {
            self.permissionTableView.reloadData()
            self.permissionTableViewHeightContraint.constant = 0
            self.permissionTableViewHeightContraint.constant = CGFloat(self.user_permission_table_list!.count * 70) + 10// self.permissionsTableView.contentSize.height
            
            self.mainViewHeightConstraint.constant += self.permissionTableViewHeightContraint.constant
        }
    }
    
    private func setupJSON(numberOfDays: Int, startday: String?, endday: String?) {
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
        self.filterTableView.reloadData()
        
        if self.filterTableViewHeightConstraint.constant != 0 {
            self.mainViewHeightConstraint.constant -= self.filterTableViewHeightConstraint.constant
            self.filterTableViewHeightConstraint.constant = 0
            self.getDateSpecificWiseRecords(date: self.stackBarChartDate)
        }
        
        
        self.mainViewHeightConstraint.constant -= self.tableViewHeightConstraint.constant
        self.tableViewHeightConstraint.constant = 0
        self.tableViewHeightConstraint.constant = CGFloat((self.tbl_request_logs!.count * 100) + 50)
        self.mainViewHeightConstraint.constant +=  self.tableViewHeightConstraint.constant
    }
    
    private func getFilterType() -> String {
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
    
    private func setupCircularView() {
        if let data = self.tbl_request_logs {
            let pendingCount = data.filter({ (logs) -> Bool in
                logs.TICKET_STATUS == "Submitted" || logs.TICKET_STATUS == "submitted"
                }).count
            let approvedCount = data.filter({ (logs) -> Bool in
                logs.TICKET_STATUS == "Responded" || logs.TICKET_STATUS == "responded" ||
                logs.TICKET_STATUS == "Investigating" || logs.TICKET_STATUS == "investigating" ||
                logs.TICKET_STATUS == "Inprogress-Er" || logs.TICKET_STATUS == "inprogress-er" ||
                logs.TICKET_STATUS == "Inprogress-S" || logs.TICKET_STATUS == "inprogress-s" ||
                logs.TICKET_STATUS == "Inprogress-Srhrbp" || logs.TICKET_STATUS == "inprogress-srhrbp" ||
                logs.TICKET_STATUS == "Inprogress-Ceo" || logs.TICKET_STATUS == "inprogress-ceo"
            }).count
            let rejectedCount = data.filter({ (logs) -> Bool in
                logs.TICKET_STATUS == "Closed" || logs.TICKET_STATUS == "closed"
            }).count
            
            self.submittedProgressView.maxValue = CGFloat(data.count)
            self.inReviewProgressView.maxValue = CGFloat(data.count)
            self.closedProgressView.maxValue = CGFloat(data.count)
            
            UIView.animate(withDuration: 1) {
                self.submittedProgressView.value = CGFloat(pendingCount)
                self.inReviewProgressView.value = CGFloat(approvedCount)
                self.closedProgressView.value = CGFloat(rejectedCount)
            }
        }
    }
    
    private func setupStackBarChart() {
        var previousDate = Date()
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
        
        
        var submittedCounter = 0
        var inreviewCounter = 0
        var closedCounter = 0
        var barChartEntries = [BarChartDataEntry]()
        for (index,date) in dates!.enumerated() {
            let ticket = tickets?.filter({ (GraphTotalCount) -> Bool in
                GraphTotalCount.ticket_date == date
            })
            
            for t in ticket! {
                switch t.ticket_status {
                case "Submitted":
                    submittedCounter += Int(t.ticket_total!)!
                    break
                case "Responded", "Investigating", "Inprogress-Er", "Inprogress-S", "Inprogess-Srhrbp", "Inprogress-Ceo":
                    inreviewCounter += Int(t.ticket_total!)!
                    break
                case "Closed":
                    closedCounter += Int(t.ticket_total!)!
                    break
                default:
                    break
                }
            }
            print("\(date)\n=====================\nPending: \(submittedCounter)\nApproved: \(inreviewCounter)\nRejected: \(closedCounter)\n\n\n\n")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let tDate = dateFormatter.date(from: date)!.monthAsStringAndDay()
            xAxisDates.append(tDate)
            
            let yVal : [Double] = [Double(submittedCounter), Double(inreviewCounter), Double(closedCounter)]
            
            let barchart = BarChartDataEntry(x: Double(index), yValues: yVal, data: date)
            barChartEntries.append(barchart)
            submittedCounter = 0
            inreviewCounter = 0
            closedCounter = 0
        }
        
        let formatt = CustomFormatter()
        formatt.labels = xAxisDates
        xAxis.valueFormatter = formatt
        set = BarChartDataSet(entries: barChartEntries, label: "")
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
}


extension GrievanceHelpDeskViewController: ChartViewDelegate {
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
        self.mainViewHeightConstraint.constant -= self.filterTableViewHeightConstraint.constant
        self.filterTableViewHeightConstraint.constant = 0
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
        
        if self.filterTableViewHeightConstraint.constant != 0 {
            self.mainViewHeightConstraint.constant -= self.filterTableViewHeightConstraint.constant
        }
        
        self.filterTableView.reloadData()
        
        self.filterTableViewHeightConstraint.constant = 0
        self.filterTableViewHeightConstraint.constant = CGFloat(self.date_specific_tbl_request_logs!.count * 100) + 10
        self.mainViewHeightConstraint.constant += self.filterTableViewHeightConstraint.constant
    }
}



extension GrievanceHelpDeskViewController: UITableViewDataSource, UITableViewDelegate {
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
        } else if tableView == self.permissionTableView {
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
        if tableView == self.permissionTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ModulePermissionsCell") as! ModulePermissionsTableCell
            
            let data = self.user_permission_table_list![indexPath.row]
            cell.titleLabel.text = "\(data.title!)"
            cell.sampleImage.image = UIImage(named: "\(data.imageName!)")
            
            return cell
        } else {
            if isLoadFilteredData {
                if tableView == self.filterTableView {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "RequestListingCell") as! RequestListingTableCell
                    let data = self.date_specific_tbl_request_logs![indexPath.row]
                    cell.mainHeading.text = data.MASTER_QUERY!
                    cell.subHeading.text = data.DETAIL_QUERY!
                    cell.date.text = data.CREATED_DATE?.dateSeperateWithT ?? ""
                    
                    if data.TICKET_STATUS == "Submitted" || data.TICKET_STATUS == "submitted" {
                        cell.status.text = "Submitted"
                        cell.status.textColor = UIColor.pendingColor()
                    } else if data.TICKET_STATUS == "Responded" || data.TICKET_STATUS == "responded" ||
                              data.TICKET_STATUS == "Investigating" || data.TICKET_STATUS == "investigating" ||
                              data.TICKET_STATUS == "Inprogress-Er" || data.TICKET_STATUS == "Inprogress-er" ||
                              data.TICKET_STATUS == "Inprogress-S" || data.TICKET_STATUS == "Inprogress-s" ||
                              data.TICKET_STATUS == "Inprogress-Srhrbp" || data.TICKET_STATUS == "Inprogress-srhrbp" ||
                              data.TICKET_STATUS == "Inprogress-Ceo" || data.TICKET_STATUS == "Inprogress-ceo"{
                        cell.status.text = INREVIEW
                        cell.status.textColor = UIColor.approvedColor()
                    } else {
                        cell.status.text = "Closed"
                        cell.status.textColor = UIColor.rejectedColor()
                    }
                    //HR FEEDBACK
                    cell.ticketID.text = "Ticket Id: \(data.SERVER_ID_PK!)"
                    //HR FEEDBACK
                    cell.type.text = "Awaz"
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
            cell.ticketID.text = "Ticket Id: \(data!.SERVER_ID_PK!)"
            //HR FEEDBACK
            
            if data!.TICKET_STATUS == "Submitted" || data!.TICKET_STATUS == "submitted" {
                cell.status.text = "Submitted"
                cell.status.textColor = UIColor.pendingColor()
            } else if data!.TICKET_STATUS == "Responded" || data!.TICKET_STATUS == "responded" ||
                      data!.TICKET_STATUS == "Investigating" || data!.TICKET_STATUS == "investigating" ||
                      data!.TICKET_STATUS == "Inprogress-Er" || data!.TICKET_STATUS == "inprogress-er" ||
                      data!.TICKET_STATUS == "Inprogress-S" || data!.TICKET_STATUS == "inprogress-s" ||
                      data!.TICKET_STATUS == "Inprogress-Srhrbp" || data!.TICKET_STATUS == "Inprogress-srhrbp" ||
                      data!.TICKET_STATUS == "Inprogress-Ceo" || data!.TICKET_STATUS == "Inprogress-ceo"{
                cell.status.text = INREVIEW
                cell.status.textColor = UIColor.approvedColor()
            } else {
                cell.status.text = "Closed"
                cell.status.textColor = UIColor.rejectedColor()
            }
            
            cell.type.text = "Awaz"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.indexPath = indexPath
        if tableView == permissionTableView {
            self.permissionTableView.deselectRow(at: indexPath, animated: true)
            switch self.user_permission_table_list![indexPath.row].title {
                case "Awaz Requests":
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "GrievanceHelpDeskRequestsViewController") as! GrievanceHelpDeskRequestsViewController
                    
                    self.navigationController?.pushViewController(controller, animated: true)
                    break
                case "Awaz Monitoring":
                    let storyboard = UIStoryboard(name: "Home", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "NewChartListingViewController") as! NewChartListingViewController
                    controller.title = "Dashboard"
                    self.navigationController?.pushViewController(controller, animated: true)
                    break
                default:
                    break
            }
        } else {
            let viewRequest = self.storyboard?.instantiateViewController(withIdentifier: "GrievanceViewRequestViewController") as! GrievanceViewRequestViewController
            let closedRequest = self.storyboard?.instantiateViewController(withIdentifier: "GrievanceViewClosedRequestViewController") as! GrievanceViewClosedRequestViewController
            if isLoadFilteredData {
                if tableView == self.tableView {
                    if isFiltered {
                        let ticket_status = self.filtered_data![indexPath.row].TICKET_STATUS?.lowercased()
                        if ticket_status == "closed" {
                            closedRequest.ticket_id = self.tbl_request_logs![indexPath.row].SERVER_ID_PK
                            self.navigationController?.pushViewController(closedRequest, animated: true)
                        } else {
                            if self.user_permission.contains(where: { permissions -> Bool in
                                let permission = String(permissions.PERMISSION.lowercased().split(separator: " ").last!)
                                return permission == ticket_status!
                            }) {
                                viewRequest.ticket_id = self.filtered_data![indexPath.row].SERVER_ID_PK
                                self.navigationController?.pushViewController(viewRequest, animated: true)
                            } else {
                                closedRequest.ticket_id = self.tbl_request_logs![indexPath.row].SERVER_ID_PK
                                self.navigationController?.pushViewController(closedRequest, animated: true)
                                print("NOT CONTAINS")
                            }
                        }
                    } else {
                        let ticket_status = self.tbl_request_logs![indexPath.row].TICKET_STATUS?.lowercased()
                        if ticket_status == "closed" {
                            closedRequest.ticket_id = self.tbl_request_logs![indexPath.row].SERVER_ID_PK
                            self.navigationController?.pushViewController(closedRequest, animated: true)
                        } else {
                            if self.user_permission.contains(where: { permissions -> Bool in
                                let permission = String(permissions.PERMISSION.lowercased().split(separator: " ").last!)
                                return permission == ticket_status!
                            }) {
                                viewRequest.ticket_id = self.tbl_request_logs![indexPath.row].SERVER_ID_PK
                                self.navigationController?.pushViewController(viewRequest, animated: true)
                            } else {
                                print("NOT CONTAINS")
                                closedRequest.ticket_id = self.tbl_request_logs![indexPath.row].SERVER_ID_PK
                                self.navigationController?.pushViewController(closedRequest, animated: true)
                                //ONLY VIEW
                            }
                        }
                    }
                } else {
                    let ticket_status = self.date_specific_tbl_request_logs![indexPath.row].TICKET_STATUS?.lowercased()
                    if ticket_status == "closed" {
                        closedRequest.ticket_id = self.date_specific_tbl_request_logs![indexPath.row].SERVER_ID_PK
                        self.navigationController?.pushViewController(closedRequest, animated: true)
                    } else {
                        if self.user_permission.contains(where: { permissions -> Bool in
                            let permission = String(permissions.PERMISSION.lowercased().split(separator: " ").last!)
                            return permission == ticket_status!
                        }) {
                            viewRequest.ticket_id = self.date_specific_tbl_request_logs![indexPath.row].SERVER_ID_PK
                            self.navigationController?.pushViewController(viewRequest, animated: true)
                        } else {
                            closedRequest.ticket_id = self.date_specific_tbl_request_logs![indexPath.row].SERVER_ID_PK
                            self.navigationController?.pushViewController(closedRequest, animated: true)
                        }
                    }
                }
            } else {
                if isFiltered {
                    let ticket_status = self.filtered_data![indexPath.row].TICKET_STATUS?.lowercased()
                    if ticket_status == "closed" {
                        closedRequest.ticket_id = self.filtered_data![indexPath.row].SERVER_ID_PK
                        self.navigationController?.pushViewController(closedRequest, animated: true)
                    } else {
                        if self.user_permission.contains(where: { permissions -> Bool in
                            let permission = String(permissions.PERMISSION.lowercased().split(separator: " ").last!)
                            return permission == ticket_status!
                        }) {
                            viewRequest.ticket_id = self.filtered_data![indexPath.row].SERVER_ID_PK
                            self.navigationController?.pushViewController(viewRequest, animated: true)
                        } else {
                            print("NOT CONTAINS")
                            closedRequest.ticket_id = self.filtered_data![indexPath.row].SERVER_ID_PK
                            self.navigationController?.pushViewController(closedRequest, animated: true)
                            //ONLY VIEW
                        }
                    }
                } else {
                    let ticket_status = self.tbl_request_logs![indexPath.row].TICKET_STATUS?.lowercased()
                    if ticket_status == "closed" {
                        closedRequest.ticket_id = self.tbl_request_logs![indexPath.row].SERVER_ID_PK
                        self.navigationController?.pushViewController(closedRequest, animated: true)
                    } else {
                        if self.user_permission.contains(where: { permissions -> Bool in
                            let permission = String(permissions.PERMISSION.lowercased().split(separator: " ").last!)
                            return permission == ticket_status!
                        }) {
                            viewRequest.ticket_id = self.tbl_request_logs![indexPath.row].SERVER_ID_PK
                            self.navigationController?.pushViewController(viewRequest, animated: true)
                        } else {
                            print("NOT CONTAINS")
                            closedRequest.ticket_id = self.tbl_request_logs![indexPath.row].SERVER_ID_PK
                            self.navigationController?.pushViewController(closedRequest, animated: true)
                            //ONLY VIEW
                        }
                    }
                }
            }
        }
    }
}



extension GrievanceHelpDeskViewController: DateSelectionDelegate {
    func dateSelection(numberOfDays: Int, selected_query: String) {
        self.selected_query = selected_query
        self.filterBtn.setTitle(selected_query, for: .normal)
        
        self.startday = nil
        self.endday = nil
        
        self.numberOfDays = numberOfDays
        self.setupJSON(numberOfDays: numberOfDays,  startday: startday, endday: endday)
    }
    
    func dateSelection(startDate: String, endDate: String, selected_query: String) {
        self.selected_query = selected_query
        self.filterBtn.setTitle(selected_query, for: .normal)
        
        self.startday = startDate
        self.endday   = endDate
        
        self.setupJSON(numberOfDays: 0, startday: startDate, endday: endDate)
    }
    
    func requestModeSelected(selected_query: String) {
        self.filterType = selected_query
        self.setupJSON(numberOfDays: self.numberOfDays, startday: self.startday, endday: self.endday)
    }
}
