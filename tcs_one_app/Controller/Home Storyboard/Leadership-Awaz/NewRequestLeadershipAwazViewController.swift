//
//  NewRequestLeadershipAwazViewController.swift
//  tcs_one_app
//
//  Created by TCS on 26/02/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import GrowingTextView
import SwiftyJSON

class NewRequestLeadershipAwazViewController: BaseViewController {
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var message_subject: UITextView!
    @IBOutlet weak var message_textview: UITextView!
    @IBOutlet weak var message_group: MDCOutlinedTextField!
    @IBOutlet weak var word_counter: UILabel!
    @IBOutlet weak var forwardBtn: UIButton!
    
    
    var request_mode:   tbl_RequestModes?
    var ad_group:       tbl_la_ad_group?
    
    
    var ticket_request: tbl_Hr_Request_Logs?
    @IBOutlet weak var mainHeading: UILabel!
    
    @IBOutlet weak var forward_btn: UIButton!
    @IBOutlet weak var reject_btn: UIButton!
    @IBOutlet weak var broadcast_btn: UIButton!
    
    var isChairmen = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeTopCornersRounded(roundView: self.mainView)
        self.title = "New Request"
        setupTextFields()
        
        message_subject.delegate = self
        message_textview.delegate = self
        message_group.delegate = self
        
        if let tr = ticket_request {
            self.message_textview.isEditable = false
            self.message_subject.isEditable = false
            self.message_group.isUserInteractionEnabled = false
            
            if let emp_info = AppDelegate.sharedInstance.db?.read_tbl_UserProfile().first {
                if emp_info.HIGHNESS == "1" {
                    isChairmen = true
                    if tr.TICKET_STATUS == "Pending" {
                        self.title = "Update Request"
                        self.mainHeading.text = "Update Request"
                        
                        self.broadcast_btn.isHidden = false
                        self.reject_btn.isHidden = false
                        self.forwardBtn.isHidden = true
                    }
                } else {
                    isChairmen = false
                    self.title = "View Request"
                    self.mainHeading.text = "View Request"
                    self.forwardBtn.isHidden = true
                }
            }
            
            self.message_subject.text = "\(tr.REQ_REMARKS ?? "")"
            self.message_subject.textColor = UIColor.black
            
            self.message_textview.text = "\(tr.HR_REMARKS ?? "")"
            self.message_textview.textColor = UIColor.black
            self.word_counter.text = "\(tr.HR_REMARKS?.count ?? 0)/525"
            
            let query = "SELECT * FROM \(db_la_ad_group) WHERE SERVER_ID_PK = '\(tr.ASSIGNED_TO!)'"
            let groupName = AppDelegate.sharedInstance.db?.read_tbl_la_ad_group(query: query).first?.AD_GROUP_NAME
            self.message_group.text = "\(groupName ?? "")"
        }
    }
    
    func setupTextFields() {
        message_group.label.textColor = UIColor.nativeRedColor()
        message_group.label.text = "Select Group"
        message_group.placeholder = ""
        message_group.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        message_group.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
    }
    
    @IBAction func forwardBtn_Tapped(_ sender: Any) {
        if message_subject.text == "Enter Subject" {
            self.view.makeToast("Subject is mandatory")
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
    @IBAction func broadcastBtnTapped(_ sender: Any) {
        
    }
}

extension NewRequestLeadershipAwazViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        switch textField.tag {
        case 0:
            return true
        case 1:
            let storyboard = UIStoryboard(name: "Popups", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestListingViewController") as! NewRequestListingViewController
            controller.la_ad_group = AppDelegate.sharedInstance.db?.read_tbl_la_ad_group(query: "SELECT * FROM \(db_la_ad_group)").sorted(by: { (list1, list2) -> Bool in
                list1.AD_GROUP_NAME < list2.AD_GROUP_NAME
            })
            controller.heading = "Message Subject"
            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .overFullScreen
            }
            controller.modalTransitionStyle = .crossDissolve
            controller.leadershipawazdelegate = self
            Helper.topMostController().present(controller, animated: true, completion: nil)
            return false
        default:
            return false
        }
    }
}

extension NewRequestLeadershipAwazViewController: LeadershipAwazDelegate {
    func updateRequestMode(requestmode: tbl_RequestModes) {}
    
    func updateMessageSubject(messagesubject: tbl_la_ad_group) {
        self.ad_group = messagesubject
        self.message_group.text = messagesubject.AD_GROUP_NAME
    }
}

extension NewRequestLeadershipAwazViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        switch textView.tag {
        case 0:
            if textView.text == "Enter Subject" {
                textView.text = ""
                textView.textColor = UIColor.black
            }
            break
        case 1:
            if textView.text == "Enter your message." {
                textView.text = ""
                textView.textColor = UIColor.black
            }
            break
        default:
            break
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        switch textView.tag {
        case 0:
            if textView.text.count <= 0 {
                textView.text = "Enter Subject"
                textView.textColor = UIColor.lightGray
            }
            break
        case 1:
            if textView.text.count <= 0 {
                textView.text = "Enter your message."
                textView.textColor = UIColor.lightGray
            }
            break
        default:
            break
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        switch textView.tag {
        case 1:
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
        default:
            return true
        }
    }
}


extension NewRequestLeadershipAwazViewController: ConfirmationProtocol {
    func confirmationProtocol() {
        if isChairmen {
            self.broadcastMessage()
        } else {
            self.addrequesttoserver()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func noButtonTapped() {
        forwardBtn.isEnabled = true
    }
    
    private func broadcastMessage() {
        let json = [
            "updawazticket" : [
                "access_token" : UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                "tickets": [
                    "status" : "Approved",
                    "ticket_id": "\(self.ticket_request!.SERVER_ID_PK!)"
                ]
            ]
        ] as [String:Any]
        let params = getAPIParameter(service_name: <#T##String#>, request_body: json)
    }
    
    
    private func addrequesttoserver() {
        var req_mod_id = AppDelegate.sharedInstance.db?.read_tbl_requestModes(module_id: CONSTANT_MODULE_ID)
        req_mod_id = req_mod_id?.filter({ f -> Bool in
            f.REQ_MODE_DESC == "Broadcasting"
        })
        let json = [
            "addawazticket" : [
                "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                "tickets" : [
                    "requestmodeid" : "\(req_mod_id?.first?.SERVER_ID_PK ?? 0)",
                    "reqsubject" : "\(self.message_subject.text.replacingOccurrences(of: "'", with: "''"))",
                    "requesterremarks" : "\(self.message_textview.text.replacingOccurrences(of: "'", with: "''"))",
                    "requestgroup" : "\(self.ad_group!.SERVER_ID_PK)",
                    "refid" : randomString(),
                    "ticketdate" : getCurrentDate()
                ]
            ]
        ] as [String:Any]
        let params = getAPIParameter(service_name: ADDAWAZTICKET, request_body: json)
        NetworkCalls.addawazrequest(params: params) { (granted, response) in
            if granted {
                var hrFile = [HrFiles]()
                var hrLog = [HrLog]()
                
                if let returnResponse = JSON(response).dictionary {
                    if let hr_logs  = returnResponse[_hr_logs]?.array {
                        for logs in hr_logs {
                            do {
                                let dictionary = try logs.rawData()
                                hrLog.append(try JSONDecoder().decode(HrLog.self, from: dictionary))
                            } catch let err {
                                print(err.localizedDescription)
                            }
                        }
                        for logs in hrLog {
                            AppDelegate.sharedInstance.db?.insert_tbl_hr_grievance(hr_log: logs)
                        }
                    }
                    if let hr_files = returnResponse[_hr_files]?.array {
                        for files in hr_files {
                            do {
                                let dictionary = try files.rawData()
                                hrFile.append(try JSONDecoder().decode(HrFiles.self, from: dictionary))
                            } catch let err {
                                print(err.localizedDescription)
                            }
                        }
                        for files in hrFile {
                            AppDelegate.sharedInstance.db?.insert_tbl_hr_files(hrfile: files)
                        }
                    }
                    let ticket_logs = returnResponse[_tickets_logs]?.array?.first
                    
                    DispatchQueue.main.async {
                        let ref_id = ticket_logs?["REF_ID"].string ?? ""
                        AppDelegate.sharedInstance.db?.deleteRow(tableName: db_hr_request, column: "REF_ID", ref_id: ref_id, handler: { success in
                            if success {
                                do {
                                    let dictionary = try ticket_logs?.rawData()
                                    let hrgrievance = try JSONDecoder().decode(HrRequest.self, from: dictionary!)
                                    
                                    DispatchQueue.main.async {
                                        AppDelegate.sharedInstance.db?.insert_tbl_hr_request(hrrequests: hrgrievance, { dump_succes in
                                            if success {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                    NotificationCenter.default.post(Notification.init(name: .refreshedViews))
                                                    Helper.topMostController().view.makeToast("Request Saved Successfully")
                                                }
                                                print("DUMPED UPDATED TICKET")
                                            }
                                        })
                                    }
                                } catch let err {
                                    print(err.localizedDescription)
                                }
                            }
                        })
                    }
                    print(returnResponse)
                }
            } else {
                print(response)
            }
        }
    }
}
