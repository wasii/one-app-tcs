//
//  NotificationsViewController.swift
//  tcs_one_app
//
//  Created by ibs on 19/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit

class NotificationsViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var hightAlertSwitch: UISwitch!
    @IBOutlet weak var highAlertLabel: UILabel!
    var ticket_id: Int?
    var hr_notification: [tbl_HR_Notification_Request]?
    var indexPath: IndexPath?
    
    var isSwitchOn = false
    override func viewDidAppear(_ animated: Bool) {
        if indexPath != nil {
            self.tableView.deselectRow(at: self.indexPath!, animated: true)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(refreshedView(notification:)), name: .refreshedViews, object: nil)
        hightAlertSwitch.addTarget(self, action: #selector(switchChanged(mySwitch:)), for: .valueChanged)
        if isSwitchOn {
            self.getBreachedTickets()
        } else {
            setup()
        }
    }
    @objc func refreshedView(notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.setup()
        }
        
    }
    @objc func switchChanged(mySwitch: UISwitch) {
//        let value = mySwitch.isOn
        if mySwitch.isOn {
            print("ON")
            self.isSwitchOn = true
            self.getBreachedTickets()
        } else {
            self.isSwitchOn = false
            setup_hr_notification { (success, count) in
                if success {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        let height = (100 * count) + 50
                        if CGFloat(height) > UIScreen.main.bounds.height {
                            self.mainViewHeightConstraint.constant = CGFloat(height)
                        } else {
                            self.mainViewHeightConstraint.constant = UIScreen.main.bounds.height
                        }
                        self.mainView.layoutIfNeeded()
                        self.tableView.reloadData()
                    }
                }
            }
            print("OFF")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSingleNavigationButton()
        self.title = "Notifications"
        self.mainViewHeightConstraint.constant = UIScreen.main.bounds.height
        self.makeTopCornersRounded(roundView: self.mainView)
        
        self.tableView.register(UINib(nibName: "RequestListingTableCell", bundle: nil), forCellReuseIdentifier: "RequestListingCell")
        self.tableView.rowHeight = 100
    }
    
    
    func setup_hr_notification(_ handler: @escaping(_ success: Bool, _ count: Int) -> Void) {
        let query = "SELECT n.*,r.TICKET_STATUS as LOG_TICKET FROM \(db_hr_notifications) n LEFT JOIN \(db_hr_request) r ON n.TICKET_ID = r.SERVER_ID_PK WHERE r.CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' ORDER BY n.CREATED_DATE desc"
        hr_notification = AppDelegate.sharedInstance.db?.read_tbl_hr_notification_request(query: query)
        
        if hr_notification!.count > 0 {
//            hr_notification = hr_notification?.filter({ (not1) -> Bool in
//                not1.MODULE_ID == 1 || not1.MODULE_ID == 2
//            })
            
            hr_notification = hr_notification?.sorted(by: { (req1, req2) -> Bool in
                req1.CREATED_DATE > req2.CREATED_DATE
            })
            
            handler(true, hr_notification!.count)
        }
    }
    
    func setup() {
        setup_hr_notification { (success, count) in
            if success {
                DispatchQueue.main.async {
                    let height = (100 * count) + 50
                    if CGFloat(height) > UIScreen.main.bounds.height {
                        self.mainViewHeightConstraint.constant = CGFloat(height)
                    } else {
                        self.mainViewHeightConstraint.constant = UIScreen.main.bounds.height
                    }
                    self.mainView.layoutIfNeeded()
                    self.tableView.reloadData()
                    
                    if self.ticket_id != nil {
                        let index = self.hr_notification!.firstIndex { (log) -> Bool in
                            log.TICKET_ID == self.ticket_id!
                        }
                        print(index)
                    }
                }
            }
        }
        if let management_bar = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: PERMISSION_HR_LISTING_MANAGEMENT_BAR).count {
            if management_bar > 0 {
                highAlertLabel.isHidden = false
                hightAlertSwitch.isHidden = false
                tableViewTopConstraint.constant = 50
            }
        }
        if let management_bar = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: PERMISSION_GRIEVENCE_LISTING_MANAGEMENT_BAR).count {
            if management_bar > 0 {
                highAlertLabel.isHidden = false
                hightAlertSwitch.isHidden = false
                tableViewTopConstraint.constant = 50
            }
        }
    }
    
    func getBreachedTickets() {
        var tat = [tbl_HR_Notification_Request]()
        if let notifications = self.hr_notification {
            for dictionary in notifications {
                let createdDateString = dictionary.CREATED_DATE
                var updatedDateString = dictionary.REQUEST_LOG.first?.UPDATED_DATE ?? ""
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                
                if updatedDateString == "" {
                    let diffComponents = Calendar.current.dateComponents([.day],
                                                                         from: dateFormatter.date(from: createdDateString)!,
                                                                         to: Date())
                    if diffComponents.day! >= dictionary.REQUEST_LOG.first!.ESCALATE_DAYS! {
                        print("tat breach")
                        tat.append(dictionary)
                    }
                } else {
                    
                    dateFormatter.dateFormat = "dd-MMM-yy"
                    if let tempDate = dateFormatter.date(from: updatedDateString) {
                        let t = tempDate.convertDateToString(date: tempDate)

                        print(t.dateOnly+createdDateString.timeOnly)
                        let tt = t.dateOnly+"T"+createdDateString.timeOnly
                        updatedDateString = tt
                    }
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    let diffComponents = Calendar.current.dateComponents([.day],
                                                                         from: dateFormatter.date(from: createdDateString)!,
                                                                         to: dateFormatter.date(from: updatedDateString)!)
                    
                    
                    if diffComponents.day! >= dictionary.REQUEST_LOG.first!.ESCALATE_DAYS! {
                        print("tat breach")
                        tat.append(dictionary)
                    }
                }
            }
        }
        tat = tat.filter({ (notifications) -> Bool in
            notifications.REQUEST_LOG.first?.TICKET_STATUS == "Pending" ||
            notifications.REQUEST_LOG.first?.TICKET_STATUS == "pending"
        })
        self.hr_notification = tat
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            let height = (100 * tat.count) + 50
            if CGFloat(height) > UIScreen.main.bounds.height {
                self.mainViewHeightConstraint.constant = CGFloat(height)
            } else {
                self.mainViewHeightConstraint.constant = UIScreen.main.bounds.height
            }
            self.mainView.layoutIfNeeded()
            self.tableView.reloadData()
        }
    }
}

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.hr_notification?.count {
            return count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestListingCell") as! RequestListingTableCell
        
        let data = self.hr_notification![indexPath.row]
        if data.READ_STATUS_DTTM != "a" {
            //read same white
            cell.mainView.bgColor = UIColor.white
        } else {
            cell.mainView.bgColor = UIColor(red: 220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0, alpha: 1.0)
            //unread gray
        }
        cell.mainHeading.text = data.NOTIFY_TITLE
        cell.subHeading.text = data.TITLE_MESSAGE
        //HR FEEDBACK
        cell.ticketID.text = "\(data.TICKET_ID)"
        //HR FEEDBACK
        
        switch data.MODULE_ID {
        case 1:
            cell.status.text = data.TICKET_STATUS
            cell.type.text = "HR Help Desk"
            switch data.TICKET_STATUS.lowercased() {
                case "pending":
                    cell.status.textColor = UIColor.pendingColor()
                    break
                case "approved":
                    cell.status.textColor = UIColor.approvedColor()
                    cell.status.text = "Completed"
                    break
                case "rejected":
                    cell.status.textColor = UIColor.rejectedColor()
                    break
            default:
                break
            }
            break
        case 2:
            cell.status.text = data.TICKET_STATUS
            cell.type.text = "Grievance"
            switch data.TICKET_STATUS.lowercased() {
            case "submitted":
                cell.status.textColor = UIColor.pendingColor()
                break
            case "inprogress-er", "inprogress-s", "responded", "investigating", "inprogress-ceo", "inprogress-srhrbp":
                cell.status.textColor = UIColor.approvedColor()
                cell.status.text = INREVIEW
                break
            case "closed":
                cell.status.textColor = UIColor.rejectedColor()
                break
            default:
                break
            }
            break
        case 3:
            cell.status.text = data.TICKET_STATUS
            cell.type.text = "IMS"
            switch data.TICKET_STATUS {
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
            break
        default:
            break
        }
        
//        cell.status.text = data.TICKET_STATUS
//        if data.TICKET_STATUS == "approved" || data.TICKET_STATUS == "Approved" {
//            cell.status.text = "Completed"
//        }
//        if data.TICKET_STATUS == "rejected" {
//            cell.status.text = "Rejected"
//        }
//        switch data.TICKET_STATUS {
//        case "Pending", "pending", "Submitted", "submitted":
//            cell.status.textColor = UIColor.pendingColor()
//            break
//        case "Approved", "approved", "Completed", "completed":
//            cell.status.textColor = UIColor.approvedColor()
//            break
//        case "Rejected", "rejected", "Closed", "closed":
//            cell.status.textColor = UIColor.rejectedColor()
//            break
//        case "Inprogress-Er", "Inprogress-S", "Responded", "Investigating", "Inprogress-Ceo", "Inprogress-Srhrbp":
//            cell.status.textColor = UIColor.approvedColor()
//            cell.status.text = INREVIEW
//            break
//        case IMS_Status_Inprogress_As, IMS_Status_Inprogress_Hs, IMS_Status_Inprogress_Ds, IMS_Status_Inprogress_Cs, IMS_Status_Inprogress_Ro, IMS_Status_Inprogress_Ca, IMS_Status_Inprogress_Hr, IMS_Status_Inprogress_Fi, IMS_Status_Inprogress_Rm, IMS_Status_Inprogress_Fs, IMS_Status_Inprogress_Rds, IMS_Status_Inprogress_Hod, IMS_Status_Inprogress_Ins, IMS_Status_Inprogress_Rhod:
//            cell.status.textColor = UIColor.approvedColor()
//            cell.status.text = IMS_Status_Inprogress
//        default:
//            break
//        }
        if data.CREATED_DATE == "" {
            cell.date.text = data.CREATED_DATE
        } else {
            cell.date.text = data.CREATED_DATE.dateSeperateWithT
        }
        
//        cell.type.text = data.MODULE_DSCRP
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.hr_notification![indexPath.row].READ_STATUS_DTTM == "a" {
            let record_id = self.hr_notification![indexPath.row].RECORD_ID
            let columns = ["READ_STATUS_DTTM"]
            let values  = ["1"]
            
            AppDelegate.sharedInstance.db?.updateTables(tableName: db_hr_notifications, columnName: columns, updateValue: values, onCondition: "RECORD_ID = '\(record_id)'", { (success) in
                if success {
                    DispatchQueue.main.async {
                        let read_notification = [
                            "hr_request": [
                                "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                                "notificationid" :"\(record_id)"
                            ]
                        ]
                        let params = self.getAPIParameter(service_name: READ_NOTIFICATION, request_body: read_notification)
                        NetworkCalls.read_notification(params: params) { (success, response) in
                            if success {
                                print("NOTIFICATION READ.")
                            } else {
                                print("NOTIFICATION NOT READ.")
                            }
                        }
                    }
                }
            })
        }
        
        self.indexPath = indexPath
        self.tableView.deselectRow(at: indexPath, animated: true)
        let ticket_id = self.hr_notification![indexPath.row].TICKET_ID
        let module_id = self.hr_notification![indexPath.row].MODULE_ID
        switch module_id {
        case 1:
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let ticket_status = self.hr_notification![indexPath.row].TICKET_STATUS.lowercased()
            switch ticket_status {
            case "pending":
                let responsible = AppDelegate.sharedInstance.db?.read_column(query: "SELECT RESPONSIBLE_EMPNO FROM \(db_hr_request) WHERE SERVER_ID_PK = '\(ticket_id)'") as! String
                
                if responsible == CURRENT_USER_LOGGED_IN_ID {
                    let updateController = storyboard.instantiateViewController(withIdentifier: "UpdateRequestViewController") as! UpdateRequestViewController
                    updateController.ticket_id = ticket_id
                    self.navigationController?.pushViewController(updateController, animated: true)
                } else {
                    let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestViewController") as! NewRequestViewController
                    controller.ticket_id = ticket_id
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                break
            case "approved", "rejected":
                let updateController = storyboard.instantiateViewController(withIdentifier: "UpdateRequestViewController") as! UpdateRequestViewController
                updateController.ticket_id = ticket_id
                self.navigationController?.pushViewController(updateController, animated: true)
                break
            default:
                break
            }
            break
        case 2:
            let ticket_status = self.hr_notification![indexPath.row].TICKET_STATUS.lowercased()
            if ticket_status == "closed" {
                let storyboard = UIStoryboard(name: "GrievanceStoryboard", bundle: nil)
                let closedRequest = storyboard.instantiateViewController(withIdentifier: "GrievanceViewClosedRequestViewController") as! GrievanceViewClosedRequestViewController
                closedRequest.ticket_id = self.hr_notification![indexPath.row].SERVER_ID_PK
                self.navigationController?.pushViewController(closedRequest, animated: true)
            } else {
                let user_permission = AppDelegate.sharedInstance.db!.read_tbl_UserPermission()
                if user_permission.contains(where: { permissions -> Bool in
                    let permission = String(permissions.PERMISSION.lowercased().split(separator: " ").last!)
                    return permission == ticket_status
                }) {
                    let storyboard = UIStoryboard(name: "GrievanceStoryboard", bundle: nil)
                    let viewRequest = storyboard.instantiateViewController(withIdentifier: "GrievanceViewRequestViewController") as! GrievanceViewRequestViewController
                    viewRequest.ticket_id = self.hr_notification![indexPath.row].SERVER_ID_PK
                    self.navigationController?.pushViewController(viewRequest, animated: true)
                } else {
                    let storyboard = UIStoryboard(name: "GrievanceStoryboard", bundle: nil)
                    let closedRequest = storyboard.instantiateViewController(withIdentifier: "GrievanceViewClosedRequestViewController") as! GrievanceViewClosedRequestViewController
                    closedRequest.ticket_id = self.hr_notification![indexPath.row].SERVER_ID_PK
                    self.navigationController?.pushViewController(closedRequest, animated: true)
                }
            }
            break
        case 3:
            let storyboard = UIStoryboard(name: "IMSStoryboard", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "IMSViewUpdateRequestViewController") as! IMSViewUpdateRequestViewController
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
            let current_ticket = self.hr_notification![indexPath.row]
            let isGranted = permissions?.contains(where: { (perm) -> Bool in
                let permission = String(perm.PERMISSION.lowercased().split(separator: " ").last!)
                return permission == current_ticket.TICKET_STATUS.lowercased()
            })
            
            let query = "SELECT * FROM \(db_hr_request) WHERE SERVER_ID_PK = '\(current_ticket.TICKET_ID)'"
            if let data = AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: query).first {
                controller.ticket_request = data
                controller.current_user = current_user
                controller.havePermissionToEdit = isGranted!
                
                print(current_user)
                if current_user == "" {
                    let controller = storyboard.instantiateViewController(withIdentifier: "IMSNewRequestViewController") as! IMSNewRequestViewController
                    controller.current_ticket = data
                    self.navigationController?.pushViewController(controller, animated: true)
                } else {
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
            
            break
        default:
            break
        }
    }
}
