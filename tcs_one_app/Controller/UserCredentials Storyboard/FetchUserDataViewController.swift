//
//  FetchUserDataViewController.swift
//  tcs_one_app
//
//  Created by ibs on 16/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import SwiftyJSON
import FirebaseMessaging

class FetchUserDataViewController: BaseViewController {
    
    @IBOutlet weak var hrSetupData_Label: UILabel!
    @IBOutlet weak var imsSetupData_Label: UILabel!
    @IBOutlet weak var logRequest_Label: UILabel!
    @IBOutlet weak var hrNotification_Label: UILabel!

    @IBOutlet weak var mainView: UIView!

    @IBOutlet var loaderViews: [UIView]!
    
    @IBOutlet var activityIndicator: [UIActivityIndicatorView]!
    @IBOutlet var checkedImageView: [UIImageView]!
    
    @IBOutlet weak var counter: UILabel!
    @IBOutlet weak var notification_counter: UILabel!
    
    
    @IBOutlet weak var version: UILabel!
    @IBOutlet weak var build: UILabel!
    
    //IMS Constraint/Variable
    @IBOutlet weak var logReqTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imsSetupView: CustomView!
    //IMS Constraint/Variable
    
    var HR_Request = [HrRequest]()
    var HR_Notification_Request = [HRNotificationRequest]()
    var count = 0


    var skip = 0
    var access_token = ""
    var isPresented = false
    
    
    var isTotalCounter = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.title = "Fetching Data"

        self.makeTopCornersRounded(roundView: self.mainView)
        
        version.text = "Version: " + Bundle.main.releaseVersionNumber!
        build.text = "Build: " + Bundle.main.buildVersionNumber!
        notification_counter.isHidden = true
        self.counter.isHidden = true
        activityIndicator.forEach { (UIActivityIndicatorView) in
            UIActivityIndicatorView.isHidden = true
        }
        checkedImageView.forEach { (UIImageView) in
            UIImageView.isHidden = true
            UIImageView.image = UIImageView.image?.withRenderingMode(.alwaysTemplate)
            UIImageView.tintColor = UIColor.white
        }
        if CustomReachability.isConnectedNetwork() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.setupAPI()
            }
        } else {
            self.view.makeToast(NOINTERNETCONNECTION)
//            if isPresented {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
//                    self.dismiss(animated: true, completion: nil)
//                })
//            }
            return
        }
    }
    
    
    func setupAPI() {
        //1: SETUPS
        //2: HRLOGSRequest
        //3: NOTIFICATION SYNC

//        if !Reachability.isConnectedNetwork() {
//            self.view.makeToast(NOINTERNETCONNECTION)
//            return
//        }
        guard let access_token = UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN) else {
            self.navigationController?.popViewController(animated: true)
            return
        }

        self.access_token = access_token
        activityIndicator[0].isHidden = false
        activityIndicator[0].startAnimating()
        
        var setup_body = [String: [String:Any]]()
        setup_body = [
            "Setup_Body": [
                "access_token": access_token,
                "sync_date": ""
            ]
        ]
        
        //MARK: oneapp.setup
        let params = self.getAPIParameter(service_name: SETUP, request_body: setup_body)
        NetworkCalls.setup(params: params) { (success, response) in
            if success {
                DispatchQueue.main.async {
                    self.hrSetupData_Label.text = "Successfully Synced HR"
                    //show success for view 1
                    self.loaderViews[0].backgroundColor = UIColor.nativeRedColor()
                    self.activityIndicator[0].stopAnimating()
                    self.activityIndicator[0].isHidden = true
                    self.checkedImageView[0].isHidden = false
                    //start animation for view 2
                    self.activityIndicator[2].isHidden = false
                    self.activityIndicator[2].startAnimating()

                    self.getTCSLocations {
                        self.getHrRequest()
                    }
                    //MARK: oneapp.gethrrequest
//                    self.getHrRequest()

                }
//                DispatchQueue.main.async {
//                    self.logReqTopConstraint.constant = 70
//                    self.loaderViews[0].backgroundColor = UIColor.nativeRedColor()
//                    self.activityIndicator[0].stopAnimating()
//                    self.activityIndicator[0].isHidden = true
//                    self.checkedImageView[0].isHidden = false
//                    //start animation for view 1
//                    self.activityIndicator[1].isHidden = false
//                    self.activityIndicator[1].startAnimating()
//                    self.imsSetupView.isHidden = false
//                }
//                self.getIMSSetup { imsSuccess, imsReponse in
//                    if imsSuccess {
//                        DispatchQueue.main.async {
//                            let json = JSON(imsReponse)
//                            self.initialiseIMS(response: json) { _ in
//                                DispatchQueue.main.async {
//
//                                    self.loaderViews[1].backgroundColor = UIColor.nativeRedColor()
//                                    self.activityIndicator[1].stopAnimating()
//                                    self.activityIndicator[1].isHidden = true
//                                    self.checkedImageView[1].isHidden = false
//                                    //start animation for view 2
//                                    self.activityIndicator[2].isHidden = false
//                                    self.activityIndicator[2].startAnimating()
//                                    //MARK: oneapp.gethrrequest
//                                    self.getHrRequest()
//                                }
//                            }
//                        }
//
//                    } else {
//                        DispatchQueue.main.async {
//                            self.loaderViews[0].backgroundColor = UIColor.nativeRedColor()
//                            self.activityIndicator[0].stopAnimating()
//                            self.activityIndicator[0].isHidden = true
//                            self.checkedImageView[0].isHidden = false
//                            //start animation for view 2
//                            self.activityIndicator[2].isHidden = false
//                            self.activityIndicator[2].startAnimating()
//                            //MARK: oneapp.gethrrequest
//                            self.getHrRequest()
//                        }
//                    }
//                }
            } else {
                if response as! String == REVERTBACK {
                    DispatchQueue.main.async {
                        self.view.makeToast("Session Expired.")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            UserDefaults.standard.removeObject(forKey: USER_ACCESS_TOKEN)
                            UserDefaults.standard.removeObject(forKey: "CurrentUser")
                            if self.isPresented {
                                self.dismiss(animated: true) {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                        Helper.topMostController().dismiss(animated: true, completion: nil)
                                    }
                                }
                                return
                            }
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .networkRefreshed, object: nil)
    }
    
    
    @objc func refresh() {
        self.setupAPI()
    }
    
    
    func setup(json: JSON, _ handler: @escaping(_ success: Bool)->Void) {
        if let sync_date = json.dictionary?[_sync_date] {
            Helper.updateLastSyncStatus(APIName: SETUP,
                                      date: sync_date.stringValue,
                                      skip: 0,
                                      take: 0,
                                      total_records: 0)
        }
        var remark = [Remarks]()
        if let data = json.dictionary?[_remarks] {
            do {
                for json in data.array! {
                    let dictionary = try json.rawData()
                    remark.append(try JSONDecoder().decode(Remarks.self, from: dictionary))
                }
                AppDelegate.sharedInstance.db?.deleteAll(tableName: db_remarks) { success in
                    if success {
                        for rm in remark {
                            AppDelegate.sharedInstance.db?.insert_tbl_Remarks(remarks: rm)
                        }
                    }
                }
            } catch let err {
                print(err.localizedDescription)
            }
        }

        var querymatrix = [QueryMatrix]()
        if let data = json.dictionary?[_query_matrix] {
            do {
                for json in data.array! {
                    let dictionary = try json.rawData()
                    querymatrix.append(try JSONDecoder().decode(QueryMatrix.self, from: dictionary))
                }
                AppDelegate.sharedInstance.db?.deleteAll(tableName: db_query_matrix) { success in
                    if success {
                        for qm in querymatrix {
                            AppDelegate.sharedInstance.db?.insert_tbl_queryMatrix(querymatrix: qm)
                        }
                    }
                }
            } catch let err {
                print(err.localizedDescription)
            }
        }
        var masterquery = [MasterQuery]()
        if let data = json.dictionary?[_master_query] {
            do {
                for json in data.array! {
                    let dictionary = try json.rawData()
                    masterquery.append(try JSONDecoder().decode(MasterQuery.self, from: dictionary))
                }
                AppDelegate.sharedInstance.db?.deleteAll(tableName: db_master_query) { success in
                    if success {
                        for mq in masterquery {
                            AppDelegate.sharedInstance.db?.insert_tbl_masterQuery(masterquery: mq)
                        }
                    }
                }
            } catch let err {
                print(err.localizedDescription)
            }
        }
        var detailquery = [DetailQuery]()
        if let data = json.dictionary?[_detail_query] {
            do {
                for json in data.array! {
                    let dictionary = try json.rawData()
                    detailquery.append(try JSONDecoder().decode(DetailQuery.self, from: dictionary))
                }
                AppDelegate.sharedInstance.db?.deleteAll(tableName: db_detail_query) { success in
                    if success {
                        for dq in detailquery {
                            AppDelegate.sharedInstance.db?.insert_tbl_detailQuery(detailquery: dq)
                        }
                    }
                }
            } catch let err {
                print(err.localizedDescription)
            }
        }
        var searchkeywords = [SearchKeyword]()
        if let data = json.dictionary?[_search_keyword] {
            do {
                for json in data.array! {
                    let dictionary = try json.rawData()
                    searchkeywords.append(try JSONDecoder().decode(SearchKeyword.self, from: dictionary))
                }
                AppDelegate.sharedInstance.db?.deleteAll(tableName: db_search_keywords) { success in
                    if success {
                        for sk in searchkeywords {
                            AppDelegate.sharedInstance.db?.insert_tbl_serachKeywords(searchkeywords: sk)
                        }
                    }
                }
            } catch let err {
                print(err.localizedDescription)
            }
        }
        var apprequestmode = [AppRequestMode]()
        if let data = json.dictionary?[_app_request_mode] {
            do {
                for json in data.array! {
                    let dictionary = try json.rawData()
                    apprequestmode.append(try JSONDecoder().decode(AppRequestMode.self, from: dictionary))
                }
                AppDelegate.sharedInstance.db?.deleteAll(tableName: db_request_modes) { success in
                    if success {
                        for arm in apprequestmode {
                            AppDelegate.sharedInstance.db?.insert_tbl_requestModes(apprequestmode: arm)
                        }
                    }
                }
            } catch let err {
                print(err.localizedDescription)
            }
        }
        handler(true)
    }
    
    func getIMSSetup(handler: @escaping(_ success: Bool,_ response: Any?) -> Void) {
        let ims_setup = [
            "Setup_Body": [
                "access_token": access_token,
                "sync_date": "",
                "moduleid" : "3"
            ]
        ]
        let params = getAPIParameter(service_name: IMSSETUP, request_body: ims_setup)
        NetworkCalls.ims_setup(params: params) { (success, response) in
            if success {
                DispatchQueue.main.async {
                    handler(true, response)
                }
            } else {
                handler(false, nil)
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
                } catch let err {
                    print(err.localizedDescription)
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
                } catch let err {
                    print(err.localizedDescription)
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
                } catch let err {
                    print(err.localizedDescription)
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
                } catch let err {
                    print(err.localizedDescription)
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
                } catch let err {
                    print(err.localizedDescription)
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
                } catch let err {
                    print(err.localizedDescription)
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
                } catch let err {
                    print(err.localizedDescription)
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
                } catch let err {
                    print(err.localizedDescription)
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
                } catch let err {
                    print(err.localizedDescription)
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
                } catch let err {
                    print(err.localizedDescription)
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
                } catch let err {
                    print(err.localizedDescription)
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
                } catch let err {
                    print(err.localizedDescription)
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
                } catch let err {
                    print(err.localizedDescription)
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
                } catch let err {
                    print(err.localizedDescription)
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
                            } catch let err {
                                print(err.localizedDescription)
                            }
                        }
                    })
                }
            } else {
                
            }
            handler()
        }
    }
    
    @objc func getHrRequest() {
        var hr_request = [String: [String:Any]]()
        let lastSyncStatus = AppDelegate.sharedInstance.db?.readLastSyncStatus(tableName: db_last_sync_status,
                                                   condition: "SYNC_KEY = '\(GET_HR_REQUEST)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'")
        
        print(lastSyncStatus)
        if lastSyncStatus == nil {
            hr_request = [
                "hr_request":[
                    "access_token": access_token,
                    "skip" :skip,
                    "take" : 80,
                    "sync_date": ""
                ]
            ]
        } else {
            hr_request = [
                "hr_request":[
                    "access_token": access_token,
                    "skip" :0,
                    "take" : 80,
                    "sync_date": lastSyncStatus!.DATE
                ]
            ]
        }
        let params = self.getAPIParameter(service_name: GET_HR_REQUEST, request_body: hr_request)
        NetworkCalls.hr_request(params: params) { success, response in
            if success {
                self.count = JSON(response).dictionary![_count]!.intValue
                if self.count < 0 {
                    self.getHrNotifications()
                }
                if let hr_response = JSON(response).dictionary?[_hr_requests]?.array {
                    let sync_date = JSON(response).dictionary?[_sync_date]?.string ?? ""
                    do {
                        
                        DispatchQueue.main.async {
                            self.counter.isHidden = false
                            self.counter.text = "\(self.isTotalCounter)/\(self.count)"
                        }
                        
                        for json in hr_response {
                            self.isTotalCounter += 1
//                            print("ASSIGNED_TO: \(json.dictionary?["ASSIGNED_TO"]?.int ?? -111)")
                            print("VIEW_COUNT: \(json.dictionary?["VIEW_COUNT"]?.int ?? -111)")
                            let dictionary = try json.rawData()
                            let hrRequest: HrRequest = try JSONDecoder().decode(HrRequest.self, from: dictionary)
                            AppDelegate.sharedInstance.db?.deleteRowWithMultipleConditions(tbl: db_hr_request, conditions: "SERVER_ID_PK = '\(hrRequest.ticketID!)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'", { _ in
                                AppDelegate.sharedInstance.db?.insert_tbl_hr_request(hrrequests: hrRequest, { _ in
                                    DispatchQueue.main.async {
                                        self.counter.text = "\(self.isTotalCounter)/\(self.count)"
                                    }
                                })
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
                                self.setup_HRLogs_HRFILES(response: response)
                                DispatchQueue.main.async {
                                    self.logRequest_Label.text = "Synced HR Log Requests"
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.counter.isHidden = false
                                self.counter.text = "\(self.isTotalCounter)/\(self.count)"
                            }
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
                    DispatchQueue.main.async {
                        self.logRequest_Label.text = "Synced HR Log Requests"
                    }
                    self.count = 0
                    self.skip = 0
                    self.getHrNotifications()
                }
            } else {
                DispatchQueue.main.async {
                    self.view.makeToast(SOMETHINGWENTWRONG)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
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
                    } catch let err {
                        print("File Error: \(err.localizedDescription)")
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
        self.count = 0
        self.isTotalCounter = 0
        self.getHrNotifications()
    }
}
extension FetchUserDataViewController {
    
    @objc func getHrNotifications() {
        DispatchQueue.main.async {
            print(self.count)
            self.loaderViews[2].backgroundColor = UIColor.nativeRedColor()
            self.activityIndicator[2].stopAnimating()
            self.activityIndicator[2].isHidden = true
            self.checkedImageView[2].isHidden = false
            self.activityIndicator[3].isHidden = false
            self.activityIndicator[3].startAnimating()
            
            var hr_notification = [String: [String:Any]]()
            let lastSyncStatus = AppDelegate.sharedInstance.db?.readLastSyncStatus(tableName: db_last_sync_status,
                                                       condition: "SYNC_KEY = '\(GET_HR_NOTIFICATION)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'")
            if lastSyncStatus == nil {
                hr_notification = [
                    "hr_request": [
                        "access_token": self.access_token,
                        "skip" : self.skip,
                        "take" :80,
                        "sync_date" : ""
                    ]
                ]
            } else {
                hr_notification = [
                    "hr_request": [
                        "access_token": self.access_token,
                        "skip" :0,
                        "take" : 80,
                        "sync_date": lastSyncStatus!.DATE
                    ]
                ]
            }
            
            let params = self.getAPIParameter(service_name: GET_HR_NOTIFICATION, request_body: hr_notification)
            NetworkCalls.hr_notification(params: params) { success, response in
                if success {
                    self.count = JSON(response).dictionary![_count]!.intValue
                    if self.count < 0 {
                        self.navigateHomeScreen()
                    }
                    
                    if let notification_requests = JSON(response).dictionary?[_notification_requests]?.array {
                        let sync_date = JSON(response).dictionary?[_sync_date]?.string ?? ""
                        do {
                            DispatchQueue.main.async {
                                self.notification_counter.isHidden = false
                                self.notification_counter.text = "\(self.isTotalCounter)/\(self.count)"
                            }
                            
                            for json in notification_requests {
                                self.isTotalCounter += 1
                                let dictionary = try json.rawData()
                                let hrNotification: HRNotificationRequest = try JSONDecoder().decode(HRNotificationRequest.self, from: dictionary)
                                AppDelegate.sharedInstance.db?.deleteRow(tableName: db_hr_notifications, column: "TICKET_ID", ref_id: "\(hrNotification.ticketID!)", handler: { _ in
                                    AppDelegate.sharedInstance.db?.insert_tbl_HR_Notification_Request(hnr: hrNotification, { _ in
                                        DispatchQueue.main.async {
                                            self.notification_counter.text = "\(self.isTotalCounter)/\(self.count)"
                                        }
                                    })
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
                                        self.hrNotification_Label.text = "Synced HR Notifications Logs"
                                    }
                                    self.navigateHomeScreen()
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.notification_counter.isHidden = false
                                    self.notification_counter.text = "\(self.isTotalCounter)/\(self.count)"
                                }
                                self.skip += 80
                                self.getHrNotifications()
                            }
                        } catch let err {
                            print(err.localizedDescription)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.hrNotification_Label.text = "Synced HR Notifications Logs"
                        }
                        self.navigateHomeScreen()
                    }

                } else {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    @objc func navigateHomeScreen() {
        DispatchQueue.main.async {
            self.loaderViews[3].backgroundColor = UIColor.nativeRedColor()
            self.activityIndicator[3].stopAnimating()
            self.activityIndicator[3].isHidden = true
            self.checkedImageView[3].isHidden = false
        }
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
            
            Helper.topMostController().present(controller, animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
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
