//
//  NewRequestViewController.swift
//  tcs_one_app
//
//  Created by ibs on 19/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import SwiftSVG
import MobileCoreServices
import SwiftyJSON

import Alamofire
import AVFoundation
import Photos

class NewRequestViewController: BaseViewController {

    @IBOutlet weak var mainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var newRequestLabel: UILabel!
    @IBOutlet weak var employee_id_view: UIView!
    @IBOutlet weak var submitBtn: CustomButton!
    @IBOutlet weak var reqMode: MDCOutlinedTextField!
    @IBOutlet weak var employeeIdSearch: MDCOutlinedTextField!
    @IBOutlet weak var employeeName: MDCOutlinedTextField!
    @IBOutlet weak var queryType: MDCOutlinedTextField!
    @IBOutlet weak var subQueryType: MDCOutlinedTextField!
    @IBOutlet weak var remarks: MDCOutlinedTextField!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var queryTypeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var remarksTopConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var pocView: CustomView!
    
    @IBOutlet weak var case_detail_top_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var case_detail_placeholder: UILabel!
    @IBOutlet weak var case_detail: UITextView!
    
    @IBOutlet var gestureTextFields: [MDCOutlinedTextField]!
    
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var pocValue: UILabel!
    @IBOutlet weak var designationValue: UILabel!
    
    //HR CHANGES
    var picker = UIImagePickerController()
    var attachmentFiles: [AttachmentsList]?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var attachments: MDCOutlinedTextField!
    @IBOutlet weak var attachmentView: UIView!
    @IBOutlet weak var maxCharacterWarning: UILabel!
    @IBOutlet weak var characterCounter: UILabel!
    
    @IBOutlet weak var ticketStatus: MDCOutlinedTextField!
    
    @IBOutlet weak var submitBtnTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var ticketStatusTopConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var downloadBtn: CustomButton!
    //HR CHANGES END
    var tbl_request_mode: tbl_RequestModes?
    var tbl_masterquery: tbl_MasterQuery?
    var tbl_detailquery: tbl_DetailQuery?
    var tbl_querymatrix: tbl_QueryMatrix?
    var tbl_remarks: tbl_Remarks?
    
    var emp_model = [User]()
    
    var ticket_id: Int?
    
    var request_logs: tbl_Hr_Request_Logs?
    var notifications = true
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeTopCornersRounded(roundView: self.mainView)
        
        attachmentFiles = [AttachmentsList]()
        
        picker.delegate = self
        
        employeeName.isHidden = true
        setupMainViewHeight()
        setupTextFields()
        
        if ticket_id != nil {
            request_logs = AppDelegate.sharedInstance.db?.read_tbl_hr_request(ticketId: self.ticket_id!).first
            self.title = "View Request"
            self.newRequestLabel.text = "View Request"
            reqMode.text = request_logs?.REQ_MODE_DESC ?? ""
            if reqMode.text == "Self"
            {
                self.employee_id_view.isHidden = true
            }
            reqMode.isUserInteractionEnabled = false
            
            queryTypeTopConstraint.constant = 70
            employeeName.isHidden = false
            
            employeeIdSearch.isUserInteractionEnabled = false
            employeeIdSearch.text = "\(request_logs?.REQ_ID ?? 0)"
            
            employeeName.isUserInteractionEnabled = false
            employeeName.text = "\(request_logs?.EMP_NAME ?? "")"
            
            queryType.isUserInteractionEnabled = false
            queryType.text = request_logs?.MASTER_QUERY ?? ""
            
            subQueryType.isUserInteractionEnabled = false
            subQueryType.text = request_logs?.DETAIL_QUERY ?? ""

            pocView.isHidden = false
            remarksTopConstraint.constant = 120

            pocValue.text = "\(request_logs?.RESPONSIBILITY ?? "")"
            designationValue.text = "\(request_logs?.PERSON_DESIG ?? "")"
            
            remarks.isUserInteractionEnabled = false
            remarks.text = request_logs?.REQ_REMARKS ?? ""
            
            ticketStatus.isUserInteractionEnabled = false
            if request_logs?.TICKET_STATUS == "Approved" {
                ticketStatus.text = "Completed"
            } else {
                ticketStatus.text = request_logs?.TICKET_STATUS ?? ""
            }
            
            
            self.mainViewHeight.constant += 150
            
            self.case_detail_top_constraint.constant = 7
            self.case_detail_placeholder.font = UIFont.systemFont(ofSize: 11)
            self.case_detail.text = request_logs?.REQ_CASE_DESC ?? ""
            self.case_detail.isScrollEnabled = true
            self.case_detail.isEditable = false
            self.searchBtn.isUserInteractionEnabled = false
            submitBtn.isHidden = true
            
            //hr changes - 28/12/2020
            self.characterCounter.isHidden = true
            self.maxCharacterWarning.isHidden = true
            self.ticketStatus.isHidden = false
            
            self.attachmentView.isHidden = true
            
            self.downloadBtn.isHidden = false
            
            
            let downloadURL = Bundle.main.url(forResource: "download-fill-icon", withExtension: "svg")!
            let historyURL = Bundle.main.url(forResource: "history-icon-fill", withExtension: "svg")!

            
            downloadBtn.addTarget(self, action: #selector(openDownloadHistory), for: .touchUpInside)
            _ = CALayer(SVGURL: downloadURL) { (svgLayer) in
                svgLayer.resizeToFit(self.downloadBtn.bounds)
                self.downloadBtn.layer.addSublayer(svgLayer)
            }
            
            submitBtnTopConstraint.constant = -10
            //hr changes - 28/12/2020
            
        } else {
            self.title = "New Request"
            self.newRequestLabel.text = "New Request"
            submitBtn.isHidden = false
            //hr changes - 28/12/2020
            ticketStatus.isHidden = true
            self.tableView.register(UINib(nibName: "AddAttachmentsTableCell", bundle: nil), forCellReuseIdentifier: "AddAttachmentsCell")
            self.tableView.rowHeight = 60
            //hr changes - 28/12/2020
            self.searchBtn.isUserInteractionEnabled = true
            let userpermission = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: PERMISSION_HR_ADD_REQUEST_MODE).count
            if userpermission! == 0 {
                tbl_request_mode = AppDelegate.sharedInstance.db?.read_tbl_requestModes(module_id: CONSTANT_MODULE_ID).first
                reqMode.isUserInteractionEnabled = false
                reqMode.text = tbl_request_mode?.REQ_MODE_DESC ?? ""
                employee_id_view.isHidden = true
            }
        }
    }
    
    @objc func openDownloadHistory() {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "HRFilesViewController") as! HRFilesViewController
        controller.ticket_id = self.request_logs!.SERVER_ID_PK
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
        NotificationCenter.default.addObserver(self, selector: #selector(upload_pending_request), name: .networkRefreshed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigateThroughtNotify(notification:)), name: .navigateThroughNotification, object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    func setupMainViewHeight() {
        switch UIDevice().type {
        case .iPhone5, .iPhone5S, .iPhone5C, .iPhoneSE, .iPhone6, .iPhone6S, .iPhone7, .iPhone8, .iPhoneSE2:
            self.mainViewHeight.constant = 610
            break
        case .iPhone6Plus, .iPhone7Plus, .iPhone8Plus:
            self.mainViewHeight.constant = 641
            break
        case .iPhoneX, .iPhoneXR, .iPhoneXS, .iPhone11Pro, .iPhone12, .iPhone12Pro:
            self.mainViewHeight.constant = 704
            break
        case .iPhone11, .iPhoneXSMax, .iPhone11ProMax:
            self.mainViewHeight.constant = 792
            break
        case .iPhone12ProMax:
            self.mainViewHeight.constant = 880
            break
        case .iPhone12Mini:
            self.mainViewHeight.constant = 673
        default:
            break
        }
    }
    func setupTextFields() {
        reqMode.label.textColor = UIColor.nativeRedColor()
        reqMode.label.text = "*Request Modes"
        reqMode.placeholder = ""
        reqMode.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        reqMode.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        reqMode.delegate = self
        
        employeeName.label.textColor = UIColor.nativeRedColor()
        employeeName.label.text = "Employee Name"
        employeeName.placeholder = ""
        employeeName.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        employeeName.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        
        employeeIdSearch.label.textColor = UIColor.nativeRedColor()
        employeeIdSearch.label.text = "Employee ID"
        employeeIdSearch.placeholder = ""
        employeeIdSearch.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        employeeIdSearch.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        
        queryType.label.textColor = UIColor.nativeRedColor()
        queryType.label.text = "*Query Type"
        queryType.placeholder = ""
        queryType.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        queryType.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        queryType.delegate = self
        
        subQueryType.label.textColor = UIColor.nativeRedColor()
        subQueryType.label.text = "*Sub Query Type"
        subQueryType.placeholder = ""
        subQueryType.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        subQueryType.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        subQueryType.delegate = self
        
        remarks.label.textColor = UIColor.nativeRedColor()
        remarks.label.text = "*User Remarks"
        remarks.placeholder = ""
        remarks.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        remarks.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        remarks.delegate = self
        
        ticketStatus.label.textColor = UIColor.nativeRedColor()
        ticketStatus.label.text = "Status"
        ticketStatus.placeholder = ""
        ticketStatus.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        ticketStatus.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
//        ticketStatus.delegate = self
        
        attachments.label.textColor = UIColor.nativeRedColor()
        attachments.label.text = "Attachments"
        attachments.text = "choose files"
        attachments.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        attachments.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        attachments.isUserInteractionEnabled = false
        
        case_detail.delegate = self
    }
    
    @IBAction func attachemtTapped(_ sender: Any) {
        self.showAlertActionSheet(title: "Select an image and documents", message: "", sender: sender as! UIButton)
    }
    @IBAction func searchEmployee_Tapped(_ sender: Any) {
        if employeeIdSearch.text == "" {
            self.view.makeToast("Employee ID cannot be left blank.")
            return
        }
//        if !Reachability.isConnectedNetwork() {
//            self.view.makeToast(NOINTERNETCONNECTION)
//            return
//        }
        self.dismissKeyboard()
        self.freezeScreen()
        self.view.makeToastActivity(.center)
        let search_employee = [
            "empployee": [
                "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                "emp_id" :"\(self.employeeIdSearch.text!)"
            ]
        ]
        let params = self.getAPIParameter(service_name: SERACH_EMPLOYEE, request_body: search_employee)
        NetworkCalls.search_empoloyee(params: params) { (success, response) in
            if success {
                if let emp_data = JSON(response).array?.first {
                    do {
                        let user = try emp_data.rawData()
                        self.emp_model.append(try JSONDecoder().decode(User.self, from: user))
                    } catch let err {
                        print(err.localizedDescription)
                    }
                    DispatchQueue.main.async {
                        self.view.hideToastActivity()
                        self.unFreezeScreen()
                        
                        self.employeeName.isHidden = false
                        self.employeeName.text = self.emp_model.first?.empName ?? ""
                        self.queryTypeTopConstraint.constant = 70
                        self.mainViewHeight.constant += 70
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.unFreezeScreen()
                    self.view.hideToastActivity()
                    self.view.makeToast(response as! String)
                }
            }
        }
    }
    
    fileprivate func camera() {
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            picker.sourceType = .camera
            present(picker, animated: true, completion: nil)
        } else {
            let alertWarning = UIAlertView(title:"Warning", message: "You don't have camera", delegate:nil, cancelButtonTitle:"OK", otherButtonTitles:"")
            alertWarning.show()
        }
    }
    fileprivate func photoLibrary() {
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    
    
    func showAlertActionSheet(title: String, message: String, sender: UIButton) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: { _ in
            self.camera()
        }))
        
        alert.addAction(UIAlertAction(title: "Select from Gallery", style: .default, handler: { _ in
            self.photoLibrary()
        }))
        
        alert.addAction(UIAlertAction(title: "Select Documents", style: .default, handler: { _ in
            self.addAttachments_Tapped()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
            alert.popoverPresentationController?.permittedArrowDirections = [.up, .down]
        default:
            break
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func submitBtn_Tapped(_ sender: Any) {
        self.submitBtn.isEnabled = false
        self.view.hideToast()
        guard let _ = self.tbl_request_mode else {
            self.view.makeToast("Request Mode is mandatory.")
            self.submitBtn.isEnabled = true
            return
        }
        
        guard let _ = self.tbl_masterquery else {
            self.view.makeToast("Query Type is mandatory.")
            self.submitBtn.isEnabled = true
            return
        }
        guard let _ = self.tbl_detailquery else {
            self.view.makeToast("Sub Query Type is mandatory.")
            self.submitBtn.isEnabled = true
            return
        }
        guard let _ = self.tbl_remarks else {
            self.view.makeToast("User Remarks is mandatory.")
            self.submitBtn.isEnabled = true
            return
        }
        if self.case_detail.text == "" {
            self.view.makeToast("User Comments is mandatory.")
            self.submitBtn.isEnabled = true
            return
        }
        var employeeId = ""
        
        self.submitBtn.isEnabled = false
        if reqMode.text != "Self" && employeeIdSearch.text! == "" {
            self.view.makeToast("Employee Id is mandatory")
            return
        }
        //HR REVIEWS
        let popup = UIStoryboard(name: "Popups", bundle: nil)
        let controller = popup.instantiateViewController(withIdentifier: "ConfirmationPopViewController") as! ConfirmationPopViewController
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        controller.modalTransitionStyle = .crossDissolve
        controller.delegate = self
        Helper.topMostController().present(controller, animated: true, completion: nil)
        //HR REVIEWS END
        
        
    }
    
    func addRequesttoServer(offlinedata: tbl_Hr_Request_Logs) {
        self.submitBtn.isEnabled = true
//        let request_body = [
//            "hr_request":[
//                "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
//                "tickets":[
//                    [
//                        "employeeID":"\(CURRENT_USER_LOGGED_IN_ID)",
//                        "requesterEmployeeID":"\(offlinedata.REQ_ID!)",
//                        "requestModeID":"\(self.tbl_request_mode!.SERVER_ID_PK)",
//                        "matrixID":"\(self.tbl_querymatrix!.SERVER_ID_PK)",
//                        "masterQueryID":"\(self.tbl_masterquery!.SERVER_ID_PK)",
//                        "detailQueryID":"\(self.tbl_detailquery!.DQ_UNIQ_ID)",
//                        "requesterRemarks":"\(self.tbl_remarks!.HR_REMARKS)", //HR_REMARKS
//                        "hrRemarks":"",
//                        "refId": offlinedata.REF_ID,
//                        "ticketDate":getCurrentDate(),
//                        "req_case_desc" : offlinedata.REQ_CASE_DESC!
//                    ]
//                ]
//            ]
//        ]
//        let params = self.getAPIParameter(service_name: REQUEST_LOGS, request_body: request_body)
//        NetworkCalls.request_logs(params: params) { (success, response) in
//            if success {
//                if let ticket_logs = JSON(response).first?.1 {
//                    let ref_id = ticket_logs["REF_ID"].string ?? ""
//                    print("Offline Data REF_ID: \(offlinedata.REF_ID ?? "")")
//                    print("Server Based REF_ID: \(ref_id)")
//                    print("RESPONSIBLE_EMPNO: \(ticket_logs["RESPONSIBLE_EMPNO"].int ?? 0)")
//                    DispatchQueue.main.async {
//                        AppDelegate.sharedInstance.db?.deleteRow(tableName: db_hr_request, column: "REF_ID", ref_id: ref_id, handler: { success in
//                            if success {
//                                do {
//                                    let dictionary = try ticket_logs.rawData()
//                                    let hr_helpdesk = try JSONDecoder().decode(HrRequest.self, from: dictionary)
//                                    
//                                    DispatchQueue.main.async {
//                                        AppDelegate.sharedInstance.db?.insert_tbl_hr_request(hrrequests: hr_helpdesk, { dump_succes in
//                                            if success {
//                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                                                    NotificationCenter.default.post(Notification.init(name: .refreshedViews))
//                                                    Helper.topMostController().view.makeToast("Request Saved Successfully")
//                                                }
//                                                print("DUMPED HR UPDATED TICKET")
//                                            }
//                                        })
//                                    }
//                                } catch let err {
//                                    print(err.localizedDescription)
//                                }
//                            }
//                        })
//                    }
//                }
//            } else {
//                print("\(REQUEST_LOGS): FAILED")
//            }
//        }
        var ticket_files = [[String:String]]()
        for index in self.attachmentFiles! {
            if index.fileUploadedURL != "" {
                let dictionary = [
                    "file_url": index.fileUploadedURL,
                    "file_extention": index.fileExtension,
                    "file_size_kb": String(index.fileSize.split(separator: " ").first!)
                ]
                ticket_files.append(dictionary)
                var offline_hr_files = tbl_Files_Table()
                offline_hr_files.FILE_URL = index.fileUploadedURL
                offline_hr_files.FILE_EXTENTION = index.fileExtension
                offline_hr_files.FILE_SIZE_KB = Int(index.fileSize.split(separator: " ").first!)!
                offline_hr_files.REF_ID = offlinedata.REF_ID!
                offline_hr_files.CREATED = offlinedata.CREATED_DATE!
                offline_hr_files.FILE_SYNC = 0
                
                AppDelegate.sharedInstance.db?.dump_tbl_hr_files(hrfile: offline_hr_files)
            }
        }
        let request_body = [
            "hr_request":[
                "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                "tickets":[
                    "requesteremployeeid":"\(offlinedata.REQ_ID!)",
                    "requestmodeid":"\(self.tbl_request_mode!.SERVER_ID_PK)",
                    "masterqueryid":"\(self.tbl_masterquery!.SERVER_ID_PK)",
                    "detailqueryid":"\(self.tbl_detailquery!.DQ_UNIQ_ID)",
                    "requesterremarks":"\(self.tbl_remarks!.HR_REMARKS)", //HR_REMARKS
                    "hrremarks":"",
                    "refid": offlinedata.REF_ID!,
                    "ticketdate":getCurrentDate(),
                    "req_case_desc" : offlinedata.REQ_CASE_DESC!,
                    "ticket_logs": [
                        [
                            "empl_no":"\(CURRENT_USER_LOGGED_IN_ID)",
                            "refid":offlinedata.REF_ID!,
                            "remarks_input":"Initiator",
                            "ticket_files": ticket_files
                        ]
                    ]
                ]
            ]
        ]
        let params = self.getAPIParameter(service_name: REQUEST_LOGS, request_body: request_body)
        NetworkCalls.request_logs(params: params) { (success, response) in
            if success {
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
                                                    Helper.topMostController().view.makeToast("Request Saved Successfully")
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
            } else {
                print("\(REQUEST_LOGS): FAILED")
            }
        }
    }
}



extension NewRequestViewController: AddNewRequestDelegate {
    func updateRequestMode(requestmode: tbl_RequestModes) {
        self.tbl_request_mode = requestmode
        self.reqMode.text = requestmode.REQ_MODE_DESC

        self.queryTypeTopConstraint.constant = 10
        self.employeeName.isHidden = true

        if requestmode.REQ_MODE_DESC == "Self" {
            self.employee_id_view.isHidden = true
        } else {
            self.employee_id_view.isHidden = false
            self.employeeIdSearch.text = ""
            self.employeeIdSearch.isUserInteractionEnabled = true
            self.searchBtn.isUserInteractionEnabled = true
        }
    }
    
    func updateMasterQuery(masterquery: tbl_MasterQuery) {
        self.tbl_masterquery = masterquery
        self.queryType.text = masterquery.MQ_DESC
    }
    
    func updateDetailQuery(detailquery: tbl_DetailQuery) {
        self.tbl_detailquery = detailquery
        self.subQueryType.text = detailquery.DQ_DESC
        var querymatrix = tbl_querymatrix
        
        if self.emp_model.count == 0 {

            querymatrix = AppDelegate.sharedInstance.db?.read_tbl_queryMatrix(mq_id: self.tbl_masterquery!.SERVER_ID_PK,
                                                        dq_id: detailquery.DQ_UNIQ_ID,
                                                        area: AppDelegate.sharedInstance.db?.read_tbl_UserProfile().first?.AREA_CODE ?? "").first

            if querymatrix == nil {
                querymatrix = AppDelegate.sharedInstance.db?.read_tbl_queryMatrix(mq_id: self.tbl_masterquery!.SERVER_ID_PK,
                                                       dq_id: detailquery.DQ_UNIQ_ID,
                                                       area:  nil).first
            }
            if remarksTopConstraint.constant == 10 {
                self.mainViewHeight.constant += 120
            }
            self.remarksTopConstraint.constant = 120
            self.pocView.isHidden = false

            self.pocValue.text = querymatrix?.RESPONSIBILITY ?? ""
            self.designationValue.text = querymatrix?.PERSON_DESIG ?? ""

        } else {
            querymatrix = AppDelegate.sharedInstance.db?.read_tbl_queryMatrix(mq_id: self.tbl_masterquery!.SERVER_ID_PK,
                                                   dq_id: detailquery.DQ_UNIQ_ID,
                                                   area: self.emp_model.first?.areaCode ?? "").first
            if querymatrix == nil {
                querymatrix = AppDelegate.sharedInstance.db?.read_tbl_queryMatrix(mq_id: self.tbl_masterquery!.SERVER_ID_PK,
                                                       dq_id: detailquery.DQ_UNIQ_ID,
                                                       area:  "HOF").first
            }
            if let _ = querymatrix {
                if remarksTopConstraint.constant == 10 {
                    self.mainViewHeight.constant += 120
                }
                
                self.remarksTopConstraint.constant = 120
                self.pocView.isHidden = false

                self.pocValue.text = querymatrix?.RESPONSIBILITY ?? ""
                self.designationValue.text = querymatrix?.PERSON_DESIG ?? ""
            }
//            else {
//                self.remarksTopConstraint.constant = 10
//                self.pocView.isHidden = true
//            }
        }
        self.tbl_querymatrix = querymatrix
    }
    
    func updateRemarks(remarks: tbl_Remarks) {
        self.tbl_remarks = remarks
        self.remarks.text = remarks.HR_REMARKS
    }
    
}


extension NewRequestViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 10 {
            let storyboard = UIStoryboard(name: "Popups", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestListingViewController") as! NewRequestListingViewController
            
            controller.request_mode = AppDelegate.sharedInstance.db?.read_tbl_requestModes(module_id: CONSTANT_MODULE_ID)
            controller.heading = "Request Mode"
            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .overFullScreen
            }
            controller.modalTransitionStyle = .crossDissolve
            controller.delegate = self
            Helper.topMostController().present(controller, animated: true, completion: nil)
            
            return false
        }
        if textField.tag == 11 {
            if self.tbl_request_mode == nil {
                return false
            }
            let storyboard = UIStoryboard(name: "Popups", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestListingViewController") as! NewRequestListingViewController
            
            controller.master_query = AppDelegate.sharedInstance.db?.read_tbl_masterQuery(module_id: CONSTANT_MODULE_ID)
            controller.heading = "Master Query"
            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .overFullScreen
            }
            controller.modalTransitionStyle = .crossDissolve
            controller.delegate = self
            Helper.topMostController().present(controller, animated: true, completion: nil)
            
            return false
        }
        if textField.tag == 12 {
            if self.tbl_masterquery == nil {
                return false
            }
            let storyboard = UIStoryboard(name: "Popups", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestListingViewController") as! NewRequestListingViewController
            
            controller.detail_query = AppDelegate.sharedInstance.db?.read_tbl_detailQuery(master_query_id: self.tbl_masterquery!.SERVER_ID_PK)
            controller.heading = "Detail Query"
            
            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .overFullScreen
            }
            controller.modalTransitionStyle = .crossDissolve
            controller.delegate = self
            Helper.topMostController().present(controller, animated: true, completion: nil)
            
            return false
        }
        if textField.tag == 13 {
            if self.tbl_detailquery == nil {
                return false
            }
            let storyboard = UIStoryboard(name: "Popups", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestListingViewController") as! NewRequestListingViewController
            
            controller.remarks = AppDelegate.sharedInstance.db?.read_tbl_Remarks(mq_id: self.tbl_masterquery!.SERVER_ID_PK,
                                                      dq_id: self.tbl_detailquery!.DQ_UNIQ_ID,
                                                      remarks_type: "USER_REMARKS")
            controller.heading = "Remarks"
            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .overFullScreen
            }
            controller.modalTransitionStyle = .crossDissolve
            controller.delegate = self
            Helper.topMostController().present(controller, animated: true, completion: nil)
            
            return false
        }
        return true
    }
}



extension NewRequestViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.1) {
            self.case_detail_top_constraint.constant = 7
            self.case_detail_placeholder.font = UIFont.systemFont(ofSize: 10)
            self.view.layoutIfNeeded()
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.count <= 0 {
            UIView.animate(withDuration: 0.1) {
                self.case_detail_top_constraint.constant = 25
                self.case_detail_placeholder.font = UIFont.systemFont(ofSize: 13)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxLength = 525
        let currentString: NSString = textView.text as! NSString
        let newString: NSString =
                currentString.replacingCharacters(in: range, with: text) as NSString
        if let texts = textView.text,
           let textRange = Range(range, in: texts) {
            let updatedText = texts.replacingCharacters(in: textRange, with: text)
            if updatedText.containsEmoji {
                return false
            }
        }
        if newString.length <= maxLength {
            self.characterCounter.text = "\(newString.length)/525"
            return true
        }
        return false
//        return newString.length <= maxLength
    }
}







extension NewRequestViewController: UIDocumentPickerDelegate {
    func addAttachments_Tapped() {
        let newType = ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key","public.image", "com.apple.application", "public.item", "public.content", "public.audiovisual-content", "public.movie", "public.audiovisual-content", "public.video", "public.audio", "public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content"]
        let importMenu = UIDocumentPickerViewController(documentTypes: newType, in: .import)
        
        if #available(iOS 11.0, *) {
            importMenu.allowsMultipleSelection = false
        }
        
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        
        present(importMenu, animated: true)
    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let fileName = urls.first?.lastPathComponent
        if urls.first!.fileSize > 2048000 {
            self.view.makeToast("File size should be less than 2MB")
            return
        }
        let fileManager = FileManager.default
        if let tDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let url = NSURL(fileURLWithPath: tDocumentDirectory.absoluteString)
            if let pathComponent = url.appendingPathComponent("\(fileName!)") {
                do {
                    if fileManager.fileExists(atPath: pathComponent.path) {
                        print("file size = \(pathComponent.fileSize), \(pathComponent.fileSizeString)")
                        
                        let fileExtension = pathComponent.pathExtension
                        self.attachmentFiles?.append(AttachmentsList(fileName: fileName!,
                                                                     fileExtension: fileExtension,
                                                                     fileUrl: pathComponent.absoluteString,
                                                                     fileSize: pathComponent.fileSizeString,
                                                                     fileUploadedURL: "", isUploaded: false,
                                                                     fileUploadedBy: "",
                                                                     createdOn: ""))
                    } else {
                        try fileManager.copyItem(at: urls.first!, to: pathComponent)
                        let fileExtension = pathComponent.pathExtension
                        self.attachmentFiles?.append(AttachmentsList(fileName: fileName!,
                                                                     fileExtension: fileExtension,
                                                                     fileUrl: pathComponent.absoluteString,
                                                                     fileSize: pathComponent.fileSizeString,
                                                                     fileUploadedURL: "",
                                                                     isUploaded: false,
                                                                     fileUploadedBy: "",
                                                                     createdOn: ""))
                    }
                    
                    
                    self.tableView.reloadData()
                    
                    DispatchQueue.main.async {
                        self.mainViewHeight.constant -= self.tableViewHeightConstraint.constant
                        self.tableViewHeightConstraint.constant = 0
                        self.tableViewHeightConstraint.constant += CGFloat((self.attachmentFiles!.count * 60) + 10)
                        UIView.animate(withDuration: 0.4) {
                            self.mainViewHeight.constant += self.tableViewHeightConstraint.constant
                            self.view.layoutIfNeeded()
                        }
                    }
                } catch let err {
                    print(err.localizedDescription)
                }
            }
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension NewRequestViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.attachmentFiles?.count {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddAttachmentsCell") as! AddAttachmentsTableCell
        let data = self.attachmentFiles![indexPath.row]
        
        cell.attachment_uploadBtn.isHidden = true
        
        if data.fileUploadedURL == "" {
            cell.attachment_uploadBtn.isHidden = false
            cell.attachment_discardBtn.tag = indexPath.row
            cell.attachment_uploadBtn.tag  = indexPath.row
            
            cell.attachment_discardBtn.addTarget(self, action: #selector(discard_btn_tapped(sender:)), for: .touchUpInside)
            cell.attachment_uploadBtn.addTarget(self, action: #selector(upload_btn_tapped(sender:)), for: .touchUpInside)
        } else {
            cell.attachment_discardBtn.setBackgroundImage(UIImage(named: "checked-new"), for: .normal)
        }
        cell.attachment_name.text = data.fileName
        
        return cell
    }
    
    @objc func upload_btn_tapped(sender: UIButton) {
        if !CustomReachability.isConnectedNetwork() {
            self.view.makeToast(NOINTERNETCONNECTION)
            return
        }
        self.freezeScreen()
        self.view.makeToastActivity(.center)
        let fileData = self.attachmentFiles![sender.tag]
        
        
        let fileManager = FileManager.default
        if let tDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let url = NSURL(fileURLWithPath: tDocumentDirectory.absoluteString)
            if let pathComponent = url.appendingPathComponent("\(fileData.fileName)") {
                let fileExtension: CFString = "\(fileData.fileExtension)" as CFString
                
                guard let extUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, nil)?.takeUnretainedValue() else { return }
                guard let mimeUTI = UTTypeCopyPreferredTagWithClass(extUTI, kUTTagClassMIMEType) else { return }
                
                let type = (mimeUTI.takeRetainedValue() as? NSString) as! String
                
                var data: Data?
                
                if String(type.split(separator: "/").first!) == "application" {
                    do {
                        data = try Data(contentsOf: pathComponent)
                    } catch let err {
                        print(err.localizedDescription)
                    }
                } else if String(type.split(separator: "/").first!) == "image" {
                    let image = UIImage(contentsOfFile: pathComponent.path)
                    data = image?.jpegData(compressionQuality: 100.0)
                }
                Alamofire.upload(multipartFormData: { (formData) in
                    formData.append(CURRENT_USER_LOGGED_IN_ID.data(using: .utf8)!, withName: "empno")
                    formData.append(API_KEY.data(using: .utf8)!, withName: "api_key")
                    formData.append(data!, withName: "file", fileName: fileData.fileName, mimeType: type)
                }, usingThreshold: .max, to: UPLOADFILESURL, method: .post, headers: nil) { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.uploadProgress(closure: { (progress) in
                                   print("Upload Progress: \(progress.fractionCompleted)")
                              })
                        upload.responseJSON { response in
                            if let data = response.data {
                                let json = JSON(data)
                                print(json)
                                if let returnCode = json.dictionary?[returnStatus]?.dictionary?[_code] {
                                    switch returnCode.stringValue {
                                    case "0200":
                                        if let fileSize = json.dictionary?["fileSize"] {
                                            self.attachmentFiles![sender.tag].fileSize = "\(fileSize.intValue / 1024)"
                                        }
                                        if let filePath = json.dictionary?["path"] {
                                            self.attachmentFiles![sender.tag].fileUploadedURL = filePath.stringValue
                                        }
                                        if let fileExtension = json.dictionary?["fileExtension"] {
                                            self.attachmentFiles![sender.tag].fileExtension = fileExtension.stringValue
                                        }
                                        do {
                                            try fileManager.removeItem(atPath: fileData.fileUrl)
                                        } catch let err {
                                            print(err.localizedDescription)
                                        }
                                        self.attachmentFiles![sender.tag].isUploaded = true
                                        print("SUcccessfully upload")
                                        DispatchQueue.main.async {
                                            self.unFreezeScreen()
                                            self.view.hideToastActivity()
                                            self.tableView.reloadData()
                                        }
                                        break
                                    case "0400", "0401","0402","0403","0404":
                                        DispatchQueue.main.async {
                                            self.view.hideToastActivity()
                                            self.view.makeToast("Max allowed file size is 2 MB")
                                            self.unFreezeScreen()
                                        }
                                        break
                                    default:
                                        DispatchQueue.main.async {
                                            self.view.hideToastActivity()
                                            self.view.makeToast(SOMETHINGWENTWRONG)
                                            self.unFreezeScreen()
                                        }
                                        break
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        self.view.hideToastActivity()
                                        self.view.makeToast(SOMETHINGWENTWRONG)
                                        self.unFreezeScreen()
                                    }
                                }
                            }
                        }
                        break
                    case .failure(let err):
                        print(err.localizedDescription)
                        DispatchQueue.main.async {
                            self.view.hideToastActivity()
                            self.view.makeToast(SOMETHINGWENTWRONG)
                            self.unFreezeScreen()
                        }
                        break
                    }
                }
            }
        }
    }
    
    @objc func discard_btn_tapped(sender: UIButton) {
        let fileData = self.attachmentFiles![sender.tag]
        if fileData.isUploaded {
            return
        }
        let fileManager = FileManager.default
        if let tDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let url = NSURL(fileURLWithPath: tDocumentDirectory.absoluteString)
            if let pathComponent = url.appendingPathComponent("\(fileData.fileName)") {
                do {
                    try fileManager.removeItem(atPath: pathComponent.path)
                    self.attachmentFiles!.remove(at: sender.tag)
                    self.tableView.reloadData()
                    DispatchQueue.main.async {
                        self.tableViewHeightConstraint.constant = 0
                        self.tableViewHeightConstraint.constant += CGFloat((self.attachmentFiles!.count * 60) + 10)
                        UIView.animate(withDuration: 0.2) {
                            self.mainViewHeight.constant -= 60
                            self.view.layoutIfNeeded()
                        }
                    }
                } catch let err {
                    print(err.localizedDescription)
                }
            }
        }
    }
}


extension NewRequestViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        picker.dismiss(animated: true) {
            Helper.topMostController().view.makeToastActivity(.center)
            if let image = info[.originalImage] as? UIImage {
                let newImage = image.compressTo(1)
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fileName = "\(UUID().uuidString).jpg" // name of the image to be saved
                    let fileExtension = "jpg"
                    let fileURL = documentsDirectory.appendingPathComponent(fileName)
                    if let data = newImage!.jpegData(compressionQuality: 0.2),!FileManager.default.fileExists(atPath: fileURL.path){
                        do {
                            try data.write(to: fileURL)
                            
                            print("file saved")
                            self.attachmentFiles?.append(AttachmentsList(fileName: fileName,
                                                                         fileExtension: fileExtension,
                                                                         fileUrl: fileURL.absoluteString,
                                                                         fileSize: fileURL.fileSizeString,
                                                                         fileUploadedURL: "",
                                                                         isUploaded: false,
                                                                         fileUploadedBy: "",
                                                                         createdOn: ""))
                        } catch {
                            print("error saving file:", error)
                        }
                    }
                FileManager.default.clearTmpDirectory()
                self.tableView.reloadData()
                
                DispatchQueue.main.async {
                    Helper.topMostController().view.hideToastActivity()
                    self.mainViewHeight.constant -= self.tableViewHeightConstraint.constant
                    self.tableViewHeightConstraint.constant = 0
                    self.tableViewHeightConstraint.constant += CGFloat((self.attachmentFiles!.count * 60) + 10)
                    UIView.animate(withDuration: 0.4) {
                        self.mainViewHeight.constant += self.tableViewHeightConstraint.constant
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
    }
}



extension NewRequestViewController: ConfirmationProtocol {
    func confirmationProtocol() {
        var offline_data = tbl_Hr_Request_Logs()
        offline_data.TICKET_DATE = getLocalCurrentDate()
        offline_data.LOGIN_ID = Int(CURRENT_USER_LOGGED_IN_ID)!
        
        if reqMode.text == "Self" {
            offline_data.REQ_ID = Int(CURRENT_USER_LOGGED_IN_ID)!
        } else {
            offline_data.REQ_ID = Int(employeeIdSearch.text!)!
        }
        
        
        offline_data.REQ_MODE = self.tbl_request_mode!.SERVER_ID_PK
        offline_data.MAT_ID = self.tbl_querymatrix!.SERVER_ID_PK
        offline_data.MQ_ID = self.tbl_masterquery!.SERVER_ID_PK
        offline_data.DQ_ID = self.tbl_detailquery!.DQ_UNIQ_ID
        offline_data.TICKET_STATUS = "Pending"
        offline_data.CREATED_DATE = getCurrentDate()
        offline_data.REQ_REMARKS = self.tbl_remarks!.HR_REMARKS
        offline_data.TAT_DAYS = self.tbl_querymatrix!.ESCLATE_DAY
        offline_data.REF_ID = randomString()
        offline_data.AREA_CODE = AppDelegate.sharedInstance.db?.read_tbl_UserProfile().first?.AREA_CODE ?? self.emp_model.first?.areaCode ?? ""
        offline_data.EMP_NAME = employeeName.text!
        offline_data.RESPONSIBILITY = self.tbl_querymatrix!.RESPONSIBILITY
        offline_data.RESPONSIBLE_EMPNO = self.tbl_querymatrix!.RESPONSIBLE_EMPNO
        offline_data.PERSON_DESIG = self.tbl_querymatrix!.PERSON_DESIG
        offline_data.MASTER_QUERY = self.tbl_masterquery!.MQ_DESC
        offline_data.DETAIL_QUERY = self.tbl_detailquery!.DQ_DESC
        offline_data.ESCALATE_DAYS = self.tbl_querymatrix!.ESCLATE_DAY
        offline_data.REQUEST_LOGS_SYNC_STATUS = 0
        offline_data.REQ_MODE_DESC = self.reqMode.text!
        offline_data.MODULE_ID = 1
        offline_data.REQ_CASE_DESC = self.case_detail.text ?? ""
        
        offline_data.CURRENT_USER = CURRENT_USER_LOGGED_IN_ID
        
        AppDelegate.sharedInstance.db?.dump_data_HRRequest(hrrequests: offline_data, { success in
            if success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.addRequesttoServer(offlinedata: offline_data)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        })
    }
    func noButtonTapped() {
        self.submitBtn.isEnabled = true
    }
}
