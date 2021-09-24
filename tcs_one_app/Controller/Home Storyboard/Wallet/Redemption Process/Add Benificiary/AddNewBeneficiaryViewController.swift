//
//  AddNewBeneficiaryViewController.swift
//  tcs_one_app
//
//  Created by TCS on 22/09/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields

class AddNewBeneficiaryViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var beneficiaryLabel: UILabel!
    @IBOutlet weak var referenceNumber: MDCOutlinedTextField!
    @IBOutlet weak var beneficiaryName: MDCOutlinedTextField!
    @IBOutlet weak var beneficiaryEmpId: MDCOutlinedTextField!
    
    @IBOutlet weak var optionalValueViews: CustomView!
    @IBOutlet weak var beneficiaryNumber: MDCOutlinedTextField!
    @IBOutlet weak var beneficiaryNickName: MDCOutlinedTextField!
    @IBOutlet weak var beneficiaryEmail: MDCOutlinedTextField!
    
    @IBOutlet weak var sendConfirmationView: CustomView!
    @IBOutlet weak var confirmationBtn: UIButton!
    
    
    @IBOutlet weak var sendConfirmation: MDCOutlinedTextField!
    
    @IBOutlet weak var termAndConditionBtn: UIButton!
    @IBOutlet weak var termsAndConditiion: UILabel!
    
    @IBOutlet weak var oneTimePasscodeView: UIView!
    @IBOutlet weak var otp: MDCOutlinedTextField!
    @IBOutlet weak var confirmOtp: MDCOutlinedTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallet"
        makeTopCornersRounded(roundView: mainView)
        setupTextFields()
    }
    
    private func setupTextFields() {
        referenceNumber.label.textColor = UIColor.nativeRedColor()
        referenceNumber.label.text = "Reference Number"
        referenceNumber.placeholder = "Reference Number"
        referenceNumber.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        referenceNumber.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        beneficiaryName.label.textColor = UIColor.nativeRedColor()
        beneficiaryName.label.text = "Beneficiary Name"
        beneficiaryName.placeholder = "Enter Beneficiary Name"
        beneficiaryName.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        beneficiaryName.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        beneficiaryEmpId.label.textColor = UIColor.nativeRedColor()
        beneficiaryEmpId.label.text = "Beneficiary EMP ID"
        beneficiaryEmpId.placeholder = "Enter Beneficiary Employee Id"
        beneficiaryEmpId.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        beneficiaryEmpId.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        beneficiaryNumber.label.textColor = UIColor.nativeRedColor()
        beneficiaryNumber.label.text = "Beneficiary Number"
        beneficiaryNumber.placeholder = "Enter Beneficiary Number"
        beneficiaryNumber.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        beneficiaryNumber.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        beneficiaryNickName.label.textColor = UIColor.nativeRedColor()
        beneficiaryNickName.label.text = "Beneficiary Nickname"
        beneficiaryNickName.placeholder = "Enter Beneficiary Nickname"
        beneficiaryNickName.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        beneficiaryNickName.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        beneficiaryEmail.label.textColor = UIColor.nativeRedColor()
        beneficiaryEmail.label.text = "Beneficiary Email"
        beneficiaryEmail.placeholder = "Enter Beneficiary Email"
        beneficiaryEmail.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        beneficiaryEmail.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        sendConfirmation.label.textColor = UIColor.nativeRedColor()
        sendConfirmation.label.text = "Send confirmation to Beneficiary when a transfer is made"
        sendConfirmation.text = "No"
        sendConfirmation.isUserInteractionEnabled = false
        sendConfirmation.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        sendConfirmation.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        otp.label.textColor = UIColor.nativeRedColor()
        otp.label.text = "OTP"
        otp.placeholder = "Enter OTP"
        otp.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        otp.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        confirmOtp.label.textColor = UIColor.nativeRedColor()
        confirmOtp.label.text = "OTP"
        confirmOtp.placeholder = "Enter Confirm OTP"
        confirmOtp.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        confirmOtp.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
    }
}
