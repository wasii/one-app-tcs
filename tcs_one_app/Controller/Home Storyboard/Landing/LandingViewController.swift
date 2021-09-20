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

class LandingViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var logoCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var percentCounter: UILabel!
    @IBOutlet weak var indicatorView: NVActivityIndicatorView!
    var safeTopArea: CGFloat = 0.0
    var currentCenterConstraintPosition: CGFloat = 0.0
    
    var totalApiCounts: Int = 4 //Setup, HrRequest, HrNotification, Attendance
    var currentCount: Int = 0
    
    var isIMSAllowed: Bool = false
    var isFulfilmentAllowed: Bool = false
    var access_token: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.clipsToBounds = true
        mainView.layer.cornerRadius = 40
        mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            safeTopArea = window?.safeAreaInsets.top ?? 0.0
        }
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            safeTopArea = window?.safeAreaInsets.top ?? 0.0
        }
        currentCenterConstraintPosition = self.logoCenterConstraint.constant
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN) == nil {
                if UserDefaults.standard.string(forKey: "CurrentUser") == nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        let storyboard = UIStoryboard(name: "UserCredentials", bundle: nil)
                        let controller = storyboard.instantiateViewController(withIdentifier: "mainNavigation") as! UINavigationController
                        (controller.children.first as! EnterPinViewController).delegate = self
                        controller.modalTransitionStyle = .crossDissolve
                        if #available(iOS 13.0, *) {
                            controller.modalPresentationStyle = .overFullScreen
                        }
                        self.present(controller, animated: true, completion: nil)
                        return
                    }
                }
            } else {
                self.setupAnimations()
            }
        }
    }
    private func setupAnimations() {
        let screenSize = UIScreen.main.bounds.height / 3.7
        UIView.animate(withDuration: 0.75) {
            self.logoCenterConstraint.constant = -screenSize + self.safeTopArea
            self.logoHeightConstraint.constant = 200
            
            self.mainViewHeightConstraint.constant = 350
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.checkConditions()
        }
    }
    
    private func checkConditions() {
        self.totalApiCounts = 4
        if CustomReachability.isConnectedNetwork() {
            //MIS
            if let count = AppDelegate.sharedInstance.db?.read_tbl_UserPage().filter({ userPage in
                userPage.PAGENAME == PERMISSION_MIS_LISTING
            }).count {
                if count > 0 {
                    self.totalApiCounts += 2
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
        
        self.currentCount += 100 / self.totalApiCounts
        self.percentCounter.text = "0%"
        self.indicatorView.type = .circleStrokeSpin
        self.indicatorView.startAnimating()
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
                self.percentCounter.text = String(format: "%.0f", self.currentCount)
                if self.isIMSAllowed {
                    self.syncIMSSetup { _ in }
                }
                
            } else {
                //SETUP ERROR
                
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
