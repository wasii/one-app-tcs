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
    
    @IBOutlet weak var rn_view: UIView!
    @IBOutlet weak var rn_textview: UITextView!
    @IBOutlet weak var rn_wordcounter: UILabel!
    
    @IBOutlet weak var it_view: UIView!
    @IBOutlet weak var it_textview: UITextView!
    @IBOutlet weak var it_wordcounter: UILabel!
    
    @IBOutlet weak var es_view: UIView!
    @IBOutlet weak var es_textview: UITextView!
    @IBOutlet weak var es_wordcounter: UILabel!
    
    @IBOutlet weak var recommendation_view: UIView!
    @IBOutlet weak var recommendation_textview: UITextView!
    @IBOutlet weak var recommendation_wordcounter: UILabel!
    
    @IBOutlet weak var endoresement_view: UIView!
    @IBOutlet weak var endorsement_textview: UITextView!
    @IBOutlet weak var endoresement_wordcounter: UILabel!
    
    @IBOutlet weak var ds_recommendation_view: UIView!
    @IBOutlet weak var ds_recommendation_textview: UITextView!
    @IBOutlet weak var ds_recommendation_wordcounter: UILabel!
    
    var ticket: tbl_Hr_Request_Logs?
    var isEditable = false
    
    var updatedelegate: UpdateIncidentInvestigation?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "IMS"
        
        detal_investigation_textview.delegate = self
        prosecution_narrative_textview.delegate = self
        defense_narrative_textview.delegate = self
        challenges_textview.delegate = self
        fact_textview.delegate = self
        findings_textview.delegate = self
        opinions_textview.delegate = self
        
        rn_textview.delegate = self
        it_textview.delegate = self
        
        setupTextFields()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isEditable {
            self.updatedelegate?.updateIncidentInvestigation(ticket: self.ticket!)
        }
    }
    
    func setupTextFields() {
        if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_View_Detailed_Investigation).count > 0 {
            if self.isEditable {
                self.di_view.isHidden = false
                self.detal_investigation_textview.isUserInteractionEnabled = true
                if ticket?.DETAILED_INVESTIGATION == "" {
                    self.detal_investigation_textview.text = ENTER_DETAIL_INVESTIGATION
                } else {
                    self.detal_investigation_textview.text = ticket?.DETAILED_INVESTIGATION ?? ""
                }
                
            } else {
                if ticket?.DETAILED_INVESTIGATION == "" {
                    self.di_view.isHidden = true
                } else {
                    self.di_view.isHidden = false
                    self.detal_investigation_textview.text = ticket?.DETAILED_INVESTIGATION ?? ""
                    self.detail_investigation_wordcounter.text = "\(ticket?.DETAILED_INVESTIGATION?.count ?? 0)/2000"
                    self.detal_investigation_textview.isEditable = false
                }
            }
        } else {
            self.di_view.isHidden = true
        }
        
        if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_View_Prosecution_Narrative).count > 0 {
            if self.isEditable {
                self.pn_view.isHidden = false
                self.prosecution_narrative_textview.isUserInteractionEnabled = true
                if ticket?.PROSECUTION_NARRATIVE == "" {
                    self.prosecution_narrative_textview.text = ENTER_PROCECUSTION_NARRATIVE
                } else {
                    self.prosecution_narrative_textview.text = ticket?.PROSECUTION_NARRATIVE ?? ""
                }
            } else {
                if ticket?.PROSECUTION_NARRATIVE == "" {
                    self.pn_view.isHidden = true
                } else {
                    self.pn_view.isHidden = false
                    self.prosecution_narrative_textview.isEditable = false
                    self.prosecution_narrative_textview.text = ticket?.PROSECUTION_NARRATIVE ?? ""
                    self.prosecution_narrative_wordcounter.text = "\(ticket?.PROSECUTION_NARRATIVE?.count ?? 0)/1000"
                }
            }
        } else {
            self.pn_view.isHidden = true
        }
        
        if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_View_Defense_Narrative).count > 0 {
            if self.isEditable {
                self.dn_view.isHidden = false
                self.defense_narrative_textview.isUserInteractionEnabled = true
                if ticket?.DEFENSE_NARRATIVE == "" {
                    self.defense_narrative_textview.text = ENTER_DEFENSE_NARRATIVE
                } else {
                    self.defense_narrative_textview.text = ticket?.DEFENSE_NARRATIVE ?? ""
                }
            } else {
                if ticket?.DEFENSE_NARRATIVE == "" {
                    self.dn_view.isHidden = true
                } else {
                    self.dn_view.isHidden = false
                    self.defense_narrative_textview.isEditable = false
                    self.defense_narrative_textview.text = ticket?.DEFENSE_NARRATIVE ?? ""
                    self.defense_narrative_wordcounter.text = "\(ticket?.DEFENSE_NARRATIVE?.count ?? 0)/200"
                }
            }
        } else {
            self.dn_view.isHidden = true
        }
        
        if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_View_Challenges).count > 0 {
            if self.isEditable {
                self.c_view.isHidden = false
                self.challenges_textview.isUserInteractionEnabled = true
                if ticket?.CHALLENGES == "" {
                    self.challenges_textview.text = ENTER_CHALLENGES
                } else {
                    self.challenges_textview.text = ticket?.CHALLENGES ?? ""
                }
            } else {
                if ticket?.CHALLENGES == "" {
                    self.c_view.isHidden = true
                } else {
                    self.c_view.isHidden = false
                    self.challenges_textview.isEditable = false
                    self.challenges_textview.text = ticket?.CHALLENGES ?? ""
                    self.challenges_wordcounter.text = "\(ticket?.CHALLENGES?.count ?? 0)/200"
                }
            }
        } else {
            self.c_view.isHidden = true
        }
        
        if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_View_Facts).count > 0 {
            if self.isEditable {
                self.f_view.isHidden = false
                self.fact_textview.isUserInteractionEnabled = true
                if ticket?.FACTS == "" {
                    self.fact_textview.text = ENTER_FACTS
                } else {
                    self.fact_textview.text = ticket?.FACTS ?? ""
                }
            } else {
                if ticket?.FACTS == "" {
                    self.f_view.isHidden = true
                } else {
                    self.f_view.isHidden = false
                    self.fact_textview.isEditable = false
                    self.fact_textview.text = ticket?.FACTS ?? ""
                    self.facts_wordcounter.text = "\(ticket?.FACTS?.count ?? 0)/500"
                }
            }
        } else {
            self.f_view.isHidden = true
        }
        
        if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_View_Findings).count > 0 {
            if self.isEditable {
                self.finding_view.isHidden = false
                self.findings_textview.isUserInteractionEnabled = true
                if ticket?.FINDINGS == "" {
                    self.findings_textview.text = ENTER_FINDINGS
                } else {
                    self.findings_textview.text = ticket?.FINDINGS ?? ""
                }
            } else {
                if ticket?.FINDINGS == "" {
                    self.finding_view.isHidden = true
                } else {
                    self.finding_view.isHidden = false
                    self.findings_textview.isEditable = false
                    self.findings_textview.text = ticket?.FINDINGS ?? ""
                    self.findings_wordcounter.text = "\(ticket?.FINDINGS?.count ?? 0)/1000"
                }
            }
        } else {
            self.finding_view.isHidden = true
        }
        
        if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_View_Opinions).count > 0 {
            if self.isEditable {
                self.o_view.isHidden = false
                self.opinions_textview.isUserInteractionEnabled = true
                if ticket?.OPINION == "" {
                    self.opinions_textview.text = ENTER_OPINIONS
                } else {
                    self.opinions_textview.text = ticket?.OPINION ?? ""
                }
            } else {
                if ticket?.OPINION == "" {
                    self.o_view.isHidden = true
                } else {
                    self.o_view.isHidden = false
                    self.opinions_textview.isEditable = false
                    self.opinions_textview.text = ticket?.OPINION ?? ""
                    self.opinions_wordcounter.text = "\(ticket?.OPINION?.count ?? 0)/500"
                }
            }
        } else {
            self.o_view.isHidden = true
        }
        if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_Area_View_Reference).count > 0 {
            if self.isEditable {
                self.rn_view.isHidden = false
                self.rn_textview.isUserInteractionEnabled = true
                if ticket?.AREA_REF == "" {
                    self.rn_textview.text = ENTER_REFERENCE_NUM
                } else {
                    self.rn_textview.text = ticket?.AREA_REF ?? ""
                }
            } else {
                if ticket?.AREA_REF == "" {
                    self.rn_view.isHidden = true
                } else {
                    self.rn_view.isHidden = false
                    self.rn_textview.isEditable = false
                    self.rn_textview.text = ticket?.AREA_REF ?? ""
                    self.rn_wordcounter.text = "\(ticket?.AREA_REF?.count ?? 0)/100"
                }
            }
        } else {
            self.rn_view.isHidden = true
        }
        if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_Area_View_Title).count > 0 {
            if self.isEditable {
                self.it_view.isHidden = false
                self.it_textview.isUserInteractionEnabled = true
                if ticket?.AREA_INVEST_TITLE == "" {
                    self.it_textview.text = ENTER_INVESTIGATION_TITLE
                } else {
                    self.it_textview.text = ticket?.AREA_INVEST_TITLE ?? ""
                }
            } else {
                if ticket?.AREA_INVEST_TITLE == "" {
                    self.it_view.isHidden = true
                } else {
                    self.it_view.isHidden = false
                    self.it_textview.isEditable = false
                    self.it_textview.text = ticket?.AREA_INVEST_TITLE ?? ""
                    self.it_wordcounter.text = "\(ticket?.AREA_INVEST_TITLE?.count ?? 0)/525"
                }
            }
        } else {
            self.it_view.isHidden = true
        }
        
        //HS
        if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_View_Executive_Summary).count > 0 {
            if ticket?.HO_SEC_SUMMARY == ""  {
                self.es_view.isHidden = true
            } else {
                self.es_view.isHidden = false
                self.es_textview.text = ticket?.HO_SEC_SUMMARY ?? ""
                self.es_wordcounter.text = "\(ticket?.HO_SEC_SUMMARY?.count ?? 0)/200"
            }
        }
        if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_View_HS_Recommendation).count > 0 {
            if ticket?.HO_SEC_RECOM == "" {
                self.recommendation_view.isHidden = true
            } else {
                self.recommendation_view.isHidden = false
                self.recommendation_textview.text = ticket?.HO_SEC_RECOM ?? ""
                self.recommendation_wordcounter.text = "\(ticket?.HO_SEC_RECOM?.count ?? 0)/200"
            }
        }
        
        //DS
        if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_View_Endorsement).count > 0 {
            if ticket?.DIR_SEC_ENDOR == ""  {
                self.endoresement_view.isHidden = true
            } else {
                self.endoresement_view.isHidden = false
                self.endorsement_textview.text = ticket?.DIR_SEC_ENDOR ?? ""
                self.endoresement_wordcounter.text = "\(ticket?.DIR_SEC_ENDOR?.count ?? 0)/200"
            }
        }
        if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_View_DS_Recommendation).count > 0 {
            if ticket?.DIR_SEC_RECOM == "" {
                self.ds_recommendation_view.isHidden = true
            } else {
                self.ds_recommendation_view.isHidden = false
                self.ds_recommendation_textview.text = ticket?.DIR_SEC_RECOM ?? ""
                self.ds_recommendation_wordcounter.text = "\(ticket?.DIR_SEC_RECOM?.count ?? 0)/200"
            }
        }
    }
    
    @IBAction func back_button_tapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
        case ENTER_REFERENCE_TAG:
            if textView.text == ENTER_REFERENCE_NUM {
                textView.text = ""
            }
        case ENTER_INVESTIGATION_TITLE_TAG:
            if textView.text == ENTER_INVESTIGATION_TITLE {
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
        case ENTER_REFERENCE_TAG:
            if textView.text.count <= 0 {
                textView.text = ENTER_REFERENCE_NUM
                ticket?.AREA_REF = ""
            } else {
                ticket?.AREA_REF = textView.text
            }
            break
        case ENTER_INVESTIGATION_TITLE_TAG:
            if textView.text.count <= 0 {
                textView.text = ENTER_INVESTIGATION_TITLE
                ticket?.AREA_INVEST_TITLE = ""
            } else {
                ticket?.AREA_INVEST_TITLE = textView.text
            }
            break
        default:
            break
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if let texts = textView.text,
           let textRange = Range(range, in: texts) {
            let updatedText = texts.replacingCharacters(in: textRange, with: text)
            if updatedText.containsEmoji {
                return false
            }
        }
        var maxLength = 200
        switch textView.tag {
        case ENTER_PROCECUSTION_NARRATIVE_TAG:
            maxLength = 1000
            break
        case ENTER_DETAIL_INVESTIGATION_TAG:
            maxLength = 2000
            break
        case ENTER_FINDINGS_TAG:
            maxLength = 1000
            break
        case ENTER_FACTS_TAG, ENTER_OPINIONS_TAG:
            maxLength = 500
            break
        case ENTER_REFERENCE_TAG:
            maxLength = 100
            break
        case ENTER_INVESTIGATION_TITLE_TAG:
            maxLength = 525
            break
        default:
            break
        }
        
        
        let currentString: NSString = textView.text as! NSString
        let newString: NSString =
                currentString.replacingCharacters(in: range, with: text) as NSString
        
        if newString.length <= maxLength {
            switch textView.tag {
            case ENTER_DETAIL_INVESTIGATION_TAG:
                self.detail_investigation_wordcounter.text = "\(newString.length)/2000"
                return true
            case ENTER_PROCECUSTION_NARRATIVE_TAG:
                self.prosecution_narrative_wordcounter.text = "\(newString.length)/1000"
                return true
            case ENTER_DEFENSE_NARRATIVE_TAG:
                self.defense_narrative_wordcounter.text = "\(newString.length)/200"
                return true
            case ENTER_CHALLENGES_TAG:
                self.challenges_wordcounter.text = "\(newString.length)/200"
                return true
            case ENTER_FACTS_TAG:
                self.facts_wordcounter.text = "\(newString.length)/500"
                return true
            case ENTER_FINDINGS_TAG:
                self.findings_wordcounter.text = "\(newString.length)/1000"
                return true
            case ENTER_OPINIONS_TAG:
                self.opinions_wordcounter.text = "\(newString.length)/500"
                return true
            case ENTER_REFERENCE_TAG:
                self.rn_wordcounter.text = "\(newString.length)/100"
                return true
            case ENTER_INVESTIGATION_TITLE_TAG:
                self.it_wordcounter.text = "\(newString.length)/525"
                return true
            default:
                return false
            }
        }
        return false
    }
}
