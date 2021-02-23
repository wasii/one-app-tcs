//
//  WatchAllRequestsViewController.swift
//  tcs_one_app
//
//  Created by TCS on 08/11/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import MBCircularProgressBar

class WatchAllRequestsViewController: BaseViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainVIew: UIView!
    @IBOutlet weak var pendingCircularView: MBCircularProgressBarView!
    @IBOutlet weak var approvedCircularView: MBCircularProgressBarView!
    @IBOutlet weak var rejectedCircularView: MBCircularProgressBarView!
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var rejectedLabel: UILabel!
    @IBOutlet weak var approvedLabel: UILabel!
    @IBOutlet weak var pendingLabel: UILabel!
    
    
    @IBOutlet weak var dateLabelButton: UIButton!
    @IBOutlet weak var currentMonthLabel: UILabel!
    @IBOutlet var sortingButtonHighlighters: [UIImageView]!
    
    var indexPath: IndexPath?
    
    var tbl_request_logs: [tbl_Hr_Request_Logs]?
    var filtered_table: [tbl_Hr_Request_Logs]?
    
    var temp_logs : [tbl_Hr_Request_Logs]?
    var isFiltered = false
    
    var index = 0
    var Title = ""
    var query = ""
    
    var dateHeading: String?
    var startday: String?// = ""
    var endday: String?// = ""
    var selected_query: String = ""
    
    
    var isAllRequests: Bool         = false
    var isTAT: Bool                 = false
    var isTATBreached: Bool         = false
    var isQueryAndSubQuery: Bool    = false
    
    var mq_id: Int?
    var dq_id: Int?
    
    override func viewDidAppear(_ animated: Bool) {
        if indexPath != nil {
            self.tableView.deselectRow(at: indexPath!, animated: true)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(upload_pending_request), name: .networkRefreshed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigateThroughtNotify(notification:)), name: .navigateThroughNotification, object: nil)
        setupCircularViews()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchTextField.delegate = self
        self.temp_logs = self.tbl_request_logs
        self.makeTopCornersRounded(roundView: self.mainVIew)
        self.tableView.register(UINib(nibName: "RequestListingTableCell", bundle: nil), forCellReuseIdentifier: "RequestListingCell")
        self.tableView.rowHeight = 80
        
        if let _ = dateHeading {
            self.dateLabelButton.setTitle(self.dateHeading!, for: .normal)
        }
        
        switch CONSTANT_MODULE_ID {
        case 1:
            pendingLabel.text = "Pending"
            approvedLabel.text = "Completed"
            rejectedLabel.text = "Rejected"
            break
        case 2:
            pendingLabel.text = "Submitted"
            approvedLabel.text = "In-Review"
            rejectedLabel.text = "Closed"
            break
        default:
            break
        }
        
        switch UIDevice().type {
        case .iPhone5, .iPhone5S, .iPhone5C, .iPhoneSE:
            break
        case .iPhone6, .iPhone6S, .iPhone7, .iPhone8:
            self.mainViewHeightConstraint.constant = 870
            break
        case .iPhone6Plus, .iPhone7Plus, .iPhone8Plus:
            self.mainViewHeightConstraint.constant = 970
            break
        case .iPhoneX, .iPhoneXR, .iPhoneXS, .iPhone11Pro:
            self.mainViewHeightConstraint.constant = 1100
            break
        case .iPhone11, .iPhoneXSMax, .iPhone11ProMax:
            self.mainViewHeightConstraint.constant = 970
            break
        default:
            break
        }
        
        if self.mainViewHeightConstraint.constant < CGFloat(self.tbl_request_logs!.count * 80) {
            self.mainViewHeightConstraint.constant = 0
            self.mainViewHeightConstraint.constant += CGFloat(self.tbl_request_logs!.count * 80) + 300
        }
    }
    
    func setupTableViewHeight(isFiltered: Bool) {
        var height: CGFloat = 0.0
        if isFiltered {
            height = CGFloat((filtered_table!.count * 80) + 300)
        } else {
            height = CGFloat((tbl_request_logs!.count * 80) + 300)
        }
        self.mainViewHeightConstraint.constant = 300
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
        case .iPhoneX, .iPhoneXR, .iPhoneXS, .iPhone11Pro:
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
    
    func filteredData(status: String) {
        switch CONSTANT_MODULE_ID {
        case 1:
            self.filtered_table = self.tbl_request_logs?.filter({ (logs) -> Bool in
                logs.TICKET_STATUS?.lowercased() == status.lowercased()
            })
            break
        case 2:
            if status == INREVIEW {
                self.filtered_table = self.tbl_request_logs?.filter({ (logs) -> Bool in
                    logs.TICKET_STATUS == "Inprogress-Er" || logs.TICKET_STATUS == "Inprogress-S" || logs.TICKET_STATUS == "Responded" || logs.TICKET_STATUS == "Investigating"
                })
            } else {
                self.filtered_table = self.tbl_request_logs?.filter({ (logs) -> Bool in
                    logs.TICKET_STATUS == status
                })
            }
            break
        default:
            break
        }
        
        self.isFiltered = true
        self.tableView.reloadData()
        self.setupTableViewHeight(isFiltered: true)
    }
    
    func setupCircularViews() {
        switch CONSTANT_MODULE_ID {
        case 1:
            let pendingCount = self.tbl_request_logs?.filter({ (logs) -> Bool in
                logs.TICKET_STATUS == "Pending" || logs.TICKET_STATUS == "pending"
                }).count
            let approvedCount = self.tbl_request_logs?.filter({ (logs) -> Bool in
                logs.TICKET_STATUS == "Approved" || logs.TICKET_STATUS == "approved"
            }).count
            let rejectedCount = self.tbl_request_logs?.filter({ (logs) -> Bool in
                logs.TICKET_STATUS == "Rejected" || logs.TICKET_STATUS == "rejected"
            }).count
            
            self.pendingCircularView.maxValue = CGFloat(self.tbl_request_logs?.count ?? 0)
            self.approvedCircularView.maxValue = CGFloat(self.tbl_request_logs?.count ?? 0)
            self.rejectedCircularView.maxValue = CGFloat(self.tbl_request_logs?.count ?? 0)
            
            UIView.animate(withDuration: 0.5) {
                self.pendingCircularView.value = CGFloat(pendingCount ?? 0)
                self.approvedCircularView.value = CGFloat(approvedCount ?? 0)
                self.rejectedCircularView.value = CGFloat(rejectedCount ?? 0)
            }
            break
        case 2:
            let pendingCount = self.tbl_request_logs?.filter({ (logs) -> Bool in
                logs.TICKET_STATUS == "Submitted" || logs.TICKET_STATUS == "submitted"
                }).count
            let approvedCount = self.tbl_request_logs?.filter({ (logs) -> Bool in
                logs.TICKET_STATUS == "Responded" || logs.TICKET_STATUS == "responded" ||
                logs.TICKET_STATUS == "Investigating" || logs.TICKET_STATUS == "investigating" ||
                logs.TICKET_STATUS == "Inprogress-Er" || logs.TICKET_STATUS == "Inprogress-er" ||
                logs.TICKET_STATUS == "Inprogress-S" || logs.TICKET_STATUS == "Inprogress-s"
            }).count
            let rejectedCount = self.tbl_request_logs?.filter({ (logs) -> Bool in
                logs.TICKET_STATUS == "Closed" || logs.TICKET_STATUS == "closed"
            }).count
            
            
            self.pendingCircularView.maxValue = CGFloat(self.tbl_request_logs?.count ?? 0)
            self.approvedCircularView.maxValue = CGFloat(self.tbl_request_logs?.count ?? 0)
            self.rejectedCircularView.maxValue = CGFloat(self.tbl_request_logs?.count ?? 0)
            UIView.animate(withDuration: 0.5) {
                self.pendingCircularView.value = CGFloat(pendingCount ?? 0)
                self.approvedCircularView.value = CGFloat(approvedCount ?? 0)
                self.rejectedCircularView.value = CGFloat(rejectedCount ?? 0)
            }
            
            break
        default:
            break
        }
    }
    
    @IBAction func sortingBtnTapped(_ sender: UIButton) {
        if self.sortingButtonHighlighters[sender.tag].image != nil {
            self.sortingButtonHighlighters[sender.tag].image = nil
            
            isFiltered = false
            self.tableView.reloadData()
            return
        } else {
            self.sortingButtonHighlighters.forEach { (UIImageView) in
                UIImageView.image = nil
            }
            switch CONSTANT_MODULE_ID {
            case 1:
                switch sender.tag {
                case 0:
                    self.sortingButtonHighlighters[0].image = UIImage(named: "rightY")
                    self.filteredData(status: "Pending")
                    break
                case 1:
                    self.sortingButtonHighlighters[1].image = UIImage(named: "rightG")
                    self.filteredData(status: "Approved")
                    break
                case 2:
                    self.sortingButtonHighlighters[2].image = UIImage(named: "rightR")
                    self.filteredData(status: "Rejected")
                    break
                default:
                    break
                }
                break
            case 2:
                switch sender.tag {
                case 0:
                    self.sortingButtonHighlighters[0].image = UIImage(named: "rightY")
                    self.filteredData(status: "Submitted")
                    break
                case 1:
                    self.sortingButtonHighlighters[1].image = UIImage(named: "rightG")
                    self.filteredData(status: INREVIEW)
                    break
                case 2:
                    self.sortingButtonHighlighters[2].image = UIImage(named: "rightR")
                    self.filteredData(status: "Closed")
                    break
                default:
                    break
                }
                break
            default:
                break
            }
        }
    }
    @IBAction func customFilterTapped(_ sender: Any) {
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
    
    func getQueryAndSubQuery(days: Int?, start_date: String?, end_date: String?) {
        var query = ""
        
        if start_date == nil && end_date == nil {
            let previousDate = getPreviousDays(days: -days!)
            let weekly = previousDate.convertDateToString(date: previousDate)
            
            if self.mq_id! == 0 {
                query = "SELECT * FROM \(db_hr_request) WHERE CREATED_DATE >= '\(weekly)' AND CREATED_DATE <= '\(getLocalCurrentDate())'  AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' AND (MQ_ID = \(self.mq_id!) AND DQ_ID = '\(self.dq_id!)' ) order by CREATED_DATE ASC"
            } else {
                query = "select * from \(db_hr_request) WHERE CREATED_DATE >='\(weekly)' AND CREATED_DATE <= '\(getLocalCurrentDate())'  AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' AND (MQ_ID = '\(self.mq_id!)' OR DQ_ID = '\(self.dq_id!)' ) order by CREATED_DATE ASC"
            }
        } else {
            if self.mq_id! == 0 {
                query = "SELECT * FROM \(db_hr_request) WHERE CREATED_DATE >= '\(start_date!)' AND CREATED_DATE <= '\(end_date!)'  AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' AND (MQ_ID = \(self.mq_id!) OR DQ_ID = '\(self.dq_id!)' ) order by CREATED_DATE ASC"
            } else {
                query = "select * from \(db_hr_request) WHERE CREATED_DATE >='\(start_date!)' AND CREATED_DATE <= '\(end_date!)'  AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' AND (MQ_ID = '\(self.mq_id!)' OR DQ_ID = '\(self.dq_id!)' ) order by CREATED_DATE ASC"
            }
        }
        tbl_request_logs = (AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: query))!
        temp_logs = tbl_request_logs
        tableView.reloadData()
        setupCircularViews()
        setupTableViewHeight(isFiltered: false)
    }
    func getAllRequest(days: Int?, month:Int?, start_date: String?, end_date: String?) {
        var query = ""
        
        if start_date == nil && end_date == nil {
            if month == nil {
                let previousDate = getPreviousDays(days: -days!)
                let weekly = previousDate.convertDateToString(date: previousDate)
                query = "select * from REQUEST_LOGS WHERE module_id = '\(CONSTANT_MODULE_ID)' AND Created_Date >= '\(weekly)' AND Created_Date <= '\(getLocalCurrentDate())' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

                let lastMonth = Calendar.current.date(byAdding: .month, value: -month!, to: Date())
                let lastMonthEndDate = lastMonth?.endOfMonth
                let lastMonthStartDate = lastMonth?.startOfMonth

                query = "select * from REQUEST_LOGS WHERE module_id = '\(CONSTANT_MODULE_ID)' AND Created_Date >= '\(dateFormatter.string(from: lastMonthStartDate!))' AND Created_Date <= '\(dateFormatter.string(from: lastMonthEndDate!))' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
            }
            
        } else {
            query = "SELECT * FROM \(db_hr_request) WHERE MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CREATED_DATE <= '\(end_date!)' AND CREATED_DATE >= '\(start_date!)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
        }
        
        tbl_request_logs = (AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: query))!
        temp_logs = tbl_request_logs
        tableView.reloadData()
        setupCircularViews()
        setupTableViewHeight(isFiltered: false)
        
    }
}



extension WatchAllRequestsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltered {
            if let count = self.filtered_table?.count {
                return count
            }
            return 0
        } else {
            if let count = tbl_request_logs?.count {
                return count
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestListingCell") as! RequestListingTableCell
        
        var data : tbl_Hr_Request_Logs?
        
        if isFiltered {
            data = self.filtered_table![indexPath.row]
        } else {
            data = self.tbl_request_logs![indexPath.row]
        }
        
        
        cell.mainHeading.text = data!.MASTER_QUERY!
        cell.subHeading.text = data!.DETAIL_QUERY!
        cell.date.text = data!.CREATED_DATE?.dateSeperateWithT ?? ""
        
        switch CONSTANT_MODULE_ID {
        case 1:
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
            break
        case 2:
            if data!.TICKET_STATUS == "Submitted" || data!.TICKET_STATUS == "submitted" {
                cell.status.text = "Submitted"
                cell.status.textColor = UIColor.pendingColor()
            } else if data!.TICKET_STATUS == "Responded" || data!.TICKET_STATUS == "responded" ||
                      data!.TICKET_STATUS == "Investigating" || data!.TICKET_STATUS == "investigating" ||
                      data!.TICKET_STATUS == "Inprogress-Er" || data!.TICKET_STATUS == "inprogress-er" ||
                      data!.TICKET_STATUS == "Inprogress-S" || data!.TICKET_STATUS == "inprogress-s"  {
                cell.status.text = INREVIEW
                cell.status.textColor = UIColor.approvedColor()
            } else {
                cell.status.text = "Closed"
                cell.status.textColor = UIColor.rejectedColor()
            }
            break
        default:
            break
        }
        
        
        cell.type.text = "HR"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.indexPath = indexPath
        switch CONSTANT_MODULE_ID {
        case 1:
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "NewRequestViewController") as! NewRequestViewController
            let viewcontroller = self.storyboard?.instantiateViewController(withIdentifier: "UpdateRequestViewController") as! UpdateRequestViewController
            
            if isFiltered {
                if self.filtered_table![indexPath.row].TICKET_STATUS == "Pending" {
                    if self.filtered_table![indexPath.row].RESPONSIBLE_EMPNO == Int(CURRENT_USER_LOGGED_IN_ID) {
                        viewcontroller.request_log = self.filtered_table![indexPath.row]
                        self.navigationController?.pushViewController(viewcontroller, animated: true)
                    } else {
                        controller.ticket_id = self.filtered_table![indexPath.row].SERVER_ID_PK!
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                } else {
                    viewcontroller.request_log = self.filtered_table![indexPath.row]
                    self.navigationController?.pushViewController(viewcontroller, animated: true)
                }
                
            } else {
                if self.tbl_request_logs![indexPath.row].TICKET_STATUS == "Pending" {
                    if self.tbl_request_logs![indexPath.row].RESPONSIBLE_EMPNO == Int(CURRENT_USER_LOGGED_IN_ID) {
                        viewcontroller.request_log = self.tbl_request_logs![indexPath.row]
                        self.navigationController?.pushViewController(viewcontroller, animated: true)
                    } else {
                        controller.ticket_id = self.tbl_request_logs![indexPath.row].SERVER_ID_PK!
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                } else {
                    viewcontroller.request_log = self.tbl_request_logs![indexPath.row]
                    self.navigationController?.pushViewController(viewcontroller, animated: true)
                }
            }
            
            
            break
        case 2:
            let storyboard = UIStoryboard(name: "GrievanceStoryboard", bundle: nil)
            let viewRequest = storyboard.instantiateViewController(withIdentifier: "GrievanceViewRequestViewController") as! GrievanceViewRequestViewController
            let closedRequest = storyboard.instantiateViewController(withIdentifier: "GrievanceViewClosedRequestViewController") as! GrievanceViewClosedRequestViewController
            
            let user_permission = AppDelegate.sharedInstance.db!.read_tbl_UserPermission()
            if isFiltered {
                let ticket_status = self.filtered_table![indexPath.row].TICKET_STATUS?.lowercased()
                if ticket_status == "closed" {
                    closedRequest.ticket_id = self.filtered_table![indexPath.row].SERVER_ID_PK
                    self.navigationController?.pushViewController(closedRequest, animated: true)
                } else {
                    if user_permission.contains(where: { permissions -> Bool in
                        let permission = String(permissions.PERMISSION.lowercased().split(separator: " ").last!)
                        return permission == ticket_status!
                    }) {
                        viewRequest.ticket_id = self.filtered_table![indexPath.row].SERVER_ID_PK
                        self.navigationController?.pushViewController(viewRequest, animated: true)
                    } else {
                        closedRequest.ticket_id = self.filtered_table![indexPath.row].SERVER_ID_PK
                        self.navigationController?.pushViewController(closedRequest, animated: true)
                    }
                }
            } else {
                let ticket_status = self.tbl_request_logs![indexPath.row].TICKET_STATUS?.lowercased()
                if ticket_status == "closed" {
                    closedRequest.ticket_id = self.tbl_request_logs![indexPath.row].SERVER_ID_PK
                    self.navigationController?.pushViewController(closedRequest, animated: true)
                } else {
                    if user_permission.contains(where: { permissions -> Bool in
                        let permission = String(permissions.PERMISSION.lowercased().split(separator: " ").last!)
                        return permission == ticket_status!
                    }) {
                        viewRequest.ticket_id = self.tbl_request_logs![indexPath.row].SERVER_ID_PK
                        self.navigationController?.pushViewController(viewRequest, animated: true)
                    } else {
                        closedRequest.ticket_id = self.tbl_request_logs![indexPath.row].SERVER_ID_PK
                        self.navigationController?.pushViewController(closedRequest, animated: true)
                    }
                }
            }
            break
        default:
            break
        }
    }
}



extension WatchAllRequestsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        searchQueryTimer?.invalidate()
        
        let currentText = textField.text ?? ""
        if (currentText as NSString).replacingCharacters(in: range, with: string).count == 0 {
            self.tbl_request_logs = self.temp_logs
            self.tableView.reloadData()
            self.setupCircularViews()
            self.setupTableViewHeight(isFiltered: false)
        }
        if (currentText as NSString).replacingCharacters(in: range, with: string).count >= 3 {
            searchQueryTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(performSearch), userInfo: nil, repeats: false)
        }
        return true
    }
    @objc func performSearch() {
        self.tbl_request_logs = self.temp_logs
        self.tbl_request_logs = self.tbl_request_logs?.filter({ (filtered_logs) -> Bool in
            if self.searchTextField.text!.lowercased().contains("inreview") {
                return filtered_logs.TICKET_STATUS!.lowercased().contains("inprogress-er") ||
                filtered_logs.TICKET_STATUS!.lowercased().contains("responded") ||
                filtered_logs.TICKET_STATUS!.lowercased().contains("investigating") ||
                filtered_logs.TICKET_STATUS!.lowercased().contains("inprogress-s")
            } else {
                return filtered_logs.MASTER_QUERY!.lowercased().contains(self.searchTextField.text!.lowercased()) ||
                filtered_logs.DETAIL_QUERY!.lowercased().contains(self.searchTextField.text!.lowercased()) ||
                filtered_logs.TICKET_STATUS!.lowercased().contains(self.searchTextField.text!.lowercased())
            }
        })
        self.tableView.reloadData()
        setupCircularViews()
        self.setupTableViewHeight(isFiltered: false)
    }
}


extension WatchAllRequestsViewController: DateSelectionDelegate {
    func dateSelection(numberOfDays: Int, selected_query: String) {
        self.selected_query = selected_query
        if isAllRequests {
            self.dateLabelButton.setTitle(selected_query, for: .normal)
            self.getAllRequest(days: numberOfDays, month: nil, start_date: nil, end_date: nil)
            return
        } else if isTAT {
            tbl_request_logs = self.calculateWithInTat(days: numberOfDays, month: nil, start_day: nil, end_day: nil)
        } else if isTATBreached {
            tbl_request_logs = self.calculateTatBreached(days: numberOfDays, month: nil, start_day: nil, end_day: nil)
        } else if isQueryAndSubQuery {
            self.dateLabelButton.setTitle(selected_query, for: .normal)
            self.getQueryAndSubQuery(days: numberOfDays, start_date: nil, end_date: nil)
            return
        }
        
        self.dateLabelButton.setTitle(selected_query, for: .normal)
        self.tableView.reloadData()
        self.setupCircularViews()
        self.setupTableViewHeight(isFiltered: false)
    }
    func dateSelection(startDate: String, endDate: String, selected_query: String) {
        self.selected_query = selected_query
        
        self.startday = startDate
        self.endday   = endDate
        
        self.dateLabelButton.setTitle(selected_query, for: .normal)
        
        if isAllRequests {
            self.getAllRequest(days: nil, month: nil, start_date: startDate, end_date: endDate)
            return
        } else if isTAT {
            tbl_request_logs = self.calculateWithInTat(days: nil, month: nil, start_day: startday, end_day: endday)
            temp_logs = tbl_request_logs
        } else if isTATBreached {
            tbl_request_logs = self.calculateTatBreached(days: nil, month: nil, start_day: startday, end_day: endday)
            temp_logs = tbl_request_logs
        } else if isQueryAndSubQuery {
            self.getQueryAndSubQuery(days: nil, start_date: startDate, end_date: endDate)
            return
        }
        self.tableView.reloadData()
        self.setupCircularViews()
        self.setupTableViewHeight(isFiltered: false)
    }
    
    func requestModeSelected(selected_query: String) {}
}
