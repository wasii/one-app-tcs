//
//  SalesCRMAddNewLeadsViewController.swift
//  tcs_one_app
//
//  Created by Wasiq Saleem on 10/01/2022.
//  Copyright © 2022 Personal. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields

class SalesCRMAddNewLeadsViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var firstName: MDCOutlinedTextField!
    @IBOutlet weak var lastName: MDCOutlinedTextField!
    @IBOutlet weak var businessName: MDCOutlinedTextField!
    @IBOutlet weak var designation: MDCOutlinedTextField!
    @IBOutlet weak var phoneNumber: MDCOutlinedTextField!
    @IBOutlet weak var industry: MDCOutlinedTextField!
    @IBOutlet weak var organization: MDCOutlinedTextField!
    @IBOutlet weak var product: MDCOutlinedTextField!
    @IBOutlet weak var amount: MDCOutlinedTextField!
    @IBOutlet weak var source: MDCOutlinedTextField!
    @IBOutlet weak var station: MDCOutlinedTextField!
    @IBOutlet weak var assignedTo: MDCOutlinedTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sales CRM"
        self.makeTopCornersRounded(roundView: self.mainView)
        setupTextField()
    }
    func setupTextField() {
        
        firstName.label.textColor = UIColor.nativeRedColor()
        firstName.label.text = "*First Name"
        firstName.placeholder = "Enter First Name"
        firstName.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        firstName.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        lastName.label.textColor = UIColor.nativeRedColor()
        lastName.label.text = "*Last Name"
        lastName.placeholder = "Enter Last Name"
        lastName.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        lastName.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        businessName.label.textColor = UIColor.nativeRedColor()
        businessName.label.text = "*Business Name"
        businessName.placeholder = "Enter Business Name"
        businessName.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        businessName.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        designation.label.textColor = UIColor.nativeRedColor()
        designation.label.text = "*Designation"
        designation.placeholder = "Enter Designation"
        designation.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        designation.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        phoneNumber.label.textColor = UIColor.nativeRedColor()
        phoneNumber.label.text = "*Primary Phone"
        phoneNumber.placeholder = "Enter Phone #"
        phoneNumber.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        phoneNumber.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        industry.label.textColor = UIColor.nativeRedColor()
        industry.label.text = "*Industry"
        industry.placeholder = "Enter Industry"
        industry.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        industry.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        organization.label.textColor = UIColor.nativeRedColor()
        organization.label.text = "*Organization"
        organization.placeholder = "Enter Organization"
        organization.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        organization.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        product.label.textColor = UIColor.nativeRedColor()
        product.label.text = "*Product"
        product.placeholder = "Enter Product"
        product.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        product.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        amount.label.textColor = UIColor.nativeRedColor()
        amount.label.text = "*Monthly Expected Revenue"
        amount.placeholder = "Enter Amount"
        amount.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        amount.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        source.label.textColor = UIColor.nativeRedColor()
        source.label.text = "*Lead Source"
        source.placeholder = "Enter Source"
        source.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        source.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        station.label.textColor = UIColor.nativeRedColor()
        station.label.text = "*Lead Status"
        station.placeholder = "Enter Status"
        station.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        station.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        assignedTo.label.textColor = UIColor.nativeRedColor()
        assignedTo.label.text = "*Assigned To"
        assignedTo.placeholder = "Assigned To"
        assignedTo.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        assignedTo.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        
    }
}
