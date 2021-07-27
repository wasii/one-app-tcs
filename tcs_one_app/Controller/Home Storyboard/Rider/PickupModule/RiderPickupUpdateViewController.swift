//
//  RiderPickupUpdateViewController.swift
//  tcs_one_app
//
//  Created by TCS on 22/06/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields

class RiderPickupUpdateViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var PickupNumber: MDCOutlinedTextField!
    @IBOutlet weak var AccountNumber: MDCOutlinedTextField!
    @IBOutlet weak var CustomerName: MDCOutlinedTextField!
    @IBOutlet weak var Address: UITextView!
    @IBOutlet weak var DeliveredRadioButton: UIImageView!
    @IBOutlet weak var UndeliveredRadioButton: UIImageView!
    @IBOutlet weak var Comments: UITextView!
    
    var selectedDeliveredOption: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Rider"
        
        self.makeTopCornersRounded(roundView: self.mainView)
        setupTextFields()
    }
    
    func setupTextFields() {
        PickupNumber.label.textColor = UIColor.nativeRedColor()
        PickupNumber.label.text = "Pickup Number"
        PickupNumber.text = ""
        PickupNumber.placeholder = ""
        PickupNumber.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        PickupNumber.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        PickupNumber.delegate = self
        
        AccountNumber.label.textColor = UIColor.nativeRedColor()
        AccountNumber.label.text = "Account Number"
        AccountNumber.text = ""
        AccountNumber.placeholder = ""
        AccountNumber.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        AccountNumber.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        AccountNumber.delegate = self
        
        CustomerName.label.textColor = UIColor.nativeRedColor()
        CustomerName.label.text = "Customer Name"
        CustomerName.text = ""
        CustomerName.placeholder = ""
        CustomerName.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        CustomerName.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        CustomerName.delegate = self
    }
    @IBAction func deliveredBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.tag == 0 {
            if sender.isSelected {
                self.DeliveredRadioButton.image = UIImage(named: "radioMark")
                self.UndeliveredRadioButton.image = UIImage(named: "radioUnmark")
                self.selectedDeliveredOption = 1
            } else {
                self.DeliveredRadioButton.image = UIImage(named: "radioUnmark")
                self.UndeliveredRadioButton.image = UIImage(named: "radioUnmark")
                self.selectedDeliveredOption = 0
            }
        } else {
            if sender.isSelected {
                self.DeliveredRadioButton.image = UIImage(named: "radioUnmark")
                self.UndeliveredRadioButton.image = UIImage(named: "radioMark")
                self.selectedDeliveredOption = 2
            } else {
                self.DeliveredRadioButton.image = UIImage(named: "radioUnmark")
                self.UndeliveredRadioButton.image = UIImage(named: "radioUnmark")
                self.selectedDeliveredOption = 0
            }
        }
    }
    
    
    @IBAction func forwardBtnTapped(_ sender: Any) {
    }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
    }
}


extension RiderPickupUpdateViewController: UITextFieldDelegate {}
