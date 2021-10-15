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
    @IBOutlet weak var resendCode: UIButton!
    var range = NSRange()
    var currentFormIndex: Int = 0
    
    
    var IsSendConfirmation: Bool = false
    var IsTermsAndConditionsRead: Bool = false
    var get_employee: GetEmployee?
    
    var counter = 30
    var timer : Timer?
    var wallet_beneficiary: WalletBeneficiary?
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
        
        self.resendCode.isHidden = true
        self.timer?.invalidate()
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
            self.sendConfirmation.text = "\(self.IsSendConfirmation ? "Yes" : "No")"
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
            
            //resend otp button
            self.timer?.invalidate()
            self.resendCode.isHidden = false
            self.resendCode.isEnabled = false
            self.counter = 30
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateCounter), userInfo: nil, repeats: true)
            break
        case 3:
            agreementView.isHidden = true
            self.sendConfirmationView.isHidden = true
            self.oneTimePasscodeView.isHidden = true
            //BUTTONS
            self.forwardBtn.isHidden = true
            self.confirmBtn.isHidden = true
            self.backBtn.isHidden = true
            
            if let wallet_beneficiary = self.wallet_beneficiary {
                self.referenceNumber.text = wallet_beneficiary.referenceNumber
                self.referenceNumber.setTextColor(UIColor.gray, for: .normal)
                self.referenceNumber.isEnabled = false
                self.referenceNumber.setOutlineColor(UIColor.nativeRedColor(), for: .disabled)
            }
            
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
            if self.IsSendConfirmation {
                if self.beneficiaryEmail.text == "" && self.beneficiaryNumber.text == "" {
                    self.view.makeToast("You need to insert Email or Mobile Number.")
                    return
                }
            }
            //Optional Value Checked (Email)
            if self.beneficiaryEmail.text != "" {
                if !isValidEmail(self.beneficiaryEmail.text!) {
                    self.view.makeToast("\(self.beneficiaryEmail.text!) is not a valid email.")
                }
            }
            if self.beneficiaryNumber.text != "" {
                if self.beneficiaryNumber.text!.count < 11 {
                    self.view.makeToast("Phone Number is not a valid.")
                }
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
                        self.view.hideToastActivity()
                        self.unFreezeScreen()
                        self.currentFormIndex += 1
                        self.setupConditions()
                    } else {
                        self.view.hideToastActivity()
                        self.unFreezeScreen()
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
        if !CustomReachability.isConnectedNetwork() {
            self.view.makeToast(NOINTERNETCONNECTION)
            return
        }
        self.view.makeToastActivity(.center)
        self.freezeScreen()
        self.timer?.invalidate()
        self.addBeneficiary { granted, message in
            if granted {
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    self.unFreezeScreen()
                    if let message = message {
                        self.view.makeToast(message)
                        return
                    } else {
                        self.currentFormIndex += 1
                        self.setupConditions()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    self.unFreezeScreen()
                    self.view.makeToast(SOMETHINGWENTWRONG)
                }
            }
        }
    }
    @IBAction func homeBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
    @IBAction func resendCodeTapped(_ sender: Any) {
        self.freezeScreen()
        self.view.makeToastActivity(.center)
        self.getOTP { granted in
            DispatchQueue.main.async {
                if granted {
                    self.resendCode.isEnabled = false
                    self.resendCode.setTitleColor(UIColor.init(hexString: "#E2E2E2"), for: .normal)
                } else {
                    self.view.hideToastActivity()
                    self.unFreezeScreen()
                    self.view.makeToast(SOMETHINGWENTWRONG)
                }
            }
        }
    }
    @objc func updateCounter() {
        if counter > 0 {
            counter -= 1
            if counter <= 9 {
                self.resendCode.setTitle("Resend code: 0\(counter) seconds", for: .normal)
            } else {
                self.resendCode.setTitle("Resend code: \(counter) seconds", for: .normal)
            }
            
        } else {
            self.resendCode.isEnabled = true
            self.resendCode.setTitleColor(UIColor.darkGray, for: .normal)
            self.timer?.invalidate()
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
        if textField.text == "" || textField.text!.count < 3 {
            return
        }
        switch textField.accessibilityLabel {
        case "BeneficiaryEmpId":
            self.view.makeToastActivity(.center)
            self.freezeScreen()
            getEmployee { granted in
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    self.unFreezeScreen()
                    if granted {
                        if let get_employee = self.get_employee {
                            self.beneficiaryName.text = get_employee.empName
                            self.beneficiaryNumber.text = get_employee.empCell1
                            self.beneficiaryEmail.text = get_employee.officialEmailID
                        } else {
                            self.beneficiaryName.text = ""
                            self.beneficiaryNumber.text = ""
                            self.beneficiaryEmail.text = ""
                        }
                    } else {
                        self.view.makeToast("No Employee Found")
                    }
                }
            }
            break
            
        default: break
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            return true
        }
        switch textField.accessibilityLabel {
        case "BeneficiaryEmpId", "OTP", "ConfirmOTP":
            let maxLength = 6
            let currentString: NSString = textField.text as! NSString
            let newString: NSString =
                    currentString.replacingCharacters(in: range, with: string) as NSString
            if newString.length <= maxLength {
                return true
            }
            return false
        case "BeneficiaryNumber":
            let maxLength = 11
            let currentString: NSString = textField.text as! NSString
            let newString: NSString =
                    currentString.replacingCharacters(in: range, with: string) as NSString
            if newString.length <= maxLength {
                return true
            }
            return false
        default: return true
        }
    }
}

//MARK: -API Calls
extension AddNewBeneficiaryViewController {
    private func getEmployee(_ handler: @escaping(Bool) -> Void) {
        let request_body = ["p_emp_id": self.beneficiaryEmpId.text!]
        let params = self.getAPIParameterNew(serviceName: S_WALLET_GET_EMPLOYEE, client: "", request_body: request_body)
        NetworkCalls.getwalletemployee(params: params) { granted, response in
            if granted {
                let json = JSON(response)
                if let result = json.dictionary?[_result]?.dictionary?[_getEmployee]?.array {
                    do {
                        if result.count == 0 {
                            handler(false)
                            return
                        }
                        for r in result {
                            let rawData = try r.rawData()
                            let getEmployee : GetEmployee = try JSONDecoder().decode(GetEmployee.self, from: rawData)
                            self.get_employee = getEmployee
                            handler(true)
                        }
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
        self.view.makeToastActivity(.center)
        self.freezeScreen()
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
    
    private func addBeneficiary(_ handler: @escaping(Bool, String?)->Void) {
        let request_body = [
            "p_employee_id": CURRENT_USER_LOGGED_IN_ID,
            "p_beneficiary_name": "\(self.beneficiaryName.text ?? "")",
            "p_beneficiary_emp_id": "\(self.beneficiaryEmpId.text ?? "")",
            "p_beneficiary_mobile_number": "\(self.beneficiaryNumber.text ?? "")",
            "p_beneficiary_nickname": "\(self.beneficiaryNickName.text ?? "")",
            "p_beneficiary_email": "\(self.beneficiaryEmail.text ?? "")",
            "p_is_email_notify": "\(self.IsSendConfirmation ? "Y" : "N")",
            "p_entry_type": "I",
            "p_otp": Int(((self.otp.text ?? "") as NSString).intValue),
            "p_user_id": CURRENT_USER_LOGGED_IN_ID
        ] as [String:Any]
        let params = self.getAPIParameterNew(serviceName: S_WALLETADD_BENEFICIARY, client: "", request_body: request_body)
        NetworkCalls.addwalletbeneficiaries(params: params) { granted, response in
            if granted {
                let json = JSON(response)
                if let getBeneficiary = json.dictionary?[_result]?.dictionary?[_getBeneficiary]?.array {
                    print(getBeneficiary)
                    do {
                        if getBeneficiary.count == 0 {
                            if let message = json.dictionary?[returnStatus]?["message"].string {
                                handler(true, message)
                                return
                            }
                        }
                        for gb in getBeneficiary {
                            let rawData = try gb.rawData()
                            let wallet_beneficiary: WalletBeneficiary = try JSONDecoder().decode(WalletBeneficiary.self, from: rawData)
                            self.wallet_beneficiary = wallet_beneficiary
                            AppDelegate.sharedInstance.db?.insert_tbl_wallet_beneficiaries(wallet_beneficiary: wallet_beneficiary, handler: { success in
                                if success {
                                    handler(true, nil)
                                } else {
                                    handler(false, nil)
                                }
                                return
                            })
                        }
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
                } else {
                    if let message = json.dictionary?[returnStatus]?["message"].string {
                        handler(true, message)
                    }
                }
            } else {
                handler(false, nil)
            }
        }
    }
}
