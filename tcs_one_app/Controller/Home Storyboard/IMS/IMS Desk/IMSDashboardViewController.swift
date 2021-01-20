//
//  IMSDashboardViewController.swift
//  tcs_one_app
//
//  Created by TCS on 30/12/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import Charts
import MBCircularProgressBar

class IMSDashboardViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var allRequestView: UIView!
    @IBOutlet weak var allRequestBtn: UIButton!
    
    @IBOutlet weak var weeklyFilterBtn: UIButton!
    @IBOutlet weak var barStackChart: BarChartView!
    
    @IBOutlet weak var filteredTableviewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var filteredTableView: UITableView!
    
    
    @IBOutlet var sortedImages: [UIImageView]!
    @IBOutlet weak var submittedProgressView: MBCircularProgressBarView!
    @IBOutlet weak var inreviewProgressView: MBCircularProgressBarView!
    
    @IBOutlet weak var closedProgressView: MBCircularProgressBarView!
    
    @IBOutlet weak var permissionTableView: UITableView!
    @IBOutlet weak var permissionTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    
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
        self.makeTopCornersRounded(roundView: self.mainView)
        self.title = "IMS Help Desk"
        self.selected_query = "Weekly"
        
        self.tableView.register(UINib(nibName: "RequestListingTableCell", bundle: nil), forCellReuseIdentifier: "RequestListingCell")
        self.tableView.rowHeight = 80
        
        self.filteredTableView.register(UINib(nibName: "RequestListingTableCell", bundle: nil), forCellReuseIdentifier: "RequestListingCell")
        self.filteredTableView.rowHeight = 80
        
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
    
    
    //MARK: IBACTIONS START
    
    @IBAction func monthlyFilterBtnTapped(_ sender: Any) {
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
    @IBAction func allRequestBtnTapped(_ sender: Any) {
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
    
    @IBAction func sortingBtnTapped(_ sender: UIButton) {
        if self.sortedImages[sender.tag].image != nil {
            self.sortedImages[sender.tag].image = nil
            
            isFiltered = false
            self.tableView.reloadData()
            
            self.mainViewHeightConstraint.constant -= self.tableViewHeightConstraint.constant
            self.tableViewHeightConstraint.constant = 0
            self.tableViewHeightConstraint.constant = CGFloat((self.tbl_request_logs!.count * 80) + 50)
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
    //MARK: IBACTIONS END
    
    //MARK: Custom Functions STARTS
    private func filteredData(status: String) {
        if status == INREVIEW {
            self.filtered_data = self.tbl_request_logs?.filter({ (logs) -> Bool in
                logs.TICKET_STATUS == IMS_Status_Inprogress ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_Rds ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_Ro ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_Rm ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_Hod ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_Cs ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_As ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_Hs ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_Ds ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_Fs ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_Ins ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_Hr ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_Fi ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_Ca ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_Rhod
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
        self.tableViewHeightConstraint.constant = CGFloat((self.filtered_data!.count * 80) + 50)
        self.mainViewHeightConstraint.constant +=  self.tableViewHeightConstraint.constant
    }
    private func setupPermission() {
        let listing_all_filter_count = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_Listing_All_Filters).count
        let listing_responsible_bar_count = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_Listing_Responsible_Bar).count
        
        user_permission_table_list = [UserPermssionsTableList]()
        if listing_all_filter_count! > 0 {
            self.filterType = "All"
            allRequestView.isHidden = false
        }
        
        if listing_responsible_bar_count! > 0 {
            user_permission_table_list?.append(UserPermssionsTableList(title: "IMS Requests", imageName: "helpdesk"))
        }
        
        if let _ = self.user_permission_table_list {
            self.permissionTableView.reloadData()
            self.permissionTableViewHeightConstraint.constant = 0
            self.permissionTableViewHeightConstraint.constant = CGFloat(self.user_permission_table_list!.count * 70) + 10
            
            self.mainViewHeightConstraint.constant += self.permissionTableViewHeightConstraint.constant
        }
    }
    private func setupJSON(numberOfDays: Int, startday: String?, endday: String?) {
        var query = ""
        
        if startday == nil && endday == nil {
            let previousDate = getPreviousDays(days: -numberOfDays)
            let weekly = previousDate.convertDateToString(date: previousDate)
            
            
            query = "SELECT * FROM REQUEST_LOGS WHERE CREATED_DATE >= '\(weekly)' AND CREATED_DATE <= '\(getLocalCurrentDate())' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'\(getFilterType()) order by CREATED_DATE DESC LIMIT 0,50"
        } else {
            query = "SELECT * FROM REQUEST_LOGS WHERE CREATED_DATE >= '\(startday!)' AND CREATED_DATE <= '\(endday!)' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = \(CURRENT_USER_LOGGED_IN_ID)\(getFilterType()) order by CREATED_DATE DESC LIMIT 0,50"
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
                logs.TICKET_STATUS == IMS_Status_Submitted
                }).count
            let approvedCount = data.filter({ (logs) -> Bool in
                logs.TICKET_STATUS == IMS_Status_Inprogress ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_Rds ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_Ro ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_Rm ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_Hod ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_Cs ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_As ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_Hs ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_Ds ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_Fs ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_Ins ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_Hr ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_Fi ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_Ca ||
                logs.TICKET_STATUS == IMS_Status_Inprogress_Rhod
            }).count
            let rejectedCount = data.filter({ (logs) -> Bool in
                logs.TICKET_STATUS == IMS_Status_Closed
            }).count
            
            self.submittedProgressView.maxValue = CGFloat(data.count)
            self.inreviewProgressView.maxValue = CGFloat(data.count)
            self.closedProgressView.maxValue = CGFloat(data.count)
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
                self.submittedProgressView.value = CGFloat(pendingCount)
                UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear, animations: {
                    self.inreviewProgressView.value = CGFloat(approvedCount)
                    UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveLinear, animations: {
                        self.closedProgressView.value = CGFloat(rejectedCount)
                    }, completion: nil)
                }, completion: nil)
            }, completion: nil)
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
        
        barStackChart.drawBarShadowEnabled = false
        barStackChart.drawValueAboveBarEnabled = false
        barStackChart.highlightFullBarEnabled = false
        barStackChart.pinchZoomEnabled = false
        barStackChart.doubleTapToZoomEnabled = false
        
        let leftAxis = barStackChart.leftAxis
        leftAxis.axisMinimum = 0
        
        barStackChart.rightAxis.enabled = false
        
        barStackChart.delegate = self
        
        let xAxis = barStackChart.xAxis
        
        xAxis.labelPosition = .top
        xAxis.granularity = 1.0
        
        xAxis.labelFont = UIFont.init(name: "Helvetica", size: 10)!
        barStackChart.legend.form = .empty
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
                case IMS_Status_Submitted:
                    submittedCounter += Int(t.ticket_total!)!
                    break
                case IMS_Status_Inprogress, IMS_Status_Inprogress_Rds, IMS_Status_Inprogress_Ro, IMS_Status_Inprogress_Rm, IMS_Status_Inprogress_Hod, IMS_Status_Inprogress_Cs, IMS_Status_Inprogress_As , IMS_Status_Inprogress_Hs, IMS_Status_Inprogress_Ds, IMS_Status_Inprogress_Fs, IMS_Status_Inprogress_Ins, IMS_Status_Inprogress_Hr, IMS_Status_Inprogress_Fi, IMS_Status_Inprogress_Ca, IMS_Status_Inprogress_Rhod:
                    inreviewCounter += Int(t.ticket_total!)!
                    break
                case IMS_Status_Closed:
                    closedCounter += Int(t.ticket_total!)!
                    break
                default:
                    break
                }
            }
            
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
        barStackChart.fitBars = true
        barStackChart.data = data
        
        barStackChart.animate(yAxisDuration: 0.5, easing: nil)
    }
    //MARK: Custom Functions ENDS
}



//MARK: ChartView Delegate
extension IMSDashboardViewController: ChartViewDelegate {
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
        let query = "SELECT * FROM REQUEST_LOGS WHERE CREATED_DATE >= '\(date)T00:00:00' AND CREATED_DATE <= '\(date)T23:59:59' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'\(getFilterType()) order by CREATED_DATE DESC LIMIT 0,50"
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


//MARK: UITableView Delegate & Datasource
extension IMSDashboardViewController: UITableViewDataSource, UITableViewDelegate {
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
                if tableView == self.filteredTableView {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "RequestListingCell") as! RequestListingTableCell
                    let data = self.date_specific_tbl_request_logs![indexPath.row]
                    cell.mainHeading.text = data.INCIDENT_TYPE!
                    if let department = AppDelegate.sharedInstance.db?.read_tbl_department(query: "SELECT * FROM \(db_lov_department) WHERE SERVER_ID_PK = '\(data.DEPARTMENT ?? "")'").first {
                        cell.subHeading.text = department.DEPAT_NAME
                    }
                    
                    cell.date.text = data.CREATED_DATE?.dateSeperateWithT ?? ""
                    
                    if data.TICKET_STATUS == IMS_Status_Submitted {
                        cell.status.text = IMS_Status_Submitted
                        cell.status.textColor = UIColor.pendingColor()
                    } else if data.TICKET_STATUS == IMS_Status_Inprogress ||
                                data.TICKET_STATUS == IMS_Status_Inprogress_Rds ||
                                data.TICKET_STATUS == IMS_Status_Inprogress_Ro ||
                                data.TICKET_STATUS == IMS_Status_Inprogress_Rm ||
                                data.TICKET_STATUS == IMS_Status_Inprogress_Hod ||
                                data.TICKET_STATUS == IMS_Status_Inprogress_Cs ||
                                data.TICKET_STATUS == IMS_Status_Inprogress_As ||
                                data.TICKET_STATUS == IMS_Status_Inprogress_Hs ||
                                data.TICKET_STATUS == IMS_Status_Inprogress_Ds ||
                                data.TICKET_STATUS == IMS_Status_Inprogress_Fs ||
                                data.TICKET_STATUS == IMS_Status_Inprogress_Ins ||
                                data.TICKET_STATUS == IMS_Status_Inprogress_Hr ||
                                data.TICKET_STATUS == IMS_Status_Inprogress_Fi ||
                                data.TICKET_STATUS == IMS_Status_Inprogress_Ca ||
                                data.TICKET_STATUS == IMS_Status_Inprogress_Rhod {
                        cell.status.text = IMS_Status_Inprogress
                        cell.status.textColor = UIColor.approvedColor()
                    } else {
                        cell.status.text = IMS_Status_Closed
                        cell.status.textColor = UIColor.rejectedColor()
                    }
                    cell.type.text = "IMS"
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
            cell.mainHeading.text = data!.INCIDENT_TYPE!
            if let department = AppDelegate.sharedInstance.db?.read_tbl_department(query: "SELECT * FROM \(db_lov_department) WHERE SERVER_ID_PK = '\(data?.DEPARTMENT ?? "")'").first {
                cell.subHeading.text = department.DEPAT_NAME
            }
            cell.date.text = data!.CREATED_DATE?.dateSeperateWithT ?? ""
            
            if data!.TICKET_STATUS == IMS_Status_Submitted {
                cell.status.text = IMS_Status_Submitted
                cell.status.textColor = UIColor.pendingColor()
            } else if data!.TICKET_STATUS == IMS_Status_Inprogress ||
                        data!.TICKET_STATUS == IMS_Status_Inprogress_Rds ||
                        data!.TICKET_STATUS == IMS_Status_Inprogress_Ro ||
                        data!.TICKET_STATUS == IMS_Status_Inprogress_Rm ||
                        data!.TICKET_STATUS == IMS_Status_Inprogress_Hod ||
                        data!.TICKET_STATUS == IMS_Status_Inprogress_Cs ||
                        data!.TICKET_STATUS == IMS_Status_Inprogress_As ||
                        data!.TICKET_STATUS == IMS_Status_Inprogress_Hs ||
                        data!.TICKET_STATUS == IMS_Status_Inprogress_Ds ||
                        data!.TICKET_STATUS == IMS_Status_Inprogress_Fs ||
                        data!.TICKET_STATUS == IMS_Status_Inprogress_Ins ||
                        data!.TICKET_STATUS == IMS_Status_Inprogress_Hr ||
                        data!.TICKET_STATUS == IMS_Status_Inprogress_Fi ||
                        data!.TICKET_STATUS == IMS_Status_Inprogress_Ca ||
                        data!.TICKET_STATUS == IMS_Status_Inprogress_Rhod {
                cell.status.text = IMS_Status_Inprogress
                cell.status.textColor = UIColor.approvedColor()
            } else {
                cell.status.text = IMS_Status_Closed
                cell.status.textColor = UIColor.rejectedColor()
            }
            
            cell.type.text = "IMS"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.indexPath = indexPath
        if tableView == permissionTableView {
            self.permissionTableView.deselectRow(at: indexPath, animated: true)
            switch self.user_permission_table_list![indexPath.row].title {
                case "IMS Requests":
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "IMSAllRequestsViewController") as! IMSAllRequestsViewController
                    
                    self.navigationController?.pushViewController(controller, animated: true)
                    break
                default:
                    break
            }
        } else {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "IMSViewUpdateRequestViewController") as! IMSViewUpdateRequestViewController
            
            let permissions = AppDelegate.sharedInstance.db?.read_tbl_UserPermission()
            var current_user = ""
            for perm in permissions! {
                var breakk = false
                let p = perm.PERMISSION
                for constant in IMSAllPermissions {
                    if p == constant {
                        current_user = p
                        breakk = true
                        break
                    }
                }
                if breakk {
                    break
                }
            }
            if isFiltered {
                let current_ticket = self.filtered_data![indexPath.row]
                let isGranted = permissions?.contains(where: { (perm) -> Bool in
                    let permission = String(perm.PERMISSION.lowercased().split(separator: " ").last!)
                    return permission == current_ticket.TICKET_STATUS?.lowercased()
                })
                
                controller.ticket_request = current_ticket
                controller.current_user = current_user
                controller.havePermissionToEdit = isGranted!
                print(current_user)
                if current_user == "" {
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "IMSNewRequestViewController") as! IMSNewRequestViewController
                    controller.current_ticket = current_ticket
                    self.navigationController?.pushViewController(controller, animated: true)
                } else {
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            } else {
                let current_ticket = self.tbl_request_logs![indexPath.row]
                let isGranted = permissions?.contains(where: { (perm) -> Bool in
                    let permission = String(perm.PERMISSION.lowercased().split(separator: " ").last!)
                    return permission == current_ticket.TICKET_STATUS?.lowercased()
                })
                
                controller.ticket_request = current_ticket
                controller.current_user = current_user
                controller.havePermissionToEdit = isGranted!
                
                print(current_user)
                if current_user == "" {
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "IMSNewRequestViewController") as! IMSNewRequestViewController
                    controller.current_ticket = current_ticket
                    self.navigationController?.pushViewController(controller, animated: true)
                } else {
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                
            }
        }
    }
}


//MARK: DateSelection Delegate
extension IMSDashboardViewController: DateSelectionDelegate {
    func dateSelection(numberOfDays: Int, selected_query: String) {
        self.selected_query = selected_query
        self.weeklyFilterBtn.setTitle(selected_query, for: .normal)
        
        self.startday = nil
        self.endday = nil
        
        self.numberOfDays = numberOfDays
        self.setupJSON(numberOfDays: numberOfDays,  startday: startday, endday: endday)
    }
    
    func dateSelection(startDate: String, endDate: String, selected_query: String) {
        self.selected_query = selected_query
        self.weeklyFilterBtn.setTitle(selected_query, for: .normal)
        
        self.startday = startDate
        self.endday   = endDate
        
        self.setupJSON(numberOfDays: 0, startday: startDate, endday: endDate)
    }
    
    func requestModeSelected(selected_query: String) {
        self.filterType = selected_query
        self.setupJSON(numberOfDays: self.numberOfDays, startday: self.startday, endday: self.endday)
    }
}

