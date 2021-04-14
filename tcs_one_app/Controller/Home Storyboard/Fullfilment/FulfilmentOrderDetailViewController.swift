//
//  FulfilmentOrderDetailViewController.swift
//  tcs_one_app
//
//  Created by TCS on 25/03/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import BarcodeScanner
import SwiftyJSON

class FulfilmentOrderDetailViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var orderID: MDCOutlinedTextField!
    @IBOutlet weak var city: MDCOutlinedTextField!
//    @IBOutlet weak var address: MDCOutlinedTextField!
    @IBOutlet weak var address: UITextView!
    
    
    
    @IBOutlet weak var readyToDeliverText: UILabel!
    @IBOutlet weak var shipment: MDCOutlinedTextField!
    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var unscanned: UILabel!
    @IBOutlet weak var scanned: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var received: UILabel!
    @IBOutlet weak var truckBtn: UIButton!
    @IBOutlet weak var checkBtn: UIButton!
    
    var orderId: String?
    var fulfilment_orders: [tbl_fulfilments_order]?
    var scan_prefix: [tbl_scan_prefix]?
    
    var isCNScanned = false
    var isBasketScanned = false
    var isOLEExist = false
    
    var OLEPrefix = "OLEP"
    var DGroupPrefix = "DGRO"
    
    
    var isOrderReceived = false
    var receivedOrderBasket = ""
    
    
    var isAllASKT = false
    var currentCNSGIndex = 0
    var currentCNSG      = ""
    
    var submit_orders: [SubmitOrder]?
    
    var isNavigateFromDashboard = false
    var cnsg_no: String?
    let barcodeViewController = BarcodeScannerViewController()
    var isAreaScanned = false
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Fulfilment"
        addDoubleNavigationButtons()
        setupTextField()
        
        tableView.register(UINib(nibName: "FulfilmentOrderDetailTableCell", bundle: nil), forCellReuseIdentifier: "FulfilmentOrderDetailCell")
        tableView.rowHeight = 65
        self.makeTopCornersRounded(roundView: self.mainView)
        
        scan_prefix = AppDelegate.sharedInstance.db?.read_tbl_scan_prefix(query: "SELECT * FROM \(db_scan_prefix)")
    }
    
    private func setupTextField() {
        orderID.label.textColor = UIColor.nativeRedColor()
        orderID.label.text = "Order ID"
        orderID.placeholder = ""
        orderID.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        
        city.label.textColor = UIColor.nativeRedColor()
        city.label.text = "City"
        city.placeholder = ""
        city.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        
//        address.label.textColor = UIColor.nativeRedColor()
//        address.label.text = "Address"
//        address.placeholder = ""
//        address.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        
        shipment.label.textColor = UIColor.nativeRedColor()
        shipment.label.text = "Search"
        shipment.placeholder = "Enter CN / Order Number"
        shipment.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        shipment.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        shipment.delegate = self
        
        if let _ = orderId {
            let query = "SELECT * FROM \(db_fulfilment_orders) WHERE ORDER_ID = '\(orderId!)'"
            if let fulfilment_order = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orders(query: query) {
                let allPendingCount = fulfilment_order.filter({ (logs) -> Bool in
                    logs.ITEM_STATUS == "Pending"
                }).count
                if allPendingCount == fulfilment_order.count {
                    if let OLEExist = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orderId(orderId: orderId!) {
                        if OLEExist > 0 {
                            let query = "SELECT * FROM \(db_scan_prefix) WHERE SERVICE_NO = 'OLE'"
                            if let scan_prefix = AppDelegate.sharedInstance.db?.read_tbl_scan_prefix(query: query).first {
                                self.DGroupPrefix = scan_prefix.PREFIX_CODE
                                self.isOLEExist = true
                            }
                        } else {
                            let query = "SELECT * FROM \(db_scan_prefix) WHERE SERVICE_NO = 'D'"
                            if let scan_prefix = AppDelegate.sharedInstance.db?.read_tbl_scan_prefix(query: query).first {
                                self.DGroupPrefix = scan_prefix.PREFIX_CODE
                                self.isOLEExist = false
                            }
                        }
                    }
                }
                
                if let temp = fulfilment_order.filter ({ (logs) -> Bool in
                    logs.ITEM_STATUS == "Received" && logs.ORDER_ID == orderId!
                }).first {
                    self.isOrderReceived = true
                    self.receivedOrderBasket = temp.BASKET_BARCODE
                } else {
                    if let OLEExist = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orderId(orderId: orderId!) {
                        if OLEExist > 0 {
                            let query = "SELECT * FROM \(db_scan_prefix) WHERE SERVICE_NO = 'OLE'"
                            if let scan_prefix = AppDelegate.sharedInstance.db?.read_tbl_scan_prefix(query: query).first {
                                self.DGroupPrefix = scan_prefix.PREFIX_CODE
                                self.isOLEExist = true
                            }
                        } else {
                            let query = "SELECT * FROM \(db_scan_prefix) WHERE SERVICE_NO = 'D'"
                            if let scan_prefix = AppDelegate.sharedInstance.db?.read_tbl_scan_prefix(query: query).first {
                                self.DGroupPrefix = scan_prefix.PREFIX_CODE
                                self.isOLEExist = false
                            }
                        }
                    }
                }
                
                self.fulfilment_orders = fulfilment_order
                self.fulfilment_orders?.forEach({ (logs) in
                    if logs.SERVICE_NO == "OLE" {
                        self.isAreaScanned = true
                    }
                    self.createSubmissionArray(orderId: logs.ORDER_ID,
                                               cn_number: logs.CNSG_NO,
                                               basket_no: logs.BASKET_BARCODE)
                })
                orderID.text = fulfilment_order.first?.ORDER_ID ?? ""
                city.text = fulfilment_order.first?.DESTINATION ?? ""
                if fulfilment_order.first?.CONSIGNEE_ADDRESS == "" {
                    address.text = "No Address Found"
                } else {
                    address.text = fulfilment_order.first?.CONSIGNEE_ADDRESS ?? ""
                }
                
//                let query = "SELECT * FROM \(db_fulfilment_orders_temp) WHERE ORDER_ID = '\(orderId!)'"
//                if let temp_order = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orders_temp(query: query) {
//                    let scanned_item = temp_order.filter { (log) -> Bool in
//                        log.STATUS == "Scanned"
//                    }
//                    for (i,o) in self.fulfilment_orders!.enumerated() {
//                        for si in scanned_item {
//                            if o.CNSG_NO == si.CN_NUMBER {
//                                if si.BASKET_NO == "" {
//                                    self.fulfilment_orders![i].ITEM_STATUS = si.STATUS
//                                } else {
//                                    self.fulfilment_orders![i].ITEM_STATUS = si.STATUS
//                                    self.fulfilment_orders![i].BASKET_BARCODE = si.BASKET_NO
//                                    self.createSubmissionArray(orderId: orderId!, cn_number: si.CN_NUMBER, basket_no: si.BASKET_NO)
//                                    self.isBasketScanned = true
//                                }
//                                break
//                            }
//                        }
//                    }
//                }
                if self.fulfilment_orders?.count == 1 {
                    if self.fulfilment_orders![0].ITEM_STATUS != "Received" {
                        self.fulfilment_orders![0].ITEM_STATUS = "Scanned"
                        self.fulfilment_orders![0].BASKET_BARCODE = "0"
                        
                        AppDelegate.sharedInstance.db?.deleteRow(tableName: db_fulfilment_orders_temp, column: "CN_Number", ref_id: "\(self.fulfilment_orders![0].CNSG_NO)", handler: { _ in
                            let temp_order = SubmitOrder(ORDER_ID: self.fulfilment_orders![0].ORDER_ID,
                                                         STATUS: "Scanned",
                                                         CN_NUMBER: self.fulfilment_orders![0].CNSG_NO,
                                                         BASKET_NO: "0")
                            AppDelegate.sharedInstance.db?.insert_tbl_fulfilment_orders_temp(orders: temp_order, handler: { _ in })
                            AppDelegate.sharedInstance.db?.updateTables(tableName: db_fulfilment_orders, columnName: ["ITEM_STATUS"], updateValue: ["Scanned"], onCondition: "CNSG_NO = '\(self.fulfilment_orders![0].CNSG_NO)'", { _ in })
                        })
                        
                        
                        self.createSubmissionArray(orderId: self.fulfilment_orders![0].ORDER_ID,
                                                   cn_number: self.fulfilment_orders![0].CNSG_NO,
                                                   basket_no: "0")
                    }
                } else if isNavigateFromDashboard {
                    for (index,order) in self.fulfilment_orders!.enumerated() {
                        if order.CNSG_NO == cnsg_no {
                            self.fulfilment_orders![index].ITEM_STATUS = "Scanned"
                            AppDelegate.sharedInstance.db?.deleteRow(tableName: db_fulfilment_orders_temp, column: "CN_Number", ref_id: "\(self.fulfilment_orders![index].CNSG_NO)", handler: { _ in
//                                let temp_order = SubmitOrder(ORDER_ID: self.fulfilment_orders![index].ORDER_ID,
//                                                             STATUS: "Scanned",
//                                                             CN_NUMBER: self.fulfilment_orders![index].CNSG_NO,
//                                                             BASKET_NO: "")
//                                AppDelegate.sharedInstance.db?.insert_tbl_fulfilment_orders_temp(orders: temp_order, handler: { _ in })
//                                AppDelegate.sharedInstance.db?.updateTables(tableName: db_fulfilment_orders, columnName: ["ITEM_STATUS"], updateValue: ["Scanned"], onCondition: "CNSG_NO = '\(self.fulfilment_orders![index].CNSG_NO)'", { _ in })
                            })
                            break
                        }
                    }
                    openBarCodeScanner(is_cn_scanned: true)
                    
                }
                
                getCounts()
                setupTableViewHeight()
            }
        } else if let orders = self.fulfilment_orders {
            orderID.text = orders.first?.ORDER_ID ?? ""
            city.text = orders.first?.DESTINATION ?? ""
            if orders.first?.CONSIGNEE_ADDRESS == "" {
                address.text = "No Address Found"
            } else {
                address.text = orders.first?.CONSIGNEE_ADDRESS ?? ""
            }
            orders.forEach { (logs) in
                if logs.SERVICE_NO == "OLE" {
                    self.isAreaScanned = true
                }
                self.createSubmissionArray(orderId: logs.ORDER_ID, cn_number: logs.CNSG_NO, basket_no: logs.BASKET_BARCODE)
                orderId = logs.ORDER_ID
            }
            getCounts()
            setupTableViewHeight()
        }
    }
    private func getCounts() {
        if let _ = self.fulfilment_orders {
            let sCount = self.fulfilment_orders?.filter { (logs) -> Bool in
                logs.ITEM_STATUS == "Scanned"
            }.count ?? 0
            let usCount = self.fulfilment_orders?.filter { (logs) -> Bool in
                logs.ITEM_STATUS == "Pending"
            }.count ?? 0
            let rCount = self.fulfilment_orders?.filter { (logs) -> Bool in
                logs.ITEM_STATUS == "Received"
            }.count ?? 0
            let sCountWOBasket = self.fulfilment_orders?.filter { (logs) -> Bool in
                logs.ITEM_STATUS == "Scanned" && logs.BASKET_BARCODE != ""
            }.count ?? 0
            
            
            
            self.scanned.text = "Scanned: \(sCount)"
            self.unscanned.text = "Unscanned: \(usCount)"
            if rCount > 0 {
                self.received.text = "Received: \(rCount)"
            }
            
            if sCountWOBasket == 0 {
                return
            }
            if rCount == self.fulfilment_orders?.count {
                self.truckBtn.isHidden = true
                self.checkBtn.isHidden = true
                return
            }
            if usCount == self.fulfilment_orders?.count {
                self.truckBtn.isHidden = true
                self.checkBtn.isHidden = true
                return
            }
            if (sCount + rCount) == self.fulfilment_orders?.count {
                self.truckBtn.isHidden = false
                self.readyToDeliverText.isHidden = false
                return
            }
            
            if sCount == self.fulfilment_orders?.count {
                if isBasketScanned {
                    self.readyToDeliverText.isHidden = false
                    truckBtn.isHidden = false
                    checkBtn.isHidden = true
                } else {
                    truckBtn.isHidden = true
                    checkBtn.isHidden = true
                }
                
            } else {
                if isBasketScanned {
                    truckBtn.isHidden = true
                    checkBtn.isHidden = false
                } else {
                    truckBtn.isHidden = true
                    checkBtn.isHidden = true
                }
            }
        }
    }
    
    private func scannedBarCode(code: String) {
        if self.isCNScanned {
            if self.receivedOrderBasket == "" {
                let prefix = code[0..<self.OLEPrefix.count]
                print(prefix)
                if prefix == self.OLEPrefix {
                    for (i,_) in self.fulfilment_orders!.enumerated() {
                        self.fulfilment_orders![i].BASKET_BARCODE = code
                    }
                    DispatchQueue.main.async {
                        let temp = self.fulfilment_orders?.filter({ (log) -> Bool in
                            log.CNSG_NO == self.currentCNSG
                        }).first
                        
                        self.createSubmissionArray(orderId: temp?.ORDER_ID ?? "",
                                                   cn_number: temp?.CNSG_NO ?? "",
                                                   basket_no: code)
                        self.isCNScanned = false
                        self.isBasketScanned = true
                        
                        self.isAllASKT = true
                        self.shipment.label.text = "Shipment #"
                        self.shipment.text = ""
                        
                        self.tableView.reloadData()
                        self.getCounts()
                        
                        self.receivedOrderBasket = code
                    }
                } else if prefix == DGroupPrefix {
                    for (i,_) in self.fulfilment_orders!.enumerated() {
                        self.fulfilment_orders![i].BASKET_BARCODE = code
                    }
                    DispatchQueue.main.async {
                        let temp = self.fulfilment_orders?.filter({ (log) -> Bool in
                            log.CNSG_NO == self.currentCNSG
                        }).first
                        
                        self.createSubmissionArray(orderId: temp?.ORDER_ID ?? "",
                                                   cn_number: temp?.CNSG_NO ?? "",
                                                   basket_no: code)
                        self.isCNScanned = false
                        self.isBasketScanned = true
                        
                        self.shipment.label.text = "Shipment #"
                        self.shipment.text = ""
                        
                        self.tableView.reloadData()
                        self.getCounts()
                    }
                } else {
                    self.view.makeToast("Wrong basket scanned.")
                }
            } else {
                if self.receivedOrderBasket == code {
                    DispatchQueue.main.async {
                        let temp = self.fulfilment_orders?.filter({ (log) -> Bool in
                            log.CNSG_NO == self.currentCNSG
                        }).first
                        
                        self.createSubmissionArray(orderId: temp?.ORDER_ID ?? "",
                                                   cn_number: temp?.CNSG_NO ?? "",
                                                   basket_no: code)
                        self.isCNScanned = false
                        self.isBasketScanned = true
                        
                        self.shipment.label.text = "Shipment #"
                        self.shipment.text = ""
                        
                        self.tableView.reloadData()
                        self.getCounts()
                        
                        self.receivedOrderBasket = code
                    }
                } else {
                    self.view.makeToast("Wrong basket scanned.")
                }
            }
        } else {
            var isFound = false
            for (index, order) in self.fulfilment_orders!.enumerated() {
                if order.CNSG_NO == code {
                    isFound = true
                    self.fulfilment_orders![index].ITEM_STATUS = "Scanned"
                    
                    self.isBasketScanned = false
                    self.currentCNSG = order.CNSG_NO
                    
                    if isAllASKT {
                        self.isCNScanned = false
                    } else {
                        self.isCNScanned = true
                        
                        shipment.label.text = "Bucket #"
                        shipment.text = ""
                    }
                    break
                }
            }
            if !isFound {
                self.isBasketScanned = false
                self.view.makeToast("CN # not valid")
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.getCounts()
            }
        }
    }
    
    private func setupTableViewHeight() {
        var height: CGFloat = 0.0
        if let count = self.fulfilment_orders?.count {
            height = CGFloat((count * 65) + 10)
            self.tableViewHeightConstraint.constant = height
        }
        self.mainViewHeightConstraint.constant = 450 + height
        switch UIDevice().type {
        case .iPhone5, .iPhone5S, .iPhone5C, .iPhoneSE:
            if self.mainViewHeightConstraint.constant < 570 {
                self.mainViewHeightConstraint.constant = 600
            }
            break
        case .iPhone6, .iPhone6S, .iPhone7, .iPhone8:
            if self.mainViewHeightConstraint.constant < 670 {
                self.mainViewHeightConstraint.constant = 670
            }
        case .iPhone6Plus, .iPhone7Plus, .iPhone8Plus:
            if self.mainViewHeightConstraint.constant < 740 {
                self.mainViewHeightConstraint.constant = 740
            }
            break
        case .iPhoneX, .iPhoneXR, .iPhoneXS, .iPhone11Pro, .iPhone12, .iPhone12Pro:
            if self.mainViewHeightConstraint.constant < 790 {
                self.mainViewHeightConstraint.constant = 790
            }
        case .iPhone11, .iPhoneXSMax, .iPhone11ProMax:
            if self.mainViewHeightConstraint.constant < 840 {
                self.mainViewHeightConstraint.constant = 840
            }
            break
        case .iPhone12ProMax:
            if self.mainViewHeightConstraint.constant < 880 {
                self.mainViewHeightConstraint.constant = 880
            }
            break
        case .iPhone12Mini:
            if self.mainViewHeightConstraint.constant < 770 {
                self.mainViewHeightConstraint.constant = 770
            }
        default:
            break
        }
    }
    
    func openBarCodeScanner(is_cn_scanned: Bool) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "scanNavController") as! UINavigationController
        (controller.children.first as! ScanFulfillmentViewController).fulfilment_orders = self.fulfilment_orders
        (controller.children.first as! ScanFulfillmentViewController).orderId = self.orderId
        (controller.children.first as! ScanFulfillmentViewController).delegate = self
        if is_cn_scanned {
            (controller.children.first as! ScanFulfillmentViewController).isCNScanned = is_cn_scanned
            (controller.children.first as! ScanFulfillmentViewController).currentCNSG = cnsg_no ?? ""
        }
        controller.modalTransitionStyle = .crossDissolve
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        present(controller, animated: true, completion: nil)
    }
    //MARK: IBACTIONS
    @IBAction func scanBarCod(_ sender: Any) {
        if shipment.text == "" {
            return
        }
        
        self.fulfilment_orders = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orders(query: "SELECT * FROM \(db_fulfilment_orders) WHERE CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'")
        
        self.fulfilment_orders = self.fulfilment_orders?.filter({ (logs) -> Bool in
            return (logs.ORDER_ID.lowercased().contains(self.shipment.text?.lowercased() ?? "")) ||
                (String(logs.CNSG_NO).contains(self.shipment.text?.lowercased() ?? ""))
        })
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.getCounts()
            self.setupTableViewHeight()
        }
        if let order = fulfilment_orders?.first {
            orderID.text = order.ORDER_ID
            city.text = order.DESTINATION
            if order.CONSIGNEE_ADDRESS == "" {
                address.text = "No Address Found"
            } else {
                address.text = order.CONSIGNEE_ADDRESS
            }
        }
    }
    @IBAction func checkBtnTapped(_ sender: Any) {
        checkBtn.isEnabled = false
        let popup = UIStoryboard(name: "Popups", bundle: nil)
        let controller = popup.instantiateViewController(withIdentifier: "ConfirmationPopViewController") as! ConfirmationPopViewController
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        controller.modalTransitionStyle = .crossDissolve
        controller.delegate = self
        Helper.topMostController().present(controller, animated: true, completion: nil)
    }
    @IBAction func deliverBtnTapped(_ sender: Any) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        
        truckBtn.isEnabled = false
        let popup = UIStoryboard(name: "Popups", bundle: nil)
        let controller = popup.instantiateViewController(withIdentifier: "ConfirmationPopViewController") as! ConfirmationPopViewController
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        controller.modalTransitionStyle = .crossDissolve
        controller.delegate = self
        Helper.topMostController().present(controller, animated: true, completion: nil)
    }
}


extension FulfilmentOrderDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.fulfilment_orders?.count {
            return count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FulfilmentOrderDetailCell") as! FulfilmentOrderDetailTableCell
        let data = self.fulfilment_orders![indexPath.row]
        
        cell.orderID.text = "CN # \(data.CNSG_NO)"
        if self.isAreaScanned {
            cell.bucketBarcode.text = "Area # \(data.BASKET_BARCODE)"
        } else {
            cell.bucketBarcode.text = "Basket # \(data.BASKET_BARCODE)"
        }
        
//        cell.resetBtn.tag = indexPath.row
//        cell.resetBtn.addTarget(self, action: #selector(revertStatus(sender:)), for: .touchUpInside)
        cell.status.text = data.ITEM_STATUS
        
        switch data.ITEM_STATUS {
        case "Pending":
            cell.status.textColor = UIColor.pendingColor()
            cell.resetBtn.isEnabled = false
            break
        case "Received":
            cell.status.textColor = UIColor.approvedColor()
            cell.resetBtn.isEnabled = false
            break
        case "Scanned":
            cell.status.textColor = UIColor.inprocessColor()
            cell.resetBtn.isEnabled = true
            break
        default:
            break
        }
        return cell
    }
    
    @objc func revertStatus(sender: UIButton) {
        self.fulfilment_orders![sender.tag].ITEM_STATUS = "Pending"
        AppDelegate.sharedInstance.db?.updateTables(tableName: db_fulfilment_orders, columnName: ["ITEM_STATUS"], updateValue: ["Pending"], onCondition: "CNSG_NO = '\(self.fulfilment_orders![sender.tag].CNSG_NO)'", { _ in })
        AppDelegate.sharedInstance.db?.deleteRow(tableName: db_fulfilment_orders_temp, column: "CN_NUMBER", ref_id: "\(self.fulfilment_orders![sender.tag].CNSG_NO)", handler: { _ in })
        let count = self.fulfilment_orders?.count
        let pFilter = self.fulfilment_orders?.filter({ (log) -> Bool in
            log.ITEM_STATUS == "Pending"
        }).count
        DispatchQueue.main.async {
            self.isCNScanned = false
            if count == pFilter {
                for (i, _) in self.fulfilment_orders!.enumerated() {
                    self.fulfilment_orders![i].BASKET_BARCODE = ""
                }
                self.receivedOrderBasket = ""
            }
            self.removeFromSubmissionArray(cn_number: self.fulfilment_orders![sender.tag].CNSG_NO)
            
            self.shipment.label.text = "Shipment #"
            self.shipment.text = ""
            
            self.tableView.reloadData()
            self.getCounts()
        }
    }
}


extension FulfilmentOrderDetailViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        for (i,o) in self.fulfilment_orders!.enumerated() {
            if o.CNSG_NO == code {
                self.currentCNSGIndex = i
                break
            }
        }
        self.scannedBarCode(code: code)
        controller.reset(animated: false)
        controller.headerViewController.titleLabel.text = "Bucket Shipment"
        
    }
}
extension FulfilmentOrderDetailViewController: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        
    }
}
extension FulfilmentOrderDetailViewController: BarcodeScannerDismissalDelegate {
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        dismiss(animated: true, completion: nil)
    }
}


extension FulfilmentOrderDetailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            return true
        }
        let maxlength = 12
        let currentString: NSString = textField.text as! NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length <= maxlength {
            let alphaNumericRegEx = "[a-zA-Z0-9]"
            let predicate = NSPredicate(format:"SELF MATCHES %@", alphaNumericRegEx)
            return predicate.evaluate(with: string)
        }
        return false
    }
}


extension FulfilmentOrderDetailViewController {
    private func createSubmissionArray(orderId: String, cn_number: String, basket_no: String) {
        if let _ = self.submit_orders {
            self.submit_orders?.append(SubmitOrder(ORDER_ID: orderId,
                                                   STATUS: "Received",
                                                   CN_NUMBER: cn_number,
                                                   BASKET_NO: basket_no))
        } else {
            self.submit_orders = [SubmitOrder]()
            self.submit_orders?.append(SubmitOrder(ORDER_ID: orderId,
                                                   STATUS: "Received",
                                                   CN_NUMBER: cn_number,
                                                   BASKET_NO: basket_no))
        }
    }
    private func removeFromSubmissionArray(cn_number: String) {
        if let submission_array = self.submit_orders {
            for (index,order) in submission_array.enumerated() {
                if order.CN_NUMBER == cn_number {
                    self.submit_orders?.remove(at: index)
                    break
                }
            }
            print(self.submit_orders)
        }
    }
    private func getAPIParameters(service_name: String, request_body: [String:Any]) -> [String:Any] {
        let params = [
            "eAI_MESSAGE": [
                "eAI_HEADER": [
                    "serviceName": service_name,
                    "client": "ibm_apiconnect",
                    "clientChannel": "MOB",
                    "referenceNum": "",
                    "securityInfo": [
                        "authentication": [
                            "userId": "",
                            "password": ""
                        ]
                    ]
                ],
                "eAI_BODY": [
                    "eAI_REQUEST": request_body
                ]
            ]
        ]
        return params as [String: Any]
    }
    func updateFulfilmentOrder(params: [String:Any], _ handler: @escaping(_ success: Bool)->Void) {
        NetworkCalls.updatefulfillmentorder(params: params) { (granted, response) in
            if granted {
                if let orders = JSON(response).array {
                    for order in orders {
                        AppDelegate.sharedInstance.db?.deleteRow(tableName: db_fulfilment_orders, column: "CNSG_NO", ref_id: order["CNSG_NO"].stringValue, handler: { _ in
                            do {
                                let data = try order.rawData()
                                let fulfilment_order = try JSONDecoder().decode(FulfilmentOrders.self, from: data)
                                AppDelegate.sharedInstance.db?.insert_tbl_fulfilment_orders(fulfilment_orders: fulfilment_order, handler: { _ in })
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
                        })
                    }
                    handler(true)
                }
            } else {
                handler(false)
            }
        }
    }
}

extension FulfilmentOrderDetailViewController: ConfirmationProtocol {
    func confirmationProtocol() {
        print(self.submit_orders)
        guard let access_token = UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN) else {
            self.view.makeToast("Session Expired")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dismiss(animated: true, completion: nil)
            }
            return
        }
        if let submit_order = self.submit_orders {
            self.view.makeToastActivity(.center)
            self.freezeScreen()
            
            var dictionary = [NSMutableDictionary]()
            for o in submit_order {
                let temp = NSMutableDictionary()
                temp.setValue(o.ORDER_ID, forKey: "order_id")
                temp.setValue(o.STATUS, forKey: "status")
                temp.setValue(o.CN_NUMBER, forKey: "cn_number")
                temp.setValue(o.BASKET_NO, forKey: "basket_no")
                dictionary.append(temp)
            }
            let json = [
                "update_request": [
                    "access_token" : access_token,
                    "orders" : dictionary
                ]
            ] as [String:Any]
            let params = self.getAPIParameters(service_name: UPDATEORDERFULFILMENT, request_body: json)
            self.updateFulfilmentOrder(params: params) { granted in
                if granted {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.view.hideToastActivity()
                        self.unFreezeScreen()
                        
                        let popup = UIStoryboard(name: "Popups", bundle: nil)
                        let controller = popup.instantiateViewController(withIdentifier: "FulfillmentPopViewController") as! FulfillmentPopViewController
                        if #available(iOS 13.0, *) {
                            controller.modalPresentationStyle = .overFullScreen
                        }
                        controller.modalTransitionStyle = .crossDissolve
                        controller.delegate = self
                        Helper.topMostController().present(controller, animated: true, completion: nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.checkBtn.isEnabled = true
                        self.truckBtn.isEnabled = true
                        self.view.hideToastActivity()
                        self.unFreezeScreen()
                        self.view.makeToast(SOMETHINGWENTWRONG)
                    }
                }
            }
        } else {
            self.truckBtn.isEnabled = true
            self.view.makeToast("Scan any consignment first.")
        }
    }
    
    func noButtonTapped() {
        self.checkBtn.isEnabled = true
        self.truckBtn.isEnabled = true
    }
}

extension FulfilmentOrderDetailViewController: FulFillmentPopup {
    func donePressed() {
        let condition = "ORDER_ID = \(orderId!) AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
        AppDelegate.sharedInstance.db?.deleteRowWithMultipleConditions(tbl: db_fulfilment_orders_temp, conditions: condition, { _ in })
        self.navigationController?.popViewController(animated: true)
    }
}

extension FulfilmentOrderDetailViewController: ScanFulfillmentProtocol {
    func didScanCode(code: String, isBucket: Bool, CN: String) {
        self.scannedBarCode(code: code)
        var colum = [String]()
        var value = [String]()
        var condition = ""
        
        let query = "SELECT * FROM \(db_fulfilment_orders_temp) WHERE CN_NUMBER = '\(CN)'"
        if let _ = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orders_temp(query: query)?.first {
            if isBucket {
                colum = ["BASKET_NO"]
                value = [code]
                condition = "CN_NUMBER = '\(CN)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
                
                AppDelegate.sharedInstance.db?.updateTables(tableName: db_fulfilment_orders,
                                                            columnName: ["BASKET_BARCODE"],
                                                            updateValue: [code],
                                                            onCondition: condition, { _ in })
            } else {
                if fulfilment_orders?.count == 1 {
                    colum = ["STATUS", "BASKET_NO"]
                    value = ["Scanned", "0"]
                    condition = "CN_NUMBER = '\(CN)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
                    
                    AppDelegate.sharedInstance.db?.updateTables(tableName: db_fulfilment_orders,
                                                                columnName: ["ITEM_STATUS", "BASKET_BARCODE"],
                                                                updateValue: ["Scanned", "0"],
                                                                onCondition: condition, { _ in })
                } else {
                    colum = ["STATUS"]
                    value = ["Scanned"]
                    condition = "CN_NUMBER = '\(CN)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
                    AppDelegate.sharedInstance.db?.updateTables(tableName: db_fulfilment_orders,
                                                                columnName: ["ITEM_STATUS"],
                                                                updateValue: ["Scanned"],
                                                                onCondition: condition, { _ in })
                }
                
            }
            
            AppDelegate.sharedInstance.db?.updateTables(tableName: db_fulfilment_orders_temp,
                                                        columnName: colum,
                                                        updateValue: value,
                                                        onCondition: condition, { _ in })
        } else {
            var temp_order = SubmitOrder()
            if fulfilment_orders?.count == 1 {
                temp_order = SubmitOrder(ORDER_ID: orderId!, STATUS: "Scanned", CN_NUMBER: CN, BASKET_NO: "0")
                AppDelegate.sharedInstance.db?.insert_tbl_fulfilment_orders_temp(orders: temp_order, handler: { _ in })
            } else {
                temp_order = SubmitOrder(ORDER_ID: orderId!, STATUS: "Scanned", CN_NUMBER: CN, BASKET_NO: code)
                AppDelegate.sharedInstance.db?.insert_tbl_fulfilment_orders_temp(orders: temp_order, handler: { _ in })
            }
            AppDelegate.sharedInstance.db?.updateTables(tableName: db_fulfilment_orders,
                                                        columnName: ["ITEM_STATUS", "BASKET_BARCODE"],
                                                        updateValue: ["Scanned", code],
                                                        onCondition: condition, { _ in })
        }
        
        if let id = orderId {
            fulfilment_orders = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orders(query: "SELECT * FROM \(db_fulfilment_orders) WHERE ORDER_ID = '\(id)'")
            self.tableView.reloadData()
            self.getCounts()
            self.setupTableViewHeight()
        }
    }
    func didScanOrder(orders: [tbl_fulfilments_order]) {}
}


struct SubmitOrder {
    var ORDER_ID: String = ""
    var STATUS: String = ""
    var CN_NUMBER: String = ""
    var BASKET_NO: String = ""
}
