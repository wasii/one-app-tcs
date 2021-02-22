    //
//  IMSAllRequestsViewController.swift
//  tcs_one_app
//
//  Created by TCS on 31/12/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import MBCircularProgressBar


class IMSAllRequestsViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var monthlyBtn: UIButton!
    
    @IBOutlet weak var submittedProgressView: MBCircularProgressBarView!
    @IBOutlet weak var inreviewProgressView: MBCircularProgressBarView!
    @IBOutlet weak var closedProgressView: MBCircularProgressBarView!
    @IBOutlet var sortedImages: [UIImageView]!
    
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
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
    
    
    var current_user = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "All Requests"
        
        self.makeTopCornersRounded(roundView: self.mainView)
        self.selected_query = "Weekly"
        self.tableView.register(UINib(nibName: "RequestListingTableCell", bundle: nil), forCellReuseIdentifier: "RequestListingCell")
//        self.tableView.rowHeight = 70
        self.tableView.rowHeight = 100
        
//        self.searchTextField.delegate = self
        user_permission = AppDelegate.sharedInstance.db!.read_tbl_UserPermission()
        
        
        for perm in user_permission {
            var breakk = false
            let p = perm.PERMISSION
            for constant in IMSAllPermissions {
                if p == constant {
                    switch p {
                    case IMS_Submitted, IMS_Inprogress_Ro, IMS_Inprogress_Rhod:
                        current_user = IMS_InputBy_LineManager
                        break
                    case IMS_Inprogress_Hod:
                        current_user = IMS_InputBy_Hod
                        break
                    case IMS_Inprogress_Cs:
                        current_user = IMS_InputBy_CentralSecurity
                        break
                    case IMS_Inprogress_As:
                        current_user = IMS_InputBy_AreaSecurity
                        break
                    case IMS_Inprogress_Hs, IMS_Inprogress_Rds:
                        current_user = IMS_InputBy_HeadSecurity
                        break
                    case IMS_Inprogress_Ds:
                        current_user = IMS_InputBy_DirectorSecurity
                        break
                    case IMS_Inprogress_Fs, IMS_Inprogress_Ins:
                        current_user = IMS_InputBy_FinancialService
                        break
                    case IMS_Inprogress_Hr:
                        current_user = IMS_InputBy_HumanResource
                        break
                    case IMS_Inprogress_Fi:
                        current_user = IMS_InputBy_Finance
                        break
                    case IMS_Inprogress_Ca:
                        current_user = IMS_InputBy_Controller
                        break
                    default:
                        break
                    }
                    breakk = true
                    break
                }
            }
            if breakk {
                break
            }
        }
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
        var query = ""
        
        if start_day == nil && end_day == nil {
            let previousDate = getPreviousDays(days: -numberOfDays)
            let weekly = previousDate.convertDateToString(date: previousDate)
            
            query = "SELECT * FROM REQUEST_LOGS WHERE CREATED_DATE >= '\(weekly)' AND CREATED_DATE <= '\(getLocalCurrentDate())' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
        } else {
             query = "SELECT * FROM REQUEST_LOGS WHERE CREATED_DATE >= '\(startday!)' AND CREATED_DATE <= '\(endday!)' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
        }
        tbl_request_logs = AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: query)
        var temp_logs : [tbl_Hr_Request_Logs]?
        if let _ = tbl_request_logs {
            temp_logs = [tbl_Hr_Request_Logs]()

            for index in tbl_request_logs! {
                let permissions = AppDelegate.sharedInstance.db?.read_tbl_UserPermission()
                let isGranted = permissions?.contains(where: { (perm) -> Bool in
                    let permission = String(perm.PERMISSION.lowercased().split(separator: " ").last!)
                    return permission == index.TICKET_STATUS?.lowercased()
                }) ?? false

                if index.LOGIN_ID == Int(CURRENT_USER_LOGGED_IN_ID) && isGranted {
                    if current_user == IMS_Remarks_Line_Manager {
                        if index.LINE_MANAGER1 == Int(CURRENT_USER_LOGGED_IN_ID)! {
                            temp_logs?.append(index)
                            continue
                        }
                    }
                    if current_user == IMS_Remarks_Department_Head {
                        if index.LINE_MANAGER2 == Int(CURRENT_USER_LOGGED_IN_ID)! {
                            temp_logs?.append(index)
                            continue
                        }
                    }
                }
                let query = "SELECT * FROM \(db_grievance_remarks) WHERE EMPL_NO = '\(Int(CURRENT_USER_LOGGED_IN_ID)!)' AND TICKET_ID = '\(index.SERVER_ID_PK!)' AND REMARKS_INPUT = '\(current_user)'"
                
                
                let history = AppDelegate.sharedInstance.db?.read_tbl_hr_grievance(query: query)
                if history!.count > 0 {
                    temp_logs?.append(index)
                    continue
                }
                if index.LOGIN_ID == Int(CURRENT_USER_LOGGED_IN_ID) {
                    continue
                }
                else {
                    temp_logs?.append(index)
                }
            }
        }
        tbl_request_logs = temp_logs
        
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
            height = CGFloat((filtered_data!.count * 100) + 300)
        } else {
            height = CGFloat((tbl_request_logs!.count * 100) + 300)
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
    func setupCircularViews() {
        
        let pendingCount = self.tbl_request_logs?.filter({ (logs) -> Bool in
            logs.TICKET_STATUS == IMS_Status_Submitted
            }).count
        let approvedCount = self.tbl_request_logs?.filter({ (logs) -> Bool in
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
        let rejectedCount = self.tbl_request_logs?.filter({ (logs) -> Bool in
            logs.TICKET_STATUS == IMS_Status_Closed
        }).count
        
        self.submittedProgressView.maxValue = CGFloat(self.tbl_request_logs?.count ?? 0)
        self.inreviewProgressView.maxValue = CGFloat(self.tbl_request_logs?.count ?? 0)
        self.closedProgressView.maxValue = CGFloat(self.tbl_request_logs?.count ?? 0)
        
        UIView.animate(withDuration: 0.5) {
            self.submittedProgressView.value = CGFloat(pendingCount ?? 0)
            self.inreviewProgressView.value = CGFloat(approvedCount ?? 0)
            self.closedProgressView.value = CGFloat(rejectedCount ?? 0)
        }
    }
    
    func filteredData(status: String) {
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
    
    
    @IBAction func monthlyBtnTapped(_ sender: Any) {
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
    
    @IBAction func sortedBtnTapped(_ sender: UIButton) {
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
}



//MARK: DateSelection Delegate
extension IMSAllRequestsViewController: DateSelectionDelegate {
    func requestModeSelected(selected_query: String) {}
    
    func dateSelection(numberOfDays: Int, selected_query: String) {
        self.selected_query = selected_query
        self.numberOfDays = numberOfDays
        self.monthlyBtn.setTitle(selected_query, for: .normal)
        
        self.start_day = nil
        self.end_day = nil
        
        self.setupJSON(numberOfDays: numberOfDays,  startday: nil, endday: nil)
    }
    func dateSelection(startDate: String, endDate: String, selected_query: String) {
        self.selected_query = selected_query
        self.monthlyBtn.setTitle(selected_query, for: .normal)
        
        self.start_day = startDate
        self.end_day = endDate
        self.setupJSON(numberOfDays: 0, startday: startDate, endday: endDate)
    }
}


//MARK: UITableview Delegate and Datasource
extension IMSAllRequestsViewController: UITableViewDataSource, UITableViewDelegate {
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
        cell.mainHeading.text = data!.INCIDENT_TYPE!
        if let department = AppDelegate.sharedInstance.db?.read_tbl_department(query: "SELECT * FROM \(db_lov_department) WHERE SERVER_ID_PK = '\(data?.DEPARTMENT ?? "")'").first {
            cell.subHeading.text = department.DEPAT_NAME
        }
        cell.date.text = data!.CREATED_DATE?.dateSeperateWithT ?? ""
        //HR FEEDBACK
        cell.ticketID.text = "Ticket Id: \(data!.SERVER_ID_PK!)"
        //HR FEEDBACK
        
        switch data!.TICKET_STATUS {
        case IMS_Status_Submitted:
            cell.status.text = "Submitted"
            cell.status.textColor = UIColor.pendingColor()
            break
        case IMS_Status_Inprogress:
            cell.status.text = IMS_Status_Inprogress
            cell.status.textColor = UIColor.approvedColor()
            break
        case IMS_Status_Inprogress_Rm:
            cell.status.text = INPROGRESS_INITIATOR
            cell.status.textColor = UIColor.approvedColor()
            break
        case IMS_Status_Inprogress_Ro, IMS_Status_Inprogress_Rhod:
            cell.status.text = INPROGRESS_LINEMANAGER
            cell.status.textColor = UIColor.approvedColor()
            break
        case IMS_Status_Inprogress_Hod:
            cell.status.text = INPROGRESS_HOD
            cell.status.textColor = UIColor.approvedColor()
            break
        case IMS_Status_Inprogress_Cs:
            cell.status.text = INPROGRESS_CS
            cell.status.textColor = UIColor.approvedColor()
            break
        case IMS_Status_Inprogress_As:
            cell.status.text = INPROGRESS_AS
            cell.status.textColor = UIColor.approvedColor()
            break
        case IMS_Status_Inprogress_Hs, IMS_Status_Inprogress_Rds:
            cell.status.text = INPROGRESS_HS
            cell.status.textColor = UIColor.approvedColor()
            break
        case IMS_Status_Inprogress_Ds:
            cell.status.text = INPROGRESS_DS
            cell.status.textColor = UIColor.approvedColor()
            break
        case IMS_Status_Inprogress_Fs, IMS_Status_Inprogress_Ins:
            cell.status.text = INPROGRESS_FS
            cell.status.textColor = UIColor.approvedColor()
            break
        case IMS_Status_Inprogress_Hr:
            cell.status.text = INPROGRESS_HR
            cell.status.textColor = UIColor.approvedColor()
            break
        case IMS_Status_Inprogress_Fi:
            cell.status.text = INPROGRESS_FI
            cell.status.textColor = UIColor.approvedColor()
            break
        case IMS_Status_Inprogress_Ca:
            cell.status.text = INPROGRESS_CA
            cell.status.textColor = UIColor.approvedColor()
            break
        case IMS_Status_Closed:
            cell.status.text = IMS_Status_Closed
            cell.status.textColor = UIColor.rejectedColor()
        default:
            print("Wrong Ticket Status")
            break
        }
        
        cell.type.text = "IMS"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.indexPath = indexPath
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "IMSViewUpdateRequestViewController") as! IMSViewUpdateRequestViewController
        
        let permissions = AppDelegate.sharedInstance.db?.read_tbl_UserPermission()
        if isFiltered {
            let current_ticket = self.filtered_data![indexPath.row]
            
            var isGranted = false
            if current_ticket.TICKET_STATUS == "Closed" {
                isGranted = false
            } else {
                isGranted = permissions?.contains(where: { (perm) -> Bool in
                    let permission = String(perm.PERMISSION.lowercased().split(separator: " ").last!)
                    return permission == current_ticket.TICKET_STATUS?.lowercased()
                }) ?? false
            }
            print(isGranted)
            
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
            
            controller.ticket_request = current_ticket
            controller.current_user = current_user
            controller.havePermissionToEdit = isGranted
            
            print(current_user)
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            let current_ticket = self.tbl_request_logs![indexPath.row]
            var isGranted = false
            if current_ticket.TICKET_STATUS == "Closed" {
                isGranted = false
            } else {
                isGranted = permissions?.contains(where: { (perm) -> Bool in
                    let permission = String(perm.PERMISSION.lowercased().split(separator: " ").last!)
                    return permission == current_ticket.TICKET_STATUS?.lowercased()
                }) ?? false
            }
            print(isGranted)
            
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
            
            if IMS_Inprogress_Fs == "\(current_user)" {
                if current_ticket.TICKET_STATUS == IMS_Status_Inprogress_Ins {
                    isGranted = true
                    controller.current_user = IMS_Inprogress_Ins
                } else {
                    controller.current_user = current_user
                }
            } else if IMS_Inprogress_Ins == "\(current_user)" {
                if current_ticket.TICKET_STATUS == IMS_Status_Inprogress_Fs {
                    controller.current_user = IMS_Inprogress_Ins
                    isGranted = false
                }
            } else {
                controller.current_user = current_user
            }
            
            controller.ticket_request = current_ticket
            
            controller.havePermissionToEdit = isGranted
            
            print(current_user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
