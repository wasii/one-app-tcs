//
//  UpdateRequestViewController.swift
//  tcs_one_app
//
//  Created by ibs on 29/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import MobileCoreServices
import SwiftyJSON

import Alamofire
import AVFoundation
import Photos

class UpdateRequestViewController: BaseViewController {
    @IBOutlet weak var checkBtn: CustomButton!
    @IBOutlet weak var crossBtn: CustomButton!
    
    
    @IBOutlet weak var viewRequestLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: CustomView!
    @IBOutlet weak var mainViewWidthContraint: NSLayoutConstraint!
    @IBOutlet weak var reqMode: MDCOutlinedTextField!
    
    @IBOutlet weak var employeeId: MDCOutlinedTextField!
    
    @IBOutlet weak var employeeName: MDCOutlinedTextField!
    
    @IBOutlet weak var queryType: MDCOutlinedTextField!
    @IBOutlet weak var subQueryType: MDCOutlinedTextField!
    
    @IBOutlet weak var pocValue: UILabel!
    @IBOutlet weak var designationValue: UILabel!
    @IBOutlet weak var hrRemarks: MDCOutlinedTextField!
    
    @IBOutlet weak var userRemarks: MDCOutlinedTextField!
    
    @IBOutlet weak var ticketStatus: MDCOutlinedTextField!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    
    var request_log: tbl_Hr_Request_Logs?
    var ticket_id: Int?
    
    @IBOutlet weak var ticketStatusTopConstraint: NSLayoutConstraint!
    
    //HR Changes
    
    @IBOutlet weak var attachmentView: UIView!
    @IBOutlet weak var attachment_text_field: MDCOutlinedTextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var characterCounts: UILabel!
    @IBOutlet weak var maxCharacterLabel: UILabel!
    @IBOutlet weak var hrCommentsLabel: UILabel!
    @IBOutlet weak var hrCommentsTextView: UITextView!
    @IBOutlet weak var hrCommentsLabelTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var requesterCommentsTextView: UITextView!
    
    
    @IBOutlet weak var downloadBtn: CustomButton!
    
    var attachmentFiles: [AttachmentsList]?
    var picker = UIImagePickerController()
    
    var isApprovedTapped = false
    //HR Changes ENDs
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeTopCornersRounded(roundView: self.mainView)
        attachmentFiles = [AttachmentsList]()
        picker.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(navigateThroughtNotify(notification:)), name: .navigateThroughNotification, object: nil)
        if request_log == nil {
            request_log = AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: "SELECT * FROM \(db_hr_request) WHERE SERVER_ID_PK = '\(self.ticket_id ?? 0)'").first
        }
        self.mainViewHeightConstraint.constant = 1100
        
        if request_log!.TICKET_STATUS == "Rejected" || request_log!.TICKET_STATUS == "rejected" || request_log!.TICKET_STATUS == "Approved" || request_log!.TICKET_STATUS == "approved" {
            checkBtn.isHidden = true
            crossBtn.isHidden = true
            self.title = "View Request"
            self.viewRequestLabel.text = "View Request"
            self.requesterCommentsTextView.text = request_log?.REQ_CASE_DESC ?? ""
            
            //HR CHANGES
            self.attachmentView.isHidden = true
            self.mainViewHeightConstraint.constant = 970
            //HR CHANGES END
        } else {
            if request_log?.RESPONSIBLE_EMPNO == Int(CURRENT_USER_LOGGED_IN_ID) {
                self.title = "Update Request"
                self.viewRequestLabel.text = "Update Request"
                self.tableView.register(UINib(nibName: "AddAttachmentsTableCell", bundle: nil), forCellReuseIdentifier: "AddAttachmentsCell")
                self.tableView.rowHeight = 60
            } else {
                self.title = "View Request"
                self.viewRequestLabel.text = "View Request"
                self.attachmentView.isHidden = true
                self.mainViewHeightConstraint.constant = 970
            }
        }
        
        
        
        let downloadURL = Bundle.main.url(forResource: "download-fill-icon", withExtension: "svg")!
        

        
        downloadBtn.addTarget(self, action: #selector(openDownloadHistory), for: .touchUpInside)
        _ = CALayer(SVGURL: downloadURL) { (svgLayer) in
            svgLayer.resizeToFit(self.downloadBtn.bounds)
            self.downloadBtn.layer.addSublayer(svgLayer)
        }
        
        
        setupTextFields()
    }
    
    @objc func openDownloadHistory() {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "HRFilesViewController") as! HRFilesViewController
        controller.ticket_id = request_log!.SERVER_ID_PK
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func openRemarksHistory() {
        let storyboard = UIStoryboard(name: "GrievanceStoryboard", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "GrievanceRemarksHistoryViewController") as! GrievanceRemarksHistoryViewController
        
        
        controller.ticket_id = request_log!.SERVER_ID_PK
        controller.isNotHRHelpDesk = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func attachment_btn_tapped(_ sender: Any) {
        self.showAlertActionSheet(title: "Select an image and documents", message: "", sender: sender as! UIButton)
    }
    @IBAction func crossBtn_Tapped(_ sender: Any) {
        if hrRemarks.text == "" {
            self.view.makeToast("Select HR Remarks")
            return
        }
        if hrCommentsTextView.text == "" {
            self.view.makeToast("HR Comments is mandatory.")
            return
        }
        self.isApprovedTapped = false
        
        checkBtn.isEnabled = false
        crossBtn.isEnabled = false
        
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
//
    }
    @IBAction func submitBtn_Tapped(_ sender: Any) {
        if hrRemarks.text == "" {
            self.view.makeToast("Select HR Remarks")
            return
        }
        if hrCommentsTextView.text == "" {
            self.view.makeToast("HR Comments is mandatory.")
            return
        }
        self.isApprovedTapped = true
        
        checkBtn.isEnabled = false
        crossBtn.isEnabled = false
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
    
    func setupAPI(status: String) {
        let hrComments = self.hrCommentsTextView.text?.replacingOccurrences(of: "'", with: "''")
        
        
//        var ticket_files = [[String:String]]()
        for index in self.attachmentFiles! {
            if index.fileUploadedURL != "" {
//                let dictionary = [
//                    "file_url": index.fileUploadedURL,
//                    "file_extention": index.fileExtension,
//                    "file_size_kb": String(index.fileSize.split(separator: " ").first!)
//                ]
//                ticket_files.append(dictionary)
                var offline_hr_files = tbl_Files_Table()
                offline_hr_files.FILE_URL = index.fileUploadedURL
                offline_hr_files.FILE_EXTENTION = index.fileExtension
                offline_hr_files.FILE_SIZE_KB = Int(index.fileSize.split(separator: " ").first!)!
                offline_hr_files.REF_ID = self.request_log!.REF_ID!
                offline_hr_files.CREATED = self.request_log!.CREATED_DATE!
                offline_hr_files.FILE_SYNC = 0
                
                AppDelegate.sharedInstance.db?.dump_tbl_hr_files(hrfile: offline_hr_files)
            }
        }
        
        AppDelegate.sharedInstance.db?.updateTables(tableName: db_hr_request,
                        columnName: ["TICKET_STATUS", "HR_REMARKS", "REQUEST_LOGS_SYNC_STATUS", "HR_CASE_DESC"],
                        updateValue: [status,self.hrRemarks.text!, "0", hrComments ?? ""],
                        onCondition: "SERVER_ID_PK = '\(self.request_log!.SERVER_ID_PK!)'") { success in
                            if success {
                                self.navigationController?.popViewController(animated: true)
                                self.update_hr_logs(status: status)
                            }
        }
    }
    
    
    func setupTextFields() {
        mainViewWidthContraint.constant = UIScreen.main.bounds.width
        
        pocValue.text = request_log!.RESPONSIBILITY
        designationValue.text = request_log!.PERSON_DESIG
        
        reqMode.label.textColor = UIColor.nativeRedColor()
        reqMode.label.text = "*Request Modes"
        reqMode.placeholder = "\(request_log!.REQ_MODE_DESC ?? "")"
        reqMode.text = "\(request_log!.REQ_MODE_DESC ?? "")"
        reqMode.setOutlineColor(UIColor.nativeRedColor(), for: .normal)

        
        employeeId.label.textColor = UIColor.nativeRedColor()
        employeeId.label.text = "Employee ID"
        employeeId.placeholder = "\(request_log!.REQ_ID ?? 0)"
        employeeId.text = "\(request_log!.REQ_ID ?? 0)"
        employeeId.setOutlineColor(UIColor.nativeRedColor(), for: .normal)

        
        employeeName.label.textColor = UIColor.nativeRedColor()
        employeeName.label.text = "Employee Name"
        employeeName.placeholder = "\(request_log!.EMP_NAME!)"
        employeeName.text = "\(request_log!.EMP_NAME!)"
        employeeName.setOutlineColor(UIColor.nativeRedColor(), for: .normal)

        
        queryType.label.textColor = UIColor.nativeRedColor()
        queryType.label.text = "*Query Type"
        queryType.placeholder = "\(request_log!.MASTER_QUERY!)"
        queryType.text = "\(request_log!.MASTER_QUERY!)"
        queryType.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        
        
        
        subQueryType.label.textColor = UIColor.nativeRedColor()
        subQueryType.label.text = "*Sub Query Type"
        subQueryType.placeholder = "\(request_log!.DETAIL_QUERY!)"
        subQueryType.text = "\(request_log!.DETAIL_QUERY!)"
        subQueryType.setOutlineColor(UIColor.nativeRedColor(), for: .normal)

        
        userRemarks.label.textColor = UIColor.nativeRedColor()
        userRemarks.label.text = "*User Remarks"
        userRemarks.placeholder = "\(request_log!.REQ_REMARKS!)"
        userRemarks.text = "\(request_log!.REQ_REMARKS!)"
        userRemarks.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        
        ticketStatus.label.textColor = UIColor.nativeRedColor()
        ticketStatus.label.text = "Status"
        
        if request_log!.TICKET_STATUS == "Approved" {
            ticketStatus.placeholder = "Completed"
            ticketStatus.text = "Completed"
        } else {
            ticketStatus.placeholder = "\(request_log!.TICKET_STATUS!)"
            ticketStatus.text = "\(request_log!.TICKET_STATUS!)"
        }
        
        ticketStatus.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        ticketStatus.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        ticketStatus.isUserInteractionEnabled = false
        
        if request_log?.REQ_CASE_DESC == "@null" {
            self.requesterCommentsTextView.text = ""
        } else {
            self.requesterCommentsTextView.text = request_log?.REQ_CASE_DESC ?? ""
        }
        
        if request_log!.HR_REMARKS == nil || request_log!.HR_REMARKS == "" {
            hrRemarks.isUserInteractionEnabled = true
            hrCommentsTextView.delegate = self
        } else {
            hrRemarks.isUserInteractionEnabled = false
            hrRemarks.text = "\(request_log!.REQ_REMARKS!)"
            
            hrCommentsTextView.text = request_log?.HR_CASE_DESC ?? ""
            hrCommentsTextView.isUserInteractionEnabled = true
            hrCommentsTextView.isEditable = false
            maxCharacterLabel.isHidden = true
            characterCounts.isHidden = true
            
            self.hrCommentsLabelTopConstraint.constant = 7
            self.hrCommentsLabel.font = UIFont.systemFont(ofSize: 11)
        }
        hrRemarks.label.textColor = UIColor.nativeRedColor()
        hrRemarks.label.text = "*HR Remarks"
        hrRemarks.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        hrRemarks.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        hrRemarks.delegate = self
        
        
        attachment_text_field.textColor = UIColor.nativeRedColor()
        attachment_text_field.text = "choose files"
        attachment_text_field.label.text = "Attachments"
        attachment_text_field.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        attachment_text_field.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
    }
}


extension UpdateRequestViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 10 {
            let storyboard = UIStoryboard(name: "Popups", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestListingViewController") as! NewRequestListingViewController
            
            controller.remarks = AppDelegate.sharedInstance.db?.read_tbl_Remarks(mq_id: self.request_log!.MQ_ID!,
                                                      dq_id: self.request_log!.DQ_ID!,
                                                      remarks_type: "HR_REMARKS")
            controller.heading = "HR Remarks"
            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .overFullScreen
            }
            controller.modalTransitionStyle = .crossDissolve
            controller.delegate = self
            Helper.topMostController().present(controller, animated: true, completion: nil)
            
            return false
        }
        return false
    }
}

extension UpdateRequestViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.1) {
            self.hrCommentsLabelTopConstraint.constant = 7
            self.hrCommentsLabel.font = UIFont.systemFont(ofSize: 11)
            self.view.layoutIfNeeded()
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.count <= 0 {
            UIView.animate(withDuration: 0.1) {
                self.hrCommentsLabelTopConstraint.constant = 25
                self.hrCommentsLabel.font = UIFont.systemFont(ofSize: 14)
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
            self.characterCounts.text = "\(newString.length)/525"
            return true
        }
        return false
    }
}


extension UpdateRequestViewController: AddNewRequestDelegate {
    func updateRequestMode(requestmode: tbl_RequestModes) {}
    func updateMasterQuery(masterquery: tbl_MasterQuery) {}
    func updateDetailQuery(detailquery: tbl_DetailQuery) {}
    
    func updateRemarks(remarks: tbl_Remarks) {
        self.hrRemarks.text = remarks.HR_REMARKS
    }
}



extension UpdateRequestViewController: UITableViewDataSource, UITableViewDelegate {
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


extension UpdateRequestViewController: UIDocumentPickerDelegate {
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
                        UIView.animate(withDuration: 0.4) {
                            self.mainViewHeightConstraint.constant += self.tableViewHeightConstraint.constant
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
extension UpdateRequestViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        picker.dismiss(animated: true) {
//            Helper.topMostController().view.makeToastActivity(.center)
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
                    UIView.animate(withDuration: 0.4) {
                        self.mainViewHeightConstraint.constant += self.tableViewHeightConstraint.constant
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
    }
}



extension UpdateRequestViewController {
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
}


extension UpdateRequestViewController: ConfirmationProtocol {
    func confirmationProtocol() {
        if self.isApprovedTapped {
            self.setupAPI(status: "approved")
        } else {
            self.setupAPI(status: "rejected")
        }
    }
    func noButtonTapped() {
        checkBtn.isEnabled = true
        crossBtn.isEnabled = true
    }
}
