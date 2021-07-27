//
//  RiderPickupUpdatePopupViewController.swift
//  tcs_one_app
//
//  Created by TCS on 23/06/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields

class RiderPickupUpdatePopupViewController: UIViewController {

    @IBOutlet weak var CNNumber: MDCOutlinedTextField!
    @IBOutlet weak var Amount: MDCOutlinedTextField!
    @IBOutlet weak var Weight: MDCOutlinedTextField!
    @IBOutlet weak var Pisces: MDCOutlinedTextField!
    @IBOutlet weak var Destination: MDCOutlinedTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        view.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
        setupTextFields()
    }
    
    func setupTextFields() {
        CNNumber.label.textColor = UIColor.nativeRedColor()
        CNNumber.label.text = "CN Number"
        CNNumber.text = ""
        CNNumber.placeholder = ""
        CNNumber.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        CNNumber.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        CNNumber.delegate = self
        
        Amount.label.textColor = UIColor.nativeRedColor()
        Amount.label.text = "Amount"
        Amount.text = ""
        Amount.placeholder = ""
        Amount.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        Amount.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        Amount.delegate = self
        
        Weight.label.textColor = UIColor.nativeRedColor()
        Weight.label.text = "Weight"
        Weight.text = ""
        Weight.placeholder = ""
        Weight.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        Weight.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        Weight.delegate = self
        
        Pisces.label.textColor = UIColor.nativeRedColor()
        Pisces.label.text = "Pisces"
        Pisces.text = ""
        Pisces.placeholder = ""
        Pisces.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        Pisces.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        Pisces.delegate = self
        
        Destination.label.textColor = UIColor.nativeRedColor()
        Destination.label.text = "Destination"
        Destination.text = ""
        Destination.placeholder = ""
        Destination.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        Destination.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        Destination.delegate = self
    }
    
    @IBAction func forwardBtnTapped(_ sender: Any) {
        self.dismiss(animated: true) {}
    }
}


extension RiderPickupUpdatePopupViewController: UITextFieldDelegate {
    
}
