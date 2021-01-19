//
//  AddMemoPopupViewController.swift
//  tcs_one_app
//
//  Created by TCS on 18/11/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit

class AddMemoPopupViewController: UIViewController {

    @IBOutlet weak var characterCounter: UILabel!
    @IBOutlet weak var closure_remarks: UILabel!
    @IBOutlet weak var labelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var memoTextView: UITextView!
    var delegate: AddClosureRemarksDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        memoTextView.delegate = self
        view.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
    }
    @IBAction func applyBtnTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.addClosureRemarks(closure_remarks: self.memoTextView.text!)
        }
    }
    @IBAction func cancelBtn_Tapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


extension AddMemoPopupViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxLength = 525
        let currentString: NSString = textView.text as! NSString
        let newString: NSString =
                currentString.replacingCharacters(in: range, with: text) as NSString
        if newString.length <= maxLength {
            self.characterCounter.text = "\(newString.length)/525"
            return true
        }
        return false
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.1) {
            self.labelTopConstraint.constant = 4
            self.closure_remarks.font = UIFont.systemFont(ofSize: 12)
            self.view.layoutIfNeeded()
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.count <= 0 {
            UIView.animate(withDuration: 0.1) {
                self.labelTopConstraint.constant = 25
                self.closure_remarks.font = UIFont.systemFont(ofSize: 15)
                self.view.layoutIfNeeded()
            }
        }
    }
}
