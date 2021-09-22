//
//  WalletDetailsViewController.swift
//  tcs_one_app
//
//  Created by TCS on 16/06/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import SwiftyJSON
import QuickLook
import TPPDF

class WalletDetailsViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var thisWeekBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    
    //MARK: Variables
    var fileDownloadedURL : URL?
    var selected_query: String?
    var numberOfDays = 7
    
    var indexPath: IndexPath?
    var startday: String?
    var endday: String?
    
    var points: Int = 0
    var tbl_details: [tbl_wallet_listing]?
    var temp_data: [tbl_wallet_listing]?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallet"
        self.thisWeekBtn.setTitle(selected_query!, for: .normal)
        self.makeTopCornersRounded(roundView: self.mainView)
        addDoubleNavigationButtons()
        
        searchTextField.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(upload_pending_request), name: .networkRefreshed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshedView(notification:)), name: .refreshedViews, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigateThroughtNotify(notification:)), name: .navigateThroughNotification, object: nil)
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
        setupJSON(numberOfDays: self.numberOfDays, startday: self.startday, endday: self.endday)
    }
    @objc func refreshedView(notification: Notification) {
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
        self.setupJSON(numberOfDays: numberOfDays, startday: startday, endday: endday)
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupJSON(numberOfDays: Int, startday: String?, endday: String?) {
        var previousDate = Date()// getPreviousDays(days: -numberOfDays)
        var weekly = String()
        var query = ""
        
        
        if startday == nil && endday == nil {
            previousDate = getPreviousDays(days: -numberOfDays)
            weekly = previousDate.convertDateToString(date: previousDate)
            
            query = "select EMPLOYEE_ID,SUM(TOTAL_SHIPMENT) as cn,(SELECT HEADER_NAME from WALLET_MASTER_DETAILS where HEADER_ID = CAT) as category,CAT as category_id,SUB_CAT as subcategory_id, (SELECT CODE_DESCRIPTION from WALLET_QUERY_DETAILS where HEADER_ID = CAT AND INC_ID = SUB_CAT) as sub_cat_name , SUM(MATURE_POINTS) as MATURE_POINTS, SUM(UN_MATURE_POINTS) as UN_MATURE_POINTS  from WALLET_POINT_SUMMARY_DETAILS where EMPLOYEE_ID = '\(CURRENT_USER_LOGGED_IN_ID)' AND (TRANSACTION_DATE BETWEEN '\(weekly)' AND '\(getLocalCurrentDate())') GROUP BY CAT"
            
        } else {
            query = "select EMPLOYEE_ID,SUM(TOTAL_SHIPMENT) as cn,(SELECT HEADER_NAME from WALLET_MASTER_DETAILS where HEADER_ID = CAT) as category,CAT as category_id,SUB_CAT as subcategory_id, (SELECT CODE_DESCRIPTION from WALLET_QUERY_DETAILS where HEADER_ID = CAT AND INC_ID = SUB_CAT) as sub_cat_name , SUM(MATURE_POINTS) as MATURE_POINTS, SUM(UN_MATURE_POINTS) as UN_MATURE_POINTS  from WALLET_POINT_SUMMARY_DETAILS where EMPLOYEE_ID = '\(CURRENT_USER_LOGGED_IN_ID)' AND (TRANSACTION_DATE BETWEEN '\(startday!)' AND '\(endday!)') GROUP BY CAT"
            
            self.thisWeekBtn.setTitle("\(startday!.dateOnly) TO \(endday!.dateOnly)", for: .normal)
        }
        
        print(query)
        self.tbl_details = AppDelegate.sharedInstance.db?.read_tbl_wallet_master_and_summary_detail(query: query)
        
        if points == 1 {
            self.tbl_details = self.tbl_details?.filter({ details in
                details.MATURE_POINTS != 0
            })
        } else {
            self.tbl_details = self.tbl_details?.filter({ details in
                details.UNMATURE_POINTS != 0
            })
        }
        self.temp_data = self.tbl_details
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.setupTableViewHeight()
        }
    }
    func setupTableViewHeight() {
        var height: CGFloat = 0.0
        if let count = self.tbl_details?.count {
            height = CGFloat((count * 70) + 150)
        }
        self.mainViewHeightConstraint.constant = 280
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
        case .iPhoneX, .iPhoneXR, .iPhoneXS, .iPhone11Pro, .iPhone12, .iPhone12Pro:
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
        case .iPhone12ProMax:
            if height > 880 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 880
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
    
    @IBAction func thisWeekBtnTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Popups", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "FilterDataPopupViewController") as! FilterDataPopupViewController
        
        if self.selected_query == "Custom Selection" {
            controller.fromdate = self.startday
            controller.todate   = self.endday
        }
        controller.selected_query = self.selected_query
        controller.delegate = self
        controller.modalTransitionStyle = .crossDissolve
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        
        Helper.topMostController().present(controller, animated: true, completion: nil)
    }
}


extension WalletDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.tbl_details?.count {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WalletListingTableCell") as? WalletListingTableCell else {
            fatalError()
        }
        if let points_data = self.tbl_details {
            cell.categoryLabel.text = points_data[indexPath.row].CATEGORY_NAME
            if points == 1 {
                cell.pointsLabel.text = "\(points_data[indexPath.row].MATURE_POINTS)"
            } else {
                cell.pointsLabel.text = "\(points_data[indexPath.row].UNMATURE_POINTS)"
            }
            cell.dateLabel.text = ""
            cell.pdfButton.tag = indexPath.row
            cell.pdfButton.addTarget(self, action: #selector(OpenPDFTapped(sender:)), for: .touchUpInside)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    @objc func OpenPDFTapped(sender: UIButton) {
        if !CustomReachability.isConnectedNetwork() {
            self.view.makeToast(NOINTERNETCONNECTION)
            return
        }
        self.view.makeToastActivity(.center)
        self.freezeScreen()
        var previousDate = Date()// getPreviousDays(days: -numberOfDays)
        var weekly = String()
        var request_body = [String:Any]()
        if startday == nil && endday == nil {
            previousDate = getPreviousDays(days: -numberOfDays)
            weekly = previousDate.convertDateToString(date: previousDate)
            
            
            request_body = [
                "p_employee_id": CURRENT_USER_LOGGED_IN_ID,
                "p_from_date": weekly.dateOnly,
                "p_to_date": getLocalCurrentDate().dateOnly,
                "p_category": self.tbl_details![sender.tag].CATEGORY_ID
            ]
            
        } else {
            request_body = [
                "p_employee_id": CURRENT_USER_LOGGED_IN_ID,
                "p_from_date": startday!.dateOnly,
                "p_to_date": endday!.dateOnly,
                "p_category": self.tbl_details![sender.tag].CATEGORY_ID
            ]
        }
        let params = self.getAPIParameter(service_name: S_WALLET_POINTS_DETAILS, request_body: request_body)
        NetworkCalls.getwalletdetailpoints(params: params) { granted, response in
            if granted {
                let data = JSON(response)
                if let walletDetailPoints = data.dictionary?[_walletDetailPoints] {
                    if let _pointsDetail = walletDetailPoints[_pointsDetail].array {
                        AppDelegate.sharedInstance.db?.deleteAll(tableName: db_w_detail_point, handler: { _ in
                            for pointdetail in _pointsDetail {
                                do {
                                    let dictionary = try pointdetail.rawData()
                                    let detail: PointsDetail = try JSONDecoder().decode(PointsDetail.self, from: dictionary)
                                    
                                    AppDelegate.sharedInstance.db?.insert_tbl_wallet_detail_point(points_detail: detail, handler: { _ in })
                                    
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
                            self.generatePdf()
                        })
                    } else {
                        DispatchQueue.main.async {
                            self.unFreezeScreen()
                            self.view.makeToast(SOMETHINGWENTWRONG)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.unFreezeScreen()
                        self.view.makeToast(SOMETHINGWENTWRONG)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.unFreezeScreen()
                    self.view.makeToast(SOMETHINGWENTWRONG)
                }
            }
        }
    }
    
    private func generatePdf() {
        if var point = AppDelegate.sharedInstance.db?.read_tbl_wallet_detail_point(query: "SELECT * FROM \(db_w_detail_point)") {
            
            var filteredPoints: [tbl_wallet_detail_points]?
            if points == 1 {
                filteredPoints = point.filter({ p in
                    p.IS_MATURE == 1
                })
            } else {
                filteredPoints = point.filter({ p in
                    p.IS_MATURE == 0
                })
            }
            filteredPoints = filteredPoints?.sorted(by: { one, two in
                one.TRANSACTION_DATE < two.TRANSACTION_DATE
            })
            
            let document = PDFDocument(format: .a4)
            
            let headerTable = PDFTable(rows: 1, columns: 1)
            headerTable.content = [
                ["TCS One App - Wallet"]
            ]
            let headerStyle = PDFTableStyleDefaults.simple
            let headerPDFCellStyle = PDFTableCellStyle(
                colors: (
                    fill: UIColor.nativeRedColor(), text: .white),
                borders: PDFTableCellBorders(left: PDFLineStyle(type: .full),
                                             top: PDFLineStyle(type: .full),
                                             right: PDFLineStyle(type: .full),
                                             bottom: PDFLineStyle(type: .full)),
                font: Font.systemFont(ofSize: 29))
            
            
            headerStyle.columnHeaderCount = 0
            headerStyle.alternatingContentStyle = headerPDFCellStyle
            headerStyle.contentStyle = headerPDFCellStyle
            headerStyle.rowHeaderStyle = headerPDFCellStyle
            
            
            headerTable.rows.allRowsAlignment = [.center]
            headerTable.widths = [1]
            headerTable.style = headerStyle
            headerTable.padding = 2.0

            document.add(table: headerTable)
            
            let subHeader = PDFTable(rows: 1, columns: 5)
            subHeader.content = [
                ["Consignment #", "Date", "Category", "Sub-Category", "Points"]
            ]
            let subHeaderStyle = PDFTableStyleDefaults.simple
            let subHeaderPDFCellStyle = PDFTableCellStyle(
                colors: (
                    fill: .darkGray, text: .white),
                borders: PDFTableCellBorders(left: PDFLineStyle(type: .full),
                                             top: PDFLineStyle(type: .full),
                                             right: PDFLineStyle(type: .full),
                                             bottom: PDFLineStyle(type: .full)),
                font: Font.systemFont(ofSize: 12))
            subHeaderStyle.columnHeaderCount = 0
            subHeaderStyle.alternatingContentStyle = subHeaderPDFCellStyle
            subHeaderStyle.contentStyle = subHeaderPDFCellStyle
            subHeaderStyle.rowHeaderStyle = subHeaderPDFCellStyle
            
            subHeader.rows.allRowsAlignment = [.center, .center, .center, .center, .center]
            subHeader.widths = [0.2, 0.2, 0.2, 0.2, 0.2]
            subHeader.style = subHeaderStyle
            subHeader.padding = 2.0

            document.add(table: subHeader)
            point.sort { s1, s2 in
                s1.TRANSACTION_DATE > s2.TRANSACTION_DATE
            }
            if let fp = filteredPoints {
                for p in fp {
                    let subCat = AppDelegate.sharedInstance.db?.read_column(query: "SELECT CODE_DESCRIPTION FROM WALLET_QUERY_DETAILS AS WQD JOIN WALLET_MASTER_DETAILS AS WMD ON  WQD.HEADER_ID = WMD.HEADER_ID WHERE WQD.INC_ID = '\(p.SUB_CAT)'") as? String
                    let cat = AppDelegate.sharedInstance.db?.read_column(query: "SELECT HEADER_NAME FROM WALLET_QUERY_DETAILS AS WQD JOIN WALLET_MASTER_DETAILS AS WMD ON  WQD.HEADER_ID = WMD.HEADER_ID WHERE WQD.INC_ID = '\(p.SUB_CAT)'") as? String
                    let subHeader = PDFTable(rows: 1, columns: 5)
                    subHeader.content = [
                        ["\(p.CNSG_NO)", "\(p.TRANSACTION_DATE.dateOnly)", "\(cat ?? "")", "\(subCat ?? "")", "\(p.POINTS)"]
                    ]
                    let subHeaderStyle = PDFTableStyleDefaults.simple
                    let subHeaderPDFCellStyle = PDFTableCellStyle(
                        colors: (
                            fill: .clear, text: .black),
                        borders: PDFTableCellBorders(left: PDFLineStyle(type: .full),
                                                     top: PDFLineStyle(type: .full),
                                                     right: PDFLineStyle(type: .full),
                                                     bottom: PDFLineStyle(type: .full)),
                        font: Font.systemFont(ofSize: 12))
                    subHeaderStyle.columnHeaderCount = 0
                    subHeaderStyle.alternatingContentStyle = subHeaderPDFCellStyle
                    subHeaderStyle.contentStyle = subHeaderPDFCellStyle
                    subHeaderStyle.rowHeaderStyle = subHeaderPDFCellStyle
                    
                    subHeader.rows.allRowsAlignment = [.center, .center, .center, .center, .center]
                    subHeader.widths = [0.2, 0.2, 0.2, 0.2, 0.2]
                    subHeader.style = subHeaderStyle
                    subHeader.padding = 2.0

                    document.add(table: subHeader)
                }
            }
            
            let generator = PDFGenerator(document: document)
            do {
                let url  = try generator.generateURL(filename: "Example.pdf")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.unFreezeScreen()
                    self.view.hideToastActivity()
                    self.fileDownloadedURL = url
                    let previewController = QLPreviewController()
                    previewController.dataSource = self
                    self.present(previewController, animated: true) {
                        UIApplication.shared.statusBarStyle = .default
                    }
                }
            } catch let err {
                err.localizedDescription
            }
            
        }
        
    }
}


extension WalletDetailsViewController: DateSelectionDelegate {
    func dateSelection(numberOfDays: Int, selected_query: String) {
        self.selected_query = selected_query
        self.thisWeekBtn.setTitle(selected_query, for: .normal)
        
        self.startday = nil
        self.endday = nil
        
        self.numberOfDays = numberOfDays
        self.setupJSON(numberOfDays: numberOfDays,  startday: startday, endday: endday)
    }
    
    func dateSelection(startDate: String, endDate: String, selected_query: String) {
        self.selected_query = selected_query
        self.thisWeekBtn.setTitle(selected_query, for: .normal)
        
        self.startday = startDate
        self.endday   = endDate
        
        self.setupJSON(numberOfDays: 0, startday: startDate, endday: endDate)
    }
    
    func requestModeSelected(selected_query: String) {}
}


extension WalletDetailsViewController : QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return fileDownloadedURL! as QLPreviewItem
    }
}


extension WalletDetailsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        searchQueryTimer?.invalidate()
        
        let currentText = textField.text ?? ""
        print(currentText)
        
        if (currentText as NSString).replacingCharacters(in: range, with: string).count == 0 {
            
            self.tbl_details = temp_data
            
            self.tableView.reloadData()
            self.setupTableViewHeight()
            return true
        }
        if (currentText as NSString).replacingCharacters(in: range, with: string).count >= 3 {
            searchQueryTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(performSearch), userInfo: nil, repeats: false)
        }
        return true
    }
    @objc func performSearch() {
        
        self.tbl_details = self.tbl_details?.filter({ (logs) -> Bool in
            return (logs.SUB_CATEGORY_NAME.lowercased().contains(self.searchTextField.text?.lowercased() ?? "")) || logs.CATEGORY_NAME.lowercased().contains(self.searchTextField.text?.lowercased() ?? "")
        })
        
        self.tableView.reloadData()
        self.setupTableViewHeight()
    }
}
