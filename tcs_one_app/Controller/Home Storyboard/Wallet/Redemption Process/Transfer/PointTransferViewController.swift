//
//  PointTransferViewController.swift
//  tcs_one_app
//
//  Created by TCS on 27/09/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields

class PointTransferViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var successMessageLabel: UILabel!
    
    @IBOutlet weak var transferFromView: CustomView!
    @IBOutlet weak var transferFromName: UILabel!
    @IBOutlet weak var transferFromEmpId: UILabel!
    @IBOutlet weak var transferFromCellNo: UILabel!
    
    @IBOutlet weak var beneficiaryDetailsView: CustomView!
    @IBOutlet weak var beneficiaryDetailsName: UILabel!
    @IBOutlet weak var beneficiaryDetailsEmpId: UILabel!
    @IBOutlet weak var beneficiaryDetailsCellNo: UILabel!
    
    @IBOutlet weak var transferPoints: MDCOutlinedTextField!
    @IBOutlet weak var remainingMaturePoints: MDCOutlinedTextField!
    @IBOutlet weak var transferReference: MDCOutlinedTextField!
    @IBOutlet weak var date: MDCOutlinedTextField!
    
    @IBOutlet weak var agreementView: CustomView!
    @IBOutlet weak var agreementLabel: UILabel!
    @IBOutlet weak var agreementBtn: UIButton!
    
    
    @IBOutlet weak var forwardBtn: UIButton!
    @IBOutlet weak var backwardBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var homeBtn: UIButton!
    
    var range = NSRange()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallet"
        
        makeTopCornersRounded(roundView: mainView)
        setupTextFields()
    }
    private func setupLabel() {
        agreementLabel.text = WALLET_AGREEMENT_TEXT
        self.agreementLabel.textColor =  UIColor.black
        let underlineAttriString = NSMutableAttributedString(string: WALLET_AGREEMENT_TEXT)
        range = (WALLET_AGREEMENT_TEXT as NSString).range(of: "Terms & Conditions")
        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        underlineAttriString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 13, weight: .medium), range: range)
        underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.nativeRedColor(), range: range)
        agreementLabel.attributedText = underlineAttriString
        agreementLabel.isUserInteractionEnabled = true
        agreementLabel.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapLabel(gesture:))))
    }
    @IBAction func tapLabel(gesture: UITapGestureRecognizer) {
        let termsRange = (WALLET_AGREEMENT_TEXT as NSString).range(of: "Terms & Conditions")
        if gesture.didTapAttributedTextInLabel(label: agreementLabel, inRange: termsRange) {
            print("Tapped terms")
        }
    }
    private func setupTextFields() {
        transferPoints.label.textColor = UIColor.nativeRedColor()
        transferPoints.label.text = "Transfer Points"
        transferPoints.placeholder = "Transfer Points"
        transferPoints.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        transferPoints.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        remainingMaturePoints.label.textColor = UIColor.nativeRedColor()
        remainingMaturePoints.text = "2101"
        remainingMaturePoints.setTextColor(UIColor.lightGray, for: .normal)
        remainingMaturePoints.label.text = "Remaining Mature Points"
        remainingMaturePoints.placeholder = "Remaining Mature Points"
        remainingMaturePoints.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        remainingMaturePoints.isUserInteractionEnabled = false
        
        transferReference.label.textColor = UIColor.nativeRedColor()
        transferReference.text = "One App - WALLET"
        transferReference.setTextColor(UIColor.lightGray, for: .normal)
        transferReference.label.text = "Transfer Reference"
        transferReference.placeholder = "Transfer Reference"
        transferReference.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        transferReference.isUserInteractionEnabled = false
        
        date.label.textColor = UIColor.nativeRedColor()
        date.text = "25/08/2021"
        date.setTextColor(UIColor.lightGray, for: .normal)
        date.label.text = "Date"
        date.placeholder = "Date"
        date.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        date.isUserInteractionEnabled = false
        
        setupLabel()
    }
}
