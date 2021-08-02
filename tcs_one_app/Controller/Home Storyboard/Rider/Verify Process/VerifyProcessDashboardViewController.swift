//
//  VerifyProcessDashboardViewController.swift
//  tcs_one_app
//
//  Created by TCS on 02/08/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields

class VerifyProcessDashboardViewController: BaseViewController {

    @IBOutlet weak var searchTextfield: MDCOutlinedTextField!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var totalUnverify: UILabel!
    @IBOutlet weak var totalVerify: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Verify Process"
    }
    
    
}
