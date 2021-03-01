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
    @IBOutlet weak var forwardBtn: UIButton!
    
    
    var request_mode:   tbl_RequestModes?
    var ad_group:       tbl_la_ad_group?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeTopCornersRounded(roundView: self.mainView)
        self.title = "New Request"
        setupTextFields()
        
        message_textview.delegate = self
        
        message_type.delegate = self
        message_group.delegate = self
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
    
    @IBAction func forwardBtn_Tapped(_ sender: Any) {
        if request_mode == nil {
            self.view.makeToast("Message Type is mandatory")
            return
        }
        if message_textview.text == "Enter your message." {
            self.view.makeToast("Messsage is mandatory")
            return
        }
        if ad_group == nil {
            self.view.makeToast("Select Group is mandatory")
            return
        }
        forwardBtn.isEnabled = false
        let popup = UIStoryboard(name: "Popups", bundle: nil)
        let controller = popup.instantiateViewController(withIdentifier: "ConfirmationPopViewController") as! ConfirmationPopViewController
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        controller.modalTransitionStyle = .crossDissolve
        controller.delegate = self
        Helper.topMostController().present(controller, animated: true, completion: nil)
    }
}

extension NewRequestLeadershipAwazViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let storyboard = UIStoryboard(name: "Popups", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestListingViewController") as! NewRequestListingViewController
        switch textField.tag {
        case 0:
            controller.request_mode = AppDelegate.sharedInstance.db?.read_tbl_requestModes(module_id: CONSTANT_MODULE_ID).sorted(by: { (list1, list2) -> Bool in
                list1.REQ_MODE_DESC < list2.REQ_MODE_DESC
            })
            controller.heading = "Message Type"
            break
        case 1:
            controller.la_ad_group = AppDelegate.sharedInstance.db?.read_tbl_la_ad_group(query: "SELECT * FROM \(db_la_ad_group)").sorted(by: { (list1, list2) -> Bool in
                list1.AD_GROUP_NAME < list2.AD_GROUP_NAME
            })
            controller.heading = "Message Subject"
            break
        default:
            break
        }
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        controller.modalTransitionStyle = .crossDissolve
        controller.leadershipawazdelegate = self
        Helper.topMostController().present(controller, animated: true, completion: nil)
        return false
    }
}

extension NewRequestLeadershipAwazViewController: LeadershipAwazDelegate {
    func updateRequestMode(requestmode: tbl_RequestModes) {
        self.request_mode = requestmode
        self.message_type.text = requestmode.REQ_MODE_DESC
    }
    
    func updateMessageSubject(messagesubject: tbl_la_ad_group) {
        self.ad_group = messagesubject
        self.message_group.text = messagesubject.AD_GROUP_NAME
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


extension NewRequestLeadershipAwazViewController: ConfirmationProtocol {
    func confirmationProtocol() {
        var offline_data = tbl_Hr_Request_Logs()
        offline_data.REQ_ID = Int(CURRENT_USER_LOGGED_IN_ID)!
        offline_data.SERVER_ID_PK = randomInt()
        offline_data.TICKET_DATE = getLocalCurrentDate()
        offline_data.LOGIN_ID = Int(CURRENT_USER_LOGGED_IN_ID)!
        
        offline_data.REQ_MODE = self.request_mode!.SERVER_ID_PK
        
        offline_data.CREATED_DATE = getCurrentDate()
        offline_data.REQ_REMARKS = self.message_textview.text?.replacingOccurrences(of: "'", with: "''")
        offline_data.REF_ID = randomString()
        
        
    }
    
    func noButtonTapped() {
        forwardBtn.isEnabled = true
    }
    
    
}
