//
//  AppDelegate.swift
//  tcs_one_app
//
//  Created by ibs on 15/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications
import SwiftyJSON
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    var user_profile: User?
    var db: DBHelper?
    let gcmMessageIDKey = "gcm.message_id"
    
    var record_id = 0
    
    static let sharedInstance: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        ConnectionManager.sharedInstance.observeReachability()
        
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backgroundColor = UIColor.nativeRedColor()
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().tintColor = UIColor.white
        
        UITextField.appearance().tintColor = UIColor.nativeRedColor()
        IQKeyboardManager.shared.enable = true
//        registerForPushNotifications()
        FirebaseApp.configure()
        db = DBHelper.init(databaseName: "TCSOneApp")

        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        return true
    }
    
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] (granted, error) in
                print("Permission granted: \(granted)")

                guard granted else {
                    print("Please enable \"Notifications\" from App Settings.")
                    self?.showPermissionAlert()
                    return
                }

                self?.getNotificationSettings()
            }
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
      print(fcmToken)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }

        let token = tokenParts.joined()
        DEVICEID = token
        print("Device Token: \(token)")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      // Print full message.
      print(userInfo)

      completionHandler(UIBackgroundFetchResult.newData)
    }
    
    
    func showPermissionAlert() {
        let alert = UIAlertController(title: "WARNING", message: "Please enable access to Notifications in the Settings app.", preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "Settings", style: .default) {[weak self] (alertAction) in
            self?.gotoAppSettings()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)

        alert.addAction(settingsAction)
        alert.addAction(cancelAction)

        DispatchQueue.main.async {
//            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }

    private func gotoAppSettings() {

        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.openURL(settingsUrl)
        }
    }
}




@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

    func createNotification(title: String, subTitle: String, userInfo: [AnyHashable: Any], body: String?) {
        let notificationCenter = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = subTitle
        content.sound = .default
        content.userInfo = userInfo
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        //getting the notification request
        
        let request = UNNotificationRequest(identifier: title, content: content, trigger: trigger)
        self.parseNotification(state: "", body: body ?? nil)
        //adding the notification to notification center
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            } else {
                print("Notification Triggered")
            }
        }
    }
  // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        
        if notification.request.identifier == "TAT Breached" {
            completionHandler([[.alert, .sound]])
            return
        }
        let userInfo = JSON(notification.request.content.userInfo)
        if userInfo.dictionary?["aps"]?.dictionary?["alert"]?.dictionary?["title"] == "User logout" {
            NotificationCenter.default.post(Notification.init(name: .logoutUser))
            UserDefaults.standard.removeObject(forKey: "CurrentUser")
            UserDefaults.standard.removeObject(forKey: USER_ACCESS_TOKEN)
            return
        }
        //Update Request Assigned
        if userInfo.dictionary?["aps"]?.dictionary?["alert"]?.dictionary?["title"] == "New Request Assigned" {
            if let body = userInfo.dictionary?["body"]?.string {
                let data = body.data(using: .utf8)!
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                        if jsonArray["NOTIFY_TYPE"] as! String == "LOGOUT" {
                            NotificationCenter.default.post(Notification.init(name: .logoutUser))
                            UserDefaults.standard.removeObject(forKey: "CurrentUser")
                            UserDefaults.standard.removeObject(forKey: USER_ACCESS_TOKEN)
                            return
                        }
                        if jsonArray["NOTIFY_TYPE"] as! String == "INSERT" {
                            if self.record_id == jsonArray["RECORD_ID"] as? Int ?? 0 {
                                completionHandler([[.alert, .sound]])
                                return
                            }
                            self.createNotification(title: jsonArray["NOTIFY_TITLE"] as? String ?? "",
                                                    subTitle: jsonArray["TITLE_MESSAGE"] as? String ?? "",
                                                    userInfo: notification.request.content.userInfo,
                                                    body: body)
                            self.record_id = jsonArray["RECORD_ID"] as? Int ?? 0
                            
                            
                            return
                        }
                        if jsonArray["NOTIFY_TYPE"] as! String == "UPDATE" {
                            if self.record_id == jsonArray["RECORD_ID"] as? Int ?? 0 {
                                completionHandler([[.alert, .sound]])
                                return
                            }
                            self.createNotification(title: jsonArray["NOTIFY_TITLE"] as? String ?? "",
                                                    subTitle: jsonArray["TITLE_MESSAGE"] as? String ?? "",
                                                    userInfo: notification.request.content.userInfo,
                                                    body: body)
                            self.record_id = jsonArray["RECORD_ID"] as? Int ?? 0
                        }
                    }
                } catch let err {
                    print(err.localizedDescription)
                }
            }
        }
        if userInfo.dictionary?["aps"]?.dictionary?["alert"]?.dictionary?["title"] == "Update Request Assigned" ||
            userInfo.dictionary?["aps"]?.dictionary?["alert"]?.dictionary?["title"] == "Udate Request Assigned" {
            if let body = userInfo.dictionary?["body"]?.string {
                let data = body.data(using: .utf8)!
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                        if jsonArray["NOTIFY_TYPE"] as! String == "LOGOUT" {
                            NotificationCenter.default.post(Notification.init(name: .logoutUser))
                            UserDefaults.standard.removeObject(forKey: "CurrentUser")
                            UserDefaults.standard.removeObject(forKey: USER_ACCESS_TOKEN)
                            return
                        }
                        if jsonArray["NOTIFY_TYPE"] as! String == "INSERT" {
                            if self.record_id == jsonArray["RECORD_ID"] as? Int ?? 0 {
                                completionHandler([[.alert, .sound]])
                                return
                            }
                            self.createNotification(title: jsonArray["NOTIFY_TITLE"] as? String ?? "",
                                                    subTitle: jsonArray["TITLE_MESSAGE"] as? String ?? "",
                                                    userInfo: notification.request.content.userInfo,
                                                    body: body)
                            self.record_id = jsonArray["RECORD_ID"] as? Int ?? 0
                            return
                        }
                        if jsonArray["NOTIFY_TYPE"] as! String == "UPDATE" {
                            if self.record_id == jsonArray["RECORD_ID"] as? Int ?? 0 {
                                completionHandler([[.alert, .sound]])
                                return
                            }
                            self.createNotification(title: jsonArray["NOTIFY_TITLE"] as? String ?? "",
                                                    subTitle: jsonArray["TITLE_MESSAGE"] as? String ?? "",
                                                    userInfo: notification.request.content.userInfo,
                                                    body: body)
                            self.record_id = jsonArray["RECORD_ID"] as? Int ?? 0
                        }
                    }
                } catch let err {
                    print(err.localizedDescription)
                }
            }
        }
        
//        completionHandler([[.alert, .sound]])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = JSON(response.notification.request.content.userInfo)
        // Print message ID.
        if let messageID = userInfo.dictionary?[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        let application = UIApplication.shared
        var state = ""
        
        if application.applicationState == .active {
            state = ACTIVE
        } else if application.applicationState == .background {
            state = BACKGROUND
        } else if application.applicationState == .inactive {
            state = INACTIVE
        }
//        NAE HOTA..
        if let body = userInfo.dictionary?["body"]?.string{
            let data = body.data(using: .utf8)!
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                    if let request_log = JSON(jsonArray[_data]).dictionary?[_hr_requests]?.array?.first {
                        if request_log.dictionary?["ORDER_ID"]?.string != nil {
                            NotificationCenter.default.post(Notification.init(name: .navigateThroughNotification, object: request_log.dictionary?["ORDER_ID"]?.string, userInfo: nil))
                            completionHandler()
                            return
                        }
                        let ticket_id = request_log.dictionary?["TICKET_ID"]?.int
                        let tbl_hr_request = db?.read_tbl_hr_request(query: "SELECT * FROM \(db_hr_request) WHERE SERVER_ID_PK = '\(ticket_id!)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'").first
                        
                        
                        let query = "SELECT n.*,r.TICKET_STATUS as LOG_TICKET FROM \(db_hr_notifications) n LEFT JOIN \(db_hr_request) r ON n.TICKET_ID = r.SERVER_ID_PK WHERE r.CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' AND r.SERVER_ID_PK = '\(tbl_hr_request?.SERVER_ID_PK ?? 0)'"
                        
                        let tbl_hr_notification = db?.read_tbl_hr_notification_request(query: query)
                        RECORD_ID = tbl_hr_notification?.first?.RECORD_ID ?? 0
                        print(RECORD_ID)
                        NotificationCenter.default.post(Notification.init(name: .navigateThroughNotification, object: tbl_hr_request, userInfo: nil))
                        completionHandler()
                        return
                    }
                    if let request_log = JSON(jsonArray).dictionary?["data"] {
                        let ticket_id = request_log.array?.first?.dictionary?["TICKET_ID"]?.int ?? -1
                        let tbl_hr_request = db?.read_tbl_hr_request(query: "SELECT * FROM \(db_hr_request) WHERE SERVER_ID_PK = '\(ticket_id)'").first
                        let tbl_hr_notification = db?.read_tbl_hr_notification_request(query: "SELECT * FROM \(db_hr_notifications) WHERE TICKET_ID = '\(tbl_hr_request?.SERVER_ID_PK ?? 0)'")
                        RECORD_ID = tbl_hr_notification?.first?.RECORD_ID ?? 0
                        print(RECORD_ID)
                        NotificationCenter.default.post(Notification.init(name: .navigateThroughNotification, object: tbl_hr_request, userInfo: nil))
                        completionHandler()
                        return
                    }
                }
            } catch let err {
                print(err.localizedDescription)
            }
        }
        
        print(userInfo)
        
        completionHandler()
    }
    func parseNotification(state: String, body: String?) {
        if let response = body {
            let data = response.data(using: .utf8)!
            var recordId = 0
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                    var created_date = ""
                    
                    if let request_log = JSON(jsonArray[_data]).array?.first {
                        do {
                            let rawData = try request_log.rawData()
                            let hrrequest = try JSONDecoder().decode(HrRequest.self, from: rawData)
                            
                            let hr_requests = request_log.dictionary!
                            created_date = hr_requests["CREATED_DATE"]?.stringValue ?? ""
                            let ticket_id = request_log.dictionary?["REF_ID"]?.string
                            AppDelegate.sharedInstance.db?.deleteRow(tableName: db_hr_request, column: "REF_ID", ref_id: "\(ticket_id ?? "")", handler: { (granted) in
                                if granted {
                                    AppDelegate.sharedInstance.db?.insert_tbl_hr_request(hrrequests: hrrequest, { success in
                                        if success {
                                            self.generateTATBreachedNotifications()
                                            print("HR Request Inserted via Notification")
                                        }
                                    })
                                }
                            })
                        } catch let DecodingError.dataCorrupted(context) {
                            print(context)
                        } catch let DecodingError.keyNotFound(key, context) {
                            print("Key '\(key)' not found:", context.debugDescription)
                            print("codingPath:", context.codingPath)
                        } catch let DecodingError.valueNotFound(value, context) {
                            print("Value '\(value)' not found:", context.debugDescription)
                            print("codingPath:", context.codingPath)
                        } catch let DecodingError.typeMismatch(type, context)  {
                            print("Type '\(type)' mismatch:", context.debugDescription)
                            print("codingPath:", context.codingPath)
                        } catch {
                            print("error: ", error)
                        }
                    } else {
                        if let grievance_log = JSON(jsonArray[_data]).dictionary?[_hr_requests]?.first?.1 {
                            do {
                                if let order_id = grievance_log.dictionary?["ORDER_ID"]?.string {
                                    if let fulfillment_logs = JSON(jsonArray[_data]).dictionary?[_hr_requests]?.array {
                                        AppDelegate.sharedInstance.db?.deleteRow(tableName: db_fulfilment_orders, column: "ORDER_ID", ref_id: order_id, handler: { _ in
                                            for logs in fulfillment_logs {
                                                do {
                                                    let rawData = try logs.rawData()
                                                    let fulfillment_order = try JSONDecoder().decode(FulfilmentOrders.self, from: rawData)
                                                    AppDelegate.sharedInstance.db?.insert_tbl_fulfilment_orders(fulfilment_orders: fulfillment_order, handler: { _ in })
                                                }catch let DecodingError.dataCorrupted(context) {
                                                    print(context)
                                                } catch let DecodingError.keyNotFound(key, context) {
                                                    print("Key '\(key)' not found:", context.debugDescription)
                                                    print("codingPath:", context.codingPath)
                                                } catch let DecodingError.valueNotFound(value, context) {
                                                    print("Value '\(value)' not found:", context.debugDescription)
                                                    print("codingPath:", context.codingPath)
                                                } catch let DecodingError.typeMismatch(type, context)  {
                                                    print("Type '\(type)' mismatch:", context.debugDescription)
                                                    print("codingPath:", context.codingPath)
                                                } catch {
                                                    print("error: ", error)
                                                }
                                            }
                                        })
                                    }
                                } else {
                                    let rawData = try grievance_log.rawData()
                                    let grievance_request = try JSONDecoder().decode(HrRequest.self, from: rawData)
                                    let hr_request = grievance_log.dictionary!
                                    created_date = hr_request["CREATED_DATE"]?.stringValue ?? ""
                                    print("HRBP_EXISTS::: \(hr_request["HRBP_EXISTS"]?.int ?? -1)")
                                    let ref_id = grievance_log.dictionary?["REF_ID"]?.string
                                    AppDelegate.sharedInstance.db?.deleteRow(tableName: db_hr_request, column: "REF_ID", ref_id: "\(ref_id ?? "")", handler: { (granted) in
                                        if granted {
                                            AppDelegate.sharedInstance.db?.insert_tbl_hr_request(hrrequests: grievance_request, { success in
                                                if success {
                                                    if let hr_logs = grievance_log.dictionary?[_hr_logs]?.array {
                                                        var hrlog : HrLog?
                                                        
                                                        for data in hr_logs {
                                                            hrlog = HrLog(emplNo: data.dictionary?["EMPL_NO"]?.int ?? -1,
                                                                          created: data.dictionary?["CREATED"]?.string ?? "",
                                                                          refID: ref_id ?? "",
                                                                          gremID: data.dictionary?["GREM_ID"]?.int ?? -1,
                                                                          ticketID: data.dictionary?["TICKET_ID"]?.int ?? -1,
                                                                          ticketStatus: data.dictionary?["TICKET_STATUS"]?.string ?? "",
                                                                          remarks: data.dictionary?["REMARKS"]?.string ?? "",
                                                                          remarksInput: data.dictionary?["REMARKS_INPUT"]?.string ?? "")
                                                            AppDelegate.sharedInstance.db?.deleteRow(tableName: db_grievance_remarks, column: "SERVER_ID_PK", ref_id: "\(hrlog?.gremID ?? -1)", handler: { _ in
                                                                AppDelegate.sharedInstance.db?.insert_tbl_hr_grievance(hr_log: hrlog!)
                                                                if let files = data.dictionary?[_hr_files]?.array {
                                                                    for file in files {
                                                                        do {
                                                                            let hrFileRawData = try file.rawData()
                                                                            let f = try JSONDecoder().decode(HrFiles.self, from: hrFileRawData)
                                                                            AppDelegate.sharedInstance.db?.deleteAllWithCondition(tableName: db_files, columnName: "SERVER_ID_PK", value: "\(file.dictionary?["GIMG_ID"]?.int ?? -1)", handler: { _ in
                                                                                AppDelegate.sharedInstance.db?.insert_tbl_hr_files(hrfile: f)
                                                                            })
                                                                        } catch let hrFileErr {
                                                                            print(hrFileErr.localizedDescription)
                                                                        }
                                                                    }
                                                                }
                                                            })
                                                        }
                                                    }
                                                    self.generateTATBreachedNotifications()
                                                    print("HR Request Inserted via Notification")
                                                }
                                            })
                                        }
                                    })
                                }
                                
                            }catch let DecodingError.dataCorrupted(context) {
                                print(context)
                            } catch let DecodingError.keyNotFound(key, context) {
                                print("Key '\(key)' not found:", context.debugDescription)
                                print("codingPath:", context.codingPath)
                            } catch let DecodingError.valueNotFound(value, context) {
                                print("Value '\(value)' not found:", context.debugDescription)
                                print("codingPath:", context.codingPath)
                            } catch let DecodingError.typeMismatch(type, context)  {
                                print("Type '\(type)' mismatch:", context.debugDescription)
                                print("codingPath:", context.codingPath)
                            } catch {
                                print("error: ", error)
                            }
                        }
                    }
                    let HrNotification = HRNotificationRequest(titleMessage: jsonArray["TITLE_MESSAGE"] as? String ?? "",
                                                               sendingStatus: 1,
                                                               ticketID: jsonArray["TICKET_ID"] as? Int ?? -1,
                                                               readStatusDttm: "",
                                                               deviceReadDttm: "",
                                                               moduleDscrp: jsonArray["MODULE_DSCRP"] as? String ?? "",
                                                               notifyTitle: jsonArray["NOTIFY_TITLE"] as? String ?? "",
                                                               readStatus: jsonArray["READ_STATUS"] as? Int ?? -1,
                                                               notifyType: jsonArray["NOTIFY_TYPE"] as? String ?? "",
                                                               srNo: jsonArray["RECORD_ID"] as? Int ?? -1,
                                                               recordID: jsonArray["RECORD_ID"] as? Int ?? -1,
                                                               createdDate: created_date,
                                                               notificationRequestDESCRIPTION: jsonArray["DESCRIPTION"] as? String ?? "",
                                                               moduleid: jsonArray["MODULEID"] as? Int ?? -1,
                                                               sendTo: jsonArray["SEND_TO"] as? Int ?? -1)
                    AppDelegate.sharedInstance.db?.deleteRow(tableName: db_hr_notifications, column: "SERVER_ID_PK", ref_id: "\(HrNotification.ticketID ?? 0)", handler: { success in
                        if success {
                            AppDelegate.sharedInstance.db?.insert_tbl_HR_Notification_Request(hnr: HrNotification, { granted in
                                if granted {
                                    NotificationCenter.default.post(Notification.init(name: .refreshedViews))
                                    print("HR Notification Inserted via Notification")
                                }
                            })
                        }
                    })
                    
                    if state == ACTIVE {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            NotificationCenter.default.post(name: .navigateThroughNotification, object: HrNotification)
                        }
                    }
                } else {
                    print("bad json")
                }
            } catch let err {
                print(err.localizedDescription)
            }
        }
    }
    func generateTATBreachedNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        let apppermmission = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: PERMISSION_HR_LISTING_MANAGEMENT_BAR).count
        if apppermmission! > 0 {
            let pendingRequest = AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: "SELECT * FROM \(db_hr_request) WHERE (TICKET_STATUS = 'Pending' OR TICKET_STATUS = 'pending') AND SERVER_ID_PK != '\(-1)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            for requests in pendingRequest! {
                let created_date = requests.CREATED_DATE?.stringToDate
                let escalate_day = requests.TAT_DAYS
                let tatBreachedDate = Calendar.current.date(byAdding: .day, value: escalate_day!, to: created_date!)
                
                let date_array = Helper.DateIntoYearsMonthDay(date: tatBreachedDate!)
                
                self.scheduleNotificationForTAT(year: date_array[0],
                                                month: date_array[1],
                                                day: date_array[2],
                                                hr: date_array[3],
                                                min: date_array[4],
                                                sec: date_array[5],
                                                request: requests)
                
            }
        }
    }
    
    func scheduleNotificationForTAT(year:Int, month: Int, day: Int, hr: Int, min: Int, sec: Int, request: tbl_Hr_Request_Logs) {
        let notificationCenter = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        
        content.title = "TAT Breached"
        content.body = request.MASTER_QUERY! + ": " + request.DETAIL_QUERY!
        
        var dateComponent: DateComponents?
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm: a"
        
        dateComponent = DateComponents(year: year, month: month, day: day, hour: hr, minute: min, second: sec)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent!, repeats: false)
        let identifier = "TAT Breached"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            } else {
                print("Notification Triggered: \(content.body)")
            }
        }
    }
}

extension AppDelegate : MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        FIREBASETOKEN = "\(fcmToken)"
    }
}

struct HRFilesandLog {
    var HRFilesandLogData: [HRFilesandLogData]
}
struct HRFilesandLogData {
    var hrFiles: [HrFiles]?
    var hrLogs:  HrLog?
}
