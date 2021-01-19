//
//  GrievanceNewRequestViewController.swift
//  tcs_one_app
//
//  Created by TCS on 13/11/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextAreas
import MobileCoreServices
import SwiftyJSON

import Alamofire
import AVFoundation
import Photos
class GrievanceNewRequestViewController: BaseViewController {
    @IBOutlet weak var submitBtn: CustomButton!
    @IBOutlet weak var case_detail_view: CustomView!
    @IBOutlet weak var case_detail_placeholder: UILabel!
    @IBOutlet weak var case_detail_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var employeeIdView: UIView!
    @IBOutlet weak var scrollVIew: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var query_type_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var request_mode: MDCOutlinedTextField!
    
    @IBOutlet weak var employee_id: MDCOutlinedTextField!
    @IBOutlet weak var employee_name: MDCOutlinedTextField!
    @IBOutlet weak var query_type: MDCOutlinedTextField!
    @IBOutlet weak var sub_query_type: MDCOutlinedTextField!
    
    @IBOutlet weak var case_detail: MDCOutlinedTextField!
    
    @IBOutlet weak var searchBtn: UIButton!
    
    //hr changes 28/12/2020
    @IBOutlet weak var characterCounter: UILabel!
    
    //hr changes 28/12/2020
    
    var ticket_id: Int?
    
    var attachmentFiles: [AttachmentsList]?
    
    
    var emp_model = [User]()
    var tbl_request_mode: tbl_RequestModes?
    var tbl_masterquery: tbl_MasterQuery?
    var tbl_detailquery: tbl_DetailQuery?
    var tbl_querymatrix: tbl_QueryMatrix?
    
    
    var picker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "New Request"
        self.makeTopCornersRounded(roundView: self.mainView)
        self.tableView.register(UINib(nibName: "AddAttachmentsTableCell", bundle: nil), forCellReuseIdentifier: "AddAttachmentsCell")
        self.tableView.rowHeight = 60
        setupTextFields()
        attachmentFiles = [AttachmentsList]()
        
        picker.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(upload_pending_request), name: .networkRefreshed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigateThroughtNotify(notification:)), name: .navigateThroughNotification, object: nil)
        switch UIDevice().type {
        case .iPhone5, .iPhone5S, .iPhone5C, .iPhoneSE:
            break
        case .iPhone6, .iPhone6S, .iPhone7, .iPhone8:
            self.mainViewHeightConstraint.constant = 620
            break
        case .iPhone6Plus, .iPhone7Plus, .iPhone8Plus:
            self.mainViewHeightConstraint.constant = 850
            break
        case .iPhoneX, .iPhoneXR, .iPhoneXS, .iPhone11Pro:
            self.mainViewHeightConstraint.constant = 980
            break
        case .iPhone11, .iPhoneXSMax, .iPhone11ProMax:
            self.mainViewHeightConstraint.constant = 850
            break
        default:
            break
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
        
        case_detail_view.borderColor = UIColor.nativeRedColor()
//        case_detail_placeholder.text = "Case Detail"
        textView.delegate = self
        
//        case_detail.label.textColor = UIColor.nativeRedColor()
//        case_detail.label.text = "Case Detail"
//        case_detail.label.numberOfLines = 0
//        case_detail.placeholder = ""
//        case_detail.inputView?.frame.size.height = 80.0
//        case_detail.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
//        case_detail.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
//        case_detail.delegate = self
    }
    
    @IBAction func submitBtn_Tapped(_ sender: Any) {
        self.submitBtn.isEnabled = false
        
        
        guard let _ = tbl_request_mode else {
            self.view.makeToast("Request Mode is mandatory")
            self.submitBtn.isEnabled = true
            return
        }
        
        guard let _ = tbl_masterquery else {
            self.view.makeToast("Master Query is mandatory")
            self.submitBtn.isEnabled = true
            return
        }
        guard let _ = tbl_detailquery else {
            self.view.makeToast("Sub Query is mandatory")
            self.submitBtn.isEnabled = true
            return
        }
        if request_mode.text != "Self" && employee_id.text! == "" {
            self.view.makeToast("Employee ID is mandatory")
            self.submitBtn.isEnabled = true
            return
        }
        
        if textView.text == "" {
            self.view.makeToast("Case Detail is mandatory.")
            self.submitBtn.isEnabled = true
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
    func addRequesttoServer(offline_data: tbl_Hr_Request_Logs) {
        self.submitBtn.isEnabled = true
        var ticket_files = [[String:String]]()
        for index in self.attachmentFiles! {
            let dictionary = [
                "file_url": index.fileUploadedURL,
                "file_extention": index.fileExtension,
                "file_size_kb": String(index.fileSize.split(separator: " ").first!)
            ]
            ticket_files.append(dictionary)
            let db_files = HrFiles(created: "", gremID: -1, fileSizeKB: 100, fileURL: index.fileUploadedURL, gimgID: -1, fileExtention: index.fileExtension, ticketID: offline_data.SERVER_ID_PK)
            
            AppDelegate.sharedInstance.db?.insert_tbl_hr_files(hrfile: db_files)
        }
        
        let request_body = [
            "hr_request":[
                "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                "tickets":[
                    "detailqueryid": "\(offline_data.DQ_ID!)",
                    "closure_remarks": "",
                    "masterqueryid": "\(offline_data.MQ_ID!)",
                    "refid": offline_data.REF_ID!,
                    "requestmodeid": "\(offline_data.REQ_MODE!)",
                    "requesteremployeeid": "\(offline_data.REQ_ID!)",
                    "requesterremarks": offline_data.REQ_REMARKS!,
                    "ticketdate": offline_data.CREATED_DATE!,
                    "ticket_logs" : [
                        [
                            "empl_no": CURRENT_USER_LOGGED_IN_ID,
                            "refid": offline_data.REF_ID!,
                            "remarks_input": "Initiator",
                            "ticket_files": ticket_files
                        ]
                    ]
                ]
            ]
        ]
        
        let params = self.getAPIParameter(service_name: ADDREQUESTGREV, request_body: request_body)
        print(JSON(params))
        NetworkCalls.addrequestgrev(params: params) { (success, response) in
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
            }
        }
    }
    
    @IBAction func addAttachments_Tapped(_ sender: Any) {
        self.showAlertActionSheet(title: "Select an image and documents", message: "", sender: sender as! UIButton)
    }
    
    @IBAction func searchBtn_Tapped(_ sender: Any) {
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
                        self.query_type_top_constraint.constant = 80
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
}
extension GrievanceNewRequestViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
                    self.mainViewHeightConstraint.constant -= self.tableViewHeightConstraint.constant
                    self.tableViewHeightConstraint.constant = 0
                    self.tableViewHeightConstraint.constant += CGFloat((self.attachmentFiles!.count * 60) + 10)
                    self.mainViewHeightConstraint.constant += self.tableViewHeightConstraint.constant
                }
            }
        }
    }
}
extension GrievanceNewRequestViewController: UITextFieldDelegate {
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
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 13 { //CASE DETAIL
            let maxLength = 200
            let currentString: NSString = textField.text as! NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        return true
    }
}


extension GrievanceNewRequestViewController: UIDocumentPickerDelegate {
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

extension GrievanceNewRequestViewController: UITableViewDataSource, UITableViewDelegate {
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
            cell.attachment_discardBtn.setBackgroundImage(UIImage(named: "checked-new"), for: .normal) //.withRenderingMode(.alwaysTemplate)
            //            cell.attachment_discardBtn.setBackgroundImage(UIImage(named: "check"), for: .normal)
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

extension GrievanceNewRequestViewController: AddNewRequestDelegate {
    func updateRequestMode(requestmode: tbl_RequestModes) {
        self.tbl_request_mode = requestmode
        self.request_mode.text = requestmode.REQ_MODE_DESC
        
        
        if requestmode.REQ_MODE_DESC == "Self" {
            self.employeeIdView.isHidden = true
        } else {
            self.employeeIdView.isHidden = false
            self.employee_id.text = ""
            self.employee_id.isUserInteractionEnabled = true
            self.searchBtn.isUserInteractionEnabled = true
        }
    }
    
    func updateMasterQuery(masterquery: tbl_MasterQuery) {
        self.tbl_masterquery = masterquery
        self.query_type.text = masterquery.MQ_DESC
    }
    
    func updateDetailQuery(detailquery: tbl_DetailQuery) {
        self.tbl_detailquery = detailquery
        self.sub_query_type.text = detailquery.DQ_DESC
    }
    
    func updateRemarks(remarks: tbl_Remarks) {}
}


extension GrievanceNewRequestViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.1) {
            self.case_detail_top_constraint.constant = 7
            self.case_detail_placeholder.font = UIFont.systemFont(ofSize: 12)
            self.view.layoutIfNeeded()
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.count <= 0 {
            UIView.animate(withDuration: 0.1) {
                self.case_detail_top_constraint.constant = 25
                self.case_detail_placeholder.font = UIFont.systemFont(ofSize: 15)
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

extension GrievanceNewRequestViewController: ConfirmationProtocol {
    func confirmationProtocol() {
        self.submitBtn.isEnabled = false
        var offline_data = tbl_Hr_Request_Logs()
        
        if request_mode.text == "Self" {
            offline_data.REQ_ID = Int(CURRENT_USER_LOGGED_IN_ID)!
        } else {
            offline_data.REQ_ID = Int(employee_id.text!)!
        }

        offline_data.SERVER_ID_PK = randomInt()
        offline_data.TICKET_DATE = getLocalCurrentDate()
        offline_data.LOGIN_ID = Int(CURRENT_USER_LOGGED_IN_ID)!
        offline_data.REQ_MODE = self.tbl_request_mode!.SERVER_ID_PK
        offline_data.MQ_ID = self.tbl_masterquery!.SERVER_ID_PK
        offline_data.DQ_ID = self.tbl_detailquery!.DQ_UNIQ_ID
        offline_data.TICKET_STATUS = "Submitted"
        offline_data.CREATED_DATE = getCurrentDate()
        offline_data.REQ_REMARKS = self.textView.text?.replacingOccurrences(of: "'", with: "''")
        offline_data.REF_ID = randomString()
        offline_data.AREA_CODE = AppDelegate.sharedInstance.db?.read_tbl_UserProfile().first?.AREA_CODE ?? self.emp_model.first?.areaCode ?? ""
        offline_data.EMP_NAME = employee_name.text!
        offline_data.MASTER_QUERY = self.tbl_masterquery!.MQ_DESC
        offline_data.DETAIL_QUERY = self.tbl_detailquery!.DQ_DESC
        offline_data.REQUEST_LOGS_SYNC_STATUS = 0
        offline_data.REQ_MODE_DESC = self.request_mode.text!
        offline_data.MODULE_ID = 2
        
        offline_data.CURRENT_USER = CURRENT_USER_LOGGED_IN_ID
        
        AppDelegate.sharedInstance.db?.dump_data_HRRequest(hrrequests: offline_data, { success in
            if success {
                print("Dump Request Log")
                DispatchQueue.main.async {
                    self.addRequesttoServer(offline_data: offline_data)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        })
    }
    func noButtonTapped() {}
}


struct AttachmentsList {
    var fileName: String
    var fileExtension: String
    var fileUrl: String
    var fileSize: String
    var fileUploadedURL: String
    var isUploaded: Bool
    var fileUploadedBy: String
    var createdOn: String
}
