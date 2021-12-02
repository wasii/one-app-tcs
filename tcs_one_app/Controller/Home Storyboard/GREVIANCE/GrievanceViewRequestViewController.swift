//
//  GrievanceViewRequestViewController.swift
//  tcs_one_app
//
//  Created by TCS on 16/11/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextAreas
import MobileCoreServices
import Alamofire
import SwiftyJSON
import QuickLook
import Photos
import TPPDF

class GrievanceViewRequestViewController: BaseViewController {

    @IBOutlet weak var remarks_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var remarksLabel: UILabel!
    @IBOutlet weak var queryTypeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var employeeIdView: UIView!
    
    @IBOutlet weak var attachmentsTableView: UITableView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var erManagerBtn: UIButton!
    
    @IBOutlet weak var securityBtn: UIButton!
    @IBOutlet weak var request_mode: MDCOutlinedTextField!
    @IBOutlet weak var employee_id: MDCOutlinedTextField!
    @IBOutlet weak var employee_name: MDCOutlinedTextField!
    
    @IBOutlet weak var query_type: MDCOutlinedTextField!
    
    @IBOutlet weak var sub_query_type: MDCOutlinedTextField!
    @IBOutlet weak var case_detail_textView: UITextView!
    @IBOutlet weak var case_detail: MDCOutlinedTextField!
    
    @IBOutlet weak var remarks_textView: UITextView!
    @IBOutlet weak var remarks: MDCOutlinedTextField!
    
    @IBOutlet weak var status: MDCOutlinedTextField!
    
    @IBOutlet weak var memoCreationBtn: UIButton!
    @IBOutlet weak var historyBtn: CustomButton!
    @IBOutlet weak var downloadBtn: CustomButton!
    @IBOutlet weak var closeBtn: CustomButton!
    @IBOutlet weak var forwardBtn: CustomButton!
    
    
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    
    
    //HR CHANGES 28/12/2020
    @IBOutlet weak var characterCounter: UILabel!
    
    //HR CHANGES 28/12/2020
    var ticket_id : Int?
    var attachmentFiles: [AttachmentsList]?
    var user_permission = [tbl_UserPermission]()
    var request_logs: tbl_Hr_Request_Logs?
    var tempStatus = ""
    
    var permission_grievance_close      = 0
    var permission_grievance_memo       = 0
    var permission_grievance_history    = 0
    var permission_grievance_srHRBP     = 0
    
    //HR CHANGES
    var permission_inequiry_done        = 0
    //HR CHANGES END
    var ticket_status                   = ""
    
    var fileDownloadedURL : URL?
    var picker = UIImagePickerController()
    
    
    var isSecurityTapped = false
    var forward_to_srhrbp = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeTopCornersRounded(roundView: self.mainView)
        self.title = "View Request"
        
        self.securityBtn.isHidden = true
        self.erManagerBtn.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(navigateThroughtNotify(notification:)), name: .navigateThroughNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(upload_pending_request), name: .networkRefreshed, object: nil)
        
        let downloadURL = Bundle.main.url(forResource: "download-fill-icon", withExtension: "svg")!
        let historyURL = Bundle.main.url(forResource: "history-icon-fill", withExtension: "svg")!

        
        _ = CALayer(SVGURL: downloadURL) { (svgLayer) in
            svgLayer.resizeToFit(self.downloadBtn.bounds)
            self.downloadBtn.layer.addSublayer(svgLayer)
        }
        _ = CALayer(SVGURL: historyURL) { (svgLayer) in
            svgLayer.resizeToFit(self.historyBtn.bounds)
            self.historyBtn.layer.addSublayer(svgLayer)
        }
        
        picker.delegate = self
        self.attachmentsTableView.register(UINib(nibName: "AddAttachmentsTableCell", bundle: nil), forCellReuseIdentifier: "AddAttachmentsCell")
        self.attachmentsTableView.rowHeight = 60
        attachmentFiles = [AttachmentsList]()
        
        user_permission = AppDelegate.sharedInstance.db!.read_tbl_UserPermission()
        
        permission_grievance_memo = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: PERMISSION_GRIEVANCE_MEMO).count ?? 0
        permission_grievance_history = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: PERMISSION_GRIEVANCE_HISTORY).count ?? 0
        permission_grievance_close = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: PERMISSION_GRIEVANCE_CLOSE).count ?? 0
        
        permission_inequiry_done = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: PERMISSION_GRIEVANCE_INEQUIRY_DONE).count ?? 0
        
        setupTextFields()
        setupValidations()
        
        
        
        if ticket_id != nil {
            request_logs = AppDelegate.sharedInstance.db?.read_tbl_hr_request(ticketId: self.ticket_id!).first
            
            request_mode.text = request_logs?.REQ_MODE_DESC ?? ""
            if request_mode.text == "Self" {
                employeeIdView.isHidden = true
                employee_name.isHidden = true
                
                queryTypeTopConstraint.constant = 15
                employee_id.text = "\(request_logs?.REQ_ID ?? 0)"
                employee_name.text = request_logs?.EMP_NAME ?? ""
            } else {
                mainViewHeightConstraint.constant += 80
                queryTypeTopConstraint.constant = 80
                employeeIdView.isHidden = false
                employee_name.isHidden = false
                employee_id.text = "\(request_logs?.REQ_ID ?? 0)"
                employee_name.text = request_logs?.EMP_NAME ?? ""
            }
            
            query_type.text = request_logs?.MASTER_QUERY ?? ""
            sub_query_type.text = request_logs?.DETAIL_QUERY ?? ""
            case_detail_textView.text = request_logs?.REQ_REMARKS ?? ""
//
//            HR CHANGES
//            status.text = request_logs?.TICKET_STATUS ?? ""
            if let view_inrevieww_permission = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: PERMISSION_GRIEVANCE_VIEW_INREVIEW_STATUS).count {
                if view_inrevieww_permission > 0 {
                    switch request_logs?.TICKET_STATUS {
                    case "Inprogress-Er":
                        status.text = "Inprogress Er-Officer"
                        break
                    case "Inprogress-S":
                        status.text = "Inprogress Security"
                        break
                    case "Investigating":
                        status.text = "Inprogress HRBP"
                        break
                    case "Responded", "Submitted":
                        status.text = "Inprogress Er-Manager"
                        break
                    case "Inprogress-Srhrbp":
                        status.text = "Inprogress-Srhrbp"
                        break
                    case "Inprogress-Ceo":
                        status.text = "Inprogress-Ceo"
                        break
                    default:
                        break
                    }
                } else {
                    if request_logs?.TICKET_STATUS ?? "" == "Submitted" {
                        status.text = "Submitted"
                    } else if request_logs?.TICKET_STATUS ?? "" == "Closed" {
                        status.text = "Closed"
                    } else {
                        status.text = INREVIEW
                    }
                }
            }
//            HR CHANGES END
            request_mode.isUserInteractionEnabled = false
            employee_id.isUserInteractionEnabled = false
            employee_name.isUserInteractionEnabled = false
            query_type.isUserInteractionEnabled = false
            sub_query_type.isUserInteractionEnabled = false
            case_detail_textView.isEditable = false
            status.isUserInteractionEnabled = false
            
            erManagerBtn.isHidden = true
            securityBtn.isHidden = true
            self.ticket_status = request_logs?.TICKET_STATUS ?? ""
            
//            if request_logs?.TICKET_STATUS ?? "" == "Submitted" {
//                status.text = "Submitted"
//            } else if request_logs?.TICKET_STATUS ?? "" == "Closed" {
//                status.text = "Closed"
//            } else {
//                status.text = INREVIEW
//            }
//            print(self.ticket_status)
            
            for permission in user_permission {
                let s = String(permission.PERMISSION.lowercased().split(separator: " ").last!)
                if s == self.ticket_status.lowercased() {
                    tempStatus = s
                    break
                }
            }
            switch tempStatus.lowercased() {
            case "submitted":
                remarksLabel.text = "*Er-Manager Remarks    "
                self.erManagerBtn.setTitle("ER Officer", for: .normal)
                self.securityBtn.setTitle("Security", for: .normal)
                break
            case "inprogress-er":
                remarksLabel.text = "*Er-Officer Remarks    "
                self.erManagerBtn.setTitle("ER Manager", for: .normal)
                self.securityBtn.setTitle("HRBP", for: .normal)
                break
            case "inprogress-s":
                remarksLabel.text = "*Security Remarks    "
                self.securityBtn.setTitle("ER Manager", for: .normal)
                break
            case "responded":
                remarksLabel.text = "*Er-Manager Remarks    "
                self.erManagerBtn.setTitle("ER Officer", for: .normal)
                self.securityBtn.setTitle("Security", for: .normal)
                break
            case "investigating":
                remarksLabel.text = "*HRBP Remarks    "
                self.securityBtn.setTitle("ER Officer", for: .normal)
                break
            case "inprogress-srhrbp":
                self.erManagerBtn.setTitle("ER Manager", for: .normal)
                self.securityBtn.setTitle("CEO", for: .normal)
                remarksLabel.text = "*Sr. HRBP Remarks    "
                break
            case "inprogress-ceo":
                self.securityBtn.setTitle("Sr.HRBP", for: .normal)
                remarksLabel.text = "*CEO Decision    "
                break
            default:
                break
            }
        }
    }
    
    func setupTextFields() {
        request_mode.label.textColor = UIColor.nativeRedColor()
        request_mode.label.text = "*Request Modes"
        request_mode.placeholder = ""
        request_mode.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        request_mode.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        request_mode.delegate = self
        
        employee_name.label.textColor = UIColor.nativeRedColor()
        employee_name.label.text = "Employee Name"
        employee_name.placeholder = ""
        employee_name.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        employee_name.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        
        employee_id.label.textColor = UIColor.nativeRedColor()
        employee_id.label.text = "Employee ID"
        employee_id.placeholder = ""
        employee_id.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        employee_id.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        
        query_type.label.textColor = UIColor.nativeRedColor()
        query_type.label.text = "*Query Type"
        query_type.placeholder = ""
        query_type.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        query_type.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        query_type.delegate = self
        
        sub_query_type.label.textColor = UIColor.nativeRedColor()
        sub_query_type.label.text = "*Sub Query Type"
        sub_query_type.placeholder = ""
        sub_query_type.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        sub_query_type.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        sub_query_type.delegate = self
        
        
        status.label.textColor = UIColor.nativeRedColor()
        status.label.text = "Status"
        status.placeholder = ""
        status.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        status.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        status.delegate = self
        
        
        remarks_textView.delegate = self
    }
    
    func setupValidations() {
        if permission_grievance_memo > 0 {
            self.memoCreationBtn.isHidden = false
        }
        if permission_grievance_history > 0 {
            self.historyBtn.isHidden = false
        }
        if permission_inequiry_done > 0 {
            self.closeBtn.isHidden = false
        } else if permission_grievance_close > 0 {
            self.closeBtn.isHidden = false
        }
    }
    
    func setupAPI(ticket_status: String, submittedBy: String, closure_remarks: String) {
        let column = ["TICKET_STATUS"]
        let values = [ticket_status]
        AppDelegate.sharedInstance.db?.updateTables(tableName: db_hr_request, columnName: column, updateValue: values, onCondition: "REF_ID = '\(self.request_logs!.REF_ID ?? "")'", { (success) in
            if success {
                self.syncData(ticket_status: ticket_status, submittedBy: submittedBy, closure_remarks: closure_remarks)
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    func syncData(ticket_status: String, submittedBy: String, closure_remarks: String) {
        guard let user_token = UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN) else {
            self.view.makeToast("Session Expired")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.dismiss(animated: true, completion: nil)
            }
            return
        }
        var ticket_files = [[String:String]]()
        for index in self.attachmentFiles! {
            let dictionary = [
                "file_url": index.fileUploadedURL,
                "file_extention": index.fileExtension,
                "file_size_kb": String(index.fileSize.split(separator: " ").first!)
            ]
            ticket_files.append(dictionary)
        }
        let json = [
            "hr_request": [
                "access_token": user_token,
                "tickets": [
                    "status": ticket_status,
                    "ticketid": "\(self.ticket_id!)",
                    "loginid": CURRENT_USER_LOGGED_IN_ID,
                    "masterqueryid": "\(self.request_logs!.MQ_ID!)",
                    "detailqueryid": "\(self.request_logs!.DQ_ID!)",
                    "closure_remarks": closure_remarks,
                    "ticket_logs": [
                        [
                            "inputby": submittedBy, //"Er_Manager"
                            "remarks": self.remarks_textView.text?.replacingOccurrences(of: "'", with: "''") ?? "",
                            "ticket_files": ticket_files
                        ]
                    ]
                ]
            ]
        ]
        let params = self.getAPIParameter(service_name: UPDATEREQUESTGREV, request_body: json)
        NetworkCalls.updaterequestgrev(params: params) { (success, response) in
            if success {
                var hrFile = [HrFiles]()
                var hrLog = [HrLog]()
                
                if let returnResponse = JSON(response).dictionary {
                    var hr_files = [HrFiles]()
                    var hr_logs  = [HrLog]()
                    if let hr_file = JSON(response).dictionary?[_hr_files]?.array {
                        for files in hr_file {
                            do {
                                let dictionary = try files.rawData()
                                hr_files.append(try JSONDecoder().decode(HrFiles.self, from: dictionary))
                            } catch let error {
                                print("file id: \(files.dictionary?["GREM_ID"]?.intValue) \(error.localizedDescription)")
                            }
                        }
                        for files in hr_files {
                            AppDelegate.sharedInstance.db?.deleteRow(tableName: db_files, column: "TICKET_ID", ref_id: "\(files.ticketID!)", handler: { _ in })
                        }
                        for files in hr_files {
                            AppDelegate.sharedInstance.db?.insert_tbl_hr_files(hrfile: files)
                        }
                    }
                    if let hr_log = JSON(response).dictionary?[_hr_logs]?.array {
                        for log in hr_log {
                            do {
                                let dictionary = try log.rawData()
                                hr_logs.append(try JSONDecoder().decode(HrLog.self, from: dictionary))
                            } catch let error {
                                print("log id: \(log.dictionary?["GREM_ID"]?.intValue) \(error.localizedDescription)")
                            }
                        }
                        
                        if let ticket_id = hr_log.first?.dictionary?["TICKET_ID"]?.int {
                            AppDelegate.sharedInstance.db?.deleteRow(tableName: db_grievance_remarks, column: "TICKET_ID", ref_id: "\(ticket_id)", handler: { _ in
                                for log in hr_logs {
                                    AppDelegate.sharedInstance.db?.insert_tbl_hr_grievance(hr_log: log)
                                }
                            })
                        }
                    }
                    let ticket_logs = returnResponse[_tickets_logs]?.array?.first
                    
                    DispatchQueue.main.async {
                        let ref_id = ticket_logs?["REF_ID"].string ?? ""
                        AppDelegate.sharedInstance.db?.deleteRow(tableName: db_hr_request,column: "REF_ID", ref_id: ref_id, handler: { success in
                            if success {
                                do {
                                    let dictionary = try ticket_logs?.rawData()
                                    let hrgrievance = try JSONDecoder().decode(HrRequest.self, from: dictionary!)
                                    
                                    DispatchQueue.main.async {
                                        AppDelegate.sharedInstance.db?.insert_tbl_hr_request(hrrequests: hrgrievance, { dump_succes in
                                            if success {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                    NotificationCenter.default.post(Notification.init(name: .refreshedViews))
                                                    Helper.topMostController().view.makeToast("Request Update Successfully")
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
                    print(returnResponse)
                }
            }
        }
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
    
    @IBAction func addAttachmentsTapped(_ sender: Any) {
        self.showAlertActionSheet(title: "Select an image and documents", message: "", sender: sender as! UIButton)
    }
    @IBAction func memoCreation_Tapped(_ sender: Any) {
        self.view.makeToastActivity(.center)
        self.freezeScreen()
        
        
        
        let documents = self.generatePDFDocument()
        
        let generator: PDFGeneratorProtocol
        if documents.count > 1 {
            generator = PDFMultiDocumentGenerator(documents: documents)
        } else {
            generator = PDFGenerator(document: documents.first!)
        }
        
        // Generate PDF data and save to a local file.
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)

        
        let docURL = URL(string: path)!
        let dataPath = docURL.appendingPathComponent("One App")
        
        
        var fileUrl: URL?
        if !FileManager.default.fileExists(atPath: dataPath.absoluteString.replacingOccurrences(of: "%20", with: " ")) {
            do {
                try FileManager.default.createDirectory(atPath: dataPath.absoluteString.replacingOccurrences(of: "%20", with: " "), withIntermediateDirectories: true, attributes: nil)
                let tempURL = try generator.generateURL(filename: "\(CURRENT_USER_LOGGED_IN_ID).pdf")
                fileUrl = url.appendingPathComponent("One App")?.appendingPathComponent("\(CURRENT_USER_LOGGED_IN_ID).pdf")
                try FileManager.default.copyItem(atPath: tempURL.path , toPath: fileUrl!.path)
//                try documents.write(to: fileUrl!, options: .atomicWrite)
            } catch {
                print(error.localizedDescription);
            }
        } else {
            fileUrl = url.appendingPathComponent("One App")?.appendingPathComponent("\(CURRENT_USER_LOGGED_IN_ID).pdf")
            do {
                let tempURL = try generator.generateURL(filename: "\(CURRENT_USER_LOGGED_IN_ID).pdf")
                if FileManager.default.fileExists(atPath: fileUrl!.path) {
                    try FileManager.default.removeItem(atPath: fileUrl!.path)
                }
                
                try FileManager.default.copyItem(atPath: tempURL.path , toPath: fileUrl!.path)
            } catch let err {
                print(err.localizedDescription)
            }
        }
        FileManager.default.clearTmpDirectory()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.unFreezeScreen()
            self.view.hideToastActivity()
            self.fileDownloadedURL = fileUrl
            let previewController = QLPreviewController()
            previewController.dataSource = self
            self.present(previewController, animated: true) {
                UIApplication.shared.statusBarStyle = .default
            }
        }
    }
    
    @IBAction func securityTapped(_ sender: UIButton) {
        //HR REVIEWS
        self.isSecurityTapped = true
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
    @IBAction func erManagerTapped(_ sender: UIButton) {
        //HR REVIEWS
        self.isSecurityTapped = false
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
    
    @IBAction func forwardBtn_Tapped(_ sender: Any) {
        guard let _ = self.remarks_textView.text else {
            self.view.makeToast("Remark mandatory")
            return
        }
        switch tempStatus {
        case "submitted":
            if remarks_textView.text == "" {
                self.view.makeToast("Er Manager remarks is mandatory")
                return
            }
            self.erManagerBtn.isHidden = false
            self.securityBtn.isHidden = false
            break
        case "inprogress-er":
            if remarks_textView.text == "" {
                self.view.makeToast("Er Officer remarks is mandatory")
                return
            }
            if self.request_logs!.HRBP_EXISTS == 1 {
                self.erManagerBtn.isHidden = false
                self.securityBtn.isHidden = false
            } else {
                self.erManagerBtn.isHidden = false
                self.securityBtn.isHidden = true
            }
            
            break
        case "inprogress-s":
            if remarks_textView.text == "" {
                self.view.makeToast("Security remarks is mandatory")
                return
            }
            self.erManagerBtn.isHidden = true
            self.securityBtn.isHidden = false
            break
        case "responded":
            if remarks_textView.text == "" {
                self.view.makeToast("Er Manager remarks is mandatory")
                return
            }
            self.erManagerBtn.isHidden = false
            self.securityBtn.isHidden = false
            break
        case "investigating":
            if remarks_textView.text == "" {
                self.view.makeToast("HRBP remarks is mandatory")
                return
            }
            if remarks_textView.text == "" {
                return
            }
            self.securityBtn.isHidden = false
            break
        case "inprogress-srhrbp":
            if remarks_textView.text == "" {
                self.view.makeToast("Sr. HRBP remarks is mandatory")
                return
            }
            self.erManagerBtn.isHidden = false
            self.securityBtn.isHidden = false
            break
        case "inprogress-ceo":
            if remarks_textView.text == "" {
                self.view.makeToast("CEO Decision is mandatory")
                return
            }
            self.erManagerBtn.isHidden = true
            self.securityBtn.isHidden = false
        default:
            break
        }
    }
    
    @IBAction func closeBtn_Tapped(_ sender: Any) {
        if self.permission_inequiry_done > 0 {
            //HR REVIEWS
            if self.remarks_textView.text == "" {
                self.view.makeToast("ER Manager remarks is mandatory")
                forward_to_srhrbp = false
                return
            }
            forward_to_srhrbp = true
            let popup = UIStoryboard(name: "Popups", bundle: nil)
            let controller = popup.instantiateViewController(withIdentifier: "ConfirmationPopViewController") as! ConfirmationPopViewController
            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .overFullScreen
            }
            controller.modalTransitionStyle = .crossDissolve
            controller.delegate = self
            controller.heading = "Are you sure you want to forward to ticket to\nSenior HRBP?"
            Helper.topMostController().present(controller, animated: true, completion: nil)
            //HR REVIEWS END
        } else {
            let popup = UIStoryboard(name: "Popups", bundle: nil)
            let controller = popup.instantiateViewController(withIdentifier: "AddMemoPopupViewController") as! AddMemoPopupViewController
            controller.delegate = self
            controller.modalTransitionStyle = .crossDissolve
            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .overFullScreen
            }
            Helper.topMostController().present(controller, animated: true, completion: nil)
        }
    }
    @IBAction func downloadBtn_Tapped(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DownloadListViewController") as! DownloadListViewController
        controller.ref_id = self.request_logs!.SERVER_ID_PK
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func historyBtn_Tapped(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "GrievanceRemarksHistoryViewController") as! GrievanceRemarksHistoryViewController
        controller.ticket_id = self.ticket_id
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func searchBtn_Tapped(_ sender: Any) {
    }
}



extension GrievanceViewRequestViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
}

extension GrievanceViewRequestViewController: UITableViewDataSource, UITableViewDelegate {
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
        
        if !data.isUploaded {
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
                                            self.view.hideToastActivity()
                                            self.attachmentsTableView.reloadData()
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
                    self.attachmentsTableView.reloadData()
                    DispatchQueue.main.async {
                        self.tableViewHeightConstraint.constant = 0
                        self.tableViewHeightConstraint.constant += CGFloat((self.attachmentFiles!.count * 60) + 10)
                        self.mainViewHeightConstraint.constant -= 60
                    }
                } catch let err {
                    print(err.localizedDescription)
                }
            }
        }
    }
}


extension GrievanceViewRequestViewController: AddClosureRemarksDelegate {
    func addClosureRemarks(closure_remarks: String) {
        self.setupAPI(ticket_status: "Closed", submittedBy: "Senior-HRBP", closure_remarks: closure_remarks)
    }
}

extension GrievanceViewRequestViewController: UIDocumentPickerDelegate,UINavigationControllerDelegate {
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
                                                                     fileUploadedURL: "",
                                                                     isUploaded: false,
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
                    
                    
                    self.attachmentsTableView.reloadData()
                    
                    DispatchQueue.main.async {
                        self.mainViewHeightConstraint.constant -= self.tableViewHeightConstraint.constant
                        self.tableViewHeightConstraint.constant = 0
                        self.tableViewHeightConstraint.constant += CGFloat((self.attachmentFiles!.count * 60) + 10)
                        self.mainViewHeightConstraint.constant += self.tableViewHeightConstraint.constant
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



extension GrievanceViewRequestViewController : QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return fileDownloadedURL! as QLPreviewItem
    }
}



extension GrievanceViewRequestViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true) {
            if let image = info[.originalImage] as? UIImage {
                Helper.topMostController().view.makeToastActivity(.center)
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
                self.attachmentsTableView.reloadData()
                
                DispatchQueue.main.async {
                    Helper.topMostController().view.hideToastActivity()
                    self.mainViewHeightConstraint.constant -= self.tableViewHeightConstraint.constant
                    self.tableViewHeightConstraint.constant = 0
                    self.tableViewHeightConstraint.constant += CGFloat((self.attachmentFiles!.count * 60) + 10)
                    self.mainViewHeightConstraint.constant += self.tableViewHeightConstraint.constant
                }
            }
        }
    }
}




extension GrievanceViewRequestViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.1) {
            self.remarks_top_constraint.constant = 7
            self.remarksLabel.font = UIFont.systemFont(ofSize: 12)
            self.view.layoutIfNeeded()
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.count <= 0 {
            UIView.animate(withDuration: 0.1) {
                self.remarks_top_constraint.constant = 25
                self.remarksLabel.font = UIFont.systemFont(ofSize: 15)
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
    }
}




extension GrievanceViewRequestViewController {
    func generatePDFDocument() -> [TPPDF.PDFDocument] {
        let ref_id = self.request_logs!.REF_ID
        let query = "SELECT * FROM \(db_grievance_remarks) WHERE REF_ID = '\(ref_id!)'"
        let history = AppDelegate.sharedInstance.db?.read_tbl_hr_grievance(query: query).sorted(by: { (r1, r2) -> Bool in
            r1.CREATED < r2.CREATED
        })
        
        let document = PDFDocument(format: .a4)
        
        document.set(.contentLeft, font: Font.boldSystemFont(ofSize: 25.0))
        document.set(.contentLeft, textColor: Color(red: 0.171875, green: 0.2421875, blue: 0.3125, alpha: 1.0))
        
        document.add(.contentLeft, textObject: PDFSimpleText(text: "MEMO"))
        document.add(space: 15.0)
        
        document.set(.contentLeft, font: Font.boldSystemFont(ofSize: 15.0))
        document.add(.contentLeft, textObject: PDFSimpleText(text: "Request Details"))
        document.addLineSeparator(style: .init(type: .full, color: .black, width: 1, radius: nil))

        let table = PDFTable(rows: 10, columns: 2)

        table.content = [
            ["Ticket ID", "\(self.request_logs?.SERVER_ID_PK ?? 0)"],
            ["Reqeust Mode", "\(self.request_logs?.REQ_MODE_DESC ?? "")"],
            ["Employee Name", "\(self.request_logs?.EMP_NAME ?? "")"],
            ["Ticket Status", "\(self.status.text!)"],
            ["Query Type", "\(self.request_logs?.MASTER_QUERY ?? "")"],
            ["Employee Id", "\(self.request_logs?.REQ_ID ?? 0)"],
            ["Sub Query", "\(self.request_logs?.DETAIL_QUERY ?? "")"],
            ["Ticket Date", "\(self.request_logs?.CREATED_DATE?.dateSeperateWithT ?? "")"],
            ["Case Detail" , "\(self.request_logs?.REQ_REMARKS ?? "")"],
            ["Closure Remarks" , "\(self.request_logs?.HR_REMARKS ?? "")"],
            ["Closure Date" , "\(self.request_logs?.UPDATED_DATE ?? "")"],
        ]
        


        let style = PDFTableStyleDefaults.simple
        let pdfCellStyle = PDFTableCellStyle(
            colors: (
                fill: .clear, text: .black),
            borders: PDFTableCellBorders(left: PDFLineStyle(type: .none),
                                         top: PDFLineStyle(type: .none),
                                         right: PDFLineStyle(type: .none),
                                         bottom: PDFLineStyle(type: .none)),
            font: Font.systemFont(ofSize: 12))
        
        
        style.columnHeaderCount = 0
        style.alternatingContentStyle = pdfCellStyle
        style.contentStyle = pdfCellStyle
        style.rowHeaderStyle = pdfCellStyle
        
        
        table.rows.allRowsAlignment = [.left, .left]
        table.widths = [0.35, 0.65]
        table.style = style
        table.padding = 2.0

        document.add(table: table)

        
        document.add(space: 50.0)
        document.add(.contentLeft, textObject: PDFSimpleText(text: "History"))
        document.add(space: 15.0)
        for hist in history! {
            document.set(.contentLeft, font: Font.boldSystemFont(ofSize: 13.0))
            document.add(.contentLeft, textObject: PDFSimpleText(text: "\(hist.REMARKS_INPUT)"))
            document.addLineSeparator(style: .init(type: .full, color: .black, width: 1, radius: nil))
            
            var s = ""
            if let view_inrevieww_permission = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: PERMISSION_GRIEVANCE_VIEW_INREVIEW_STATUS).count {
                if view_inrevieww_permission > 0 {
                    switch hist.REMARKS_TICKET_STATUS {
                    case "Inprogress-Er":
                        s = "Inprogress Er-Officer"
                        break
                    case "Inprogress-S":
                        s = "Inprogress Security"
                        break
                    case "Investigating":
                        s = "Inprogress HRBP"
                        break
                    case "Responded":
                        s = "Inprogress Er-Manager"
                        break
                    case  "Submitted":
                        s = "Submitted"
                    default:
                        s = hist.REMARKS_TICKET_STATUS
                        break
                    }
                } else {
                    switch hist.REMARKS_TICKET_STATUS {
                    case "Submitted":
                        s = "Submitted"
                    case "Closed":
                        s = "Closed"
                    default:
                        s = INREVIEW
                    }
                }
            }
            
            
            let tbl = PDFTable(rows: 6, columns: 2)
            tbl.style = style
            tbl.rows.allRowsAlignment = [.left, .left]
            tbl.widths = [0.35, 0.65]
            tbl.padding = 2.0
            tbl.content = [
                ["EMPLOYEE ID", "\(hist.EMPL_NO)"],
                ["GREM ID", "\(hist.SERVER_ID_PK)"],
                ["REMARKS INPUT", "\(hist.REMARKS_INPUT)"],
                ["REMARKS", "\(hist.REMARKS)"],
                ["TICKET STATUS", s],
                ["REMARKS DATE", hist.CREATED.dateSeperateWithT],
            ]
            document.add(table: tbl)
            document.add(space: 15.0)
        }
        
        document.add(space: 70.0)
        let signatureTbl = PDFTable(rows: 1, columns: 2)
        signatureTbl.style = style
        signatureTbl.rows.allRowsAlignment = [.right, .center]
        signatureTbl.widths = [0.65, 0.35]
        signatureTbl.padding = 2.0
        signatureTbl.content = [
            ["", "Signature"]
        ]
        document.add(table: signatureTbl)
        return [document]
    }
}



extension GrievanceViewRequestViewController: ConfirmationProtocol {
    func confirmationProtocol() {
        if self.forward_to_srhrbp {
            setupAPI(ticket_status: "Inprogress-Srhrbp", submittedBy: "Er-Manager", closure_remarks: "")
            return
        }
        if self.isSecurityTapped {
            //SECURITY TAPPED
            switch tempStatus {
            case "submitted":
                setupAPI(ticket_status: "Inprogress-S", submittedBy: "Er-Manager", closure_remarks: "")
                break
            case "inprogress-er":
                setupAPI(ticket_status: "Investigating", submittedBy: "Er-Officer", closure_remarks: "")
                break
            case "inprogress-s":
                setupAPI(ticket_status: "Responded", submittedBy: "Security", closure_remarks: "")
                break
            case "responded":
                setupAPI(ticket_status: "Inprogress-S", submittedBy: "Er-Manager", closure_remarks: "")
                break
            case "investigating":
                setupAPI(ticket_status: "Inprogress-Er", submittedBy: "HRBP", closure_remarks: "")
                break
            case "inprogress-srhrbp":
                setupAPI(ticket_status: "Inprogress-Ceo", submittedBy: "Senior-HRBP", closure_remarks: "")
                break
            case "inprogress-ceo":
                setupAPI(ticket_status: "Inprogress-Srhrbp", submittedBy: "CEO", closure_remarks: "")
            default:
                break
            }
        } else {
            //ER-MANGER TAPPED
            switch tempStatus {
            case "submitted":
                setupAPI(ticket_status: "Inprogress-Er", submittedBy: "Er-Manager", closure_remarks: "")
                break
            case "inprogress-er":
                setupAPI(ticket_status: "Responded", submittedBy: "Er-Officer", closure_remarks: "")
                break
            case "inprogress-s":
                setupAPI(ticket_status: "Submitted", submittedBy: "Security", closure_remarks: "")
                break
            case "responded":
                setupAPI(ticket_status: "Inprogress-Er", submittedBy: "Er-Manager", closure_remarks: "")
                break
            case "investigating":
                setupAPI(ticket_status: "Inprogress-Er", submittedBy: "HRBP", closure_remarks: "")
                break
            case "inprogress-srhrbp":
                setupAPI(ticket_status: "Responded", submittedBy: "Senior-HRBP", closure_remarks: "")
                break
            default:
                break
            }
        }
    }
    func noButtonTapped() {}
}
