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
    
    @IBOutlet weak var crossBtn: UIButton!
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
    var filtered_status = ""
    var indexPath: IndexPath?
    var startday: String?
    var endday: String?
    var DateLabels: [String] = []
    
    var stackBarChartDate = ""
    
    var ifIsSearch = false
    var temp_data: [tbl_Hr_Request_Logs]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeTopCornersRounded(roundView: self.mainView)
        self.title = "Leadership Connect"
        self.selected_query = "Weekly"
        self.tableView.register(UINib(nibName: "RequestListingTableCell", bundle: nil), forCellReuseIdentifier: "RequestListingCell")
        self.tableView.rowHeight = 80
        
        self.filteredTableView.register(UINib(nibName: "RequestListingTableCell", bundle: nil), forCellReuseIdentifier: "RequestListingCell")
        self.filteredTableView.rowHeight = 80
        
        self.search_textfield.delegate = self
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
        if !ifIsSearch {
            var query = ""
            
            if startday == nil && endday == nil {
                let previousDate = getPreviousDays(days: -numberOfDays)
                let weekly = previousDate.convertDateToString(date: previousDate)
                
                
                query = "SELECT * FROM REQUEST_LOGS WHERE CREATED_DATE >= '\(weekly)' AND CREATED_DATE <= '\(getLocalCurrentDate())' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' order by CREATED_DATE DESC"
            } else {
                query = "SELECT * FROM REQUEST_LOGS WHERE CREATED_DATE >= '\(startday!)' AND CREATED_DATE <= '\(endday!)' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = \(CURRENT_USER_LOGGED_IN_ID) order by CREATED_DATE DESC"
            }
            
            tbl_request_logs = AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: query)
            if filtered_status == "" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.setupCircularView()
                    self.setupStackBarChart()
                    self.tableView.reloadData()
                    self.temp_data = self.tbl_request_logs
                    self.setupTableViewHeight(isFiltered: false)
                }
            } else {
                self.filteredData(status: self.filtered_status)
            }
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
    
    
    @IBAction func sortedBtn_Tapped(_ sender: UIButton) {
        if self.sortedImages[sender.tag].image != nil {
            self.sortedImages[sender.tag].image = nil
            self.filtered_status = ""
            self.isFiltered = false
            self.tableView.reloadData()
            self.setupTableViewHeight(isFiltered: false)
            return
        } else {
            self.sortedImages.forEach { (UIImageView) in
                UIImageView.image = nil
            }
            switch sender.tag {
            case 0:
                self.sortedImages[0].image = UIImage(named: "rightY")
                self.filteredData(status: "Pending")
                break
            case 1:
                self.sortedImages[1].image = UIImage(named: "rightG")
                self.filteredData(status: "Approved")
                break
            case 2:
                self.sortedImages[2].image = UIImage(named: "rightR")
                self.filteredData(status: "Rejected")
                break
            default:
                break
            }
        }
    }
    func filteredData(status: String) {
        self.filtered_data = self.tbl_request_logs?.filter({ (logs) -> Bool in
            logs.TICKET_STATUS?.lowercased() == status.lowercased()
        })
        self.filtered_status = status
        self.isFiltered = true
//        self.filtered_data = temp_data
        self.setupStackBarChart()
        self.tableView.reloadData()
        self.setupTableViewHeight(isFiltered: true)
    }
    func setupTableViewHeight(isFiltered: Bool) {
        var height: CGFloat = 0.0
        if isFiltered {
            if isLoadFilteredData {
                height = CGFloat((filtered_data!.count * 80) + 580)
                height += self.filteredTableviewHeightConstraint.constant
            } else {
                height = CGFloat((filtered_data!.count * 80) + 580)
            }
        } else {
            if isLoadFilteredData {
                height = CGFloat((tbl_request_logs!.count * 80) + 580)
                height += self.filteredTableviewHeightConstraint.constant
            } else {
                height = CGFloat((tbl_request_logs!.count * 80) + 580)
            }
        }
        self.mainViewHeightConstraint.constant = 280
        switch UIDevice().type {
        case .iPhone5, .iPhone5S, .iPhone5C, .iPhoneSE:
            if height > 570 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 570
            }
            break
        case .iPhone6, .iPhone6S, .iPhone7, .iPhone8:
            if height > 670 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 670
            }
        case .iPhone6Plus, .iPhone7Plus, .iPhone8Plus:
            if height > 740 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 740
            }
            break
        case .iPhoneX, .iPhoneXR, .iPhoneXS, .iPhone11Pro, .iPhone12, .iPhone12Pro:
            if height > 790 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 790
            }
        case .iPhone11, .iPhoneXSMax, .iPhone11ProMax:
            if height > 840 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 840
            }
            break
        case .iPhone12ProMax:
            if height > 880 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 880
            }
            break
        case .iPhone12Mini:
            if height > 770 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 770
            }
        default:
            break
        }
    }
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
    @IBAction func crossBtn_tapped(_ sender: Any) {
        isLoadFilteredData = false
        self.mainViewHeightConstraint.constant -= self.filteredTableviewHeightConstraint.constant
        self.filteredTableviewHeightConstraint.constant = 0
        self.stackBarChartDate = ""
        self.crossBtn.isHidden = true
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
        self.crossBtn.isHidden = false
    }
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: Highlight) {
        print("Bar selected")
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        NSLog("chartValueNothingSelected");
        isLoadFilteredData = false
        self.mainViewHeightConstraint.constant -= self.filteredTableviewHeightConstraint.constant
        self.filteredTableviewHeightConstraint.constant = 0
        self.stackBarChartDate = ""
        self.crossBtn.isHidden = true
    }
    
    func getDateSpecificWiseRecords(date: String) {
        let query = "SELECT * FROM REQUEST_LOGS WHERE CREATED_DATE >= '\(date)T00:00:00' AND CREATED_DATE <= '\(date)T23:59:59' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' order by CREATED_DATE DESC"
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
                cell.mainHeading.text = "Ticket Id: \(data.SERVER_ID_PK!)"
                cell.subHeading.text = data.REQ_REMARKS!
                cell.date.text = data.CREATED_DATE?.dateSeperateWithT ?? ""
                
                let query = "SELECT VIEW_COUNT FROM \(db_hr_request) WHERE SERVER_ID_PK = '\(data.SERVER_ID_PK!)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"

                let string = NSMutableAttributedString(string:"")
                
                let showviewattributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13),
                                          NSAttributedString.Key.foregroundColor:UIColor.rejectedColor()]
                
                
                if let view_count = AppDelegate.sharedInstance.db?.read_column(query: query) {
                    let viewCount = NSAttributedString.init(string: "Views: \(view_count)\n", attributes: showviewattributes)
                    string.append(viewCount)
                }
                
                switch data.TICKET_STATUS?.lowercased() {
                case "pending":
                    let statusAttr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),
                                              NSAttributedString.Key.foregroundColor:UIColor.pendingColor()]
                    let status = NSAttributedString.init(string: "Pending", attributes: statusAttr)
                    string.append(status)
                    break
                case "approved":
                    let statusAttr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),
                                              NSAttributedString.Key.foregroundColor:UIColor.approvedColor()]
                    let status = NSAttributedString.init(string: "Approved", attributes: statusAttr)
                    string.append(status)
                    break
                case "rejected":
                    let statusAttr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),
                                              NSAttributedString.Key.foregroundColor:UIColor.rejectedColor()]
                    let status = NSAttributedString.init(string: "Rejected", attributes: statusAttr)
                    string.append(status)
                    break
                default:
                    break
                }
                
                cell.status.attributedText = string
                
                cell.type.text = "Leadership Connect"
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
        cell.mainHeading.text = "Ticket Id: \(data!.SERVER_ID_PK!)"
        cell.subHeading.text = data!.REQ_REMARKS!
        cell.date.text = data!.CREATED_DATE?.dateSeperateWithT ?? ""
        
        let query = "SELECT VIEW_COUNT FROM \(db_hr_request) WHERE SERVER_ID_PK = '\(data!.SERVER_ID_PK!)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"

        let string = NSMutableAttributedString(string:"")
        
        let showviewattributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13),
                                  NSAttributedString.Key.foregroundColor:UIColor.rejectedColor()]
        
        
        if let view_count = AppDelegate.sharedInstance.db?.read_column(query: query) {
            let viewCount = NSAttributedString.init(string: "Views: \(view_count)\n", attributes: showviewattributes)
            string.append(viewCount)
        }
        
        switch data!.TICKET_STATUS?.lowercased() {
        case "pending":
            let statusAttr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),
                                      NSAttributedString.Key.foregroundColor:UIColor.pendingColor()]
            let status = NSAttributedString.init(string: "Pending", attributes: statusAttr)
            string.append(status)
            break
        case "approved":
            let statusAttr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),
                                      NSAttributedString.Key.foregroundColor:UIColor.approvedColor()]
            let status = NSAttributedString.init(string: "Approved", attributes: statusAttr)
            string.append(status)
            break
        case "rejected":
            let statusAttr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),
                                      NSAttributedString.Key.foregroundColor:UIColor.rejectedColor()]
            let status = NSAttributedString.init(string: "Rejected", attributes: statusAttr)
            string.append(status)
            break
        default:
            break
        }
        
        cell.status.attributedText = string
        
        cell.type.text = "Leadership Connect"
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



extension LeadershipListingViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        searchQueryTimer?.invalidate()
        
        let currentText = textField.text ?? ""
        print(currentText)
        
        if (currentText as NSString).replacingCharacters(in: range, with: string).count == 0 {
            
            if isFiltered {
                self.filtered_data = temp_data
                self.tableView.reloadData()
                self.setupTableViewHeight(isFiltered: true)
            } else {
                self.tbl_request_logs = temp_data
                self.tableView.reloadData()
                self.setupTableViewHeight(isFiltered: false)
            }
            
            
            
            self.ifIsSearch = false
            return true
        }
        if (currentText as NSString).replacingCharacters(in: range, with: string).count >= 3 {
            searchQueryTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(performSearch), userInfo: nil, repeats: false)
        }
        return true
    }
    @objc func performSearch() {
        if isFiltered {
            self.filtered_data = self.filtered_data?.filter({ (logs) -> Bool in
                self.ifIsSearch = true
                return (logs.REQ_REMARKS?.lowercased().contains(self.search_textfield.text?.lowercased() ?? "")) ?? false ||
                    (String(logs.SERVER_ID_PK ?? 0).contains(self.search_textfield.text?.lowercased() ?? ""))
            })
            self.tableView.reloadData()
            self.setupTableViewHeight(isFiltered: true)
        } else {
            self.tbl_request_logs = self.tbl_request_logs?.filter({ (logs) -> Bool in
                self.ifIsSearch = true
                return (logs.REQ_REMARKS?.lowercased().contains(self.search_textfield.text?.lowercased() ?? "")) ?? false ||
                    (String(logs.SERVER_ID_PK ?? 0).contains(self.search_textfield.text?.lowercased() ?? ""))
            })
            self.tableView.reloadData()
            self.setupTableViewHeight(isFiltered: false)
        }
    }
}
