//
//  HRHelpDeskRequestViewController.swift
//  tcs_one_app
//
//  Created by ibs on 28/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import MBCircularProgressBar

class HRHelpDeskRequestViewController: BaseViewController {

    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var pendingCircularView: MBCircularProgressBarView!
    
    @IBOutlet weak var approvedCircularView: MBCircularProgressBarView!
    @IBOutlet weak var rejectedCircularView: MBCircularProgressBarView!
    
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
    
    
    var filtered_status = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "All Request"
        
        self.makeTopCornersRounded(roundView: self.mainView)
        self.selected_query = "Weekly"
        self.tableView.register(UINib(nibName: "RequestListingTableCell", bundle: nil), forCellReuseIdentifier: "RequestListingCell")
        self.tableView.rowHeight = 80
        
        self.searchTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if indexPath != nil {
            self.tableView.deselectRow(at: indexPath!, animated: true)
        }
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
        setupJSON(numberOfDays: numberOfDays, startday: start_day, endday: end_day)
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
        
    }
    func setupJSON(numberOfDays: Int, startday: String?, endday: String?) {
        var query = ""
        
        if start_day == nil && end_day == nil {
            let previousDate = getPreviousDays(days: -numberOfDays)
            let weekly = previousDate.convertDateToString(date: previousDate)
            
            query = "SELECT * FROM REQUEST_LOGS WHERE RESPONSIBLE_EMPNO = '\(CURRENT_USER_LOGGED_IN_ID)' AND CREATED_DATE >= '\(weekly)' AND CREATED_DATE <= '\(getLocalCurrentDate())' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
        } else {
             query = "SELECT * FROM REQUEST_LOGS WHERE RESPONSIBLE_EMPNO = '\(CURRENT_USER_LOGGED_IN_ID)' AND CREATED_DATE >= '\(startday!)' AND CREATED_DATE <= '\(endday!)' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
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
            logs.TICKET_STATUS == "Pending" || logs.TICKET_STATUS == "pending"
            }).count
        let approvedCount = self.tbl_request_logs?.filter({ (logs) -> Bool in
            logs.TICKET_STATUS == "Approved" || logs.TICKET_STATUS == "approved"
        }).count
        let rejectedCount = self.tbl_request_logs?.filter({ (logs) -> Bool in
            logs.TICKET_STATUS == "Rejected" || logs.TICKET_STATUS == "rejected"
        }).count
        
        self.pendingCircularView.maxValue = CGFloat(pendingCount ?? 0)
        self.approvedCircularView.maxValue = CGFloat(approvedCount ?? 0)
        self.rejectedCircularView.maxValue = CGFloat(rejectedCount ?? 0)
        UIView.animate(withDuration: 0.5) {
            self.pendingCircularView.value = CGFloat(pendingCount ?? 0)
            self.approvedCircularView.value = CGFloat(approvedCount ?? 0)
            self.rejectedCircularView.value = CGFloat(rejectedCount ?? 0)
        }
        
    }
    
    func filteredData(status: String) {
        self.filtered_data = self.tbl_request_logs?.filter({ (logs) -> Bool in
            logs.TICKET_STATUS?.lowercased() == status.lowercased()
        })
        self.filtered_status = status
        self.isFiltered = true
        self.tableView.reloadData()
        self.setupTableViewHeight(isFiltered: true)
        self.setupCircularViews()
    }
    
    
    @IBAction func sortingBtnTapped(_ sender: UIButton) {
        //0:PENDING
        //1:APPROVED
        //2:REJECTED
        if self.sortingButtonHighlighters[sender.tag].image != nil {
            self.sortingButtonHighlighters[sender.tag].image = nil
            
            isFiltered = false
            self.filtered_status = ""
            self.tableView.reloadData()
            return
        } else {
            self.sortingButtonHighlighters.forEach { (UIImageView) in
                UIImageView.image = nil
            }
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
        }
    }
    
    @IBAction func thisWeek_Tapped(_ sender: Any) {
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


extension HRHelpDeskRequestViewController: UITableViewDelegate, UITableViewDataSource {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.indexPath = indexPath
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "UpdateRequestViewController") as! UpdateRequestViewController
        let viewcontroller = self.storyboard?.instantiateViewController(withIdentifier: "NewRequestViewController") as! NewRequestViewController
        
        if isFiltered {
            if self.filtered_data![indexPath.row].TICKET_STATUS == "Pending" {
                if self.filtered_data![indexPath.row].RESPONSIBLE_EMPNO == Int(CURRENT_USER_LOGGED_IN_ID) {
                    controller.request_log = self.filtered_data![indexPath.row]
                    self.navigationController?.pushViewController(controller, animated: true)
                } else {
                    viewcontroller.ticket_id = self.filtered_data![indexPath.row].SERVER_ID_PK
                    self.navigationController?.pushViewController(viewcontroller, animated: true)
                }
            } else {
                controller.request_log = self.filtered_data![indexPath.row]
                self.navigationController?.pushViewController(controller, animated: true)
            }
            
            
        } else {
            if self.tbl_request_logs![indexPath.row].TICKET_STATUS == "Pending" {
                if self.tbl_request_logs![indexPath.row].RESPONSIBLE_EMPNO == Int(CURRENT_USER_LOGGED_IN_ID) {
                    controller.request_log = self.tbl_request_logs![indexPath.row]
                    self.navigationController?.pushViewController(controller, animated: true)
                } else {
                    viewcontroller.ticket_id = self.tbl_request_logs![indexPath.row].SERVER_ID_PK
                    self.navigationController?.pushViewController(viewcontroller, animated: true)
                }
            } else {
                controller.request_log = self.tbl_request_logs![indexPath.row]
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
//        self.navigationController?.pushViewController(controller, animated: true)
    }
}



extension HRHelpDeskRequestViewController: UITextFieldDelegate {
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


extension HRHelpDeskRequestViewController: DateSelectionDelegate {
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
        self.setupJSON(numberOfDays: numberOfDays, startday: startDate, endday: endDate)
    }
}
