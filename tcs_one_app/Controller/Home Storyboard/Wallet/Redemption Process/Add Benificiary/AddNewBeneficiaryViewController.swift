//
//  AddNewBeneficiaryViewController.swift
//  tcs_one_app
//
//  Created by TCS on 22/09/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import SwiftyJSON

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
    
    @IBOutlet weak var enterDetailImg: UIImageView!
    @IBOutlet weak var enterDetailLabel: UILabel!
    @IBOutlet weak var confirmDetailImg: UIImageView!
    @IBOutlet weak var confirmDetailLabel: UILabel!
    @IBOutlet weak var enterOTPImg: UIImageView!
    @IBOutlet weak var enterOTPLabel: UILabel!
    @IBOutlet weak var requestSubmittedImg: UIImageView!
    @IBOutlet weak var requestSubmittedLabel: UILabel!
    var range = NSRange()
    var currentFormIndex: Int = 0
    
    
    var IsSendConfirmation: Bool = false
    var IsTermsAndConditionsRead: Bool = false
    var emp_model: [User]?
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
        beneficiaryName.text = "Beneficiary Name"
        beneficiaryName.textColor = UIColor.darkGray
        beneficiaryName.placeholder = "Enter Beneficiary Name"
        beneficiaryName.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        beneficiaryName.setTextColor(UIColor.gray, for: .normal)
        beneficiaryName.isUserInteractionEnabled = false
        
        beneficiaryEmpId.accessibilityLabel = "BeneficiaryEmpId"
        beneficiaryEmpId.label.textColor = UIColor.nativeRedColor()
        beneficiaryEmpId.label.text = "Beneficiary EMP ID"
        beneficiaryEmpId.placeholder = "Enter Beneficiary Employee Id"
        beneficiaryEmpId.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        beneficiaryEmpId.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        beneficiaryEmpId.delegate = self
        
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
        
        //Labels and Image
        confirmDetailImg.image = UIImage(named: "confirm-G")
        confirmDetailLabel.textColor = UIColor.darkGray
        
        enterOTPImg.image = UIImage(named: "otp-G")
        enterOTPLabel.textColor = UIColor.darkGray
        
        requestSubmittedImg.image = UIImage(named: "submit-G")
        requestSubmittedLabel.textColor = UIColor.darkGray
        
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
            
            
            beneficiaryEmpId.setTextColor(UIColor.black, for: .normal)
            beneficiaryEmpId.isUserInteractionEnabled = true
            beneficiaryEmpId.label.textColor = UIColor.black
            
            //OPTIONAL VALUES
            beneficiaryNumber.setTextColor(UIColor.black, for: .normal)
            beneficiaryNumber.isUserInteractionEnabled = true
            beneficiaryNumber.label.textColor = UIColor.black
            beneficiaryNumber.isEnabled = true
            
            beneficiaryNickName.setTextColor(UIColor.black, for: .normal)
            beneficiaryNickName.isUserInteractionEnabled = true
            beneficiaryNickName.isEnabled = true
            
            beneficiaryEmail.setTextColor(UIColor.black, for: .normal)
            beneficiaryEmail.isUserInteractionEnabled = true
            beneficiaryEmail.isEnabled = true
            
            break
        case 1:
            self.beneficiaryLabel.isHidden = true
            self.referenceNumber.isHidden = true
            
            self.sendConfirmationView.isHidden = true
            self.oneTimePasscodeView.isHidden = true
            //BUTTONS
            self.confirmBtn.isHidden = true
            self.homeBtn.isHidden = true
            
            //Labels and Image
            confirmDetailImg.image = UIImage(named: "confirm-R")
            confirmDetailLabel.textColor = UIColor.nativeRedColor()
            
            self.leftBorder.backgroundColor = UIColor.nativeRedColor()
            beneficiaryEmpId.setTextColor(UIColor.gray, for: .normal)
            beneficiaryEmpId.isUserInteractionEnabled = false
            beneficiaryEmpId.label.textColor = UIColor.gray
            beneficiaryNumber.setTextColor(UIColor.gray, for: .normal)
            beneficiaryNumber.isUserInteractionEnabled = false
            
            if beneficiaryNumber.text == "" {
                beneficiaryNumber.isEnabled = false
                beneficiaryNumber.setOutlineColor(UIColor.nativeRedColor(), for: .disabled)
            }
            
            
            beneficiaryNickName.setTextColor(UIColor.gray, for: .normal)
            beneficiaryNickName.isUserInteractionEnabled = false
            
            if beneficiaryNickName.text == "" {
                beneficiaryNickName.isEnabled = false
                beneficiaryNickName.setOutlineColor(UIColor.nativeRedColor(), for: .disabled)
            }
            
            beneficiaryEmail.setTextColor(UIColor.gray, for: .normal)
            beneficiaryEmail.isUserInteractionEnabled = false
            if beneficiaryEmail.text == "" {
                beneficiaryEmail.isEnabled = false
                beneficiaryEmail.setOutlineColor(UIColor.nativeRedColor(), for: .disabled)
            }
            
            break
        case 2:
            self.beneficiaryLabel.isHidden = true
            self.referenceNumber.isHidden = true
            agreementView.isHidden = true
            self.sendConfirmationView.isHidden = true
            //BUTTONS
            self.forwardBtn.isHidden = true
            self.homeBtn.isHidden = true
            
            //Labels and Image
            confirmDetailImg.image = UIImage(named: "confirm-R")
            confirmDetailLabel.textColor = UIColor.nativeRedColor()
            enterOTPImg.image = UIImage(named: "otp-R")
            enterOTPLabel.textColor = UIColor.nativeRedColor()
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
            
            
            //Labels and Image
            confirmDetailImg.image = UIImage(named: "confirm-R")
            confirmDetailLabel.textColor = UIColor.nativeRedColor()
            enterOTPImg.image = UIImage(named: "otp-R")
            enterOTPLabel.textColor = UIColor.nativeRedColor()
            requestSubmittedImg.image = UIImage(named: "submit-R")
            requestSubmittedLabel.textColor = UIColor.nativeRedColor()
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
            if self.beneficiaryEmpId.text == "" {
                self.view.makeToast("Beneficiary Emp Id cannot be left blank.")
                return
            }
            break
        case 1:
            if !self.IsTermsAndConditionsRead {
                self.view.makeToast("You need to accept Terms and Conditions.")
                return
            }
            self.IsTermsAndConditionsRead = true
            //GET OTP
            if !CustomReachability.isConnectedNetwork() {
                self.view.makeToast(NOINTERNETCONNECTION)
                return
            }
            self.getOTP { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.currentFormIndex += 1
                        self.setupConditions()
                    } else {
                        self.view.makeToast(SOMETHINGWENTWRONG)
                    }
                }
            }
            return
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
        self.currentFormIndex += 1
        self.setupConditions()
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
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.accessibilityLabel {
        case "BeneficiaryEmpId":
            self.view.makeToastActivity(.center)
            self.freezeScreen()
            getEmployee { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.view.hideToastActivity()
                        self.unFreezeScreen()
                        
                        self.beneficiaryName.text = self.emp_model?.first?.empName ?? ""
                    } else {
                        self.unFreezeScreen()
                        self.view.hideToastActivity()
                        self.view.makeToast("No Employee Found")
                    }
                }
            }
            break
            
        default: break
        }
    }
}

//MARK: -API Calls
extension AddNewBeneficiaryViewController {
    private func getEmployee(_ handler: @escaping(Bool) -> Void) {
        let search_employee = [
            "empployee": [
                "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                "emp_id" :"\(self.beneficiaryEmpId.text!)"
            ]
        ]
        let params = self.getAPIParameter(service_name: SERACH_EMPLOYEE, request_body: search_employee)
        NetworkCalls.search_empoloyee(params: params) { (success, response) in
            if success {
                if let emp_data = JSON(response).array?.first {
                    do {
                        self.emp_model = [User]()
                        let user = try emp_data.rawData()
                        self.emp_model!.append(try JSONDecoder().decode(User.self, from: user))
                        handler(true)
                    } catch let err {
                        handler(false)
                        print(err.localizedDescription)
                    }
                } else {
                    handler(false)
                }
            } else {
                handler(false)
            }
        }
    }
    
    private func getOTP(_ handler: @escaping(Bool)-> Void) {
        let request_body = [
            "employeeno": CURRENT_USER_LOGGED_IN_ID,
            "applicationid": "2",
            "deviceid": DEVICEID ?? ""
        ]
        let params = self.getAPIParameterNew(serviceName: S_WALLET_PIN_GEN, client: "", request_body: request_body)
        NetworkCalls.getwalletpin(params: params) { granted in
            if granted {
                handler(true)
            } else {
                handler(false)
            }
        }
    }
}
