//
//  FulfilmentOrderDetailViewController.swift
//  tcs_one_app
//
//  Created by TCS on 25/03/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields

class FulfilmentOrderDetailViewController: BaseViewController {

    @IBOutlet weak var orderID: MDCOutlinedTextField!
    @IBOutlet weak var city: MDCOutlinedTextField!
    @IBOutlet weak var address: MDCOutlinedTextField!
    
    @IBOutlet weak var scan_shipment_label: UILabel!
    
    @IBOutlet weak var shipment: MDCOutlinedTextField!
    @IBOutlet weak var unscanned: UILabel!
    @IBOutlet weak var scanned: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Fulfilment"
        addDoubleNavigationButtons()
    }
    
    func setupTextField() {
        orderID.label.textColor = UIColor.nativeRedColor()
        orderID.label.text = "Order ID"
        orderID.placeholder = ""
        orderID.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        
        city.label.textColor = UIColor.nativeRedColor()
        city.label.text = "City"
        city.placeholder = ""
        city.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        
        orderID.label.textColor = UIColor.nativeRedColor()
        orderID.label.text = "Address"
        orderID.placeholder = ""
        orderID.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
    }
}
