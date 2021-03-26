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
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Fulfilment"
        addDoubleNavigationButtons()
        setupTextField()
        
        tableView.register(UINib(nibName: "FulfilmentOrderDetailTableCell", bundle: nil), forCellReuseIdentifier: "FulfilmentOrderDetailCell")
        tableView.rowHeight = 65
        self.makeTopCornersRounded(roundView: self.mainView)
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
        
        if let _ = orderId {
            let query = "SELECT * FROM \(db_fulfilment_orders) WHERE ORDER_ID = '\(orderId!)'"
            if let fulfilment_order = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orders(query: query) {
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
            
            self.scanned.text = "Scanned: \(sCount)"
            self.unscanned.text = "Unscanned: \(usCount)"
            
            if sCount == self.fulfilment_orders?.count {
                truckBtn.isHidden = false
            } else {
                checkBtn.isHidden = false
            }
        }
    }
    
    private func scannedBarCode(code: String) {
        let index = fulfilment_orders?.firstIndex(where: { (logs) -> Bool in
            logs.CNSG_NO == code
        })
        
        
        
    }
    
    private func setupTableViewHeight() {
        var height: CGFloat = 0.0
        if let count = self.fulfilment_orders?.count {
            height = CGFloat((count * 65) + 10)
            self.tableViewHeightConstraint.constant = height
        }
        self.mainViewHeightConstraint.constant = 337
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
    @IBAction func scanBarCod(_ sender: Any) {
        let viewController = BarcodeScannerViewController()
        viewController.codeDelegate = self
        viewController.errorDelegate = self
        viewController.dismissalDelegate = self

        present(viewController, animated: true, completion: nil)
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
}


extension FulfilmentOrderDetailViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        dismiss(animated: true) {
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
