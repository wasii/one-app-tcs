//
//  EnterPinViewController.swift
//  tcs_one_app
//
//  Created by ibs on 15/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import Toast_Swift
import SVProgressHUD
import MaterialComponents.MaterialTextControls_OutlinedTextFields

import SwiftSVG
protocol PinValidateDelegate {
    func pinValidateDelegate()
}
class EnterPinViewController: BaseViewController {

    var isVerifiedId = false
    var counter = 30
    var timer : Timer?
    @IBOutlet weak var enterPIN_view: UIView!
    @IBOutlet weak var resendCode_label: UILabel!
    @IBOutlet weak var resendBtn: UIButton!
    @IBOutlet weak var nextBtnOutlet: CustomButton!
    
    @IBOutlet weak var employeeId_textField: UITextField!
    
    @IBOutlet weak var enterPIN_textField: UITextField!
    @IBOutlet weak var mainView: UIView!
    
    var delegate: PinValidateDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        employeeId_textField.delegate = self
        enterPIN_textField.delegate = self
        
        
        
        self.makeTopCornersRounded(roundView: self.mainView)
        
    }
    
    @IBAction func resendBtn_Tapped(_ sender: Any) {
        FetchUser()
    }
    
    @IBAction func nextBtn_Tapped(_ sender: Any) {
        if employeeId_textField.text == "" {
            self.view.makeToast("Please Enter Employee Id")
        } else {
            if !CustomReachability.isConnectedNetwork() {
                self.view.makeToast(NOINTERNETCONNECTION)
                return
            }
            if isVerifiedId {
//                if self.enterPIN_textField.text == "1234" {
//                    
//                } else {
//                    self.view.makeToast("Pin isn't correct")
//                }
                self.freezeScreen()
                self.view.makeToastActivity(.center)
                let user_info = ["UserInfo": [
                        "employeeno": self.employeeId_textField.text!,
                        "pincode": self.enterPIN_textField.text!,
                        "applicationid": "2",
                        "firebasetoken" : FIREBASETOKEN ?? "1234"
                    ]
                ]
                let params = self.getAPIParameter(service_name: PIN_VALIDATE, request_body: user_info)
                NetworkCalls.pin_validate(params: params) { success, response in
                    if success {
                        DispatchQueue.main.async {
                            CURRENT_USER_LOGGED_IN_ID = self.employeeId_textField.text!
                            UserDefaults.standard.setValue(CURRENT_USER_LOGGED_IN_ID, forKeyPath: "CurrentUser")
                            self.unFreezeScreen()
                            self.view.hideToastActivity()
                            
                            self.dismiss(animated: true) {
                                self.delegate?.pinValidateDelegate()
                            }
                            
                            self.employeeId_textField.text = ""
                            self.enterPIN_textField.text = ""
                            self.isVerifiedId = false
                            self.enterPIN_view.isHidden = true
                            return
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.view.hideToastActivity()
                            self.unFreezeScreen()
                            self.view.makeToast(SOMETHINGWENTWRONG)
                        }
                    }
                }
                
            } else {
                self.FetchUser()
            }
        }
    }
    
    func FetchUser() {
        self.freezeScreen()
        self.view.makeToastActivity(.center)
        let user_info = ["UserInfo": [
                "employeeno": self.employeeId_textField.text!,
                "applicationid": "2",
                "deviceid": DEVICEID ?? ""
            ]
        ]
        let params = self.getAPIParameter(service_name: LOGIN, request_body: user_info)
        NetworkCalls.login(params: params) { success, response in
            if success {
                DispatchQueue.main.async {
                    self.timer?.invalidate()
                    self.unFreezeScreen()
                    self.isVerifiedId = true
                    self.enterPIN_view.isHidden = false
                    self.view.hideToastActivity()
                    self.resendBtn.isEnabled = false
                    self.counter = 30
                    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateCounter), userInfo: nil, repeats: true)
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
    @objc func updateCounter() {
        //example functionality
        if counter > 0 {
            counter -= 1
            self.resendCode_label.text = "Resend Code in: \(counter) Seconds"
        } else {
            self.resendBtn.isEnabled = true
            self.timer?.invalidate()
        }
    }
}


extension EnterPinViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 6
        let currentString: NSString = textField.text as! NSString
        let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}



//28x28
//40x40
//48x48
