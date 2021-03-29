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

class FulfilmentOrderDetailViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var orderID: MDCOutlinedTextField!
    @IBOutlet weak var city: MDCOutlinedTextField!
    @IBOutlet weak var address: MDCOutlinedTextField!
    
    @IBOutlet weak var scan_shipment_label: UILabel!
    
    @IBOutlet weak var shipment: MDCOutlinedTextField!
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
    var isOLEExist = false
    var OLEPrefix = "OLEP"
    var DGroupPrefix = "DGroup"
    
    var isOrderReceived = false
    var receivedOrderBasket = ""
    
    
    var isAllASKT = false
    var currentCNSGIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Fulfillment"
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
        
        address.label.textColor = UIColor.nativeRedColor()
        address.label.text = "Address"
        address.placeholder = ""
        address.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        
        shipment.label.textColor = UIColor.nativeRedColor()
        shipment.label.text = "Shipment #"
        shipment.placeholder = ""
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
                
                if let temp = fulfilment_order.filter { (logs) -> Bool in
                    logs.ITEM_STATUS == "Received" && logs.ORDER_ID == orderId!
                }.first {
                    self.isOrderReceived = true
                    self.receivedOrderBasket = temp.BASKET_BARCODE
                }
                
                self.fulfilment_orders = fulfilment_order
                
                orderID.text = fulfilment_order.first?.ORDER_ID ?? ""
                city.text = fulfilment_order.first?.DESTINATION ?? ""
                if fulfilment_order.first?.CONSIGNEE_ADDRESS == "" {
                    address.text = "No Address Found"
                } else {
                    address.text = fulfilment_order.first?.CONSIGNEE_ADDRESS ?? ""
                }
                
                getCounts()
                setupTableViewHeight()
            }
        }
    }
    private func getCounts() {
        if let _ = self.fulfilment_orders {
            let sCount = self.fulfilment_orders?.filter { (logs) -> Bool in
                logs.ITEM_STATUS == "Scanned"
            }.count ?? 00
            let usCount = self.fulfilment_orders?.filter { (logs) -> Bool in
                logs.ITEM_STATUS == "Pending"
            }.count ?? 00
            let rCount = self.fulfilment_orders?.filter { (logs) -> Bool in
                logs.ITEM_STATUS == "Received"
            }.count ?? 00
            
            self.scanned.text = "Scanned: \(sCount)"
            self.unscanned.text = "Unscanned: \(usCount)"
            self.received.text = "Received: \(rCount)"
            
            if usCount == self.fulfilment_orders?.count {
                self.truckBtn.isHidden = true
                self.checkBtn.isHidden = true
                return
            }
            
            if sCount == self.fulfilment_orders?.count {
                truckBtn.isHidden = false
                checkBtn.isHidden = true
            } else {
                truckBtn.isHidden = true
                checkBtn.isHidden = false
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
                        
                        self.isCNScanned = false
                        self.isAllASKT = true
                        
                        self.scan_shipment_label.text = "Scan Shipment"
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
                        
                        self.isCNScanned = false
                        
                        self.scan_shipment_label.text = "Scan Shipment"
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
                        
                        self.isCNScanned = false
                        
                        self.scan_shipment_label.text = "Scan Shipment"
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
                    
                    if isAllASKT {
                        self.isCNScanned = false
                    } else {
                        self.isCNScanned = true
                        self.scan_shipment_label.text = "Scan Bucket"
                        shipment.label.text = "Bucket #"
                        shipment.text = ""
                    }
                    break
                }
            }
            if !isFound {
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
    @IBAction func scanBarCod(_ sender: Any) {
        let viewController = BarcodeScannerViewController()
        viewController.codeDelegate = self
        viewController.errorDelegate = self
        viewController.dismissalDelegate = self

        present(viewController, animated: true, completion: nil)
    }
    @IBAction func checkBtnTapped(_ sender: Any) {
//        let generator = UINotificationFeedbackGenerator()
//        generator.notificationOccurred(.warning)
    }
    @IBAction func deliverBtnTapped(_ sender: Any) {
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
        cell.bucketBarcode.text = "Bucket # \(data.BASKET_BARCODE)"
        cell.resetBtn.tag = indexPath.row
        cell.resetBtn.addTarget(self, action: #selector(revertStatus(sender:)), for: .touchUpInside)
        cell.status.text = data.ITEM_STATUS
        
        switch data.ITEM_STATUS {
        case "Pending":
            cell.status.textColor = UIColor.pendingColor()
            cell.resetBtn.isEnabled = false
            break
        case "Received":
            cell.status.textColor = UIColor.approvedColor()
            cell.resetBtn.isEnabled = false
        case "Scanned":
            cell.status.textColor = UIColor.approvedColor()
            cell.resetBtn.isEnabled = true
            break
        default:
            break
        }
        return cell
    }
    
    @objc func revertStatus(sender: UIButton) {
        self.fulfilment_orders![sender.tag].ITEM_STATUS = "Pending"
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
            self.scan_shipment_label.text = "Scan Shipment"
            self.shipment.label.text = "Shipment #"
            self.shipment.text = ""
            
            self.tableView.reloadData()
            self.getCounts()
        }
    }
}


extension FulfilmentOrderDetailViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        dismiss(animated: true) {
            for (i,o) in self.fulfilment_orders!.enumerated() {
                if o.CNSG_NO == code {
                    self.currentCNSGIndex = i
                    break
                }
            }
            self.scannedBarCode(code: code)
        }
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
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != "" {
            for (i,o) in self.fulfilment_orders!.enumerated() {
                if o.CNSG_NO == textField.text {
                    self.currentCNSGIndex = i
                    break
                }
            }
            self.scannedBarCode(code: textField.text ?? "")
        }
    }
}
