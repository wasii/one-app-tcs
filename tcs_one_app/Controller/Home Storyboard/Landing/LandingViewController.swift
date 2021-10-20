//
//  LandingViewController.swift
//  tcs_one_app
//
//  Created by TCS on 20/09/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SwiftyJSON
import FirebaseMessaging

class LandingViewController: BaseViewController {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var logoCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var percentCounter: UILabel!
    @IBOutlet weak var indicatorView: NVActivityIndicatorView!
    var safeTopArea: CGFloat = 0.0
    var currentCenterConstraintPosition: CGFloat = 0.0
    
    var totalApiCounts = 9 //Setup, HrRequest, HrNotification, Attendance, Wallet-> Token, Setup, HistoryPoints, SummaryPoints, Beneficiairy
    var increment: Int = 0
    var currentCount: Int = 0
    
    var isIMSAllowed: Bool = false
    var isFulfilmentAllowed: Bool = false
    var access_token: String = ""
    var skip = 0
    var count = 0
    var isTotalCounter = 0
    
    var isPresented: Bool = false
    var headingText: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.clipsToBounds = true
        mainView.layer.cornerRadius = 40
        mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        if let text = headingText {
            self.headingLabel.text = text
        }
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            safeTopArea = window?.safeAreaInsets.top ?? 0.0
        }
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            safeTopArea = window?.safeAreaInsets.top ?? 0.0
        }
        view.backgroundColor = UIColor.nativeBlueColor()
        currentCenterConstraintPosition = self.logoCenterConstraint.constant
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN) == nil {
                if UserDefaults.standard.string(forKey: "CurrentUser") == nil {
                    self.openLoginScreen()
                    return
                }
            } else {
                CURRENT_USER_LOGGED_IN_ID = UserDefaults.standard.string(forKey: "CurrentUser")!
                self.setupAnimations()
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "Logout") {
            UserDefaults.standard.removeObject(forKey: "Logout")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.openLoginScreen()
                return
            }
        }
    }
    private func setupAnimations() {
        let screenSize = UIScreen.main.bounds.height / 3.7
        UIView.animate(withDuration: 0.3) {
            self.logoCenterConstraint.constant = -screenSize + self.safeTopArea
            self.logoHeightConstraint.constant = 200
            
            self.mainViewHeightConstraint.constant = 350
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.checkConditions()
        }
    }
    
    private func checkConditions() {
        self.totalApiCounts = 9
        if CustomReachability.isConnectedNetwork() {
            //MIS
            if let count = AppDelegate.sharedInstance.db?.read_tbl_UserPage().filter({ userPage in
                userPage.PAGENAME == PERMISSION_MIS_LISTING
            }).count {
                if count > 0 {
                    self.totalApiCounts += 4
                    isMISListingAllowed = true
                }
            }
            //IMS
            let isIMSSynced = AppDelegate.sharedInstance.db?.readLastSyncStatus(tableName: db_last_sync_status,
                                                                                condition: "SYNC_KEY = '\(IMSSETUP)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'")
            if isIMSSynced == nil {
                self.totalApiCounts += 1
                self.isIMSAllowed = true
            } else {
                self.isIMSAllowed = false
            }
            
            //Fulfilment
            if let fulfilment_perssion = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: PERMISSION_FulfilmentModule).count {
                if fulfilment_perssion > 0 {
                    self.totalApiCounts += 1
                    self.isFulfilmentAllowed = true
                }
            }
            
        } else {
            self.view.makeToast(NOINTERNETCONNECTION)
            return
        }
        
        self.increment += 100 / self.totalApiCounts
        self.percentCounter.text = "0%"
        self.indicatorView.type = .orbit
        self.indicatorView.startAnimating()
        
        self.setupAPIs()
    }
    
    private func setupAPIs() {
        guard let access_token = UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN) else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        self.access_token = access_token
        
        var setup_body = [String: [String:Any]]()
        setup_body = [
            "Setup_Body": [
                "access_token": access_token,
                "sync_date": ""
            ]
        ]
        
        //MARK: oneapp.setup
        let params = self.getAPIParameter(service_name: SETUP, request_body: setup_body)
        self.syncSetup(params: params) { setupSynced in
            if setupSynced {
                DispatchQueue.main.async {
                    self.currentCount += self.increment
                    self.percentCounter.text = "\(self.currentCount)%"
                }
                if self.isIMSAllowed {
                    self.syncIMSSetup { isimsSynced in
                        if isimsSynced {
                            DispatchQueue.main.async {
                                self.currentCount += self.increment
                                self.percentCounter.text = "\(self.currentCount)%"
                            }
                            self.getHrRequest()
                            return
                        } else {
                            self.showError()
                        }
                    }
                } else {
                    self.getHrRequest()
                }
            } else {
                self.showError()
            }
        }
    }
}

extension LandingViewController: PinValidateDelegate {
    func pinValidateDelegate() {
        self.setupAnimations()
    }
}

//MARK: - SETUP API
extension LandingViewController {
    func syncSetup(params: [String:Any], _ handler: @escaping(Bool)->Void) {
        NetworkCalls.setup(params: params) { synced, response in
            if synced {
                handler(true)
            } else {
                handler(false)
            }
        }
    }
}

//MARK: - SETUP IMS API
extension LandingViewController {
    func syncIMSSetup(_ handler: @escaping(Bool)->Void) {
        let ims_setup = [
            "Setup_Body": [
                "access_token": access_token,
                "sync_date": "",
                "moduleid" : "3"
            ]
        ]
        let params = getAPIParameter(service_name: IMSSETUP, request_body: ims_setup)
        NetworkCalls.ims_setup(params: params) { (syncIMS, response) in
            if syncIMS {
                DispatchQueue.main.async {
                    let json = JSON(response)
                    self.initialiseIMS(response: json) { updateIMS in
                        if updateIMS {
                            handler(true)
                        } else {
                            handler(false)
                        }
                    }
                }
            } else {
                handler(false)
            }
        }
    }
    
    func initialiseIMS(response: JSON, handler: @escaping(_ success: Bool) -> Void) {
        if let lov_master = response.dictionary?[_lov_master]?.array {
            var Lov_Master = [LovMaster]()
            for master in lov_master {
                do {
                    let dictionary = try master.rawData()
                    Lov_Master.append(try JSONDecoder().decode(LovMaster.self, from: dictionary))
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
            }
            AppDelegate.sharedInstance.db?.deleteAll(tableName: db_lov_master, handler: { _ in
                for master in Lov_Master {
                    AppDelegate.sharedInstance.db?.insert_tbl_lov_master(lov_master: master)
                }
            })
        }
        if let lov_detail = response.dictionary?[_lov_detail]?.array {
            var Lov_Detail = [LovDetail]()
            for detail in lov_detail {
                do {
                    let dictionary = try detail.rawData()
                    Lov_Detail.append(try JSONDecoder().decode(LovDetail.self, from: dictionary))
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
            }
            AppDelegate.sharedInstance.db?.deleteAll(tableName: db_lov_detail, handler: { _ in
                for detail in Lov_Detail {
                    AppDelegate.sharedInstance.db?.insert_tbl_lov_detail(lov_detail: detail)
                }
            })
        }
        if let lov_subdetail = response.dictionary?[_lov_subdetail]?.array {
            var Lov_Subdetail = [LovSubdetail]()
            for subdetail in lov_subdetail {
                do {
                    let dictionary = try subdetail.rawData()
                    Lov_Subdetail.append(try JSONDecoder().decode(LovSubdetail.self, from: dictionary))
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
            }
            AppDelegate.sharedInstance.db?.deleteAll(tableName: db_lov_sub_detail, handler: { _ in
                for subdetail in Lov_Subdetail {
                    AppDelegate.sharedInstance.db?.insert_tbl_lov_sub_detail(lov_sub_detail: subdetail)
                }
            })
        }
        if let area = response.dictionary?[_area]?.array {
            var Lov_Area = [Area]()
            for subdetail in area {
                do {
                    let dictionary = try subdetail.rawData()
                    Lov_Area.append(try JSONDecoder().decode(Area.self, from: dictionary))
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
            }
            AppDelegate.sharedInstance.db?.deleteAll(tableName: db_lov_area, handler: { _ in
                for area in Lov_Area {
                    AppDelegate.sharedInstance.db?.insert_tbl_area(lov_area: area)
                }
            })
        }
        if let city = response.dictionary?[_city]?.array {
            var Lov_City = [City]()
            for city in city {
                do {
                    let dictionary = try city.rawData()
                    Lov_City.append(try JSONDecoder().decode(City.self, from: dictionary))
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
            }
            AppDelegate.sharedInstance.db?.deleteAll(tableName: db_lov_city, handler: { _ in
                for city in Lov_City {
                    AppDelegate.sharedInstance.db?.insert_tbl_city(lov_city: city)
                }
            })
        }
        if let area_security = response.dictionary?[_area_security]?.array {
            var Lov_AreaSecurity = [AreaSecurity]()
            for areaSecurity in area_security {
                do {
                    let dictionary = try areaSecurity.rawData()
                    Lov_AreaSecurity.append(try JSONDecoder().decode(AreaSecurity.self, from: dictionary))
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
            }
            AppDelegate.sharedInstance.db?.deleteAll(tableName: db_lov_area_security, handler: { _ in
                for areaSecurity in Lov_AreaSecurity {
                    AppDelegate.sharedInstance.db?.insert_tbl_area_security(lov_area_security: areaSecurity)
                }
            })
        }
        if let department = response.dictionary?[_department]?.array {
            var Lov_Department = [Department]()
            for lov_department in department {
                do {
                    let dictionary = try lov_department.rawData()
                    Lov_Department.append(try JSONDecoder().decode(Department.self, from: dictionary))
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
            }
            AppDelegate.sharedInstance.db?.deleteAll(tableName: db_lov_department, handler: { _ in
                for department in Lov_Department {
                    AppDelegate.sharedInstance.db?.insert_tbl_department(lov_dept: department)
                }
            })
        }
        if let incident_type = response.dictionary?[_incident_type]?.array {
            var Lov_IncidentType = [IncidentType]()
            for lov_incidenttype in incident_type {
                do {
                    let dictionary = try lov_incidenttype.rawData()
                    Lov_IncidentType.append(try JSONDecoder().decode(IncidentType.self, from: dictionary))
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
            }
            AppDelegate.sharedInstance.db?.deleteAll(tableName: db_lov_incident_type, handler: { _ in
                for incidentType in Lov_IncidentType {
                    AppDelegate.sharedInstance.db?.insert_tbl_incident_type(incident_type: incidentType)
                }
            })
        }
        if let classification = response.dictionary?[_classification]?.array {
            var Lov_Classification = [Classification]()
            for lov_incidenttype in classification {
                do {
                    let dictionary = try lov_incidenttype.rawData()
                    Lov_Classification.append(try JSONDecoder().decode(Classification.self, from: dictionary))
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
            }
            AppDelegate.sharedInstance.db?.deleteAll(tableName: db_lov_classification, handler: { _ in
                for classification in Lov_Classification {
                    AppDelegate.sharedInstance.db?.insert_tbl_classification(classification: classification)
                }
            })
        }
        if let recovery_type = response.dictionary?[_recovery_type]?.array {
            var Lov_RecoveryType = [RecoveryType]()
            for recovery in recovery_type {
                do {
                    let dictionary = try recovery.rawData()
                    Lov_RecoveryType.append(try JSONDecoder().decode(RecoveryType.self, from: dictionary))
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
            }
            AppDelegate.sharedInstance.db?.deleteAll(tableName: db_lov_recovery_type, handler: { _ in
                for recovery_type in Lov_RecoveryType {
                    AppDelegate.sharedInstance.db?.insert_tbl_recovery_type(recovery_type: recovery_type)
                }
            })
        }
        if let hr_status = response.dictionary?[_hr_status]?.array {
            var hrStatus = [HrStatus]()
            for hrstatus in hr_status {
                do {
                    let dictionary = try hrstatus.rawData()
                    hrStatus.append(try JSONDecoder().decode(HrStatus.self, from: dictionary))
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
            }
            AppDelegate.sharedInstance.db?.deleteAll(tableName: db_lov_hr_status, handler: { _ in
                for hrstatus in hrStatus {
                    AppDelegate.sharedInstance.db?.insert_tbl_hr_status(hrStatus: hrstatus)
                }
            })
        }
        if let control_category = response.dictionary?[_control_category]?.array {
            var controlCategory = [ControlCategory]()
            for controlcategory in control_category {
                do {
                    let dictionary = try controlcategory.rawData()
                    controlCategory.append(try JSONDecoder().decode(ControlCategory.self, from: dictionary))
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
            }
            AppDelegate.sharedInstance.db?.deleteAll(tableName: db_lov_control_category, handler: { _ in
                for controlcategory in controlCategory {
                    AppDelegate.sharedInstance.db?.insert_tbl_control_category(control_category: controlcategory)
                }
            })
        }
        if let risk_type = response.dictionary?[_risk_type]?.array {
            var riskType = [RiskType]()
            for risktype in risk_type {
                do {
                    let dictionary = try risktype.rawData()
                    riskType.append(try JSONDecoder().decode(RiskType.self, from: dictionary))
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
            }
            AppDelegate.sharedInstance.db?.deleteAll(tableName: db_lov_risk_type, handler: { _ in
                for risktype in riskType {
                    AppDelegate.sharedInstance.db?.insert_tbl_risk_type(risk_type: risktype)
                }
            })
        }
        if let control_type = response.dictionary?[_control_type]?.array {
            var controlType = [ControlType]()
            for controltype in control_type {
                do {
                    let dictionary = try controltype.rawData()
                    controlType.append(try JSONDecoder().decode(ControlType.self, from: dictionary))
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
            }
            AppDelegate.sharedInstance.db?.deleteAll(tableName: db_lov_control_type, handler: { _ in
                for controltype in controlType {
                    AppDelegate.sharedInstance.db?.insert_tbl_control_type(control_type: controltype)
                }
            })
        }
        handler(true)
    }
}

//MARK: - HR Requst Logs
extension LandingViewController {
    @objc func getHrRequest() {
        var hr_request = [String: [String:Any]]()
        if let lastSyncStatus = AppDelegate.sharedInstance.db?.readLastSyncStatus(tableName: db_last_sync_status,
                                                                                  condition: "SYNC_KEY = '\(GET_HR_REQUEST)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'") {
            hr_request = [
                "hr_request":[
                    "access_token": self.access_token,
                    "skip" :0,
                    "take" : 80,
                    "sync_date": lastSyncStatus.DATE
                ]
            ]
        } else {
            hr_request = [
                "hr_request":[
                    "access_token": access_token,
                    "skip" :self.skip,
                    "take" : 80,
                    "sync_date": ""
                ]
            ]
        }
        let params = self.getAPIParameter(service_name: GET_HR_REQUEST, request_body: hr_request)
        NetworkCalls.hr_request(params: params) { success, response in
            if success {
                self.count = JSON(response).dictionary![_count]!.intValue
                if self.count <= 0 {
                    DispatchQueue.main.async {
                        self.currentCount += self.increment
                        self.percentCounter.text = "\(self.currentCount)%"
                    }
                    self.isTotalCounter = 0
                    self.getHrNotifications()
                    return
                }
                if let hr_response = JSON(response).dictionary?[_hr_requests]?.array {
                    let sync_date = JSON(response).dictionary?[_sync_date]?.string ?? ""
                    do {
                        self.setup_HRLogs_HRFILES(response: response)
                        for json in hr_response {
                            self.isTotalCounter += 1
                            let dictionary = try json.rawData()
                            let hrRequest: HrRequest = try JSONDecoder().decode(HrRequest.self, from: dictionary)
                            AppDelegate.sharedInstance.db?.deleteRowWithMultipleConditions(tbl: db_hr_request, conditions: "SERVER_ID_PK = '\(hrRequest.ticketID!)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'", { _ in
                                AppDelegate.sharedInstance.db?.insert_tbl_hr_request(hrrequests: hrRequest, { _ in })
                            })
                        }
                        if self.count == self.isTotalCounter {
                            
                            DispatchQueue.main.async {
                                Helper.updateLastSyncStatus(APIName: GET_HR_REQUEST,
                                                            date: sync_date,
                                                            skip: self.skip,
                                                            take: 80,
                                                            total_records: self.count)
                                self.count = 0
                                self.skip = 0
                                self.isTotalCounter = 0
                                DispatchQueue.main.async {
                                    self.currentCount += self.increment
                                    self.percentCounter.text = "\(self.currentCount)%"
                                    self.getHrNotifications()
                                }
                            }
                        } else {
                            self.skip += 80
                            self.getHrRequest()
                        }
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
                    self.count = 0
                    self.skip = 0
                    self.isTotalCounter = 0
                    DispatchQueue.main.async {
                        self.currentCount += self.increment
                        self.percentCounter.text = "\(self.currentCount)%"
                        self.getHrNotifications()
                    }
                }
            } else {
                self.showError()
            }
        }
    }
    
    func setup_HRLogs_HRFILES(response: Any) {
        if let hr_files = JSON(response).dictionary?[_hr_files]?.array {
            for file in hr_files {
                AppDelegate.sharedInstance.db?.deleteRow(tableName: db_files, column: "SERVER_ID_PK", ref_id: "\(file.dictionary?["GIMG_ID"]?.int ?? 0)", handler: { _ in
                    do {
                        print("FILE: GIMG_ID: \(file.dictionary?["GIMG_ID"]?.int ?? 0) TICKET_ID: \(file.dictionary?["TICKET_ID"]?.int ?? 0)")
                        let dictionary = try file.rawData()
                        let file = try JSONDecoder().decode(HrFiles.self, from: dictionary)
                        AppDelegate.sharedInstance.db?.insert_tbl_hr_files(hrfile: file)
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
                })
            }
        }
        if let hr_log = JSON(response).dictionary?[_hr_logs]?.array {
            for log in hr_log {
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
    }
}

//MARK: - HR Notifications Logs
extension LandingViewController {
    @objc func getHrNotifications() {
        DispatchQueue.main.async {
            var hr_notification = [String: [String:Any]]()
            if let lastSyncStatus = AppDelegate.sharedInstance.db?.readLastSyncStatus(tableName: db_last_sync_status,
                                                                                      condition: "SYNC_KEY = '\(GET_HR_NOTIFICATION)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'") {
                hr_notification = [
                    "hr_request": [
                        "access_token": self.access_token,
                        "skip" :0,
                        "take" : 80,
                        "sync_date": lastSyncStatus.DATE
                    ]
                ]
            } else {
                hr_notification = [
                    "hr_request": [
                        "access_token": self.access_token,
                        "skip" : self.skip,
                        "take" :80,
                        "sync_date" : ""
                    ]
                ]
            }
            
            let params = self.getAPIParameter(service_name: GET_HR_NOTIFICATION, request_body: hr_notification)
            NetworkCalls.hr_notification(params: params) { success, response in
                if success {
                    self.count = JSON(response).dictionary![_count]!.intValue
                    if self.count <= 0 {
                        DispatchQueue.main.async {
                            self.currentCount += self.increment
                            self.percentCounter.text = "\(self.currentCount)%"
                            self.getTCSLocations {
                                DispatchQueue.main.async {
                                    if self.isFulfilmentAllowed {
                                        self.skip = 0
                                        self.isTotalCounter = 0
                                        self.getFulfilment()
                                        return
                                    } else {
                                        if isMISListingAllowed {
                                            self.getMISToken { token_granted in
                                                if token_granted {
                                                    DispatchQueue.main.async {
                                                        self.currentCount += self.increment
                                                        self.percentCounter.text = "\(self.currentCount)%"
                                                        self.getmisdailyoverview { dailyOverview_granted in
                                                            if dailyOverview_granted {
                                                                DispatchQueue.main.async {
                                                                    self.currentCount += self.increment
                                                                    self.percentCounter.text = "\(self.currentCount)%"
                                                                    self.misdashboarddetail { dashboard_granted in
                                                                        if dashboard_granted {
                                                                            DispatchQueue.main.async {
                                                                                self.currentCount += self.increment
                                                                                self.percentCounter.text = "\(self.currentCount)%"
                                                                                //MARK: Wallet
                                                                                self.setupWallet { wallet_granted in
                                                                                    if wallet_granted {
                                                                                        DispatchQueue.main.async {
                                                                                            self.currentCount += self.increment
                                                                                            self.percentCounter.text = "\(self.currentCount)%"
                                                                                            self.setupwallethistorypoints { history_granted in
                                                                                                if history_granted {
                                                                                                    DispatchQueue.main.async {
                                                                                                        self.currentCount += self.increment
                                                                                                        self.percentCounter.text = "\(self.currentCount)%"
                                                                                                        self.setupwalletsummarypoints { summary_granted in
                                                                                                            if summary_granted {
                                                                                                                DispatchQueue.main.async {
                                                                                                                    self.currentCount += self.increment
                                                                                                                    self.percentCounter.text = "\(self.currentCount)%"
                                                                                                                    self.getwalletbeneficiaries { beneficiary_granted in
                                                                                                                        if beneficiary_granted {
                                                                                                                            DispatchQueue.main.async {
                                                                                                                                self.navigateHomeScreen()
                                                                                                                            }
                                                                                                                        } else {
                                                                                                                            self.showError()
                                                                                                                        }
                                                                                                                    }
                                                                                                                }
                                                                                                            } else {
                                                                                                                self.showError()
                                                                                                            }
                                                                                                        }
                                                                                                    }
                                                                                                } else {
                                                                                                    self.showError()
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    } else {
                                                                                        self.showError()
                                                                                    }
                                                                                }
                                                                            }
                                                                        } else {
                                                                            self.showError()
                                                                        }
                                                                    }
                                                                }
                                                            } else {
                                                                self.showError()
                                                            }
                                                        }
                                                    }
                                                } else {
                                                    self.showError()
                                                }
                                            }
                                        } else {
                                            //MARK: Wallet
                                            self.setupWallet { wallet_granted in
                                                if wallet_granted {
                                                    DispatchQueue.main.async {
                                                        self.currentCount += self.increment
                                                        self.percentCounter.text = "\(self.currentCount)%"
                                                        self.setupwallethistorypoints { history_granted in
                                                            if history_granted {
                                                                DispatchQueue.main.async {
                                                                    self.currentCount += self.increment
                                                                    self.percentCounter.text = "\(self.currentCount)%"
                                                                    self.setupwalletsummarypoints { summary_granted in
                                                                        if summary_granted {
                                                                            DispatchQueue.main.async {
                                                                                self.currentCount += self.increment
                                                                                self.percentCounter.text = "\(self.currentCount)%"
                                                                                self.getwalletbeneficiaries { beneficiary_granted in
                                                                                    if beneficiary_granted {
                                                                                        DispatchQueue.main.async {
                                                                                            self.navigateHomeScreen()
                                                                                        }
                                                                                    } else {
                                                                                        self.showError()
                                                                                    }
                                                                                }
                                                                            }
                                                                        } else {
                                                                            self.showError()
                                                                        }
                                                                    }
                                                                }
                                                            } else {
                                                                self.showError()
                                                            }
                                                        }
                                                    }
                                                } else {
                                                    self.showError()
                                                }
                                            }
                                        }
                                        return
                                    }
                                }
                            }
                        }
                        return
                    }
                    
                    if let notification_requests = JSON(response).dictionary?[_notification_requests]?.array {
                        let sync_date = JSON(response).dictionary?[_sync_date]?.string ?? ""
                        do {
                            for json in notification_requests {
                                self.isTotalCounter += 1
                                let dictionary = try json.rawData()
                                let hrNotification: HRNotificationRequest = try JSONDecoder().decode(HRNotificationRequest.self, from: dictionary)
                                AppDelegate.sharedInstance.db?.deleteRow(tableName: db_hr_notifications, column: "TICKET_ID", ref_id: "\(hrNotification.ticketID!)", handler: { _ in
                                    AppDelegate.sharedInstance.db?.insert_tbl_HR_Notification_Request(hnr: hrNotification, { _ in })
                                })
                            }
                            if self.isTotalCounter  >= self.count {
                                DispatchQueue.main.async {
                                    Helper.updateLastSyncStatus(APIName: GET_HR_NOTIFICATION,
                                                                date: sync_date,
                                                                skip: self.skip,
                                                                take: 80,
                                                                total_records: self.count)
                                    DispatchQueue.main.async {
                                        self.currentCount += self.increment
                                        self.percentCounter.text = "\(self.currentCount)%"
                                    }
                                    self.getTCSLocations {
                                        DispatchQueue.main.async {
                                            
                                            if self.isFulfilmentAllowed {
                                                self.skip = 0
                                                self.isTotalCounter = 0
                                                
                                                self.getFulfilment()
                                                return
                                            } else {
                                                if isMISListingAllowed {
                                                    self.getMISToken { token_granted in
                                                        if token_granted {
                                                            DispatchQueue.main.async {
                                                                self.currentCount += self.increment
                                                                self.percentCounter.text = "\(self.currentCount)%"
                                                                self.getmisdailyoverview { dailyOverview_granted in
                                                                    if dailyOverview_granted {
                                                                        DispatchQueue.main.async {
                                                                            self.currentCount += self.increment
                                                                            self.percentCounter.text = "\(self.currentCount)%"
                                                                            self.misdashboarddetail { dashboard_granted in
                                                                                if dashboard_granted {
                                                                                    DispatchQueue.main.async {
                                                                                        self.currentCount += self.increment
                                                                                        self.percentCounter.text = "\(self.currentCount)%"
                                                                                        //MARK: Wallet
                                                                                        self.setupWallet { wallet_granted in
                                                                                            if wallet_granted {
                                                                                                DispatchQueue.main.async {
                                                                                                    self.currentCount += self.increment
                                                                                                    self.percentCounter.text = "\(self.currentCount)%"
                                                                                                    self.setupwallethistorypoints { history_granted in
                                                                                                        if history_granted {
                                                                                                            DispatchQueue.main.async {
                                                                                                                self.currentCount += self.increment
                                                                                                                self.percentCounter.text = "\(self.currentCount)%"
                                                                                                                self.setupwalletsummarypoints { summary_granted in
                                                                                                                    if summary_granted {
                                                                                                                        DispatchQueue.main.async {
                                                                                                                            self.currentCount += self.increment
                                                                                                                            self.percentCounter.text = "\(self.currentCount)%"
                                                                                                                            self.getwalletbeneficiaries { beneficiary_granted in
                                                                                                                                if beneficiary_granted {
                                                                                                                                    DispatchQueue.main.async {
                                                                                                                                        self.navigateHomeScreen()
                                                                                                                                    }
                                                                                                                                } else {
                                                                                                                                    self.showError()
                                                                                                                                }
                                                                                                                            }
                                                                                                                        }
                                                                                                                    } else {
                                                                                                                        self.showError()
                                                                                                                    }
                                                                                                                }
                                                                                                            }
                                                                                                        } else {
                                                                                                            self.showError()
                                                                                                        }
                                                                                                    }
                                                                                                }
                                                                                            } else {
                                                                                                self.showError()
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                } else {
                                                                                    self.showError()
                                                                                }
                                                                            }
                                                                        }
                                                                    } else {
                                                                        self.showError()
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            self.showError()
                                                        }
                                                    }
                                                } else {
                                                    //MARK: Wallet
                                                    self.setupWallet { wallet_granted in
                                                        if wallet_granted {
                                                            DispatchQueue.main.async {
                                                                self.currentCount += self.increment
                                                                self.percentCounter.text = "\(self.currentCount)%"
                                                                self.setupwallethistorypoints { history_granted in
                                                                    if history_granted {
                                                                        DispatchQueue.main.async {
                                                                            self.currentCount += self.increment
                                                                            self.percentCounter.text = "\(self.currentCount)%"
                                                                            self.setupwalletsummarypoints { summary_granted in
                                                                                if summary_granted {
                                                                                    DispatchQueue.main.async {
                                                                                        self.currentCount += self.increment
                                                                                        self.percentCounter.text = "\(self.currentCount)%"
                                                                                        self.getwalletbeneficiaries { beneficiary_granted in
                                                                                            if beneficiary_granted {
                                                                                                DispatchQueue.main.async {
                                                                                                    self.navigateHomeScreen()
                                                                                                }
                                                                                            } else {
                                                                                                self.showError()
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                } else {
                                                                                    self.showError()
                                                                                }
                                                                            }
                                                                        }
                                                                    } else {
                                                                        self.showError()
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            self.showError()
                                                        }
                                                    }
                                                }
                                                return
                                            }
                                        }
                                    }
                                }
                            } else {
                                self.skip += 80
                                self.getHrNotifications()
                            }
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
                        self.getTCSLocations {
                            DispatchQueue.main.async {
                                self.currentCount += self.increment
                                self.percentCounter.text = "\(self.currentCount)%"
                                if self.isFulfilmentAllowed {
                                    self.skip = 0
                                    self.isTotalCounter = 0
                                    
                                    self.getFulfilment()
                                    return
                                } else {
                                    //MIS Setup
                                    if isMISListingAllowed {
                                        self.getMISToken { token_granted in
                                            if token_granted {
                                                DispatchQueue.main.async {
                                                    self.currentCount += self.increment
                                                    self.percentCounter.text = "\(self.currentCount)%"
                                                    self.getmisdailyoverview { dailyOverview_granted in
                                                        if dailyOverview_granted {
                                                            DispatchQueue.main.async {
                                                                self.currentCount += self.increment
                                                                self.percentCounter.text = "\(self.currentCount)%"
                                                                self.misdashboarddetail { dashboard_granted in
                                                                    if dashboard_granted {
                                                                        DispatchQueue.main.async {
                                                                            self.currentCount += self.increment
                                                                            self.percentCounter.text = "\(self.currentCount)%"
                                                                            //MARK: Wallet
                                                                            self.setupWallet { wallet_granted in
                                                                                if wallet_granted {
                                                                                    DispatchQueue.main.async {
                                                                                        self.currentCount += self.increment
                                                                                        self.percentCounter.text = "\(self.currentCount)%"
                                                                                        self.setupwallethistorypoints { history_granted in
                                                                                            if history_granted {
                                                                                                DispatchQueue.main.async {
                                                                                                    self.currentCount += self.increment
                                                                                                    self.percentCounter.text = "\(self.currentCount)%"
                                                                                                    self.setupwalletsummarypoints { summary_granted in
                                                                                                        if summary_granted {
                                                                                                            DispatchQueue.main.async {
                                                                                                                self.currentCount += self.increment
                                                                                                                self.percentCounter.text = "\(self.currentCount)%"
                                                                                                                self.getwalletbeneficiaries { beneficiary_granted in
                                                                                                                    if beneficiary_granted {
                                                                                                                        DispatchQueue.main.async {
                                                                                                                            self.navigateHomeScreen()
                                                                                                                        }
                                                                                                                    } else {
                                                                                                                        self.showError()
                                                                                                                    }
                                                                                                                }
                                                                                                            }
                                                                                                        } else {
                                                                                                            self.showError()
                                                                                                        }
                                                                                                    }
                                                                                                }
                                                                                            } else {
                                                                                                self.showError()
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                } else {
                                                                                    self.showError()
                                                                                }
                                                                            }
                                                                        }
                                                                    } else {
                                                                        self.showError()
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            self.showError()
                                                        }
                                                    }
                                                }
                                            } else {
                                                self.showError()
                                            }
                                        }
                                    } else {
                                        //MARK: Wallet
                                        self.setupWallet { wallet_granted in
                                            if wallet_granted {
                                                DispatchQueue.main.async {
                                                    self.currentCount += self.increment
                                                    self.percentCounter.text = "\(self.currentCount)%"
                                                    self.setupwallethistorypoints { history_granted in
                                                        if history_granted {
                                                            DispatchQueue.main.async {
                                                                self.currentCount += self.increment
                                                                self.percentCounter.text = "\(self.currentCount)%"
                                                                self.setupwalletsummarypoints { summary_granted in
                                                                    if summary_granted {
                                                                        DispatchQueue.main.async {
                                                                            self.currentCount += self.increment
                                                                            self.percentCounter.text = "\(self.currentCount)%"
                                                                            self.getwalletbeneficiaries { beneficiary_granted in
                                                                                if beneficiary_granted {
                                                                                    DispatchQueue.main.async {
                                                                                        self.navigateHomeScreen()
                                                                                    }
                                                                                } else {
                                                                                    self.showError()
                                                                                }
                                                                            }
                                                                        }
                                                                    } else {
                                                                        self.showError()
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            self.showError()
                                                        }
                                                    }
                                                }
                                            } else {
                                                self.showError()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                } else {
                    self.showError()
                }
            }
        }
    }
}

//MARK: - Get TCS Locations
extension LandingViewController {
    func getTCSLocations (_ handler: @escaping()->Void) {
        let json = [
            "location_request" : [
                "access_token" : access_token
            ]
        ]
        let params = self.getAPIParameter(service_name: GETLOCATIONS, request_body: json)
        NetworkCalls.get_tcs_location(params: params) { (granted, response) in
            if granted {
                if let data = JSON(response).array {
                    AppDelegate.sharedInstance.db?.deleteAll(tableName: db_att_locations, handler: { _ in
                        for locations in data {
                            do {
                                let dictionary = try locations.rawData()
                                let att_location = try JSONDecoder().decode(AttLocations.self, from: dictionary)
                                AppDelegate.sharedInstance.db?.insert_tbl_att_locations(att_location: att_location)
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
                        }
                    })
                }
            } else {
//                self.showError()
            }
            handler()
        }
    }
}
//MARK: - Fulfilment Orders
extension LandingViewController {
    private func getAPIParameters(service_name: String, request_body: [String: Any]) -> [String:Any] {
        let params = [
            "eAI_MESSAGE": [
                "eAI_HEADER": [
                    "serviceName": service_name,
                    "client": "ibm_apiconnect",
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
    func getFulfilment() {
        var fulfilment = [String: [String:Any]]()
        if let lastSyncStatus = AppDelegate.sharedInstance.db?.readLastSyncStatus(tableName: db_last_sync_status,
                                                                                  condition: "SYNC_KEY = '\(GETORDERFULFILMET)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'") {
            fulfilment = [
                "hr_request":[
                    "access_token": access_token,
                    "skip" :0,
                    "take" : 80,
                    "sync_date": lastSyncStatus.DATE
                ]
            ]
        } else {
            fulfilment = [
                "hr_request":[
                    "access_token": access_token,
                    "skip" :skip,
                    "take" : 80,
                    "sync_date": ""
                ]
            ]
        }
        let params = self.getAPIParameters(service_name: GETORDERFULFILMET, request_body: fulfilment)
        NetworkCalls.getorderfulfilment(params: params) { success, response in
            if success {
                self.count = JSON(response).dictionary![_count]!.intValue
                if self.count <= 0 {
                    DispatchQueue.main.async {
                        self.currentCount += self.increment
                        self.percentCounter.text = "\(self.currentCount)%"
                        //MIS Setup
                        if isMISListingAllowed {
                            self.getMISToken { token_granted in
                                if token_granted {
                                    DispatchQueue.main.async {
                                        self.getmisdailyoverview { dailyOverview_granted in
                                            if dailyOverview_granted {
                                                DispatchQueue.main.async {
                                                    self.currentCount += self.increment
                                                    self.percentCounter.text = "\(self.currentCount)%"
                                                    self.misdashboarddetail { dashboard_granted in
                                                        if dashboard_granted {
                                                            DispatchQueue.main.async {
                                                                self.currentCount += self.increment
                                                                self.percentCounter.text = "\(self.currentCount)%"
                                                                //MARK: Wallet
                                                                self.setupWallet { wallet_granted in
                                                                    if wallet_granted {
                                                                        DispatchQueue.main.async {
                                                                            self.currentCount += self.increment
                                                                            self.percentCounter.text = "\(self.currentCount)%"
                                                                            self.setupwallethistorypoints { history_granted in
                                                                                if history_granted {
                                                                                    DispatchQueue.main.async {
                                                                                        self.currentCount += self.increment
                                                                                        self.percentCounter.text = "\(self.currentCount)%"
                                                                                        self.setupwalletsummarypoints { summary_granted in
                                                                                            if summary_granted {
                                                                                                DispatchQueue.main.async {
                                                                                                    self.currentCount += self.increment
                                                                                                    self.percentCounter.text = "\(self.currentCount)%"
                                                                                                    self.getwalletbeneficiaries { beneficiary_granted in
                                                                                                        if beneficiary_granted {
                                                                                                            DispatchQueue.main.async {
                                                                                                                self.navigateHomeScreen()
                                                                                                            }
                                                                                                        } else {
                                                                                                            self.showError()
                                                                                                        }
                                                                                                    }
                                                                                                }
                                                                                            } else {
                                                                                                self.showError()
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                } else {
                                                                                    self.showError()
                                                                                }
                                                                            }
                                                                        }
                                                                    } else {
                                                                        self.showError()
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            self.showError()
                                                        }
                                                    }
                                                }
                                            } else {
                                                self.showError()
                                            }
                                        }
                                    }
                                } else {
                                    self.showError()
                                }
                            }
                        } else {
                            //MARK: Wallet
                            self.setupWallet { wallet_granted in
                                if wallet_granted {
                                    DispatchQueue.main.async {
                                        self.currentCount += self.increment
                                        self.percentCounter.text = "\(self.currentCount)%"
                                        self.setupwallethistorypoints { history_granted in
                                            if history_granted {
                                                DispatchQueue.main.async {
                                                    self.currentCount += self.increment
                                                    self.percentCounter.text = "\(self.currentCount)%"
                                                    self.setupwalletsummarypoints { summary_granted in
                                                        if summary_granted {
                                                            DispatchQueue.main.async {
                                                                self.currentCount += self.increment
                                                                self.percentCounter.text = "\(self.currentCount)%"
                                                                self.getwalletbeneficiaries { beneficiary_granted in
                                                                    if beneficiary_granted {
                                                                        DispatchQueue.main.async {
                                                                            self.navigateHomeScreen()
                                                                        }
                                                                    } else {
                                                                        self.showError()
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            self.showError()
                                                        }
                                                    }
                                                }
                                            } else {
                                                self.showError()
                                            }
                                        }
                                    }
                                } else {
                                    self.showError()
                                }
                            }
                        }
                    }
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
                                AppDelegate.sharedInstance.db?.insert_tbl_fulfilment_orders(fulfilment_orders: fulfilment_orders, handler: { _ in })
                            })
                        }
                        if self.isTotalCounter  >= self.count {
                            DispatchQueue.main.async {
                                self.currentCount += self.increment
                                self.percentCounter.text = "\(self.currentCount)%"
                                Helper.updateLastSyncStatus(APIName: GETORDERFULFILMET,
                                                            date: sync_date,
                                                            skip: self.skip,
                                                            take: 80,
                                                            total_records: self.count)
                                DispatchQueue.main.async {
                                    //MIS Setup
                                    if isMISListingAllowed {
                                        self.getMISToken { token_granted in
                                            if token_granted {
                                                DispatchQueue.main.async {
                                                    self.currentCount += self.increment
                                                    self.percentCounter.text = "\(self.currentCount)%"
                                                    self.getmisdailyoverview { dailyOverview_granted in
                                                        if dailyOverview_granted {
                                                            DispatchQueue.main.async {
                                                                self.currentCount += self.increment
                                                                self.percentCounter.text = "\(self.currentCount)%"
                                                                self.misdashboarddetail { dashboard_granted in
                                                                    if dashboard_granted {
                                                                        DispatchQueue.main.async {
                                                                            self.currentCount += self.increment
                                                                            self.percentCounter.text = "\(self.currentCount)%"
                                                                            //MARK: Wallet
                                                                            self.setupWallet { wallet_granted in
                                                                                if wallet_granted {
                                                                                    DispatchQueue.main.async {
                                                                                        self.currentCount += self.increment
                                                                                        self.percentCounter.text = "\(self.currentCount)%"
                                                                                        self.setupwallethistorypoints { history_granted in
                                                                                            if history_granted {
                                                                                                DispatchQueue.main.async {
                                                                                                    self.currentCount += self.increment
                                                                                                    self.percentCounter.text = "\(self.currentCount)%"
                                                                                                    self.setupwalletsummarypoints { summary_granted in
                                                                                                        if summary_granted {
                                                                                                            DispatchQueue.main.async {
                                                                                                                self.currentCount += self.increment
                                                                                                                self.percentCounter.text = "\(self.currentCount)%"
                                                                                                                self.getwalletbeneficiaries { beneficiary_granted in
                                                                                                                    if beneficiary_granted {
                                                                                                                        DispatchQueue.main.async {
                                                                                                                            self.navigateHomeScreen()
                                                                                                                        }
                                                                                                                    } else {
                                                                                                                        self.showError()
                                                                                                                    }
                                                                                                                }
                                                                                                            }
                                                                                                        } else {
                                                                                                            self.showError()
                                                                                                        }
                                                                                                    }
                                                                                                }
                                                                                            } else {
                                                                                                self.showError()
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                } else {
                                                                                    self.showError()
                                                                                }
                                                                            }
                                                                        }
                                                                    } else {
                                                                        self.showError()
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            self.showError()
                                                        }
                                                    }
                                                }
                                            } else {
                                                self.showError()
                                            }
                                        }
                                    } else {
                                        //MARK: Wallet
                                        self.setupWallet { wallet_granted in
                                            if wallet_granted {
                                                DispatchQueue.main.async {
                                                    self.currentCount += self.increment
                                                    self.percentCounter.text = "\(self.currentCount)%"
                                                    self.setupwallethistorypoints { history_granted in
                                                        if history_granted {
                                                            DispatchQueue.main.async {
                                                                self.currentCount += self.increment
                                                                self.percentCounter.text = "\(self.currentCount)%"
                                                                self.setupwalletsummarypoints { summary_granted in
                                                                    if summary_granted {
                                                                        DispatchQueue.main.async {
                                                                            self.currentCount += self.increment
                                                                            self.percentCounter.text = "\(self.currentCount)%"
                                                                            self.getwalletbeneficiaries { beneficiary_granted in
                                                                                if beneficiary_granted {
                                                                                    DispatchQueue.main.async {
                                                                                        self.navigateHomeScreen()
                                                                                    }
                                                                                } else {
                                                                                    self.showError()
                                                                                }
                                                                            }
                                                                        }
                                                                    } else {
                                                                        self.showError()
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            self.showError()
                                                        }
                                                    }
                                                }
                                            } else {
                                                self.showError()
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            self.skip += 80
                            self.getFulfilment()
                        }
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
                    DispatchQueue.main.async {
                        //MIS Setup
                        if isMISListingAllowed {
                            self.getMISToken { token_granted in
                                if token_granted {
                                    DispatchQueue.main.async {
                                        self.currentCount += self.increment
                                        self.percentCounter.text = "\(self.currentCount)%"
                                        self.getmisdailyoverview { dailyOverview_granted in
                                            if dailyOverview_granted {
                                                DispatchQueue.main.async {
                                                    self.currentCount += self.increment
                                                    self.percentCounter.text = "\(self.currentCount)%"
                                                    self.misdashboarddetail { dashboard_granted in
                                                        if dashboard_granted {
                                                            DispatchQueue.main.async {
                                                                self.currentCount += self.increment
                                                                self.percentCounter.text = "\(self.currentCount)%"
                                                                //MARK: Wallet
                                                                self.setupWallet { wallet_granted in
                                                                    if wallet_granted {
                                                                        DispatchQueue.main.async {
                                                                            self.currentCount += self.increment
                                                                            self.percentCounter.text = "\(self.currentCount)%"
                                                                            self.setupwallethistorypoints { history_granted in
                                                                                if history_granted {
                                                                                    DispatchQueue.main.async {
                                                                                        self.currentCount += self.increment
                                                                                        self.percentCounter.text = "\(self.currentCount)%"
                                                                                        self.setupwalletsummarypoints { summary_granted in
                                                                                            if summary_granted {
                                                                                                DispatchQueue.main.async {
                                                                                                    self.currentCount += self.increment
                                                                                                    self.percentCounter.text = "\(self.currentCount)%"
                                                                                                    self.getwalletbeneficiaries { beneficiary_granted in
                                                                                                        if beneficiary_granted {
                                                                                                            DispatchQueue.main.async {
                                                                                                                self.navigateHomeScreen()
                                                                                                            }
                                                                                                        } else {
                                                                                                            self.showError()
                                                                                                        }
                                                                                                    }
                                                                                                }
                                                                                            } else {
                                                                                                self.showError()
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                } else {
                                                                                    self.showError()
                                                                                }
                                                                            }
                                                                        }
                                                                    } else {
                                                                        self.showError()
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            self.showError()
                                                        }
                                                    }
                                                }
                                            } else {
                                                self.showError()
                                            }
                                        }
                                    }
                                } else {
                                    self.showError()
                                }
                            }
                        } else {
                            //MARK: Wallet
                            self.setupWallet { wallet_granted in
                                if wallet_granted {
                                    DispatchQueue.main.async {
                                        self.currentCount += self.increment
                                        self.percentCounter.text = "\(self.currentCount)%"
                                        self.setupwallethistorypoints { history_granted in
                                            if history_granted {
                                                DispatchQueue.main.async {
                                                    self.currentCount += self.increment
                                                    self.percentCounter.text = "\(self.currentCount)%"
                                                    self.setupwalletsummarypoints { summary_granted in
                                                        if summary_granted {
                                                            DispatchQueue.main.async {
                                                                self.currentCount += self.increment
                                                                self.percentCounter.text = "\(self.currentCount)%"
                                                                self.getwalletbeneficiaries { beneficiary_granted in
                                                                    if beneficiary_granted {
                                                                        DispatchQueue.main.async {
                                                                            self.navigateHomeScreen()
                                                                        }
                                                                    } else {
                                                                        self.showError()
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            self.showError()
                                                        }
                                                    }
                                                }
                                            } else {
                                                self.showError()
                                            }
                                        }
                                    }
                                } else {
                                    self.showError()
                                }
                            }
                        }
                    }
                }
                
            } else {
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
    }
}
//MARK: - Management Information System
extension LandingViewController {
    private func getMISToken(_ handler: @escaping(Bool)->Void) {
        let params = ["clientSecret": MISCLIENTSECRET] as [String:Any]
        NetworkCalls.getmistoken(params: params) { token_granted in
            if token_granted {
                //get MIS Setup Data
                DispatchQueue.main.async {
                    self.currentCount += self.increment
                    self.percentCounter.text = "\(self.currentCount)%"
                }
                let request_body = [String: Any]()
                let params = [
                    "eAI_MESSAGE": [
                        "eAI_HEADER": [
                            "serviceName": S_MIS_BUDGET_SETUP,
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
                ] as [String :Any]
                NetworkCalls.setupmis(params: params) { setup_granted, response in
                    if setup_granted {
                        let json = JSON(response)
                        if let _BudgetSetup = json.dictionary?[_BudgetSetup]?.array {
                            do {
                                AppDelegate.sharedInstance.db?.deleteAll(tableName: db_mis_budget_setup, handler: { _ in })
                                for budgetSetup in _BudgetSetup {
                                    let rawData = try budgetSetup.rawData()
                                    let budget_setup: BudgetSetup = try JSONDecoder().decode(BudgetSetup.self, from: rawData)
                                    AppDelegate.sharedInstance.db?.insert_tbl_mis_budget_setup(budget_setup: budget_setup, handler: { _ in })
                                }
                                handler(true)
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
                            handler(false)
                        }
                    } else {
                        handler(false)
                    }
                }
            } else {
                handler(false)
            }
        }
    }
    
    //GET Daily Delivery
    private func getmisdailyoverview(_ handler: @escaping(Bool)->Void) {
        var last_budget_data = [String:Any]()
        if let lastSyncStatus = AppDelegate.sharedInstance.db?.readLastSyncStatus(tableName: db_last_sync_status,
                                                                                  condition: "SYNC_KEY = '\(S_MIS_BUDGET_DATA)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'") {
            last_budget_data = [
                "dateTime" : ""//lastSyncStatus.DATE
            ]
        } else {
            last_budget_data = [
                "dateTime": ""
            ]
        }
        
        let params = [
            "eAI_MESSAGE": [
              "eAI_HEADER": [
                "serviceName": S_MIS_BUDGET_DATA,
                "client": "",
                "clientChannel": "",
                "referenceNum": "",
                "securityInfo": [
                  "authentication": [
                    "userId": "string",
                    "password": "string"
                  ]
                ]
              ],
              "eAI_BODY": [
                "eAI_REQUEST": last_budget_data
              ]
            ]
        ] as [String:Any]
        
        NetworkCalls.getbudgetdata(params: params) { daily_granted, response in
            if daily_granted {
                let json = JSON(response)
                if let budgetData = json.dictionary?[_budgetData]?.array {
                    do {
                        if budgetData.count <= 0 {
                            if let lastSync = json.dictionary?["lastSync"]?.string {
                                Helper.updateLastSyncStatus(APIName: S_MIS_BUDGET_DATA,
                                                            date: lastSync,
                                                            skip: 0,
                                                            take: 0,
                                                            total_records: 0)
                            }
                            handler(true)
                            return
                        }
                        
                        for bd in budgetData {
                            let rawData = try bd.rawData()
                            let budget_data: BudgetData = try JSONDecoder().decode(BudgetData.self, from: rawData)
                            AppDelegate.sharedInstance.db?.deleteRowWithMultipleConditions(tbl: db_mis_budget_data, conditions: "RPT_DATE = '\(budget_data.rptDate)' AND TYPE = '\(budget_data.type)'", { _ in
                                AppDelegate.sharedInstance.db?.insert_tbl_mis_budget_data(budget_data: budget_data, handler: { _ in })
                            })
                            
                        }
                        if let lastSync = json.dictionary?["lastSyncDate"]?.string {
                            Helper.updateLastSyncStatus(APIName: S_MIS_BUDGET_DATA,
                                                        date: lastSync,
                                                        skip: 0,
                                                        take: 0,
                                                        total_records: 0)
                        }
                        handler(true)
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
                    handler(false)
                }
            } else {
                handler(false)
            }
        }
    }
    
    //MARK: Dashboard Detail
    private func misdashboarddetail(_ handler: @escaping(Bool)->Void) {
        var last_budget_data = [String:Any]()
        if let lastSyncStatus = AppDelegate.sharedInstance.db?.readLastSyncStatus(tableName: db_last_sync_status,
                                                                                  condition: "SYNC_KEY = '\(S_MIS_DASHBOARD_DETAILS)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'") {
            last_budget_data = [
                "dateTime" : lastSyncStatus.DATE
            ]
        } else {
            last_budget_data = [
                "dateTime": ""
            ]
        }
        
        let params = [
            "eAI_MESSAGE": [
              "eAI_HEADER": [
                "serviceName": S_MIS_DASHBOARD_DETAILS,
                "client": "",
                "clientChannel": "",
                "referenceNum": "",
                "securityInfo": [
                  "authentication": [
                    "userId": "string",
                    "password": "string"
                  ]
                ]
              ],
              "eAI_BODY": [
                "eAI_REQUEST": last_budget_data
              ]
            ]
        ] as [String:Any]
        NetworkCalls.getmisdashboarddetails(params: params) { granted, response in
            if granted {
                let json = JSON(response)
                if let budgetData = json.dictionary?[_dashboardDetail]?.array {
                    do {
                        if budgetData.count <= 0 {
                            if let lastSync = json.dictionary?["lastSyncDate"]?.string {
                                Helper.updateLastSyncStatus(APIName: S_MIS_DASHBOARD_DETAILS,
                                                            date: lastSync,
                                                            skip: 0,
                                                            take: 0,
                                                            total_records: 0)
                            }
                            handler(true)
                            return
                        }
                        
                        for bd in budgetData {
                            let rawData = try bd.rawData()
                            let dashboard_detail: MISDashboardDetail = try JSONDecoder().decode(MISDashboardDetail.self, from: rawData)
                            let condition = "PRODUCT = '\(dashboard_detail.product)' AND MNTH = '\(dashboard_detail.mnth)' AND YEARR = '\(dashboard_detail.yearr)' AND TITLE = '\(dashboard_detail.title)' AND TYP = '\(dashboard_detail.typ)'"
                            AppDelegate.sharedInstance.db?.deleteRowWithMultipleConditions(tbl: db_mis_dashboard_detail, conditions: condition, { _ in
                                AppDelegate.sharedInstance.db?.insert_tbl_mis_dashboard_detail(dashboard_detail: dashboard_detail, handler: { _ in })
                            })
                        }
                        if let lastSync = json.dictionary?["lastSyncDate"]?.string {
                            Helper.updateLastSyncStatus(APIName: S_MIS_DASHBOARD_DETAILS,
                                                        date: lastSync,
                                                        skip: 0,
                                                        take: 0,
                                                        total_records: 0)
                        }
                        handler(true)
                        return
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
                    handler(false)
                }
                handler(true)
            } else {
                handler(false)
            }
        }
    }
}


extension LandingViewController {
    @objc func navigateHomeScreen() {
        
        self.percentCounter.text = "100%"
        UserDefaults.standard.setValue(CURRENT_USER_LOGGED_IN_ID, forKeyPath: "CurrentUser")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            NotificationCenter.default.removeObserver(self)
            if self.isPresented {
                self.isPresented = false
                self.dismiss(animated: true) {
                    NotificationCenter.default.post(Notification.init(name: .refreshedViews))
                }
                return
            }
            
            let dashboard = UIStoryboard(name: "Dashboard", bundle: nil)
            let controller = dashboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .overFullScreen
                
            }
            self.navigationController?.pushViewController(controller, animated: true)
            self.resetAllSettings()
        }
        Messaging.messaging().subscribe(toTopic: BROADCAST_KEY) { error in
            guard let err = error else {
                print("user subscribed")
                return
            }
            print(err.localizedDescription)
        }
    }
}


extension LandingViewController {
    func resetAllSettings() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.safeTopArea = 0.0
            self.currentCenterConstraintPosition = 0.0
            
            self.totalApiCounts = 9 //Setup, HrRequest, HrNotification, Attendance, Wallet-> Token, Setup, HistoryPoints, SummaryPoints, Beneficiairy
            self.increment = 0
            self.currentCount = 0
            
            self.isIMSAllowed = false
            self.isFulfilmentAllowed = false
            self.access_token = ""
            self.skip = 0
            self.count = 0
            self.isTotalCounter = 0
            self.mainViewHeightConstraint.constant = 0
            self.logoHeightConstraint.constant = 211
            self.logoCenterConstraint.constant = 0
        }
    }
    
    func openLoginScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            let storyboard = UIStoryboard(name: "UserCredentials", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "mainNavigation") as! UINavigationController
            (controller.children.first as! EnterPinViewController).delegate = self
            controller.modalTransitionStyle = .crossDissolve
            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .overFullScreen
            }
            self.present(controller, animated: true, completion: nil)
            self.resetAllSettings()
        }
    }
    
    func showError() {
        DispatchQueue.main.async {
            self.view.makeToast("Session Expired")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                Messaging.messaging().unsubscribe(fromTopic: BROADCAST_KEY)
                AppDelegate.sharedInstance.db?.deleteRow(tableName: db_last_sync_status, column: "SYNC_KEY", ref_id: GET_HR_NOTIFICATION, handler: { _ in })
                AppDelegate.sharedInstance.db?.deleteRow(tableName: db_last_sync_status, column: "SYNC_KEY", ref_id: GETORDERFULFILMET, handler: { _ in })
                
                AppDelegate.sharedInstance.db?.deleteAll(tableName: db_hr_notifications, handler: { _ in })
                AppDelegate.sharedInstance.db?.deleteAll(tableName: db_fulfilment_orders, handler: { _ in })
                UserDefaults.standard.removeObject(forKey: USER_ACCESS_TOKEN)
                UserDefaults.standard.removeObject(forKey: "CurrentUser")
                if self.isPresented {
                    self.dismiss(animated: true) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            UserDefaults.standard.set(true, forKey: "Logout")
                            Helper.topMostController().navigationController?.popToRootViewController(animated: true)
                        }
                    }
                    return
                }
                self.openLoginScreen()
            }
        }
    }
}
//MARK: Wallet Setup
extension LandingViewController {
    func setupWallet(_ handler: @escaping(Bool)->Void) {
        NetworkCalls.getwallettoken { granted in
            if granted {
                DispatchQueue.main.async {
                    self.currentCount += self.increment
                    self.percentCounter.text = "\(self.currentCount)%"
                }
                let request_body = [String : Any]()
                let params = self.getAPIParameterNew(serviceName: S_WALLET_GET_SETUP, client: "", request_body: request_body)
                NetworkCalls.setupwallet(params: params) { granted, response in
                    if granted {
                        let json = JSON(response)
                        if let o = json.dictionary?[_result]?.dictionary?[_walletSetupData] {
                            do {
                                let rawdata = try o.rawData()
                                let model = try JSONDecoder().decode(WalletSetupData.self, from: rawdata)
                                AppDelegate.sharedInstance.db?.deleteAll(tableName: db_w_query_master, handler: { _ in })
                                AppDelegate.sharedInstance.db?.deleteAll(tableName: db_w_pointtypes, handler: { _ in })
                                AppDelegate.sharedInstance.db?.deleteAll(tableName: db_w_setup_redemption, handler: { _ in })
                                
                                for incentiveData in model.incentiveData {
                                    AppDelegate.sharedInstance.db?.insert_tbl_wallet_query_master(incentiveData: incentiveData, handler: { _ in })
                                }
                                for pointType in model.pointType {
                                    AppDelegate.sharedInstance.db?.insert_tbl_wallet_point_type(pointType: pointType, handler: { _ in })
                                }
                                for setupRedemption in model.redemptionSetup {
                                    AppDelegate.sharedInstance.db?.insert_tbl_wallet_setup(redemptionSetup: setupRedemption, handler: { _ in })
                                }
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
                            handler(true)
                        } else {
                            handler(false)
                        }
                    } else {
                        handler(false)
                    }
                }
            } else {
                handler(false)
            }
        }
    }
    
    func setupwallethistorypoints(_ handler: @escaping(Bool)-> Void) {
        let lastSyncStatus = AppDelegate.sharedInstance.db?.readLastSyncStatus(tableName: db_last_sync_status,
                                                                               condition: "SYNC_KEY = '\(S_WALLET_POINTS_HISTORY)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'")
        var history_points = [String:Any]()
        if lastSyncStatus == nil {
            history_points = [
                "p_employee_id": "\(CURRENT_USER_LOGGED_IN_ID)",
                "p_transaction_date": "",
                "p_skip": self.skip,
                "p_take": 80
            ]
        } else {
            history_points = [
                "p_employee_id": "\(CURRENT_USER_LOGGED_IN_ID)",
                "p_transaction_date": "\(lastSyncStatus!.DATE)",
                "p_skip": lastSyncStatus!.SKIP,
                "p_take": 80
            ]
        }
        
        
        let params = self.getAPIParameters(service_name: S_WALLET_POINTS_HISTORY, request_body: history_points)
        NetworkCalls.getwallethistorypoints(params: params) { granted, response in
            if granted {
                let json = JSON(response)
                if let walletHistoryPointsData = json.dictionary?[_result]?.dictionary?[_walletHistoryPointData] {
                    self.count = Int(walletHistoryPointsData[_count].string ?? "0") ?? 0
                    let syncDate = walletHistoryPointsData[_sync_date].string ?? "2021-07-13"
                    if self.count <= 0 {
                        self.isTotalCounter = 0
                        handler(true)
                        return
                    }
                    if let walletHistoryPoints = walletHistoryPointsData[_walletHistoryPoints].array {
                        for history in walletHistoryPoints {
                            do {
                                let data = try history.rawData()
                                let historyPoints: WalletHistoryPoint = try JSONDecoder().decode(WalletHistoryPoint.self, from: data)
                                self.isTotalCounter += 1
                                AppDelegate.sharedInstance.db?.deleteRowWithMultipleConditions(tbl: db_w_history_point, conditions: "RID = '\(historyPoints.rid)'", { _ in
                                    AppDelegate.sharedInstance.db?.insert_tbl_wallet_history_point(history_point: historyPoints, handler: { _ in })
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
                        }
                        if self.count == self.isTotalCounter {
                            DispatchQueue.main.async {
                                Helper.updateLastSyncStatus(APIName: S_WALLET_POINTS_HISTORY,
                                                            date: syncDate, //MARK: Change Date
                                                            skip: self.skip,
                                                            take: 80,
                                                            total_records: self.count)
                                self.count = 0
                                self.skip = 0
                                self.isTotalCounter = 0
                                handler(true)
                            }
                        } else {
                            self.skip += 80
                            self.setupwallethistorypoints { _ in }
                        }
                    }
                } else {
                    handler(false)
                }
            } else {
                handler(false)
            }
        }
    }
    
    func setupwalletsummarypoints(_ handler: @escaping(Bool)->Void) {
        let lastSyncStatus = AppDelegate.sharedInstance.db?.readLastSyncStatus(tableName: db_last_sync_status,
                                                                               condition: "SYNC_KEY = '\(S_WALLET_POINTS_SUMMARY)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'")
        var summary_points = [String:Any]()
        if lastSyncStatus == nil {
            summary_points = [
                "p_employee_id": "\(CURRENT_USER_LOGGED_IN_ID)",
                "p_transaction_date": ""
            ]
        } else {
            summary_points = [
                "p_employee_id": "\(CURRENT_USER_LOGGED_IN_ID)",
                "p_transaction_date": "\(lastSyncStatus!.DATE)"
            ]
        }
        let params = self.getAPIParameters(service_name: S_WALLET_POINTS_SUMMARY, request_body: summary_points)
        NetworkCalls.getwalletsummarypoints(params: params) { granted, response in
            if granted {
                let json = JSON(response)
                if let _walletSummaryPointData = json.dictionary?[_result]?.dictionary?[_walletSummaryPointData] {
                    let syncDate = _walletSummaryPointData[_sync_date].string ?? "2021-07-13"
                    if let pointsSummary = _walletSummaryPointData[_pointsSummary].array {
                        for summary in pointsSummary {
                            do {
                                let data = try summary.rawData()
                                let summaryPoints: PointsSummary = try JSONDecoder().decode(PointsSummary.self, from: data)
                                self.isTotalCounter += 1
                                AppDelegate.sharedInstance.db?.deleteRowWithMultipleConditions(tbl: db_w_pointSummary, conditions: "TRANSACTION_DATE = '\(summaryPoints.transactionDate)' AND EMPLOYEE_ID = '\(CURRENT_USER_LOGGED_IN_ID)'", { _ in
                                    
                                    AppDelegate.sharedInstance.db?.deleteRowWithMultipleConditions(tbl: db_w_pointSumDetails, conditions: "TRANSACTION_DATE = '\(summaryPoints.transactionDate)' AND EMPLOYEE_ID = '\(CURRENT_USER_LOGGED_IN_ID)'", { _ in })
                                    
                                    
                                    AppDelegate.sharedInstance.db?.insert_tbl_wallet_point_summary(point_summary: summaryPoints, handler: { _ in
                                        for detail in summaryPoints.pointSummaryDetails {
                                            AppDelegate.sharedInstance.db?.insert_tbl_wallet_point_summary_detail(summary_detail: detail) { _ in }
                                        }
                                    })
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
                        }
                        Helper.updateLastSyncStatus(APIName: S_WALLET_POINTS_SUMMARY,
                                                    date: syncDate,
                                                    skip: 0,
                                                    take: 0,
                                                    total_records: 0)
                        handler(true)
                        return
                    } else {
                        handler(true)
                        DispatchQueue.main.async {}
                    }
                } else {
                    handler(false)
                }
            } else {
                handler(false)
            }
        }
    }
    //get beneficiaries
    func getwalletbeneficiaries(_ handler: @escaping(Bool) -> Void) {
        DispatchQueue.main.async {}
        var request_body = [String:Any]()
        if let lastSyncStatus = AppDelegate.sharedInstance.db?.readLastSyncStatus(tableName: db_last_sync_status,
                                                                                  condition: "SYNC_KEY = '\(S_WALLETGET_BENEFICIARY)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'") {
            request_body = [
                "p_employee_id": "\(CURRENT_USER_LOGGED_IN_ID)",
                "p_transaction_date": "\(lastSyncStatus.DATE)",
                "p_skip": lastSyncStatus.SKIP,
                "p_take": 80
            ]
        } else {
            request_body = [
                "p_employee_id": "\(CURRENT_USER_LOGGED_IN_ID)",
                "p_transaction_date": "",
                "p_skip": 0,
                "p_take": 80
            ]
        }
        let params = self.getAPIParameterNew(serviceName: S_WALLETGET_BENEFICIARY, client: "", request_body: request_body)
        NetworkCalls.getwalletbeneficiary(params: params) { granted, response in
            if granted {
                let json = JSON(response)
                if let result = json.dictionary?[_result] {
                    self.count = Int(result[_count].string ?? "0") ?? 0
                    let syncDate = result[_sync_date].string ?? "2021-07-13"
                    if self.count <= 0 {
                        handler(true)
                        return
                    }
                    if let getBeneficiary = result[_getBeneficiary].array {
                        do {
                            for gb in getBeneficiary {
                                let rawData = try gb.rawData()
                                let wallet_beneficiary: WalletBeneficiary = try JSONDecoder().decode(WalletBeneficiary.self, from: rawData)
                                self.isTotalCounter += 1
                                AppDelegate.sharedInstance.db?.insert_tbl_wallet_beneficiaries(wallet_beneficiary: wallet_beneficiary, handler: { _ in })
                            }
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
                        if self.count == self.isTotalCounter {
                            DispatchQueue.main.async {
                                Helper.updateLastSyncStatus(APIName: S_WALLETGET_BENEFICIARY,
                                                            date: syncDate, //MARK: Change Date
                                                            skip: self.skip,
                                                            take: 80,
                                                            total_records: self.count)
                                handler(true)
                            }
                        } else {
                            self.skip += 80
                            self.getwalletbeneficiaries { _ in }
                        }
                    } else {
                        handler(false)
                    }
                } else {
                    handler(false)
                }
            } else {
                handler(false)
            }
        }
    }
}
