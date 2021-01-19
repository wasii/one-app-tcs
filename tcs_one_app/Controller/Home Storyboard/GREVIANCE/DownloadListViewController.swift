//
//  DownloadListViewController.swift
//  tcs_one_app
//
//  Created by TCS on 16/11/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import Alamofire
import QuickLook

class DownloadListViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    
    var ref_id: Int?
    var fileAttachments: [AttachmentsList]?
    var user_permission = [tbl_UserPermission]()
    var isInitiator = false
    
    var permission_submitted        = 0
    var permission_inprogress_er    = 0
    var permission_inprogress_s     = 0
    var permission_responded        = 0
    var permission_investigating    = 0
    
    var permission_counter          = 0
    
    var user_permissions = [tbl_UserPermission]()
    
    var fileDownloadedURL: URL?
    var ticket_status = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Downloads"
        NotificationCenter.default.addObserver(self, selector: #selector(upload_pending_request), name: .networkRefreshed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigateThroughtNotify(notification:)), name: .navigateThroughNotification, object: nil)
        self.makeTopCornersRounded(roundView: self.mainView)
        self.tableView.register(UINib(nibName: "GrievacneDownloadsTableCell", bundle: nil), forCellReuseIdentifier: "GrievacneDownloadsCell")
        self.tableView.rowHeight = 60
        
        permission_submitted = AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: PERMISSION_GRIEVANCE_SUBMITTED).count
        permission_inprogress_s = AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: PERMISSION_INPROGRESS_S).count
        permission_inprogress_er = AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: PERMISSION_INPROGRESS_ER).count
        permission_responded = AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: PERMISSION_GRIEVANCE_RESPONDED).count
        permission_investigating = AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: PERMISSION_INVESTIGATING).count
        permission_counter = permission_submitted + permission_inprogress_er + permission_inprogress_s + permission_responded + permission_investigating
        
        setupAttachments { success, count in
            if success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    let height = CGFloat((60 * count) + 100)
                    self.tableView.reloadData()
                    switch UIDevice().type {
                    case .iPhone5, .iPhone5S, .iPhone5C, .iPhoneSE:
                        if height > 570 {
                            self.mainViewHeightConstraint.constant = height
                        } else {
                            self.mainViewHeightConstraint.constant = 570
                        }
                        break
                    case .iPhone6, .iPhone6S, .iPhone7, .iPhone8:
                        if height > 670 {
                            self.mainViewHeightConstraint.constant = height
                        } else {
                            self.mainViewHeightConstraint.constant = 670
                        }
                    case .iPhone6Plus, .iPhone7Plus, .iPhone8Plus:
                        if height > 740 {
                            self.mainViewHeightConstraint.constant = height
                        } else {
                            self.mainViewHeightConstraint.constant = 740
                        }
                        break
                    case .iPhoneX, .iPhoneXR, .iPhoneXS, .iPhone11Pro:
                        if height > 790 {
                            self.mainViewHeightConstraint.constant = height
                        } else {
                            self.mainViewHeightConstraint.constant = 790
                        }
                    case .iPhone11, .iPhoneXSMax, .iPhone11ProMax:
                        if height > 840 {
                            self.mainViewHeightConstraint.constant = height
                        } else {
                            self.mainViewHeightConstraint.constant = 840
                        }
                        break
                        
                    case .iPhone12Mini:
                        if height > 770 {
                            self.mainViewHeightConstraint.constant = height
                        } else {
                            self.mainViewHeightConstraint.constant = 770
                        }
                    default:
                        break
                    }
                }
            }
        }
    }
    
    func setupAttachments(_ handler: @escaping(_ success: Bool, _ count: Int)-> Void) {
        
        let query = "SELECT * from  \(db_files) WHERE TICKET_ID = '\(self.ref_id!)'"
        let attachments = AppDelegate.sharedInstance.db?.read_tbl_hr_files(query: query)
        fileAttachments = [AttachmentsList]()
        for file in attachments! {
            if file.FILE_URL != "" {
                let fileName = String(file.FILE_URL.split(separator: "/").last!)
                fileAttachments?.append(AttachmentsList(fileName: fileName,
                                                        fileExtension: file.FILE_EXTENTION,
                                                        fileUrl: file.FILE_URL,
                                                        fileSize: "\(file.FILE_SIZE_KB)",
                                                        fileUploadedURL: "",
                                                        isUploaded: true,
                                                        fileUploadedBy: file.FILE_UPLOADED_BY,
                                                        createdOn: file.CREATED))
            }
        }
        if permission_counter == 0 {
            fileAttachments = fileAttachments?.filter({ (AttachmentsList) -> Bool in
                AttachmentsList.fileUploadedBy == "Initiator"
            })
            
            fileAttachments = fileAttachments?.sorted(by: { (list1, list2) -> Bool in
                list1.createdOn < list2.createdOn
            })
            
            handler(true, fileAttachments!.count)
        } else {
            var temp_files = [AttachmentsList]()
            let temp = fileAttachments
            if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: PERMISSION_Grievance_initiator_files).count > 0 {
                fileAttachments = temp?.filter({ (AttachmentsList) -> Bool in
                    AttachmentsList.fileUploadedBy == "Initiator"
                })
                for file in fileAttachments! {
                    temp_files.append(file)
                }
            }
            if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: PERMISSION_Grievance_ermanager_files).count > 0 {
                fileAttachments = temp?.filter({ (AttachmentsList) -> Bool in
                    AttachmentsList.fileUploadedBy == "Er-Manager"
                })
                for file in fileAttachments! {
                    temp_files.append(file)
                }
            }
            if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: PERMISSION_Grievance_erofficerr_files).count > 0 {
                fileAttachments = temp?.filter({ (AttachmentsList) -> Bool in
                    AttachmentsList.fileUploadedBy == "Er-Officer"
                })
                for file in fileAttachments! {
                    temp_files.append(file)
                }
            }
            if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: PERMISSION_Grievance_security_files).count > 0 {
                fileAttachments = temp?.filter({ (AttachmentsList) -> Bool in
                    AttachmentsList.fileUploadedBy == "Security"
                })
                for file in fileAttachments! {
                    temp_files.append(file)
                }
            }
            if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: PERMISSION_Grievance_hrbp_files).count > 0 {
                fileAttachments = temp?.filter({ (AttachmentsList) -> Bool in
                    AttachmentsList.fileUploadedBy == "HRBP"
                })
                for file in fileAttachments! {
                    temp_files.append(file)
                }
            }
            if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: PERMISSION_Grievance_srhrbp_files).count > 0 {
                fileAttachments = temp?.filter({ (AttachmentsList) -> Bool in
                    AttachmentsList.fileUploadedBy == "Senior-HRBP"
                })
                for file in fileAttachments! {
                    temp_files.append(file)
                }
            }
            if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: PERMISSION_Grievance_ceo_files).count > 0 {
                fileAttachments = temp?.filter({ (AttachmentsList) -> Bool in
                    AttachmentsList.fileUploadedBy == "CEO"
                })
                for file in fileAttachments! {
                    temp_files.append(file)
                }
            }
            
            temp_files = temp_files.sorted(by: { (list1, list2) -> Bool in
                list1.createdOn < list2.createdOn
            })
            
            fileAttachments = temp_files

            handler(true, fileAttachments!.count)
        }
        
    }
}


extension DownloadListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.fileAttachments?.count {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GrievacneDownloadsCell") as! GrievacneDownloadsTableCell
        let data = self.fileAttachments![indexPath.row]
        
        cell.fileName.text = data.fileName
        cell.uploadedBy.text = data.fileUploadedBy
        
        let fileSize = Double(data.fileSize)
        
        cell.fileSize.text = String(format: "(%.4f MB)", (fileSize! / 1024))
        
        cell.downloadBtn.tag = indexPath.row
        cell.downloadBtn.addTarget(self, action: #selector(downloadFile(sender:)), for: .touchUpInside)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func downloadFile(sender: UIButton) {
        
        self.freezeScreen()
        self.view.makeToastActivity(.center)
        let fileUrl = self.fileAttachments![sender.tag].fileUrl
        let fileName = String(fileUrl.split(separator: "/").last!)
        
        let url = URL(string: fileUrl)

        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath =  documentsURL.appendingPathComponent("One App").appendingPathComponent(fileName)
        if fileManager.fileExists(atPath: filePath.path) {
            self.showPreview(url: filePath)
        } else {
            Downloader.load(url: url!, fileName: fileName) { (success, response) in
                if success {
                    self.showPreview(url: URL(string: "\(response)")!)
                } else {
                    self.unFreezeScreen()
                    self.view.hideToastActivity()
                    self.view.makeToast("\(response)")
                }
            }
        }
    }
    
    func showPreview(url: URL) {
        DispatchQueue.main.async {
            self.unFreezeScreen()
            self.view.hideToastActivity()
            self.fileDownloadedURL = url
            let previewController = QLPreviewController()
            previewController.dataSource = self
            self.present(previewController, animated: true) {
                UIApplication.shared.statusBarStyle = .default
            }
        }
    }
}

class Downloader {
    class func load(url: URL, fileName: String, _ handler: @escaping(_ success: Bool, _ url: Any)-> Void) {
            
        Alamofire.request(url).downloadProgress(closure : { (progress) in
            print("\(progress.fractionCompleted)")
        }).responseData{ (response) in
            print(response)
            if let data = response.result.value {
                let fileManager = FileManager.default
                let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                let filePath =  documentsURL.appendingPathComponent("One App")
                do {
                    if !fileManager.fileExists(atPath: filePath.path) {
                        try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                        try data.write(to: filePath.appendingPathComponent(fileName))
                        
                        handler(true, filePath.appendingPathComponent(fileName))
                    } else {
                        try data.write(to: filePath.appendingPathComponent(fileName))
                        handler(true, filePath.appendingPathComponent(fileName))
                    }
                } catch let error {
                    handler(false, "Couldn't download the file")
                    print("Something went wrong!: \(error.localizedDescription)")
                }
            } else {
                handler(false, "Couldn't download the file")
            }
        }
    }
}


extension DownloadListViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return fileDownloadedURL! as QLPreviewItem
    }
}
