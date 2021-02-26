//
//  NewRequestLeadershipAwazViewController.swift
//  tcs_one_app
//
//  Created by TCS on 26/02/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields

class NewRequestLeadershipAwazViewController: BaseViewController {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var message_type: MDCOutlinedTextField!
    
    @IBOutlet weak var message_textview: UITextView!
    @IBOutlet weak var message_group: MDCOutlinedTextField!
    @IBOutlet weak var word_counter: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeTopCornersRounded(roundView: self.mainView)
        self.title = "New Request"
        setupTextFields()
        
        message_textview.delegate = self
    }
    
    func setupTextFields() {
        message_type.label.textColor = UIColor.nativeRedColor()
        message_type.label.text = "Message Type"
        message_type.placeholder = ""
        message_type.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        message_type.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        message_group.label.textColor = UIColor.nativeRedColor()
        message_group.label.text = "Select Group"
        message_group.placeholder = ""
        message_group.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        message_group.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
    }
}



extension NewRequestLeadershipAwazViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Enter your message." {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.count <= 0 {
            textView.text = "Enter your message."
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxLength = 525
        let currentString: NSString = textView.text as! NSString
        let newString: NSString =
                currentString.replacingCharacters(in: range, with: text) as NSString
        if let texts = textView.text,
           let textRange = Range(range, in: texts) {
            let updatedText = texts.replacingCharacters(in: textRange, with: text)
            if updatedText.containsEmoji {
                return false
            }
        }
        if newString.length <= maxLength {
            self.word_counter.text = "\(newString.length)/525"
            return true
        }
        return false
    }
}
