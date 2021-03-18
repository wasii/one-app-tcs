//
//  GrievanceHelpDeskRequestsViewController.swift
//  tcs_one_app
//
//  Created by TCS on 13/11/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import MBCircularProgressBar

class GrievanceHelpDeskRequestsViewController: BaseViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    
    //@IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closedProgressView: MBCircularProgressBarView!
    @IBOutlet weak var inreviewProgressView: MBCircularProgressBarView!
    @IBOutlet weak var submittedProgressView: MBCircularProgressBarView!
    @IBOutlet weak var filter_btn: UIButton!
    @IBOutlet var sortingButtonHighlighters: [UIImageView]!
    
    var isFiltered = false
    var numberOfDays = 7
    var tbl_request_logs: [tbl_Hr_Request_Logs]?
    var filtered_data: [tbl_Hr_Request_Logs]?
    
    var indexPath: IndexPath?
    var selected_query: String?
    
    
    var start_day: String?
    var end_day: String?
    
    var user_permission = [tbl_UserPermission]()
    
    var filtered_status = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "All Request"
        
        
        self.makeTopCornersRounded(roundView: self.mainView)
        self.selected_query = "Weekly"
        self.tableView.register(UINib(nibName: "RequestListingTableCell", bundle: nil), forCellReuseIdentifier: "RequestListingCell")
        self.tableView.rowHeight = 80
        
        self.searchTextField.delegate = self
        user_permission = AppDelegate.sharedInstance.db!.read_tbl_UserPermission()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if indexPath != nil {
            self.tableView.deselectRow(at: indexPath!, animated: true)
        }
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
        setupJSON(numberOfDays: numberOfDays, startday: start_day, endday: end_day)
        NotificationCenter.default.addObserver(self, selector: #selector(upload_pending_request), name: .networkRefreshed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshedView(notification:)), name: .refreshedViews, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigateThroughtNotify(notification:)), name: .navigateThroughNotification, object: nil)
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
        self.setupJSON(numberOfDays: numberOfDays, startday: start_day, endday: end_day)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    func setupJSON(numberOfDays: Int, startday: String?, endday: String?) {
        var previousDate = Date()// getPreviousDays(days: -numberOfDays)
        var weekly = String()
        var query = ""
        
        if start_day == nil && end_day == nil {
            previousDate = getPreviousDays(days: -numberOfDays)
            weekly = previousDate.convertDateToString(date: previousDate)
            
            query = "SELECT * FROM REQUEST_LOGS WHERE CREATED_DATE >= '\(weekly)' AND CREATED_DATE <= '\(getLocalCurrentDate())' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
        } else {
             query = "SELECT * FROM REQUEST_LOGS WHERE CREATED_DATE >= '\(startday!)' AND CREATED_DATE <= '\(endday!)' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
        }
        tbl_request_logs = AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: query)
        
        if filtered_status == "" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.setupCircularViews()
                self.tableView.reloadData()
                self.setupTableViewHeight(isFiltered: false)
            }
        } else {
            self.filteredData(status: self.filtered_status)
        }
    }
    func setupTableViewHeight(isFiltered: Bool) {
        var height: CGFloat = 0.0
        if isFiltered {
            height = CGFloat((filtered_data!.count * 80) + 300)
        } else {
            height = CGFloat((tbl_request_logs!.count * 80) + 300)
        }
        self.mainViewHeightConstraint.constant = 280
        switch UIDevice().type {
        case .iPhone5, .iPhone5S, .iPhone5C, .iPhoneSE:
            if height > 610 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 610
            }
            break
        case .iPhone6, .iPhone6S, .iPhone7, .iPhone8:
            if height > 710 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 710
            }
        case .iPhone6Plus, .iPhone7Plus, .iPhone8Plus:
            if height > 780 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 780
            }
            break
        case .iPhoneX, .iPhoneXR, .iPhoneXS, .iPhone11Pro, .iPhone12, .iPhone12Pro:
            if height > 830 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 830
            }
        case .iPhone11, .iPhoneXSMax, .iPhone11ProMax:
            if height > 910 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 910
            }
            break
        case .iPhone12ProMax:
            if height > 920 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 920
            }
            break
        case .iPhone12Mini:
            if height > 810 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 810
            }
        default:
            break
        }
        //self.tableViewHeightConstraint.constant = height
        
    }
    func setupCircularViews() {
        
        let pendingCount = self.tbl_request_logs?.filter({ (logs) -> Bool in
            logs.TICKET_STATUS == "Submitted" || logs.TICKET_STATUS == "submitted"
            }).count
        let approvedCount = self.tbl_request_logs?.filter({ (logs) -> Bool in
            logs.TICKET_STATUS == "Responded" || logs.TICKET_STATUS == "responded" ||
            logs.TICKET_STATUS == "Investigating" || logs.TICKET_STATUS == "investigating" ||
            logs.TICKET_STATUS == "Inprogress-Er" || logs.TICKET_STATUS == "Inprogress-er" ||
            logs.TICKET_STATUS == "Inprogress-S" || logs.TICKET_STATUS == "Inprogress-s" ||
            logs.TICKET_STATUS == "Inprogress-Srhrbp" || logs.TICKET_STATUS == "Inprogress-srhrbp" ||
            logs.TICKET_STATUS == "Inprogress-Ceo" || logs.TICKET_STATUS == "Inprogress-ceo"
        }).count
        let rejectedCount = self.tbl_request_logs?.filter({ (logs) -> Bool in
            logs.TICKET_STATUS == "Closed" || logs.TICKET_STATUS == "closed"
        }).count
        
        self.submittedProgressView.maxValue = CGFloat(tbl_request_logs?.count ?? 0)
        self.inreviewProgressView.maxValue = CGFloat(tbl_request_logs?.count ?? 0)
        self.closedProgressView.maxValue = CGFloat(tbl_request_logs?.count ?? 0)
        
        UIView.animate(withDuration: 0.4) {
            self.submittedProgressView.value = CGFloat(pendingCount ?? 0)
            self.inreviewProgressView.value = CGFloat(approvedCount ?? 0)
            self.closedProgressView.value = CGFloat(rejectedCount ?? 0)
        }
        
    }
    
    func filteredData(status: String) {
        if status == INREVIEW {
            self.filtered_data = self.tbl_request_logs?.filter({ (logs) -> Bool in
                logs.TICKET_STATUS == "Inprogress-Er" || logs.TICKET_STATUS == "Inprogress-S" || logs.TICKET_STATUS == "Responded" || logs.TICKET_STATUS == "Investigating" || logs.TICKET_STATUS == "Inprogress-Srhrbp" || logs.TICKET_STATUS == "Inprogress-Ceo"
            })
            self.filtered_status = INREVIEW
        } else {
            self.filtered_data = self.tbl_request_logs?.filter({ (logs) -> Bool in
                logs.TICKET_STATUS == status
            })
            self.filtered_status = status
        }
        
        self.isFiltered = true
        self.tableView.reloadData()
        self.setupTableViewHeight(isFiltered: true)
    }
    
    @IBAction func sortinBtn_Tapped(_ sender: UIButton) {
        if self.sortingButtonHighlighters[sender.tag].image != nil {
            self.sortingButtonHighlighters[sender.tag].image = nil
            
            isFiltered = false
            self.tableView.reloadData()
            return
        } else {
            self.sortingButtonHighlighters.forEach { (UIImageView) in
                UIImageView.image = nil
            }
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
        }
    }
    @IBAction func thisWeekBtn_Tapped(_ sender: Any) {
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

extension GrievanceHelpDeskRequestsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        searchQueryTimer?.invalidate()
        
        let currentText = textField.text ?? ""
        if (currentText as NSString).replacingCharacters(in: range, with: string).count >= 3 {
            searchQueryTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(performSearch), userInfo: nil, repeats: false)
        }
        return true
    }
    @objc func performSearch() {
        print(self.searchTextField.text)
        
        let query = "SELECT * FROM \(db_hr_request) WHERE CREATED_DATE >= ? AND CREATED_DATE <= ? AND MODULE_ID = ? AND CURRENT_USER = ? AND (LOGIN_ID = ? OR REQ_ID = ?) AND (EMP LIKE ? OR MASTER_QUERY LIKE ? OR SERVER_ID_PK ? OR REF_ID LIKE ? OR RESPONSIBILITY LIKE ? OR RESPONSIBLE_EMPNO LIKE ? OR DETAIL_QUERY LIKE ? OR LOGIN_ID LIKE ? OR REQ_ID LIKE ?) ORDER BY CREATED_DATE DESC LIMIT 0,50"
    }
}

extension GrievanceHelpDeskRequestsViewController: DateSelectionDelegate {
    func requestModeSelected(selected_query: String) {}
    
    func dateSelection(numberOfDays: Int, selected_query: String) {
        self.selected_query = selected_query
        self.filter_btn.setTitle(selected_query, for: .normal)
        
        self.start_day = nil
        self.end_day = nil
        
        self.setupJSON(numberOfDays: numberOfDays,  startday: nil, endday: nil)
    }
    func dateSelection(startDate: String, endDate: String, selected_query: String) {
        self.selected_query = selected_query
        self.filter_btn.setTitle(selected_query, for: .normal)
        
        self.start_day = startDate
        self.end_day = endDate
        self.setupJSON(numberOfDays: 0, startday: startDate, endday: endDate)
    }
}


extension GrievanceHelpDeskRequestsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        
        if data!.TICKET_STATUS == "Submitted" || data!.TICKET_STATUS == "submitted" {
            cell.status.text = "Submitted"
            cell.status.textColor = UIColor.pendingColor()
        } else if data!.TICKET_STATUS == "Responded" || data!.TICKET_STATUS == "responded" ||
                    data!.TICKET_STATUS == "Investigating" || data!.TICKET_STATUS == "Investigating" ||
                    data!.TICKET_STATUS == "Inprogress-Er" || data!.TICKET_STATUS == "Inprogress-er" ||
                    data!.TICKET_STATUS == "Inprogress-S" || data!.TICKET_STATUS == "Inprogress-s" ||
                    data!.TICKET_STATUS == "Inprogress-Srhrbp" || data!.TICKET_STATUS == "Inprogress-srhrbp" ||
                    data!.TICKET_STATUS == "Inprogress-Ceo" || data!.TICKET_STATUS == "Inprogress-ceo" {
            cell.status.text = INREVIEW
            cell.status.textColor = UIColor.approvedColor()
        } else {
            cell.status.text = "Closed"
            cell.status.textColor = UIColor.rejectedColor()
        }
        
        cell.type.text = "Awaz"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.indexPath = indexPath
        let viewRequest = self.storyboard?.instantiateViewController(withIdentifier: "GrievanceViewRequestViewController") as! GrievanceViewRequestViewController
        let closedRequest = self.storyboard?.instantiateViewController(withIdentifier: "GrievanceViewClosedRequestViewController") as! GrievanceViewClosedRequestViewController
        
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
                    closedRequest.ticket_id = self.tbl_request_logs![indexPath.row].SERVER_ID_PK
                    self.navigationController?.pushViewController(closedRequest, animated: true)
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
                    closedRequest.ticket_id = self.tbl_request_logs![indexPath.row].SERVER_ID_PK
                    self.navigationController?.pushViewController(closedRequest, animated: true)
                }
            }
        }
    }
}
