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

    
    @IBOutlet weak var leftBorder: UIView!
    @IBOutlet weak var confirmDetails: CustomView!
    @IBOutlet weak var middleBorder: UIView!
    @IBOutlet weak var otpVIew: CustomView!
    @IBOutlet weak var rightBorder: UIView!
    @IBOutlet weak var requestSubmitted: CustomView!
    
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
    
    @IBOutlet weak var agreementView: CustomView!
    @IBOutlet weak var oneTimePasscodeView: UIView!
    @IBOutlet weak var otp: MDCOutlinedTextField!
    @IBOutlet weak var confirmOtp: MDCOutlinedTextField!
    
    @IBOutlet weak var forwardBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var homeBtn: UIButton!
    var range = NSRange()
    var currentFormIndex: Int = 0
    
    var BeneficiaryName: String = ""
    var BeneficiaryEmpId: String = ""
    var BeneficiaryNumber: String = ""
    var BeneficiaryNickName: String = ""
    var BeneficiaryEmail: String = ""
    var IsSendConfirmation: Bool = false
    var IsTermsAndConditionsRead: Bool = false
    var OTP: String = ""
    var ConfirmOTP: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallet"
        makeTopCornersRounded(roundView: mainView)
        setupTextFields()
        setupLabel()
    }
    private func setupLabel() {
        termsAndConditiion.text = WALLET_AGREEMENT_TEXT
        self.termsAndConditiion.textColor =  UIColor.black
        let underlineAttriString = NSMutableAttributedString(string: WALLET_AGREEMENT_TEXT)
        range = (WALLET_AGREEMENT_TEXT as NSString).range(of: "Terms & Conditions")
        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        underlineAttriString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 13, weight: .medium), range: range)
        underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.nativeRedColor(), range: range)
        termsAndConditiion.attributedText = underlineAttriString
        termsAndConditiion.isUserInteractionEnabled = true
        termsAndConditiion.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapLabel(gesture:))))
    }
    @IBAction func tapLabel(gesture: UITapGestureRecognizer) {
        let termsRange = (WALLET_AGREEMENT_TEXT as NSString).range(of: "Terms & Conditions")
        if gesture.didTapAttributedTextInLabel(label: termsAndConditiion, inRange: termsRange) {
            print("Tapped terms")
        }
    }
    private func setupTextFields() {
        referenceNumber.accessibilityLabel = "ReferenceNumber"
        referenceNumber.label.textColor = UIColor.nativeRedColor()
        referenceNumber.label.text = "Reference Number"
        referenceNumber.placeholder = "Reference Number"
        referenceNumber.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        referenceNumber.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        beneficiaryName.accessibilityLabel = "BeneficiaryName"
        beneficiaryName.label.textColor = UIColor.nativeRedColor()
        beneficiaryName.label.text = "Beneficiary Name"
        beneficiaryName.placeholder = "Enter Beneficiary Name"
        beneficiaryName.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        beneficiaryName.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        beneficiaryEmpId.accessibilityLabel = "BeneficiaryEmpId"
        beneficiaryEmpId.label.textColor = UIColor.nativeRedColor()
        beneficiaryEmpId.label.text = "Beneficiary EMP ID"
        beneficiaryEmpId.placeholder = "Enter Beneficiary Employee Id"
        beneficiaryEmpId.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        beneficiaryEmpId.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        beneficiaryNumber.accessibilityLabel = "BeneficiaryNumber"
        beneficiaryNumber.label.textColor = UIColor.nativeRedColor()
        beneficiaryNumber.label.text = "Beneficiary Number"
        beneficiaryNumber.placeholder = "Enter Beneficiary Number"
        beneficiaryNumber.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        beneficiaryNumber.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        beneficiaryNickName.accessibilityLabel = "BeneficiaryNickName"
        beneficiaryNickName.label.textColor = UIColor.nativeRedColor()
        beneficiaryNickName.label.text = "Beneficiary Nickname"
        beneficiaryNickName.placeholder = "Enter Beneficiary Nickname"
        beneficiaryNickName.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        beneficiaryNickName.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        beneficiaryEmail.accessibilityLabel = "BeneficiaryEmail"
        beneficiaryEmail.label.textColor = UIColor.nativeRedColor()
        beneficiaryEmail.label.text = "Beneficiary Email"
        beneficiaryEmail.placeholder = "Enter Beneficiary Email"
        beneficiaryEmail.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        beneficiaryEmail.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        sendConfirmation.accessibilityLabel = "SendConfirmation"
        sendConfirmation.label.textColor = UIColor.nativeRedColor()
        sendConfirmation.label.text = "Send confirmation to Beneficiary when a transfer is made"
        sendConfirmation.text = "No"
        sendConfirmation.isUserInteractionEnabled = false
        sendConfirmation.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        sendConfirmation.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        otp.accessibilityLabel = "OTP"
        otp.label.textColor = UIColor.nativeRedColor()
        otp.label.text = "OTP"
        otp.placeholder = "Enter OTP"
        otp.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        otp.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        confirmOtp.accessibilityLabel = "ConfirmOTP"
        confirmOtp.label.textColor = UIColor.nativeRedColor()
        confirmOtp.label.text = "OTP"
        confirmOtp.placeholder = "Enter Confirm OTP"
        confirmOtp.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        confirmOtp.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        setupConditions()
    }
    
    private func setupConditions() {
        self.beneficiaryLabel.isHidden = false
        self.referenceNumber.isHidden = false
        self.beneficiaryName.isHidden = false
        self.beneficiaryEmpId.isHidden = false
        self.beneficiaryNickName.isHidden = false
        self.beneficiaryEmail.isHidden = false
        self.sendConfirmationView.isHidden = false
        self.sendConfirmation.isHidden = false
        self.agreementView.isHidden = false
        self.oneTimePasscodeView.isHidden = false
        self.forwardBtn.isHidden = false
        self.backBtn.isHidden = false
        self.confirmBtn.isHidden = false
        self.homeBtn.isHidden = false
        switch self.currentFormIndex {
        case 0:
            self.beneficiaryLabel.isHidden = true
            self.referenceNumber.isHidden = true
            self.agreementView.isHidden = true
            self.sendConfirmation.isHidden = true
            self.oneTimePasscodeView.isHidden = true
            //BUTTONS
            self.backBtn.isHidden = true
            self.confirmBtn.isHidden = true
            self.homeBtn.isHidden = true
            
            break
        case 1:
            self.beneficiaryLabel.isHidden = true
            self.referenceNumber.isHidden = true
            
            self.sendConfirmationView.isHidden = true
            self.oneTimePasscodeView.isHidden = true
            //BUTTONS
            self.confirmBtn.isHidden = true
            self.homeBtn.isHidden = true
            
            self.leftBorder.backgroundColor = UIColor.nativeRedColor()
            break
        case 2:
            self.beneficiaryLabel.isHidden = true
            self.referenceNumber.isHidden = true
            agreementView.isHidden = true
            self.sendConfirmationView.isHidden = true
            //BUTTONS
            self.confirmBtn.isHidden = true
            self.homeBtn.isHidden = true
            
            self.middleBorder.backgroundColor = UIColor.nativeRedColor()
            break
        case 3:
            agreementView.isHidden = true
            self.sendConfirmationView.isHidden = true
            self.oneTimePasscodeView.isHidden = true
            //BUTTONS
            self.forwardBtn.isHidden = true
            self.confirmBtn.isHidden = true
            self.backBtn.isHidden = true
            
            self.rightBorder.backgroundColor = UIColor.nativeRedColor()
            break
        default: break
            
        }
    }
    @IBAction func forwardBtnTapped(_ sender: Any) {
        if self.currentFormIndex == 3 {
            return
        }
        switch currentFormIndex {
        case 0:
            if self.beneficiaryName.text == "" {
                self.view.makeToast("Beneficiary Name cannot be left blank.")
                return
            }
            if self.beneficiaryEmpId.text == "" {
                self.view.makeToast("Beneficiary Emp Id cannot be left blank.")
                return
            }
            if self.beneficiaryNumber.text == "" {
                self.view.makeToast("Beneficiary Number cannot be left blank.")
                return
            }
            if self.beneficiaryNickName.text == "" {
                self.view.makeToast("Beneficiary Nickname cannot be left blank.")
                return
            }
            BeneficiaryName = self.beneficiaryName.text!
            BeneficiaryEmpId = self.beneficiaryEmpId.text!
            BeneficiaryNumber = self.beneficiaryNumber.text!
            BeneficiaryNickName = self.beneficiaryNickName.text!
            
            break
        case 1:
            if !self.IsTermsAndConditionsRead {
                self.view.makeToast("You need to accept Terms and Conditions.")
                return
            }
            self.IsTermsAndConditionsRead = true
            break
        case 2:
            if self.otp.text != self.confirmOtp.text {
                self.view.makeToast("OTP isn't same.")
                return
            }
            break
        default: break
        }
        self.currentFormIndex += 1
        setupConditions()
    }
    @IBAction func backBtnTapped(_ sender: Any) {
        if self.currentFormIndex == 0 {
            return
        }
        self.currentFormIndex -= 1
        setupConditions()
    }
    @IBAction func confirmBtnTapped(_ sender: Any) {
    }
    @IBAction func homeBtnTapped(_ sender: Any) {
    }
    
    @IBAction func sendConfirmationBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.IsSendConfirmation = sender.isSelected
        if sender.isSelected {
            sender.setImage(UIImage(named: "check"), for: .normal)
        } else {
            sender.setImage(nil, for: .normal)
        }
    }
    
    @IBAction func readTermsBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.IsTermsAndConditionsRead = sender.isSelected
        if sender.isSelected {
            sender.setImage(UIImage(named: "check"), for: .normal)
        } else {
            sender.setImage(nil, for: .normal)
        }
    }
}
extension UITapGestureRecognizer {
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
         // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
         let layoutManager = NSLayoutManager()
         let textContainer = NSTextContainer(size: CGSize.zero)
         let textStorage = NSTextStorage(attributedString: label.attributedText!)

         // Configure layoutManager and textStorage
         layoutManager.addTextContainer(textContainer)
         textStorage.addLayoutManager(layoutManager)

         // Configure textContainer
         textContainer.lineFragmentPadding = 0.0
         textContainer.lineBreakMode = label.lineBreakMode
         textContainer.maximumNumberOfLines = label.numberOfLines
         let labelSize = label.bounds.size
         textContainer.size = labelSize

         // Find the tapped character location and compare it to the specified range
         let locationOfTouchInLabel = self.location(in: label)
         let textBoundingBox = layoutManager.usedRect(for: textContainer)
         //let textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                               //(labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
         let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)

         //let locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x,
                                                         // locationOfTouchInLabel.y - textContainerOffset.y);
         let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
         let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
         return NSLocationInRange(indexOfCharacter, targetRange)
     }
}
extension AddNewBeneficiaryViewController: UITextFieldDelegate {
    
}
