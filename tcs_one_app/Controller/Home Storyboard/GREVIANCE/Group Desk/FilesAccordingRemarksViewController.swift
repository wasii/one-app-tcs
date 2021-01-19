//
//  FilesAccordingRemarksViewController.swift
//  tcs_one_app
//
//  Created by TCS on 16/01/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import Alamofire
import QuickLook

class FilesAccordingRemarksViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    var grem_id: Int?
    var fileAttachments: [AttachmentsList]?
    var fileDownloadedURL: URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Downloads"
        
        self.makeTopCornersRounded(roundView: self.mainView)
        self.tableView.register(UINib(nibName: "GrievacneDownloadsTableCell", bundle: nil), forCellReuseIdentifier: "GrievacneDownloadsCell")
        self.tableView.rowHeight = 60
        
        // Do any additional setup after loading the view.
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
        
        let query = "SELECT * from  \(db_files) WHERE GREM_ID = '\(self.grem_id!)'"
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
        
        fileAttachments = fileAttachments?.sorted(by: { (list1, list2) -> Bool in
            list1.createdOn < list2.createdOn
        })
        handler(true, fileAttachments!.count)
    }
}


extension FilesAccordingRemarksViewController: UITableViewDelegate, UITableViewDataSource {
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

extension FilesAccordingRemarksViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return fileDownloadedURL! as QLPreviewItem
    }
}
