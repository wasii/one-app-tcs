//
//  IncidentInvestigationViewController.swift
//  tcs_one_app
//
//  Created by TCS on 06/01/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class IncidentInvestigationViewController: BaseViewController {

    @IBOutlet weak var di_view: UIView!
    @IBOutlet weak var detal_investigation_textview: UITextView!
    @IBOutlet weak var detail_investigation_wordcounter: UILabel!
    
    @IBOutlet weak var pn_view: UIView!
    @IBOutlet weak var prosecution_narrative_textview: UITextView!
    @IBOutlet weak var prosecution_narrative_wordcounter: UILabel!
    
    @IBOutlet weak var dn_view: UIView!
    @IBOutlet weak var defense_narrative_textview: UITextView!
    @IBOutlet weak var defense_narrative_wordcounter: UILabel!
    
    @IBOutlet weak var c_view: UIView!
    @IBOutlet weak var challenges_textview: UITextView!
    @IBOutlet weak var challenges_wordcounter: UILabel!
    
    @IBOutlet weak var f_view: UIView!
    @IBOutlet weak var fact_textview: UITextView!
    @IBOutlet weak var facts_wordcounter: UILabel!
    
    @IBOutlet weak var finding_view: UIView!
    @IBOutlet weak var findings_textview: UITextView!
    @IBOutlet weak var findings_wordcounter: UILabel!
    
    @IBOutlet weak var o_view: UIView!
    @IBOutlet weak var opinions_textview: UITextView!
    @IBOutlet weak var opinions_wordcounter: UILabel!
    
    var ticket: tbl_Hr_Request_Logs?
    var isEditable = false
    
    var updatedelegate: UpdateIncidentInvestigation?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Incident Investigation"
        
        detal_investigation_textview.delegate = self
        prosecution_narrative_textview.delegate = self
        defense_narrative_textview.delegate = self
        challenges_textview.delegate = self
        fact_textview.delegate = self
        findings_textview.delegate = self
        opinions_textview.delegate = self
        
        setupTextFields()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isEditable {
            self.updatedelegate?.updateIncidentInvestigation(ticket: self.ticket!)
        }
    }
    
    func setupTextFields() {
        if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_View_Detailed_Investigation).count > 0 {
            self.di_view.isHidden = false
            if self.isEditable {
                self.detal_investigation_textview.isUserInteractionEnabled = true
                if ticket?.DETAILED_INVESTIGATION == "" {
                    self.detal_investigation_textview.text = ENTER_DETAIL_INVESTIGATION
                } else {
                    self.detal_investigation_textview.text = ticket?.DETAILED_INVESTIGATION ?? ""
                }
                
            } else {
                self.detal_investigation_textview.text = ticket?.DETAILED_INVESTIGATION ?? ""
                self.detal_investigation_textview.isUserInteractionEnabled = false
            }
        } else {
            self.di_view.isHidden = true
        }
        
        if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_View_Prosecution_Narrative).count > 0 {
            self.pn_view.isHidden = false
            if self.isEditable {
                self.prosecution_narrative_textview.isUserInteractionEnabled = true
                if ticket?.PROSECUTION_NARRATIVE == "" {
                    self.prosecution_narrative_textview.text = ENTER_PROCECUSTION_NARRATIVE
                } else {
                    self.prosecution_narrative_textview.text = ticket?.PROSECUTION_NARRATIVE ?? ""
                }
            } else {
                self.prosecution_narrative_textview.isUserInteractionEnabled = false
                self.prosecution_narrative_textview.text = ticket?.PROSECUTION_NARRATIVE ?? ""
            }
        } else {
            self.pn_view.isHidden = true
        }
        
        if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_View_Defense_Narrative).count > 0 {
            self.dn_view.isHidden = false
            if self.isEditable {
                self.defense_narrative_textview.isUserInteractionEnabled = true
                if ticket?.DEFENSE_NARRATIVE == "" {
                    self.defense_narrative_textview.text = ENTER_DEFENSE_NARRATIVE
                } else {
                    self.defense_narrative_textview.text = ticket?.DEFENSE_NARRATIVE ?? ""
                }
            } else {
                self.defense_narrative_textview.isUserInteractionEnabled = false
                self.defense_narrative_textview.text = ticket?.DEFENSE_NARRATIVE ?? ""
            }
        } else {
            self.dn_view.isHidden = true
        }
        
        if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_View_Challenges).count > 0 {
            self.c_view.isHidden = false
            if self.isEditable {
                self.challenges_textview.isUserInteractionEnabled = true
                if ticket?.CHALLENGES == "" {
                    self.challenges_textview.text = ENTER_CHALLENGES
                } else {
                    self.challenges_textview.text = ticket?.CHALLENGES ?? ""
                }
            } else {
                self.challenges_textview.isUserInteractionEnabled = false
                self.challenges_textview.text = ticket?.CHALLENGES ?? ""
            }
        } else {
            self.c_view.isHidden = true
        }
        
        if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_View_Facts).count > 0 {
            self.f_view.isHidden = false
            if self.isEditable {
                self.fact_textview.isUserInteractionEnabled = true
                if ticket?.FACTS == "" {
                    self.fact_textview.text = ENTER_FACTS
                } else {
                    self.fact_textview.text = ticket?.FACTS ?? ""
                }
            } else {
                self.fact_textview.isUserInteractionEnabled = false
                self.fact_textview.text = ticket?.FACTS ?? ""
            }
        } else {
            self.f_view.isHidden = true
        }
        
        if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_View_Findings).count > 0 {
            self.finding_view.isHidden = false
            if self.isEditable {
                self.findings_textview.isUserInteractionEnabled = true
                if ticket?.FINDINGS == "" {
                    self.findings_textview.text = ENTER_FINDINGS
                } else {
                    self.findings_textview.text = ticket?.FINDINGS ?? ""
                }
            } else {
                self.findings_textview.isUserInteractionEnabled = false
                self.findings_textview.text = ticket?.FINDINGS ?? ""
            }
        } else {
            self.finding_view.isHidden = true
        }
        
        if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_View_Opinions).count > 0 {
            self.o_view.isHidden = false
            if self.isEditable {
                self.opinions_textview.isUserInteractionEnabled = true
                if ticket?.OPINION == "" {
                    self.opinions_textview.text = ENTER_FINDINGS
                } else {
                    self.opinions_textview.text = ticket?.OPINION ?? ""
                }
            } else {
                self.opinions_textview.isUserInteractionEnabled = false
                self.opinions_textview.text = ticket?.OPINION ?? ""
            }
        } else {
            self.o_view.isHidden = true
        }
    }
}


extension IncidentInvestigationViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        switch textView.tag {
        case ENTER_DETAIL_INVESTIGATION_TAG:
            if textView.text == ENTER_DETAIL_INVESTIGATION {
                textView.text = ""
            }
            break
        case ENTER_PROCECUSTION_NARRATIVE_TAG:
            if textView.text == ENTER_PROCECUSTION_NARRATIVE {
                textView.text = ""
            }
            break
        case ENTER_DEFENSE_NARRATIVE_TAG:
            if textView.text == ENTER_DEFENSE_NARRATIVE {
                textView.text = ""
            }
            break
        case ENTER_CHALLENGES_TAG:
            if textView.text == ENTER_CHALLENGES {
                textView.text = ""
            }
            break
        case ENTER_FACTS_TAG:
            if textView.text == ENTER_FACTS {
                textView.text = ""
            }
            break
        case ENTER_FINDINGS_TAG:
            if textView.text == ENTER_FINDINGS {
                textView.text = ""
            }
            break
        case ENTER_OPINIONS_TAG:
            if textView.text == ENTER_OPINIONS {
                textView.text = ""
            }
            break
        default:
            break
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        switch textView.tag {
        case ENTER_DETAIL_INVESTIGATION_TAG:
            if textView.text.count <= 0 {
                textView.text = ENTER_DETAIL_INVESTIGATION
                ticket?.DETAILED_INVESTIGATION = ""
            } else {
                ticket?.DETAILED_INVESTIGATION = textView.text
            }
            break
        case ENTER_PROCECUSTION_NARRATIVE_TAG:
            if textView.text.count <= 0 {
                textView.text = ENTER_PROCECUSTION_NARRATIVE
                ticket?.PROSECUTION_NARRATIVE = ""
            } else {
                ticket?.PROSECUTION_NARRATIVE = textView.text
            }
            break
        case ENTER_DEFENSE_NARRATIVE_TAG:
            if textView.text.count <= 0 {
                textView.text = ENTER_DEFENSE_NARRATIVE
                ticket?.DEFENSE_NARRATIVE = ""
            } else {
                ticket?.DEFENSE_NARRATIVE = textView.text
            }
            break
        case ENTER_CHALLENGES_TAG:
            if textView.text.count <= 0 {
                textView.text = ENTER_CHALLENGES
                ticket?.CHALLENGES = ""
            } else {
                ticket?.CHALLENGES = textView.text
            }
            break
        case ENTER_FACTS_TAG:
            if textView.text.count <= 0 {
                textView.text = ENTER_FACTS
                ticket?.FACTS = ""
            } else {
                ticket?.FACTS = textView.text
            }
            break
        case ENTER_FINDINGS_TAG:
            if textView.text.count <= 0 {
                textView.text = ENTER_FINDINGS
                ticket?.FINDINGS = ""
            } else {
                ticket?.FINDINGS = textView.text
            }
            break
        case ENTER_OPINIONS_TAG:
            if textView.text.count <= 0 {
                textView.text = ENTER_OPINIONS
                ticket?.OPINION = ""
            } else {
                ticket?.OPINION = textView.text
            }
            break
        default:
            break
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxLength = 200
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
            switch textView.tag {
            case ENTER_DETAIL_INVESTIGATION_TAG:
                self.detail_investigation_wordcounter.text = "\(newString.length)/200"
                return true
            case ENTER_PROCECUSTION_NARRATIVE_TAG:
                self.prosecution_narrative_wordcounter.text = "\(newString.length)/200"
                return true
            case ENTER_DEFENSE_NARRATIVE_TAG:
                self.defense_narrative_wordcounter.text = "\(newString.length)/200"
                return true
            case ENTER_CHALLENGES_TAG:
                self.challenges_wordcounter.text = "\(newString.length)/200"
                return true
            case ENTER_FACTS_TAG:
                self.facts_wordcounter.text = "\(newString.length)/200"
                return true
            case ENTER_FINDINGS_TAG:
                self.findings_wordcounter.text = "\(newString.length)/200"
                return true
            case ENTER_OPINIONS_TAG:
                self.opinions_wordcounter.text = "\(newString.length)/200"
                return true
            default:
                return false
            }
        }
        return false
    }
}
