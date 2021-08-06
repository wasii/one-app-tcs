//
//  BaseViewController.swift
//  tcs_one_app
//
//  Created by ibs on 15/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import Photos
import SwiftyJSON
import FirebaseMessaging

class BaseViewController: UIViewController {

    var searchQueryTimer: Timer?
    var dismiss = false
    
    var isNavigate = false
    var geotifications: [Geotification] = []
    lazy var locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        view.backgroundColor = UIColor.nativeRedColor()
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(logoutUser), name: .logoutUser, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    @objc func upload_pending_request() {
        sync_pending_request()
    }
    func freezeScreen() {
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    func unFreezeScreen() {
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func makeTopCornersRounded(roundView: UIView) {
        
        roundView.clipsToBounds = true
        roundView.layer.cornerRadius = 40
        roundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func removeTopRounderCorners(roundedView: UIView) {
        roundedView.layer.mask = nil
    }
    
    func setTitle(title: String) {
        self.navigationController?.navigationBar.topItem?.title = title
    }
    
    func addHomeNavigationButton() {
        let sync = UIButton()
        sync.setImage(UIImage(named: "sync"), for: .normal)
        sync.addTarget(self, action: #selector(syncServerData), for: .touchUpInside)
        let syncBtn = UIBarButtonItem(customView: sync)
        
        let setting = UIButton()
        setting.setImage(UIImage(named: "settings-navbar"), for: .normal)
        setting.addTarget(self, action: #selector(openActionSheet), for: .touchUpInside)
        let settingBtn = UIBarButtonItem(customView: setting)
        
        self.navigationItem.rightBarButtonItems = [settingBtn, syncBtn]
    }
    
    func addSingleNavigationButton() {
        let sync = UIButton()
        sync.setImage(UIImage(named: "sync"), for: .normal)
        sync.addTarget(self, action: #selector(syncServerData), for: .touchUpInside)
        let syncBtn = UIBarButtonItem(customView: sync)
        self.navigationItem.rightBarButtonItem = syncBtn
    }
    
    func addDoubleNavigationButtons() {
        let sync = UIButton()
        sync.setImage(UIImage(named: "sync"), for: .normal)
        sync.addTarget(self, action: #selector(syncServerData), for: .touchUpInside)
        let syncBtn = UIBarButtonItem(customView: sync)
        
        let notification = UIButton()
        notification.setImage(UIImage(named: "notification"), for: .normal)
        notification.addTarget(self, action: #selector(openNotificationViewController), for: .touchUpInside)
        let notificationBtn = UIBarButtonItem(customView: notification)
        
        let setting = UIButton()
        setting.setImage(UIImage(named: "settings-navbar"), for: .normal)
        setting.addTarget(self, action: #selector(openActionSheet), for: .touchUpInside)
        let settingBtn = UIBarButtonItem(customView: setting)
        
        self.navigationItem.rightBarButtonItems = [notificationBtn, syncBtn, settingBtn]
    }
    
    func addTripleNavigationButtons() {
        let sync = UIButton()
        sync.setImage(UIImage(named: "sync"), for: .normal)
        sync.addTarget(self, action: #selector(syncServerData), for: .touchUpInside)
        let syncBtn = UIBarButtonItem(customView: sync)
        
        let notification = UIButton()
        notification.setImage(UIImage(named: "notification"), for: .normal)
        notification.addTarget(self, action: #selector(openNotificationViewController), for: .touchUpInside)
        let notificationBtn = UIBarButtonItem(customView: notification)
        
        let setting = UIButton()
        setting.setImage(UIImage(named: "settings-navbar"), for: .normal)
        setting.addTarget(self, action: #selector(openActionSheet), for: .touchUpInside)
        let settingBtn = UIBarButtonItem(customView: setting)
        
        self.navigationItem.rightBarButtonItems = [notificationBtn, syncBtn, settingBtn]
    }
    
    @objc func openActionSheet(sender: UIButton) {
        let actionSheet = UIAlertController(title: "\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        let customAlertView:CustomAlertView = Bundle.main.loadNibNamed("CustomAlertView", owner: self, options: nil)?.first as! CustomAlertView
        
        actionSheet.view.addSubview(customAlertView)
        customAlertView.logoutBtn.addTarget(self, action: #selector(logoutPressed), for: .touchUpInside)
        customAlertView.userInfoBtn.addTarget(self, action: #selector(userInfoPressed), for: .touchUpInside)
        customAlertView.backgroundColor = UIColor.clear
        customAlertView.translatesAutoresizingMaskIntoConstraints = false
        customAlertView.topAnchor.constraint(equalTo: actionSheet.view.topAnchor, constant: 8).isActive = true
        customAlertView.rightAnchor.constraint(equalTo: actionSheet.view.rightAnchor, constant: -10).isActive = true
        customAlertView.leftAnchor.constraint(equalTo: actionSheet.view.leftAnchor, constant: 10).isActive = true
        customAlertView.heightAnchor.constraint(equalToConstant: 145).isActive = true
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func logoutPressed() {
        print("Lougout pressed")
        self.dismiss(animated: true) {
            let storyboard = UIStoryboard(name: "Popups", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "LogoutPopupViewController") as! LogoutPopupViewController

            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .overFullScreen
            }

            controller.modalTransitionStyle = .crossDissolve

            Helper.topMostController().present(controller, animated: true, completion: nil)
            return 
        }
    }
    @objc func userInfoPressed() {
        print("Userinfo Pressed")
        self.dismiss(animated: true) {
            let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
            let comingsoon = storyboard.instantiateViewController(withIdentifier: "ComingSoonViewController") as! ComingSoonViewController
            comingsoon.modalTransitionStyle = .crossDissolve
            if #available(iOS 13.0, *) {
                comingsoon.modalPresentationStyle = .overFullScreen
            }
            comingsoon.emp_id = CURRENT_USER_LOGGED_IN_ID
            Helper.topMostController().present(comingsoon, animated: true, completion: nil)
        }
    }
    @objc func openNotificationViewController(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "NotificationsViewController") as! NotificationsViewController
        
        
        let notification_button = self.navigationItem.rightBarButtonItems?.last
        notification_button?.removeBadge()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func syncServerData() {
        let storyboard = UIStoryboard(name: "UserCredentials", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "FetchUserDataViewController") as! FetchUserDataViewController
        
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        controller.isPresented = true
        Helper.topMostController().present(controller, animated: true, completion: nil)
    }
    
    @objc func sync_pending_request() {
        
        let request_logs = AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: "SELECT * FROM \(db_hr_request)").filter({ (logs) -> Bool in
            logs.REQUEST_LOGS_SYNC_STATUS == 0 && logs.CURRENT_USER == CURRENT_USER_LOGGED_IN_ID && ((logs.TICKET_STATUS == "pending" || logs.TICKET_STATUS == "Pending"))
        })
        
        if request_logs!.count > 0 {
            for log in request_logs! {
                let request_body = [
                    "hr_request":[
                        "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                        "tickets":[
                            [
                                "employeeID":"\(CURRENT_USER_LOGGED_IN_ID)",
                                "requesterEmployeeID":"\(log.REQ_ID!)",
                                "requestModeID":"\(log.REQ_MODE!)",
                                "matrixID":"\(log.MAT_ID!)",
                                "masterQueryID":"\(log.MQ_ID!)",
                                "detailQueryID":"\(log.DQ_ID!)",
                                "requesterRemarks":"\(log.REQ_REMARKS!)", //HR_REMARKS
                                "hrRemarks":"",
                                "refId": log.REF_ID,
                                "ticketDate":getCurrentDate(),
                                "req_case_desc": log.REQ_CASE_DESC!
                            ]
                        ]
                    ]
                ]
                let params = self.getAPIParameter(service_name: REQUEST_LOGS, request_body: request_body)
                NetworkCalls.request_logs(params: params) { (success, response) in
                    if success {
                        if let ticket_logs = JSON(response).first?.1 {
                            let ref_id = ticket_logs["REF_ID"].string ?? ""
                            print("Offline Data REF_ID: \(log.REF_ID ?? "")")
                            print("Server Based REF_ID: \(ref_id)")
                            print("RESPONSIBLE_EMPNO: \(ticket_logs["RESPONSIBLE_EMPNO"].int ?? 0)")
                            DispatchQueue.main.async {
                                AppDelegate.sharedInstance.db?.deleteRow(tableName: db_hr_request, column: "REF_ID", ref_id: ref_id, handler: { success in
                                    if success {
                                        do {
                                            let dictionary = try ticket_logs.rawData()
                                            let hr_helpdesk = try JSONDecoder().decode(HrRequest.self, from: dictionary)
                                            
                                            DispatchQueue.main.async {
                                                AppDelegate.sharedInstance.db?.insert_tbl_hr_request(hrrequests: hr_helpdesk, { dump_succes in
                                                    if success {
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                            NotificationCenter.default.post(Notification.init(name: .refreshedViews))
//                                                            Helper.topMostController().view.makeToast("Request Saved Successfully")
                                                        }
                                                        print("DUMPED HR UPDATED TICKET")
                                                    }
                                                })
                                            }
                                        } catch let err {
                                            print(err.localizedDescription)
                                        }
                                    }
                                })
                            }
                        }
                    } else {
                        print("\(REQUEST_LOGS): FAILED")
                    }
                }
            }
        }
    }
    @objc func update_hr_logs(status: String?) {
        let request_logs = AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: "SELECT * FROM \(db_hr_request)").filter { (logs) -> Bool in
            logs.REQUEST_LOGS_SYNC_STATUS == 0 && logs.CURRENT_USER == CURRENT_USER_LOGGED_IN_ID && ((logs.TICKET_STATUS == "Rejected" || logs.TICKET_STATUS == "rejected") || (logs.TICKET_STATUS == "Approved" || logs.TICKET_STATUS == "approved"))
        }
        
        if request_logs!.count > 0 {
            for log in request_logs! {
                let file_table = AppDelegate.sharedInstance.db?.read_tbl_hr_files(query: "SELECT * FROM \(db_files) WHERE REF_ID = '\(log.REF_ID!)'")
                var ticket_files = [[String:String]]()
                for file in file_table! {
                    let dictionary = [
                        "file_url": file.FILE_URL,
                        "file_extention": file.FILE_EXTENTION,
                        "file_size_kb": String(file.FILE_SIZE_KB)// .fileSize.split(separator: " ").first!)
                    ]
                    ticket_files.append(dictionary)
                }
                let hr_request = [
                    "hr_request": [
                        "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                        "tickets" : [
                            "status": log.TICKET_STATUS!,
                            "ticket_id": "\(log.SERVER_ID_PK!)",
                            "hr_remarks": log.HR_REMARKS!,
                            "hr_case_desc":log.HR_CASE_DESC!,
                            "ticket_logs": [
                                [
                                    "inputby": "Responsible",
                                    "ticket_files" : ticket_files
                                ]
                            ]
                        ]
                    ]
                ]
                let params = getAPIParameter(service_name: UPDATE_REQUEST_LOGS, request_body: hr_request)
                NetworkCalls.update_request_logs(params: params) { (success, response) in
                    if success {
                        if let s = status {
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                                if s == "approved" {
//                                    NotificationCenter.default.post(Notification.init(name: .refreshedViews))
//                                    Helper.topMostController().view.makeToast("Request has been accepted.")
//                                } else {
//                                    NotificationCenter.default.post(Notification.init(name: .refreshedViews))
//                                    Helper.topMostController().view.makeToast("Request has been rejected.")
//                                }
//                            }
                            DispatchQueue.main.async {
                                if let hr_files = JSON(response).dictionary?[_hr_files]?.array {
                                    for file in hr_files {
                                        AppDelegate.sharedInstance.db?.deleteRow(tableName: db_files, column: "SERVER_ID_PK", ref_id: "\(file.dictionary?["GIMG_ID"]?.int ?? 0)", handler: { _ in
                                            do {
                                                print("FILE: GIMG_ID: \(file.dictionary?["GIMG_ID"]?.int ?? 0) TICKET_ID: \(file.dictionary?["TICKET_ID"]?.int ?? 0)")
                                                let dictionary = try file.rawData()
                                                let file = try JSONDecoder().decode(HrFiles.self, from: dictionary)
                                                AppDelegate.sharedInstance.db?.insert_tbl_hr_files(hrfile: file)
                                            } catch let err {
                                                print("File Error: \(err.localizedDescription)")
                                            }
                                        })
                                    }
                                }
                                if let hr_logs = JSON(response).dictionary?[_hr_logs]?.array {
                                    for log in hr_logs {
                                        AppDelegate.sharedInstance.db?.deleteRow(tableName: db_grievance_remarks, column: "SERVER_ID_PK", ref_id: "\(log.dictionary?["GREM_ID"]?.int ?? -1)", handler: { _ in
                                            do {
                                                print("LOG: GREM_ID: \(log.dictionary?["GREM_ID"]?.int ?? 0) TICKET_ID: \(log.dictionary?["TICKET_ID"]?.int ?? 0)")
                                                let dictionary = try log.rawData()
                                                let log = try JSONDecoder().decode(HrLog.self, from: dictionary)
                                                AppDelegate.sharedInstance.db?.insert_tbl_hr_grievance(hr_log: log)
                                            } catch let error {
                                                print("log id: \(log.dictionary?["GREM_ID"]?.intValue) \(error.localizedDescription)")
                                            }
                                        })
                                    }
                                }
                                if let ticket_log = JSON(response).dictionary?[_tickets_logs]?.array?.first {
                                    let ref_id = ticket_log["REF_ID"].string ?? ""
                                    AppDelegate.sharedInstance.db?.deleteRow(tableName: db_hr_request, column: "REF_ID", ref_id: ref_id, handler: { success in
                                        if success {
                                            do {
                                                let dictionary = try ticket_log.rawData()
                                                let hrgrievance = try JSONDecoder().decode(HrRequest.self, from: dictionary)
                                                
                                                DispatchQueue.main.async {
                                                    AppDelegate.sharedInstance.db?.insert_tbl_hr_request(hrrequests: hrgrievance, { dump_succes in
                                                        if success {
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                                NotificationCenter.default.post(Notification.init(name: .refreshedViews))
                                                                Helper.topMostController().view.makeToast("Updated Request Successfully")
                                                            }
                                                            print("DUMPED UPDATED TICKET")
                                                        }
                                                    })
                                                }
                                            } catch let err {
                                                print(err.localizedDescription)
                                            }
                                        }
                                    })
                                }
                            }
                            
                        }
                        print("\(UPDATE_REQUEST_LOGS): SUCCESS")
                    } else {
                        print("\(UPDATE_REQUEST_LOGS): FAILED")
                    }
                }
            }
        }
    }
    
    @objc func logoutUser() {
//        AppDelegate.sharedInstance.db?.deleteRow(tableName: db_last_sync_status, column: "CURRENT_USER", ref_id: CURRENT_USER_LOGGED_IN_ID, handler: { _ in })
        Messaging.messaging().unsubscribe(fromTopic: BROADCAST_KEY)
        AppDelegate.sharedInstance.db?.deleteRow(tableName: db_last_sync_status, column: "SYNC_KEY", ref_id: GET_HR_NOTIFICATION, handler: { _ in })
        AppDelegate.sharedInstance.db?.deleteRow(tableName: db_last_sync_status, column: "SYNC_KEY", ref_id: GETORDERFULFILMET, handler: { _ in })
        
        AppDelegate.sharedInstance.db?.deleteAll(tableName: db_hr_notifications, handler: { _ in })
        AppDelegate.sharedInstance.db?.deleteAll(tableName: db_fulfilment_orders, handler: { _ in })
        Geotification.allGeotifications().forEach { (geotification) in
            stopMonitoring(geotification: geotification)
        }
        UserDefaults.standard.removeObject(forKey: PreferencesKeys.savedItems.rawValue)
        UserDefaults.standard.set(false, forKey: "GeofenceAdd")
        if isNavigate {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func navigateThroughtNotify(notification: Notification) {
        NotificationCenter.default.removeObserver(self)
        if let hr_request = notification.object as? tbl_Hr_Request_Logs {
            if let module_id = hr_request.MODULE_ID {
                let columns = ["READ_STATUS_DTTM"]
                let values  = ["1"]
                
                if RECORD_ID != 0 {
                    AppDelegate.sharedInstance.db?.updateTables(tableName: db_hr_notifications, columnName: columns, updateValue: values, onCondition: "RECORD_ID = '\(RECORD_ID)'", { (success) in
                        if success {
                            DispatchQueue.main.async {
                                let read_notification = [
                                    "hr_request": [
                                        "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                                        "notificationid" :"\(RECORD_ID)"
                                    ]
                                ]
                                let params = self.getAPIParameter(service_name: READ_NOTIFICATION, request_body: read_notification)
                                NetworkCalls.read_notification(params: params) { (success, response) in
                                    if success {
                                        RECORD_ID = 0
                                        print("NOTIFICATION READ FROM POPUP.")
                                    } else {
                                        print("NOTIFICATION NOT READ FROM POPUP.")
                                    }
                                }
                            }
                        }
                    })
                }
                
                switch module_id {
                case 1:
                    let storyboard = UIStoryboard(name: "Home", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestViewController") as! NewRequestViewController
                    let updateController = storyboard.instantiateViewController(withIdentifier: "UpdateRequestViewController") as! UpdateRequestViewController
                    
                    if hr_request.RESPONSIBLE_EMPNO ?? -1 == Int(CURRENT_USER_LOGGED_IN_ID) {
                        updateController.request_log = hr_request
                        updateController.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(updateController, animated: true)
                    } else {
                        controller.ticket_id = hr_request.SERVER_ID_PK
                        controller.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                    break
                case 2:
                    let storyboard = UIStoryboard(name: "GrievanceStoryboard", bundle: nil)
                    let viewRequest = storyboard.instantiateViewController(withIdentifier: "GrievanceViewRequestViewController") as! GrievanceViewRequestViewController
                    let closedRequest = storyboard.instantiateViewController(withIdentifier: "GrievanceViewClosedRequestViewController") as! GrievanceViewClosedRequestViewController
                    
                    if hr_request.TICKET_STATUS?.lowercased() == "closed" {
                        closedRequest.ticket_id = hr_request.SERVER_ID_PK
                        self.navigationController?.pushViewController(closedRequest, animated: true)
                    } else {
                        let user_permission = AppDelegate.sharedInstance.db!.read_tbl_UserPermission()
                        if user_permission.contains(where: { permissions -> Bool in
                            let permission = String(permissions.PERMISSION.lowercased().split(separator: " ").last!)
                            return permission == hr_request.TICKET_STATUS!.lowercased()
                        }) {
                            viewRequest.ticket_id = hr_request.SERVER_ID_PK
                            viewRequest.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(viewRequest, animated: true)
                        } else {
                            closedRequest.ticket_id = hr_request.SERVER_ID_PK
                            closedRequest.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(closedRequest, animated: true)
                            print("NOT CONTAINS")
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
                    
                    let isGranted = permissions?.contains(where: { (perm) -> Bool in
                        let permission = String(perm.PERMISSION.lowercased().split(separator: " ").last!)
                        return permission == hr_request.TICKET_STATUS?.lowercased() ?? ""
                    })
                    
                    let query = "SELECT * FROM \(db_hr_request) WHERE SERVER_ID_PK = '\(hr_request.SERVER_ID_PK!)'"
                    if let data = AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: query).first {
                        controller.ticket_request = data
                        controller.current_user = current_user
                        controller.havePermissionToEdit = isGranted!
                        
                        print(current_user)
                        if current_user == "" {
                            let controller = storyboard.instantiateViewController(withIdentifier: "IMSNewRequestViewController") as! IMSNewRequestViewController
                            controller.current_ticket = data
                            controller.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(controller, animated: true)
                        } else {
                            controller.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
                    }
                    break
                case 4:
                    let storyboard = UIStoryboard(name: "LeadershipAwaz", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestLeadershipAwazViewController") as! NewRequestLeadershipAwazViewController
                    controller.ticket_id = hr_request.SERVER_ID_PK
                    controller.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(controller, animated: true)
                    break
                default:
                    break
                }
            }
            
        } else {
            if let _ = notification.object as? String {
                let storyboard = UIStoryboard(name: "Fullfillment", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "FulfilmentListingViewController") as! FulfilmentListingViewController
                controller.numberOfDays = "7"
                controller.numberOfDaysSorting = "This Week"
                controller.ticket_status = "Pending"
                controller.ticket_status_sorting = "Pending"
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    
    func createTatNotification(title: String, subTitle: String) {
        let notificationCenter = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = subTitle
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        //getting the notification request
        
        let request = UNNotificationRequest(identifier: title, content: content, trigger: trigger)
        
        //adding the notification to notification center
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            } else {
                print("Notification Triggered")
            }
        }
    }
    
    func getNotificationCounts() -> Int{
        let query = "select n.*,r.TICKET_STATUS as LOG_TICKET from NOTIFICATION_LOGS n LEFT JOIN FULFILMENT_ORDERS f ON n.TICKET_ID = f.ORDER_ID LEFT JOIN REQUEST_LOGS r ON n.TICKET_ID = r.SERVER_ID_PK where n.READ_STATUS_DTTM = 'a' ORDER BY n.CREATED_DATE desc"
        let notifications_count = AppDelegate.sharedInstance.db?.read_tbl_hr_notification_request(query: query).uniqueElements().count
        return notifications_count ?? 0
    }
    
    
    func calculateTatBreached(days: Int?, month: Int?, start_day: String?, end_day: String?) -> [tbl_Hr_Request_Logs] {
        
        var data = [tbl_Hr_Request_Logs]()
        var query = ""
        
        var previousDate = Date()// getPreviousDays(days: -numberOfDays)
        var weekly = String()
        if start_day == nil && end_day == nil {
            if month == nil {
                previousDate = getPreviousDays(days: -days!)
                weekly = previousDate.convertDateToString(date: previousDate)
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
            query = "select * from REQUEST_LOGS WHERE module_id = '\(CONSTANT_MODULE_ID)' AND Created_Date >= '\(start_day!)' AND Created_Date <= '\(end_day!)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
        }
        
        let request_log = AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: query)
        for request in request_log! {
            let updatedDateString = request.UPDATED_DATE ?? ""
            let createdDateString = request.CREATED_DATE ?? ""
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

            if updatedDateString == "" {
                let diffComponents = Calendar.current.dateComponents([.day],
                                                                     from: dateFormatter.date(from: createdDateString)!,
                                                                     to: Date())
                
                if diffComponents.day! >= request.ESCALATE_DAYS! {
                    data.append(request)
                }
            } else {
                let diffComponents = Calendar.current.dateComponents([.day],
                                                                     from: dateFormatter.date(from: createdDateString)!,
                                                                     to: dateFormatter.date(from: updatedDateString)!)
                 
                if diffComponents.day! >= request.ESCALATE_DAYS! {
                    data.append(request)
                }
            }
        }
        return data
    }
    func calculateWithInTat(days: Int?, month: Int?, start_day: String?, end_day: String?) -> [tbl_Hr_Request_Logs] {
        
        var data = [tbl_Hr_Request_Logs]()
        var query = ""
        
        var previousDate = Date()// getPreviousDays(days: -numberOfDays)
        var weekly = String()
        if start_day == nil && end_day == nil {
            if month == nil {
                previousDate = getPreviousDays(days: -days!)
                weekly = previousDate.convertDateToString(date: previousDate)
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
            query = "select * from REQUEST_LOGS WHERE module_id = '\(CONSTANT_MODULE_ID)' AND Created_Date >= '\(start_day!)' AND Created_Date <= '\(end_day!)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
        }
        let request_log = AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: query)
        for request in request_log! {
            let updatedDateString = request.UPDATED_DATE ?? ""
            let createdDateString = request.CREATED_DATE ?? ""
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

            if updatedDateString == "" {
                let diffComponents = Calendar.current.dateComponents([.day],
                                                                     from: dateFormatter.date(from: createdDateString)!,
                                                                     to: Date())
                
                if diffComponents.day! < request.ESCALATE_DAYS! {
                    data.append(request)
                }
            } else {
                let diffComponents = Calendar.current.dateComponents([.day],
                                                                     from: dateFormatter.date(from: createdDateString)!,
                                                                     to: dateFormatter.date(from: updatedDateString)!)
                 
                if diffComponents.day! < request.ESCALATE_DAYS! {
                    data.append(request)
                }
            }
        }
        return data
    }
    
    
    //IMS Functions
    func permissionAvailable(permission: String) -> String {
//        let permissions = AppDelegate.sharedInstance.db?.read_tbl_UserPermission()
        var perm = ""
        for permission in IMSAllPermissions {
            if permission == IMS_Inprogress_Rm {
                continue
            } else {
                 
            }
        }
        return perm
    }
    
    
    func startMonitoring(geotification: Geotification) {
        // 1
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            self.showAlert(
                withTitle: "Error",
                message: "Geofencing is not supported on this device!")
            return
        }
        // 2
        let fenceRegion = geotification.region
        locationManager.startMonitoring(for: fenceRegion)
    }
    func stopMonitoring(geotification: Geotification) {
        for region in locationManager.monitoredRegions {
            guard
                let circularRegion = region as? CLCircularRegion,
                circularRegion.identifier == geotification.identifier
            else { continue }
            
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
    
    func startHapticTouch(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func locationAlert() {
        let alert = UIAlertController(title: "Alert!", message: "Turn on your location to mark your attendance", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Open Settings", style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Generate QRCode
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    //MARK: - Create Notification
    func setupNotificationBody(body: [String:Any]) -> [String:Any] {
        guard let fcmToken = FIREBASETOKEN else {
            return ["":""]
        }
        return [
            "to": fcmToken,
            "notification" : [
                "body" : "Given To",
                "title": "One App Rider"
            ],
            "data" : [
                "body" : body
            ]
        ]
    }
}
