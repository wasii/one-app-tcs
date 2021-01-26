//
//  IMSNewRequestViewController.swift
//  tcs_one_app
//
//  Created by TCS on 22/12/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import DatePickerDialog
import MobileCoreServices
import Alamofire
import SwiftyJSON
import Photos

class IMSNewRequestViewController: BaseViewController {
    @IBOutlet weak var incident_mode: MDCOutlinedTextField!
    
    @IBOutlet weak var employee_view: UIView!
    @IBOutlet weak var employee_id: MDCOutlinedTextField!
    @IBOutlet weak var employee_search_btn: UIButton!
    
    @IBOutlet weak var employee_name: MDCOutlinedTextField!
    
    @IBOutlet weak var incident_type_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var incident_type: MDCOutlinedTextField!
    
    @IBOutlet weak var financial_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var financial_label: UILabel!
    @IBOutlet weak var isFinancialSwitch: UISwitch!
    
    @IBOutlet weak var consinementView: UIView!
    @IBOutlet weak var consinement_number: MDCOutlinedTextField!
    @IBOutlet weak var verifyBtn: CustomButton!
    
    @IBOutlet weak var consignmentVerifyImage: UIImageView!
    @IBOutlet weak var city: MDCOutlinedTextField!
    @IBOutlet weak var area: MDCOutlinedTextField!
    @IBOutlet weak var date: MDCOutlinedTextField!
    @IBOutlet weak var department: UITextView!
    
    @IBOutlet weak var loss_amount_view: UIView!
    @IBOutlet weak var loss_amount: MDCOutlinedTextField!
    
    
    
    
    @IBOutlet weak var cityStackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var incident_detail: UITextView!
    @IBOutlet weak var incident_detail_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var incident_detail_label: UILabel!
    @IBOutlet weak var incident_word_counter: UILabel!
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var attachmentTableHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var remarks: UITextView!
    @IBOutlet weak var remarks_label: UILabel!
    @IBOutlet weak var remarks_label_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var remarks_word_counter: UILabel!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var ticket_status: MDCOutlinedTextField!
    
    @IBOutlet weak var create_ticket_button: CustomButton!
    @IBOutlet weak var download_btn: CustomButton!
    
    @IBOutlet weak var history_btn: CustomButton!
    @IBOutlet weak var headingLabel: UILabel!
    
    
    var emp_model = [User]()
    var tbl_request_mode:   tbl_RequestModes?
    var tbl_incident_type:  tbl_lov_incident_type?
    var tbl_city:           tbl_lov_city?
    var tbl_area:           tbl_lov_area?
    var tbl_department:     tbl_lov_department?
    var ticketCreateDate:   String?
    
    var attachmentFiles:    [AttachmentsList]?
    var picker =            UIImagePickerController()
    var fileDownloadedURL:  URL?
    
    var consignmentVerified = false
    var delegate: DateSelectionDelegate?
    let datePicker = DatePickerDialog(
        textColor: .nativeRedColor(),
        buttonColor: .nativeRedColor(),
        font: UIFont.boldSystemFont(ofSize: 17),
        showCancelButton: true
    )
    
    var current_ticket: tbl_Hr_Request_Logs?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "New Request"
        addDoubleNavigationButtons()
        self.makeTopCornersRounded(roundView: self.mainView)
        setupMainViewHeight()
        setupTextField()
        
        isFinancialSwitch.addTarget(self, action: #selector(switchChanged(mySwitch:)), for: .valueChanged)
        
        incident_detail.delegate = self
        remarks.delegate = self
        
        picker.delegate = self
        self.tableView.register(UINib(nibName: "AddAttachmentsTableCell", bundle: nil), forCellReuseIdentifier: "AddAttachmentsCell")
        self.tableView.rowHeight = 60
        attachmentFiles = [AttachmentsList]()
    }
    @objc func switchChanged(mySwitch: UISwitch) {
        if mySwitch.isOn {
            self.financial_label.text = "Financial"
            self.loss_amount_view.isHidden = false
        } else {
            self.financial_label.text = "Non Financial"
            self.loss_amount_view.isHidden = true
        }
    }
    func setupMainViewHeight() {
        self.mainViewHeightConstraint.constant = 950
    }
    func setupTextField() {
        self.loss_amount_view.isHidden = true
        incident_mode.label.textColor = UIColor.nativeRedColor()
        incident_mode.label.text = "*Incident Mode"
        incident_mode.placeholder = ""
        incident_mode.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        incident_mode.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        
        employee_id.label.textColor = UIColor.nativeRedColor()
        employee_id.label.text = "Employee ID"
        employee_id.placeholder = ""
        employee_id.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        employee_id.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        employee_name.label.textColor = UIColor.nativeRedColor()
        employee_name.label.text = "Employee Name"
        employee_name.placeholder = ""
        employee_name.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        employee_name.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        incident_type.label.textColor = UIColor.nativeRedColor()
        incident_type.label.text = "*Incident Type"
        incident_type.placeholder = ""
        incident_type.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        incident_type.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        
        consinement_number.label.textColor = UIColor.nativeRedColor()
        consinement_number.label.text = "*Enter CN#"
        consinement_number.placeholder = ""
        consinement_number.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        consinement_number.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        city.label.textColor = UIColor.nativeRedColor()
        city.label.text = "*City"
        city.text = "Select City"
        city.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        city.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        
        area.label.textColor = UIColor.nativeRedColor()
        area.label.text = "*Area"
        area.text = "Select Area"
        area.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        area.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        
        date.label.textColor = UIColor.nativeRedColor()
        date.label.text = "*Date"
        date.text = "Select Date"
        date.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        date.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        
        department.text = "Select Department"
        
         
        loss_amount.label.textColor = UIColor.nativeRedColor()
        loss_amount.label.text = "*Loss Amount"
        loss_amount.placeholder = ""
        loss_amount.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        loss_amount.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        
        self.ticket_status.label.textColor = UIColor.nativeRedColor()
        self.ticket_status.label.text = "Ticket Status"
        self.ticket_status.text = ""
        self.ticket_status.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        self.ticket_status.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        self.ticket_status.isUserInteractionEnabled = false
        
        if let ticket = self.current_ticket {
            incident_mode.text = "\(ticket.REQ_MODE_DESC!)"
            incident_mode.isUserInteractionEnabled = false
            
            if let modes = AppDelegate.sharedInstance.db?.read_tbl_requestModes(module_id: 3) {
                self.tbl_request_mode = modes.filter { (m) -> Bool in
                    m.REQ_MODE_DESC == incident_mode.text
                }.first
            }
            
            if incident_mode.text == "Self" {
                self.employee_view.isHidden = true
            } else {
                self.employee_name.isHidden = false
                self.employee_search_btn.isEnabled = false
                self.employee_id.text = "\(ticket.REQ_ID ?? 0)"
                self.employee_id.isUserInteractionEnabled = false
                
                self.employee_name.text = "\(ticket.EMP_NAME!)"
                self.employee_name.isUserInteractionEnabled = false
                
                self.incident_type_top_constraint.constant = 90
                self.financial_top_constraint.constant = 93
                
                self.mainViewHeightConstraint.constant = 1000
            }
            
            if let type = AppDelegate.sharedInstance.db?.read_tbl_incident_type(query: "SELECT * FROM \(db_lov_incident_type)") {
                tbl_incident_type = type.filter({ (t) -> Bool in
                    t.NAME == ticket.INCIDENT_TYPE
                }).first
            }
            
            self.incident_type.text = ticket.INCIDENT_TYPE
            self.incident_type.isUserInteractionEnabled = false
            if self.incident_type.text == "Shipment" {
                self.cityStackTopConstraint.constant = 90
                self.mainViewHeightConstraint.constant += 70
                self.consinementView.isHidden = false
                
                self.consinement_number.isHidden = false
                self.consinement_number.text = "\(ticket.CNSGNO!)"
                self.consinement_number.isUserInteractionEnabled = false
            }
            
            if ticket.IS_FINANCIAL == 1 {
                self.financial_label.text = "Financial"
                self.isFinancialSwitch.isOn = true
                self.loss_amount_view.isHidden = false
                self.loss_amount.text = "\(ticket.AMOUNT!)"
            } else {
                self.isFinancialSwitch.isOn = false
            }
            
            if let area = AppDelegate.sharedInstance.db?.read_tbl_area(query: "SELECT * FROM \(db_lov_area) WHERE SERVER_ID_PK = '\(ticket.AREA!)'") {
                self.tbl_area = area.first
                self.area.text = area.first?.AREA_NAME ?? ""
            }
            
            if let city = AppDelegate.sharedInstance.db?.read_tbl_city(query: "SELECT * FROM \(db_lov_city) WHERE SERVER_ID_PK = '\(tbl_area!.SERVER_ID_PK)'") {
                self.tbl_city = city.first
                self.city.text = city.first?.CITY_NAME ?? ""
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let tempdate = formatter.date(from: ticket.TICKET_DATE!)
            formatter.dateFormat = "dd/MM/yyyy'T'HH:mm:ss"
            let tempdatestring = formatter.string(from: tempdate ?? Date())
            self.date.text = tempdatestring.dateOnly
            
            if let depart = AppDelegate.sharedInstance.db?.read_tbl_department(query: "SELECT * FROM \(db_lov_department) WHERE SERVER_ID_PK = '\(ticket.DEPARTMENT!)'") {
                self.department.text = depart.first?.DEPAT_NAME  ?? ""
                self.tbl_department = depart.first
            }
            
            if ticket.REQ_REMARKS != "" {
                self.incident_detail_top_constraint.constant -= 20
                self.incident_detail_label.font = UIFont.systemFont(ofSize: 12)
                self.incident_detail.text = ticket.REQ_REMARKS ?? ""
            }
            
            if let initiator_remark = AppDelegate.sharedInstance.db?.read_tbl_hr_grievance(query: "SELECT * FROM \(db_grievance_remarks) WHERE TICKET_ID = '\(ticket.SERVER_ID_PK!)' AND REMARKS_INPUT = 'Initiator'").first {
                self.remarks.text = initiator_remark.REMARKS
                self.remarks_label_top_constraint.constant -= 20
                self.remarks_label.font = UIFont.systemFont(ofSize: 12)
            }
            
            if ticket.TICKET_STATUS != IMS_Status_Inprogress_Rm {
                self.title = "View Request"
                self.headingLabel.text = "View Request"
                self.download_btn.isHidden = false
                self.history_btn.isHidden = false
                self.create_ticket_button.isHidden = true
                
                
                self.ticket_status.isHidden = false
                self.ticket_status.text = ticket.TICKET_STATUS
                self.verifyBtn.isUserInteractionEnabled = false
                
                self.isFinancialSwitch.isEnabled = false
                self.area.isUserInteractionEnabled = false
                self.city.isUserInteractionEnabled = false
                self.date.isUserInteractionEnabled = false
                self.loss_amount.isUserInteractionEnabled = false
                self.department.isUserInteractionEnabled = false
                self.incident_detail.isUserInteractionEnabled = false
                self.remarks.isUserInteractionEnabled = false
                
                
            } else  {
                self.title = "Update Request"
                self.headingLabel.text = "Update Request"
                self.download_btn.isHidden = true
                self.history_btn.isHidden = true
                self.create_ticket_button.isHidden = false
                
                area.delegate = self
                city.delegate = self
                date.delegate = self
                department.delegate = self
                verifyBtn.isUserInteractionEnabled = false
                self.ticket_status.text = ticket.TICKET_STATUS ?? ""
            }
            
            let downloadURL = Bundle.main.url(forResource: "download-fill-icon", withExtension: "svg")!
            let historyURL = Bundle.main.url(forResource: "history-icon-fill", withExtension: "svg")!
            _ = CALayer(SVGURL: downloadURL) { (svgLayer) in
                svgLayer.resizeToFit(self.self.download_btn.bounds)
                self.download_btn.layer.addSublayer(svgLayer)
            }
            _ = CALayer(SVGURL: historyURL) { (svgLayer) in
                svgLayer.resizeToFit(self.history_btn.bounds)
                self.history_btn.layer.addSublayer(svgLayer)
            }
            
            self.download_btn.addTarget(self, action: #selector(openDownloadHistory), for: .touchUpInside)
            self.history_btn.addTarget(self, action: #selector(openRemarksHistory), for: .touchUpInside)
        } else {
            department.delegate = self
            date.delegate = self
            area.delegate = self
            city.delegate = self
            incident_mode.delegate = self
            incident_type.delegate = self
            
            self.ticket_status.isHidden = true
        }
    }
    @objc func openDownloadHistory() {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "IMSFilesViewController") as! IMSFilesViewController
        controller.ticket_id = current_ticket!.SERVER_ID_PK
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func openRemarksHistory() {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "IMSHistoryViewController") as! IMSHistoryViewController
        
        
        controller.ticket_id = current_ticket!.SERVER_ID_PK
        self.navigationController?.pushViewController(controller, animated: true)
    }
    func openDatePicker(title: String, handler: @escaping(_ success: Bool,_ date: String) -> Void) {
        datePicker.show(title,
                        doneButtonTitle: "Done",
                        cancelButtonTitle: "Cancel",
                        datePickerMode: .date,
                        window: self.view.window) { (date) in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy'T'HH:mm:ss"
                handler(true, formatter.string(from: dt))
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
    
    
    //MARK: IBActions
    
    //add attachments
    @IBAction func addAttachmentsTapped(_ sender: Any) {
        self.showAlertActionSheet(title: "Select an image and documents", message: "", sender: sender as! UIButton)
    }
    
    
    //search Employee
    @IBAction func search_employee_tapped(_ sender: Any) {
        if employee_id.text == "" {
            return
        }
        self.dismissKeyboard()
        self.freezeScreen()
        self.view.makeToastActivity(.center)
        let search_employee = [
            "empployee": [
                "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                "emp_id" :"\(self.employee_id.text!)"
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
                        
                        self.employee_name.isHidden = false
                        self.employee_name.text = self.emp_model.first?.empName ?? ""
                        self.employee_name.isUserInteractionEnabled = false
                        self.incident_type_top_constraint.constant = 90
                        self.financial_top_constraint.constant = 93
                        
                        self.mainViewHeightConstraint.constant = 1000
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
    //verify consignment
    @IBAction func verifyConsignmentTapped(_ sender: Any) {
        self.view.hideToast()
        if self.consinement_number.text == "" {
            self.view.makeToast("Please enter consignment number first.")
            return
        }
        self.view.makeToastActivity(.center)
        self.freezeScreen()
        let consignment_setup = [
            "hr_request": [
                "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                "cnno": self.consinement_number.text! //"4708109905"
            ]
        ]
        let params = getAPIParameter(service_name: PROCCONSIGNMENTVALIDATE, request_body: consignment_setup)
        NetworkCalls.procconsignmentverify(params: params) { success, response in
            if success {
                DispatchQueue.main.async {
                    self.consignmentVerified = true
                    self.consignmentVerifyImage.image = UIImage(named: "rightG")
                    self.view.hideToastActivity()
                    self.unFreezeScreen()
                }
            } else {
                DispatchQueue.main.async {
                    self.consignmentVerified = false
                    self.consignmentVerifyImage.image = UIImage(named: "cross")
                    self.view.hideToastActivity()
                    self.unFreezeScreen()
                }
            }
        }
    }
    @IBAction func submitBtnTapped(_ sender: Any) {
        guard let _ = self.tbl_request_mode else {
            self.view.makeToast("Select Incident Mode")
            return
        }
        
        if self.incident_mode.text != "Self" && self.employee_id.text == "" {
            self.view.makeToast("Please enter employee id")
            return
        }
        
        guard let _ = self.tbl_incident_type else {
            self.view.makeToast("Select Incident Type")
            return
        }
        guard let _ = self.tbl_area else {
            self.view.makeToast("Select Area")
            return
        }
        guard let _ = self.tbl_city else {
            self.view.makeToast("Select City")
            return
        }
        guard let _ = ticketCreateDate else {
            self.view.makeToast("Select Date")
            return
        }
        guard let _ = tbl_department else {
            self.view.makeToast("Select Department")
            return
        }
        
        if self.incident_detail.text == "" {
            self.view.makeToast("Incident Detail is mandatory")
            return
        }
        if self.remarks.text == "" {
            self.view.makeToast("Remarks is mandatory")
            return
        }
        
        var cnsg_no         = ""
        var is_financial    = "0"
        
        if self.tbl_incident_type!.NAME == "Shipment" {
            if consignmentVerified{
                cnsg_no = self.consinement_number.text!
            } else {
                self.view.makeToast("Consignment number isn't correct")
                return
            }
        }
        
        var loss_amount     = "0.0"
        if self.isFinancialSwitch.isOn {
            if self.loss_amount.text == "" {
                self.view.makeToast("Please enter loss amount")
                return
            } else {
                loss_amount = String(format: "%.2f", Double(self.loss_amount.text!)!)
                is_financial = "1"
            }
        }
        
        let refid = randomString()
        var employeeId = ""
        
        if self.tbl_request_mode?.REQ_MODE_DESC == "Self" {
            employeeId = CURRENT_USER_LOGGED_IN_ID
        } else {
            employeeId = self.employee_id.text!
        }
        
        var offline_data = tbl_Hr_Request_Logs()
        var offline_hr_files = tbl_Files_Table()
        var offline_remarks  = tbl_Grievance_Remarks()
        
        offline_data.REQ_ID = Int(employeeId)
        offline_data.SERVER_ID_PK = randomInt()
        offline_data.TICKET_DATE = getCurrentDate()
        offline_data.LOGIN_ID = Int(CURRENT_USER_LOGGED_IN_ID)!
        
        if self.title == "Update Request" {
            offline_data.TICKET_STATUS = IMS_Inprogress_Ro
        } else {
            offline_data.TICKET_STATUS = "Submitted"
        }
        offline_data.CREATED_DATE = getCurrentDate()
        
        offline_data.REF_ID = refid
        offline_data.AREA_CODE = AppDelegate.sharedInstance.db?.read_tbl_UserProfile().first?.AREA_CODE ?? "HOF"
        offline_data.REQUEST_LOGS_SYNC_STATUS = 0
        
        
        offline_data.REQ_MODE = self.tbl_request_mode!.SERVER_ID_PK
        offline_data.REQ_MODE_DESC = self.tbl_request_mode!.REQ_MODE_DESC
        offline_data.REQ_REMARKS = self.incident_detail.text!.replacingOccurrences(of: "'", with: "''")
        
        offline_data.INCIDENT_TYPE = self.tbl_incident_type!.SERVER_ID_PK
        offline_data.CITY = self.tbl_city!.CITY_CODE
        offline_data.AREA = self.tbl_area!.SERVER_ID_PK
        offline_data.DEPARTMENT = String(self.tbl_department!.DEPT_ID)
        offline_data.INCIDENT_DATE = self.ticketCreateDate!.dateSeperateWithT
        offline_data.CNSGNO = cnsg_no
        offline_data.IS_FINANCIAL = Int(is_financial)
        offline_data.AMOUNT = Double(loss_amount)
        
        offline_data.MODULE_ID = 3
        
        offline_data.CURRENT_USER = CURRENT_USER_LOGGED_IN_ID
        
        
        offline_remarks.CREATED = offline_data.TICKET_DATE!
        offline_remarks.EMPL_NO = Int(CURRENT_USER_LOGGED_IN_ID)!
        offline_remarks.REF_ID  = refid
        offline_remarks.REMARKS_INPUT = "Initiator"
        offline_remarks.REMARKS = self.remarks.text!
        
        
        
        AppDelegate.sharedInstance.db?.dump_data_HRRequest(hrrequests: offline_data, { success in
            if success {
                print("DUMP IMS TICKET")
                if self.title == "Update Request" {
                    self.updateIMSTicket(offline_data: offline_data)
                } else {
                    self.createImsTicket(offline_data: offline_data)
                    
                }
                
            }
        })
        self.navigationController?.popViewController(animated: true)
    }
    func updateIMSTicket(offline_data: tbl_Hr_Request_Logs) {
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
                offline_hr_files.REF_ID = offline_data.REF_ID!
                offline_hr_files.CREATED = offline_data.CREATED_DATE!
                AppDelegate.sharedInstance.db?.dump_tbl_hr_files(hrfile: offline_hr_files)
            }
        }
        let request = [
            "hr_request": [
                "access_token" : UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                "tickets": [
                    "ticketid": "\(self.current_ticket!.SERVER_ID_PK!)",
                    "status": IMS_Status_Inprogress_Ro,
                    "loginid": "\(CURRENT_USER_LOGGED_IN_ID)",
                    "closure_remarks": "",
                    "is_financial": "\(offline_data.IS_FINANCIAL!)",
                    "requesterremarks": "\(offline_data.REQ_REMARKS!)",
                    "city": "\(offline_data.CITY!)",
                    "area": "\(offline_data.AREA!)",
                    "department": "\(offline_data.DEPARTMENT!)",
                    "amount": "\(offline_data.AMOUNT!)",
                    "incident_date": "\(offline_data.INCIDENT_DATE!)",
                    "ticket_logs": [
                        [
                            "inputby": "Initiator",
                            "remarks": "\(self.remarks.text!)",
                            "ticket_files": ticket_files
                        ]
                    ]
                ]
            ]
        ]
        let params = getAPIParameter(service_name: IMSUPDATE, request_body: request)
        NetworkCalls.updaterequestims(params: params) { success, response in
            if success {
                DispatchQueue.main.async {
                    self.updateTicketRequest(response: response)
                }
            } else {
                print(success)
            }
        }
    }
    func updateTicketRequest(response: Any) {
        let json = JSON(response)
        if let hr_files = json.dictionary?[_hr_files]?.array {
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
        if let hr_log = json.dictionary?[_hr_logs]?.array {
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

        if let ticket_logs = json.dictionary?[_tickets_logs]?.array?.first {
            let ref_id = ticket_logs["REF_ID"].string ?? ""
            AppDelegate.sharedInstance.db?.deleteRow(tableName: db_hr_request,column: "REF_ID", ref_id: ref_id, handler: { success in
                if success {
                    do {
                        let dictionary = try ticket_logs.rawData()
                        let hrgrievance = try JSONDecoder().decode(HrRequest.self, from: dictionary)
                        
                        DispatchQueue.main.async {
                            AppDelegate.sharedInstance.db?.insert_tbl_hr_request(hrrequests: hrgrievance, { dump_succes in
                                if success {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        NotificationCenter.default.post(Notification.init(name: .refreshedViews))
                                        Helper.topMostController().view.makeToast("Request Update Successfully")
                                    }
                                    print("DUMPED IMS UPDATED TICKET")
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
    func createImsTicket(offline_data: tbl_Hr_Request_Logs) {
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
                offline_hr_files.REF_ID = offline_data.REF_ID!
                offline_hr_files.CREATED = offline_data.CREATED_DATE!
                AppDelegate.sharedInstance.db?.dump_tbl_hr_files(hrfile: offline_hr_files)
            }
        }
        guard let token = UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN) else {
            self.dismiss(animated: true) {
                Helper.topMostController().view.makeToast("Session Expired")
            }
            return
        }
        
        let request = [
            "hr_request": [
                "access_token" : token,
                "tickets": [
                    "requesteremployeeid": "\(Int(offline_data.REQ_ID!))",
                    "requestmodeid": "\(offline_data.REQ_MODE!)",
                    "requesterremarks": "\(offline_data.REQ_REMARKS!)",
                    "refid": offline_data.REF_ID!,
                    "ticketdate": getCurrentDate(),
                    "incident_type": "\(offline_data.INCIDENT_TYPE!)",
                    "city": "\(offline_data.CITY!)",
                    "area": "\(offline_data.AREA!)",
                    "department": "\(offline_data.DEPARTMENT!)",
                    "incident_date": "\(offline_data.INCIDENT_DATE!)",
                    "cnsg_no": offline_data.CNSGNO!,
                    "is_financial": "\(offline_data.IS_FINANCIAL!)",
                    "amount": "\(offline_data.AMOUNT!)",
                    "ticket_logs": [
                        [
                            "empl_no": "\(CURRENT_USER_LOGGED_IN_ID)",
                            "refid": offline_data.REF_ID!,
                            "remarks_input": "Initiator",
                            "logremarks": "\(self.remarks.text!)",
                            "ticket_files": ticket_files
                        ]
                    ]
                ]
            ]
        ]
        let params = getAPIParameter(service_name: ADDREQUESTIMS, request_body: request)
        NetworkCalls.addrequestims(params: params) { success, response in
            if success {
                var hrFile = [HrFiles]()
                var hrLog = [HrLog]()
                
                if let returnResponse = JSON(response).dictionary {
                    if let hr_logs  = returnResponse[_hr_logs]?.array {
                        for logs in hr_logs {
                            do {
                                let dictionary = try logs.rawData()
                                hrLog.append(try JSONDecoder().decode(HrLog.self, from: dictionary))
                            } catch let err {
                                print(err.localizedDescription)
                            }
                        }
                        for logs in hrLog {
                            AppDelegate.sharedInstance.db?.insert_tbl_hr_grievance(hr_log: logs)
                        }
                    }
                    if let hr_files = returnResponse[_hr_files]?.array {
                        for files in hr_files {
                            do {
                                let dictionary = try files.rawData()
                                hrFile.append(try JSONDecoder().decode(HrFiles.self, from: dictionary))
                            } catch let err {
                                print(err.localizedDescription)
                            }
                        }
                        for files in hrFile {
                            AppDelegate.sharedInstance.db?.insert_tbl_hr_files(hrfile: files)
                        }
                    }
                    let ticket_logs = returnResponse[_tickets_logs]?.array?.first
                    
                    DispatchQueue.main.async {
                        let ref_id = ticket_logs?["REF_ID"].string ?? ""
                        AppDelegate.sharedInstance.db?.deleteRow(tableName: db_hr_request, column: "REF_ID", ref_id: ref_id, handler: { success in
                            if success {
                                do {
                                    let dictionary = try ticket_logs?.rawData()
                                    let hrgrievance = try JSONDecoder().decode(HrRequest.self, from: dictionary!)
                                    
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
                    print(returnResponse)
                }
            } else {
                print(response)
            }
        }
    }
}



extension IMSNewRequestViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.tag == 1 {
            UIView.animate(withDuration: 0.1) {
                if self.incident_detail_top_constraint.constant != 15 {
                    self.incident_detail_top_constraint.constant -= 20
                    self.incident_detail_label.font = UIFont.systemFont(ofSize: 12)
                    self.view.layoutIfNeeded()
                }
            }
        } else if textView.tag == 2 {
            if self.remarks_label_top_constraint.constant != 15 {
                UIView.animate(withDuration: 0.1) {
                    self.remarks_label_top_constraint.constant -= 20
                    self.remarks_label.font = UIFont.systemFont(ofSize: 12)
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.tag == 1 {
            if textView.text.count <= 0 {
                UIView.animate(withDuration: 0.1) {
                    self.incident_detail_top_constraint.constant += 20
                    self.incident_detail_label.font = UIFont.systemFont(ofSize: 15)
                    self.view.layoutIfNeeded()
                }
            }
        } else if textView.tag == 2 {
            if textView.text.count <= 0 {
                UIView.animate(withDuration: 0.1) {
                    self.remarks_label_top_constraint.constant += 20
                    self.remarks_label.font = UIFont.systemFont(ofSize: 15)
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxLength = 200
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
            if textView.tag == 1 {
                self.incident_word_counter.text = "\(newString.length)/200"
            } else if textView.tag == 2 {
                self.remarks_word_counter.text = "\(newString.length)/200"
            }
            return true
        }
        return false
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        switch textView.tag {
        case 0:
            guard let _ = self.ticketCreateDate else {
                self.view.makeToast("Select Date")
                return false
            }
            let storyboard = UIStoryboard(name: "Popups", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestListingViewController") as! NewRequestListingViewController
            controller.lov_department = AppDelegate.sharedInstance.db?.read_tbl_department(query: "SELECT * FROM \(db_lov_department)")
            controller.heading = "Department"
            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .overFullScreen
            }
            controller.modalTransitionStyle = .crossDissolve
            controller.imsdelegate = self
            Helper.topMostController().present(controller, animated: true, completion: nil)
            return false
        default:
            return true
        }
    }
}


extension IMSNewRequestViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let storyboard = UIStoryboard(name: "Popups", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestListingViewController") as! NewRequestListingViewController
        switch textField.tag {
        case 1: //incident mode
            controller.request_mode = AppDelegate.sharedInstance.db?.read_tbl_requestModes(module_id: CONSTANT_MODULE_ID)
            controller.heading = "Incident Mode"
            break
        case 3: //incident type
            guard let _ = self.tbl_request_mode else {
                self.view.makeToast("Select Incident Mode")
                return false
            }
            controller.incident_type = AppDelegate.sharedInstance.db?.read_tbl_incident_type(query: "SELECT * FROM \(db_lov_incident_type)")
            controller.heading = "Incident Type"
            break
        case 5: //area
            guard let _ = self.incident_type else {
                self.view.makeToast("Select Incident Type")
                return false
            }
            controller.lov_area = AppDelegate.sharedInstance.db?.read_tbl_area(query: "SELECT * FROM \(db_lov_area)")
            controller.heading = "Area"
            
            
            break
        case 6: //city
            guard let _ = self.tbl_area else {
                self.view.makeToast("Select Area")
                return false
            }
            controller.lov_city = AppDelegate.sharedInstance.db?.read_tbl_city(query: "SELECT * FROM \(db_lov_city) WHERE SERVER_ID_PK = '\(self.tbl_area!.SERVER_ID_PK)'")
            controller.heading = "City"
            break
        case 7: //date
            guard let _ = self.tbl_city else {
                self.view.makeToast("Select City")
                return false
            }
            self.openDatePicker(title: "Ticket Date") { success, date in
                if success {
                    self.ticketCreateDate = date
                    self.date.text = date.dateOnly
                }
            }
            return false
        default:
            return true
        }
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        controller.modalTransitionStyle = .crossDissolve
        controller.imsdelegate = self
        Helper.topMostController().present(controller, animated: true, completion: nil)
        return false
    }
    
    
}

extension IMSNewRequestViewController: IMSNewRequestDelegate {
    
    func updateRequestMode(requestmode: tbl_RequestModes) {
        self.tbl_request_mode = requestmode
        if requestmode.REQ_MODE_DESC == "Self" {
            self.employee_view.isHidden = true
        } else {
            self.employee_view.isHidden = false
        }
        self.incident_mode.text = requestmode.REQ_MODE_DESC
    }
    func updateIncidentType(incidentyType: tbl_lov_incident_type) {
        self.tbl_incident_type = incidentyType
        self.incident_type.text = incidentyType.NAME
        if incidentyType.NAME == "Shipment" {
            if self.cityStackTopConstraint.constant == 20 {
                self.cityStackTopConstraint.constant = 90
                self.mainViewHeightConstraint.constant += 70
                self.consinementView.isHidden = false
            }
        } else {
            if self.cityStackTopConstraint.constant == 90 {
                self.cityStackTopConstraint.constant = 20
                self.mainViewHeightConstraint.constant -= 70
                self.consinementView.isHidden = true
            }
        }
    }
    func updateCity(city: tbl_lov_city) {
        self.tbl_city = city
        self.city.text = city.CITY_NAME
    }
    
    func updateArea(area: tbl_lov_area) {
        self.tbl_area = area
        self.area.text = area.AREA_NAME
    }
    
    func updateDepartment(department: tbl_lov_department) {
        self.tbl_department = department
        self.department.text = department.DEPAT_NAME
    }
}

//MARK: TableView Delegate and Datasource
extension IMSNewRequestViewController: UITableViewDataSource, UITableViewDelegate {
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
                        self.attachmentTableHeightConstraint.constant = 0
                        self.attachmentTableHeightConstraint.constant += CGFloat((self.attachmentFiles!.count * 60) + 10)
                        UIView.animate(withDuration: 0.2) {
                            self.mainViewHeightConstraint.constant -= 60
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



//MARK: UIDocumentPicker Delegate
extension IMSNewRequestViewController: UIDocumentPickerDelegate,UINavigationControllerDelegate {
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
                    
                    
                    self.tableView.reloadData()
                    
                    DispatchQueue.main.async {
                        self.mainViewHeightConstraint.constant -= self.attachmentTableHeightConstraint.constant
                        self.attachmentTableHeightConstraint.constant = 0
                        self.attachmentTableHeightConstraint.constant += CGFloat((self.attachmentFiles!.count * 60) + 10)
                        UIView.animate(withDuration: 0.4) {
                            self.mainViewHeightConstraint.constant += self.attachmentTableHeightConstraint.constant
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


extension IMSNewRequestViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            picker.view.makeToastActivity(.center)
            image.compressTo1(1) { NewImage in
                picker.dismiss(animated: true) {
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let fileName = "\(UUID().uuidString).jpg" // name of the image to be saved
                        let fileExtension = "jpg"
                        let fileURL = documentsDirectory.appendingPathComponent(fileName)
                        if let data = NewImage.jpegData(compressionQuality: 0.2),!FileManager.default.fileExists(atPath: fileURL.path){
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
                        picker.view.hideToastActivity()
                        self.mainViewHeightConstraint.constant -= self.attachmentTableHeightConstraint.constant
                        self.attachmentTableHeightConstraint.constant = 0
                        self.attachmentTableHeightConstraint.constant += CGFloat((self.attachmentFiles!.count * 60) + 10)
                        UIView.animate(withDuration: 0.4) {
                            self.mainViewHeightConstraint.constant += self.attachmentTableHeightConstraint.constant
                            self.view.layoutIfNeeded()
                        }
                    }
                }
            }
        }
    }
}
