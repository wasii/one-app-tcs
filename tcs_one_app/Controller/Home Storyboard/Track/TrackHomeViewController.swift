//
//  TrackHomeViewController.swift
//  tcs_one_app
//
//  Created by TCS on 15/02/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class TrackHomeViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var search_textfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Track"
        self.makeTopCornersRounded(roundView: self.mainView)
        self.search_textfield.delegate = self
    }
    @IBAction func trackBtnTapped(_ sender: Any) {
        dismissKeyboard()
        if search_textfield.text == "" {
            self.view.makeToast("Tracking number is mandatory")
            return
        }
        if !CustomReachability.isConnectedNetwork() {
            self.view.makeToast(NOINTERNETCONNECTION)
            return
        }
        
    }
}

extension TrackHomeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 12
        let currentString: NSString = textField.text as! NSString
        let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length <= maxLength {
            return true
        }
        return false
    }
}
