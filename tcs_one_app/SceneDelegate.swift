//
//  SceneDelegate.swift
//  tcs_one_app
//
//  Created by ibs on 15/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    let locationManager = CLLocationManager()
    var isEnter = false
    var didEnterBackground = false
    var skip = 0
    var count = 0
    var isTotalCounter = 0
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        guard let _ = (scene as? UIWindowScene) else { return }
        
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        if didEnterBackground {
            didEnterBackground = false
            self.getFulfilment()
        }
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        didEnterBackground = true
    }
    func getFulfilment() {
        var fulfilment = [String: [String:Any]]()
        let lastSyncStatus = AppDelegate.sharedInstance.db?.readLastSyncStatus(tableName: db_last_sync_status,
                                                   condition: "SYNC_KEY = '\(GETORDERFULFILMET)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'")
        guard let access_token = UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN) else {
            return
        }
        print(lastSyncStatus)
        if lastSyncStatus == nil {
            fulfilment = [
                "hr_request":[
                    "access_token": access_token,
                    "skip" :skip,
                    "take" : 80,
                    "sync_date": ""
                ]
            ]
        } else {
            fulfilment = [
                "hr_request":[
                    "access_token": access_token,
                    "skip" :0,
                    "take" : 80,
                    "sync_date": lastSyncStatus!.DATE
                ]
            ]
        }
        let params = self.getAPIParameter(service_name: GETORDERFULFILMET, request_body: fulfilment)
        NetworkCalls.getorderfulfilment(params: params) { success, response in
            if success {
                self.count = JSON(response).dictionary![_count]!.intValue
                if self.count <= 0 {
                    return
                }
                
                if let fulfilment_orders = JSON(response).dictionary?[_orders]?.array {
                    let sync_date = JSON(response).dictionary?[_sync_date]?.string ?? ""
                    do {
                        for json in fulfilment_orders {
                            self.isTotalCounter += 1
                            let dictionary = try json.rawData()
                            let fulfilment_orders: FulfilmentOrders = try JSONDecoder().decode(FulfilmentOrders.self, from: dictionary)
                            AppDelegate.sharedInstance.db?.deleteRowWithMultipleConditions(tbl: db_fulfilment_orders, conditions: "CNSG_NO = '\(fulfilment_orders.cnsgNo)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'", { _ in
                                AppDelegate.sharedInstance.db?.insert_tbl_fulfilment_orders(fulfilment_orders: fulfilment_orders, handler: { _ in
                                    DispatchQueue.main.async {
                                        print("new order received")
                                    }
                                })
                            })
                        }
                        if self.isTotalCounter  >= self.count {
                            DispatchQueue.main.async {
                                Helper.updateLastSyncStatus(APIName: GETORDERFULFILMET,
                                                          date: sync_date,
                                                          skip: self.skip,
                                                          take: 80,
                                                          total_records: self.count)
                                NotificationCenter.default.post(Notification.init(name: .refreshedViews))
                            }
                        } else {
                            self.skip += 80
                            self.getFulfilment()
                        }
                    } catch let err { print(err.localizedDescription) }
                } else {}
            } else {}
        }
    }
}
@available(iOS 13.0, *)
// MARK: - Location Manager Delegate
extension SceneDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            isEnter = true
            handleEvent(for: region, manager: manager)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            isEnter = false
            handleEvent(for: region, manager: manager)
        }
    }
    
    func handleEvent(for region: CLRegion, manager coordinates: CLLocationManager) {
        // Show an alert if application is active
        if UIApplication.shared.applicationState == .active {
//            guard let message = note(from: region.identifier) else { return }
//            window?.rootViewController?.showAlert(withTitle: nil, message: message)
//            print(message)
        } else {
            // Otherwise present a local notification
            guard let body = note(from: region.identifier) else { return }
            guard let access_token = UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN) else {
                return
            }
            
            if !CustomReachability.isConnectedNetwork() {
                return
            }
            
            if !isEnter {
                if let locations = AppDelegate.sharedInstance.db?.read_tbl_att_locations(query: "SELECT * FROM \(db_att_locations)") {
                    if locations.count > 0 {
                        for location in locations {
                            let latitude = (location.LATITUDE as NSString).doubleValue
                            let longitude = (location.LONGITUDE as NSString).doubleValue
                            let cllocation = CLLocation(latitude: latitude, longitude: longitude)
                            let currentLocation = CLLocation(latitude: coordinates.location?.coordinate.latitude ?? 0.0,
                                                             longitude: coordinates.location?.coordinate.longitude ?? 0.0)
                            
                            let distance = currentLocation.distance(from: cllocation)
                            if distance > 450 {
                                return
                            } else {
                                continue
                            }
                        }
                    }
                }
            }
            
            let query = "SELECT * FROM \(db_att_userAttendance)"
            if let attendance = AppDelegate.sharedInstance.db?.read_tbl_att_user_attendance_for_notification(query: query) {
                let current_day = attendance.filter { (att) -> Bool in
                    att.STATUS == "1"
                }.first
                if current_day?.TIME_IN == "00:00" {
                    if isEnter {
                        hitApi(access_token: access_token, coordinates: coordinates)
                    } else {
                        hitApi(access_token: access_token, coordinates: coordinates)
                        hitApi(access_token: access_token, coordinates: coordinates)
                    }
                } else {
                    hitApi(access_token: access_token, coordinates: coordinates)
                }
            } else {
                if isEnter {
                    hitApi(access_token: access_token, coordinates: coordinates)
                } else {
                    hitApi(access_token: access_token, coordinates: coordinates)
                    hitApi(access_token: access_token, coordinates: coordinates)
                }
            }
            
            let notificationContent = UNMutableNotificationContent()
            notificationContent.body = body
            notificationContent.sound = .default
//            notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(
                identifier: "location_change",
                content: notificationContent,
                trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
            }
        }
    }
    
    func hitApi(access_token: String, coordinates: CLLocationManager) {
        guard let access_token = UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN) else {
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        
        let date = dateFormatter.string(from: Date())
        let json = [
            "attendance_request" : [
                "access_token" : access_token,
                "latitude": "\(coordinates.location?.coordinate.latitude ?? 0.0)",
                "longitude": "\(coordinates.location?.coordinate.longitude ?? 0.0)",
                "app_datime" : date
            ]
        ]
        let params = self.getAPIParameter(service_name: MARKATTENDANCE, request_body: json)
        NetworkCalls.mark_attendance(params: params) { (_, _) in }
    }
    func getAPIParameter(service_name: String, request_body: [String: Any]) -> [String:Any] {
        let params = [
            "eAI_MESSAGE": [
                "eAI_HEADER": [
                    "serviceName": service_name,
                    "client": "TCS",
                    "clientChannel": "MOB",
                    "referenceNum": "",
                    "securityInfo": [
                        "authentication": [
                            "userId": "",
                            "password": ""
                        ]
                    ]
                ],
                "eAI_BODY": [
                    "eAI_REQUEST": request_body
                ]
            ]
        ]
        return params as [String: Any]
    }
    
    func note(from identifier: String) -> String? {
        let geotifications = Geotification.allGeotifications()
        let matched = geotifications.first { $0.identifier == identifier }
        return matched?.note
    }
}
