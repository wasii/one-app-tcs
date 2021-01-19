//
//  GrievanceViewClosedRequestViewController.swift
//  tcs_one_app
//
//  Created by TCS on 16/11/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import QuickLook
import TPPDF

class GrievanceViewClosedRequestViewController: BaseViewController {

    @IBOutlet weak var memoCreationBtn: UIButton!
    @IBOutlet weak var employeeIdView: UIView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var request_mode: MDCOutlinedTextField!
    @IBOutlet weak var employee_id: MDCOutlinedTextField!
    @IBOutlet weak var employee_name: MDCOutlinedTextField!
    @IBOutlet weak var query_type: MDCOutlinedTextField!
    @IBOutlet weak var sub_query_type: MDCOutlinedTextField!
    @IBOutlet weak var case_detail: MDCOutlinedTextField!
    @IBOutlet weak var status: MDCOutlinedTextField!
    
    @IBOutlet weak var downloadBtn: CustomButton!
    @IBOutlet weak var historyBtn: CustomButton!
    
    @IBOutlet weak var closure_remarks_label: UILabel!
    @IBOutlet weak var closure_remarks_view: UIView!
    @IBOutlet weak var closure_remarks_textview: UITextView!
    @IBOutlet weak var closure_remarks_height_constraint: NSLayoutConstraint!
    
    
    var ticket_id: Int?
    var request_logs: tbl_Hr_Request_Logs?
    
    @IBOutlet weak var textView: UITextView!
    var history_permission  = 0
    var download_permission = 0
    var fileDownloadedURL : URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "View Request"
        self.makeTopCornersRounded(roundView: self.mainView)
        memoCreationBtn.isHidden = true
        if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: PERMISSION_GRIEVANCE_MEMO).count > 0 {
            memoCreationBtn.isHidden = false
        }

        
        setupViewHeight()
        setupTextFields()
        
        NotificationCenter.default.addObserver(self, selector: #selector(upload_pending_request), name: .networkRefreshed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigateThroughtNotify(notification:)), name: .navigateThroughNotification, object: nil)
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
        
        if ticket_id != nil {
            request_logs = AppDelegate.sharedInstance.db?.read_tbl_hr_request(ticketId: self.ticket_id!).first
            
            request_mode.text = request_logs?.REQ_MODE_DESC ?? ""
            if request_mode.text == "Self" {
                employeeIdView.isHidden = false
            } else {
                employeeIdView.isHidden = false
            }
            employee_id.text = "\(request_logs?.REQ_ID ?? 0)"
            employee_name.text = request_logs?.EMP_NAME ?? ""
            query_type.text = request_logs?.MASTER_QUERY ?? ""
            sub_query_type.text = request_logs?.DETAIL_QUERY ?? ""

            textView.text = request_logs?.REQ_REMARKS ?? ""
            status.text = request_logs?.TICKET_STATUS ?? ""
            
            if request_logs?.TICKET_STATUS ?? "" == "Submitted" {
                status.text = "Submitted"
                closure_remarks_view.isHidden = true
                self.closure_remarks_label.isHidden = true
            } else if request_logs?.TICKET_STATUS ?? "" == "Closed" {
                status.text = "Closed"
                closure_remarks_view.isHidden = false
                let query = "SELECT HR_REMARKS FROM \(db_hr_request) WHERE SERVER_ID_PK = '\(ticket_id!)'"
                if let cr = AppDelegate.sharedInstance.db?.read_column(query: query) {
                    self.closure_remarks_label.isHidden = false
                    self.closure_remarks_textview.text = "\(cr)"
                    
                    self.mainViewHeightConstraint.constant += 120
                }
            } else {
                closure_remarks_view.isHidden = true
                self.closure_remarks_label.isHidden = true
                //HR CHANGES END
//                status.text = INREVIEW
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
                        
                        default:
                            break
                        }
                    } else {
                        status.text = INREVIEW
                    }
                }
                //HR CHANGES END
            }
            
            request_mode.isUserInteractionEnabled = false
            employee_id.isUserInteractionEnabled = false
            employee_name.isUserInteractionEnabled = false
            query_type.isUserInteractionEnabled = false
            sub_query_type.isUserInteractionEnabled = false
//            case_detail.isUserInteractionEnabled = false
            textView.isEditable = false
            status.isUserInteractionEnabled = false
            
            history_permission = AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: PERMISSION_GRIEVANCE_HISTORY).count
            
            if history_permission > 0 {
                self.historyBtn.isHidden = false
            }
        }
    }
    
    func setupViewHeight() {
        switch UIDevice().type {
        case .iPhone5, .iPhone5S, .iPhone5C, .iPhoneSE:
            self.mainViewHeightConstraint.constant = 565
            break
        case .iPhone6, .iPhone6S, .iPhone7, .iPhone8, .iPhoneSE2:
            self.mainViewHeightConstraint.constant = 670
            break
        case .iPhone6Plus, .iPhone7Plus, .iPhone8Plus:
            self.mainViewHeightConstraint.constant = 735
            break
        case .iPhoneX, .iPhoneXR, .iPhoneXS, .iPhone11Pro, .iPhone12, .iPhone12Pro:
            self.mainViewHeightConstraint.constant = 800
            break
        case .iPhone11, .iPhoneXSMax, .iPhone11ProMax:
            self.mainViewHeightConstraint.constant = 850
            break
        case .iPhone12ProMax:
            self.mainViewHeightConstraint.constant = 880
            break
        case .iPhone12Mini:
            self.mainViewHeightConstraint.constant = 770
        default:
            break
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
        
//        case_detail.label.textColor = UIColor.nativeRedColor()
//        case_detail.label.text = "Case Detail"
//        case_detail.label.numberOfLines = 0
//        case_detail.placeholder = ""
//        case_detail.inputView?.frame.size.height = 80.0
//        case_detail.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
//        case_detail.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
//        case_detail.delegate = self
        
        status.label.textColor = UIColor.nativeRedColor()
        status.label.text = "Status"
        status.placeholder = ""
        status.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        status.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        status.delegate = self
        
    }
    
    @IBAction func memoCreationBtn_Tapped(_ sender: Any) {
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
                    if FileManager.default.fileExists(atPath: fileUrl!.path) {
                        try FileManager.default.removeItem(atPath: fileUrl!.path)
                    }
                    try FileManager.default.copyItem(atPath: tempURL.path , toPath: fileUrl!.path)
                } else {
                    try FileManager.default.copyItem(atPath: tempURL.path , toPath: fileUrl!.path)
                }
                
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
    @IBAction func searchBtn_Tapped(_ sender: Any) {
    }
    @IBAction func downloadBtnTapped(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DownloadListViewController") as! DownloadListViewController
        controller.ref_id = self.request_logs!.SERVER_ID_PK
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func historyBtnTapped(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "GrievanceRemarksHistoryViewController") as! GrievanceRemarksHistoryViewController
        controller.ticket_id = self.request_logs!.SERVER_ID_PK
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
}


extension GrievanceViewClosedRequestViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
}




extension GrievanceViewClosedRequestViewController {
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
        
        let table = PDFTable(rows: 9, columns: 2)
        
        table.content = [
            ["Reqeust Mode", "\(self.request_logs?.REQ_MODE_DESC ?? "")"],
            ["Employee Name", "\(self.request_logs?.EMP_NAME ?? "")"],
            ["Ticket Status", "\(self.status.text!)"],
            ["Query Type", "\(self.request_logs?.MASTER_QUERY ?? "")"],
            ["Employee Id", "\(self.request_logs?.REQ_ID ?? 0)"],
            ["Sub Query", "\(self.request_logs?.DETAIL_QUERY ?? "")"],
            ["Ticket Date", "\(self.request_logs?.CREATED_DATE?.dateSeperateWithT ?? "")"],
            ["Case Detail" , "\(self.request_logs?.REQ_REMARKS ?? "")"],
            ["Closure Remarks" , "\(self.request_logs?.HR_REMARKS ?? "")"]
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
            
            let tbl = PDFTable(rows: 5, columns: 2)
            tbl.style = style
            tbl.rows.allRowsAlignment = [.left, .left]
            tbl.widths = [0.35, 0.65]
            tbl.padding = 2.0
            tbl.content = [
                ["EMPLOYEE ID", "\(hist.EMPL_NO)"],
                ["GREM ID", "\(hist.SERVER_ID_PK)"],
                ["REMARKS INPUT", "\(hist.REMARKS_INPUT)"],
                ["REMARKS", "\(hist.REMARKS)"],
                ["TICKET STATUS", s]
            ]
            document.add(table: tbl)
            document.add(space: 15.0)
        }
        document.add(space: 30.0)
        document.addLineSeparator(style: .init(type: .full, color: .black, width: 1, radius: nil))
        document.add(space: 100.0)
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


extension GrievanceViewClosedRequestViewController : QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return fileDownloadedURL! as QLPreviewItem
    }
}
