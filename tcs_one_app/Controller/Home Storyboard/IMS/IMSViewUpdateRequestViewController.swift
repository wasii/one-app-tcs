//
//  IMSViewUpdateRequestViewController.swift
//  tcs_one_app
//
//  Created by TCS on 02/01/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import MobileCoreServices
import Alamofire
import SwiftyJSON
import Photos
import GrowingTextView

class IMSViewUpdateRequestViewController: BaseViewController {
var current_user = String()
var havePermissionToEdit = false
var ticket_request: tbl_Hr_Request_Logs?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headingLabel: UILabel!
    //FIXED CONTENT STARTS
    @IBOutlet weak var showHideLabel: UILabel!
    @IBOutlet weak var showHideImage: UIImageView!
    @IBOutlet weak var incident_detail_employee_id: MDCOutlinedTextField!
    
    @IBOutlet weak var incident_detail_view: CustomView!
    @IBOutlet weak var incident_detail_employee_detail: UITextView!
    @IBOutlet weak var incident_detail_word_counter: UILabel!
    @IBOutlet weak var showEnterDetailLabel: UILabel!
    
    @IBOutlet weak var incident_detail_consignment_VIEW: UIView!
    @IBOutlet weak var incident_detail_cityview_textfield: MDCOutlinedTextField!
    @IBOutlet weak var incident_details_consignment_view_textfield: MDCOutlinedTextField!
    //HOD and After HOD
    
    @IBOutlet weak var incident_detail_view_hod: CustomView!
    @IBOutlet weak var incident_detail_employee_id_hod: MDCOutlinedTextField!
    @IBOutlet weak var incident_detail_employee_detail_hod: UITextView!
    @IBOutlet weak var incident_detail_word_counter_hod: UILabel!
    @IBOutlet weak var incident_detail_classification: MDCOutlinedTextField!
    @IBOutlet weak var incident_detail_incident_level_3: MDCOutlinedTextField!
    
    @IBOutlet weak var incident_detail_city_consignment_stackview: UIStackView!
    @IBOutlet weak var incident_detail_consignment_view: UIView!
    @IBOutlet weak var incident_detail_city_textfield: MDCOutlinedTextField!
    @IBOutlet weak var incident_detail_consignment_textfield: MDCOutlinedTextField!
    
    @IBOutlet weak var incident_detail_loss_type: MDCOutlinedTextField!
    @IBOutlet weak var incident_detail_loss_amount_view: UIStackView!
    @IBOutlet weak var incident_detail_loss_amount: MDCOutlinedTextField!
    @IBOutlet weak var incident_detail_recovery_type: MDCOutlinedTextField!
    
    @IBOutlet weak var incident_detail_view_height_constraint: NSLayoutConstraint!
    //HOD and After HOD ENDs
    
    //FIXED CONTENT ENDS
    @IBOutlet weak var incident_investigation_view: CustomView!
    @IBOutlet weak var remarks_attachment_stackview: UIStackView!
    @IBOutlet weak var employee_related_stackview: UIStackView!
    @IBOutlet weak var classification_view: UIView!
    @IBOutlet weak var classification_textfield: MDCOutlinedTextField!
    
    @IBOutlet weak var incident_1_view: UIView!
    @IBOutlet weak var incident_1_textfield: MDCOutlinedTextField!
    
    
    
    @IBOutlet weak var incident_2_view: UIView!
    @IBOutlet weak var incident_2_textfield: MDCOutlinedTextField!
    
    
    @IBOutlet weak var incident_3_view: UIView!
    @IBOutlet weak var incident_3_textfield: MDCOutlinedTextField!
    
    @IBOutlet weak var incident_loss_type: MDCOutlinedTextField!
    
    @IBOutlet weak var loss_amount_stackview: UIStackView!
    @IBOutlet weak var incident_loss_amount: MDCOutlinedTextField!
    @IBOutlet weak var incident_recovery_type: MDCOutlinedTextField!
    
    @IBOutlet weak var hod_stack_view: UIStackView!
    @IBOutlet weak var executive_summarty_view: UIView!
    @IBOutlet weak var executive_summary_textview: UITextView!
    @IBOutlet weak var executive_summary_word_counter: UILabel!
    
    
    @IBOutlet weak var endoresement_view: UIView!
    @IBOutlet weak var endoresement_textview: UITextView!
    @IBOutlet weak var endoresement_word_counter: UILabel!
    
    @IBOutlet weak var recommendations_view: UIView!
    @IBOutlet weak var recommendations_textview: UITextView!
    @IBOutlet weak var recommendations_word_counter: UILabel!
    
    @IBOutlet weak var email_view: UIView!
    @IBOutlet weak var email_textfield: MDCOutlinedTextField!
    @IBOutlet weak var email_textview: GrowingTextView!
    @IBOutlet weak var email_textview_height: NSLayoutConstraint!
    
    @IBOutlet weak var attachement_view_height_constraint: NSLayoutConstraint!
    @IBOutlet weak var attachment_view: UIView!
    @IBOutlet weak var attachment_textfield: MDCOutlinedTextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableView_height_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var remarks_view: UIView!
    @IBOutlet weak var remarks_textview: UITextView!
    @IBOutlet weak var remarks_word_counter: UILabel!
    
    
    @IBOutlet weak var investigation_required_view: UIView!
    @IBOutlet weak var investigation_required_switch: UISwitch!
    
    @IBOutlet weak var area_view: UIView!
    @IBOutlet weak var area_textfield: MDCOutlinedTextField!
    
    @IBOutlet weak var assigned_to_view: UIView!
    @IBOutlet weak var assigned_to_textfield: MDCOutlinedTextField!
    
    
    @IBOutlet weak var insurance_claimable_view: UIView!
    @IBOutlet weak var insurance_claimable_switch: UISwitch!
    
    @IBOutlet weak var claim_reference_number_view: UIView!
    @IBOutlet weak var claim_reference_number_textfield: MDCOutlinedTextField!
    
    @IBOutlet weak var ins_insurance_claimable_view: UIView!
    @IBOutlet weak var ins_insurance_claimable_switch: UISwitch!
    
    @IBOutlet weak var ins_claim_reference_number_view: UIView!
    @IBOutlet weak var ins_claim_reference_number_textfield: MDCOutlinedTextField!
    
    @IBOutlet weak var hr_reference_number_view: UIView!
    @IBOutlet weak var hr_reference_number_textfield: MDCOutlinedTextField!
    @IBOutlet weak var hr_status_view: UIView!
    @IBOutlet weak var hr_status_textfield: MDCOutlinedTextField!
    @IBOutlet weak var status_textfield: MDCOutlinedTextField!
    
    
    @IBOutlet weak var claim_defined_view: UIView!
    @IBOutlet weak var claim_defined_switch: UISwitch!
    
    @IBOutlet weak var risk_remark_view: UIView!
    @IBOutlet weak var risk_remarks_textview: UITextView!
    @IBOutlet weak var risk_remarks_word_counter: UILabel!
    
    @IBOutlet weak var type_of_risk_view: UIView!
    @IBOutlet weak var type_of_risk_textfield: MDCOutlinedTextField!
    
    @IBOutlet weak var category_of_control_view: UIView!
    @IBOutlet weak var category_of_control_textfield: MDCOutlinedTextField!
    
    @IBOutlet weak var type_of_control_view: UIView!
    @IBOutlet weak var type_of_control_textfield: MDCOutlinedTextField!
    
    @IBOutlet weak var closure_remarks_view: UIView!
    @IBOutlet weak var closure_remarks_textview: UITextView!
    @IBOutlet weak var closure_remarks_word_counter: UILabel!
    
    
    @IBOutlet weak var forwardBtn: CustomButton!
    @IBOutlet weak var rejectBtn: CustomButton!
    @IBOutlet weak var downloadBtn: CustomButton!
    @IBOutlet weak var historyBtn: CustomButton!
    @IBOutlet weak var employeeRelatedBtn: CustomButton!
    
    var lov_classification:     tbl_lov_classification?
    var lov_master_table:       tbl_lov_master?
    var lov_detail_table:       tbl_lov_detail?
    var lov_subdetail_table:    tbl_lov_sub_detail?
    var lov_recovery_type:      tbl_lov_recovery_type?
    var lov_financial:          financial_type?
    
    var lov_area:               tbl_lov_area?
    var lov_assigned_to:        tbl_lov_area_security?
    
    var lov_hr_status:          tbl_lov_hr_status?
    var lov_risk_type:          tbl_lov_risk_type?
    var lov_category_control:   tbl_lov_control_category?
    var lov_type_control:       tbl_lov_control_type?
    
    var attachmentFiles:    [AttachmentsList]?
    var picker =            UIImagePickerController()
    var fileDownloadedURL:  URL?
    
    
    var isRejected = false
    var willDBInsert = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "IMS"
        scrollView.delegate = self
        picker.delegate = self
        attachmentFiles = [AttachmentsList]()
        self.tableView.register(UINib(nibName: "AddAttachmentsTableCell", bundle: nil), forCellReuseIdentifier: "AddAttachmentsCell")
        self.tableView.rowHeight = 60
        
        lov_financial = financial_type(ID: 1, TYPE: "Non Financial")
        remarks_textview.delegate =  self
        
        setupTextfields()
        setupViews()
        setupPermissions()
    }
    
    
    //MARK: Custom Methods
    func setupViews() {
        if IMS_Submitted == "\(current_user)" || IMS_Inprogress_Ro == "\(current_user)" || IMS_Inprogress_Rhod == "\(current_user)" {
            self.classification_view.isHidden = false
            self.incident_1_view.isHidden = false
            self.incident_1_textfield.text = ""
            self.incident_2_view.isHidden = false
            self.incident_3_view.isHidden = false
            self.employee_related_stackview.isHidden = false
            
            classification_textfield.text = ticket_request!.CLASSIFICATION!
            if let classification = AppDelegate.sharedInstance.db?.read_tbl_classification(query: "SELECT * FROM \(db_lov_classification) WHERE SERVER_ID_PK = '\(ticket_request!.CLASSIFICATION ?? "")'").first {
                classification_textfield.text = classification.SERVER_ID_PK
                lov_classification = classification
            }
            if let incident_1 = AppDelegate.sharedInstance.db?.read_tbl_lov_master(query: "SELECT * FROM \(db_lov_master) WHERE SERVER_ID_PK = '\(ticket_request!.LOV_MASTER ?? -1)'").first {
                incident_1_textfield.text = incident_1.LOV_NAME
                lov_master_table = incident_1
            }
            if let incident_2 = AppDelegate.sharedInstance.db?.read_tbl_lov_detail(query: "SELECT * FROM \(db_lov_detail) WHERE SERVER_ID_PK = '\(ticket_request!.LOV_DETAIL ?? -1)'").first {
                incident_2_textfield.text = incident_2.NAME
                lov_detail_table = incident_2
            }
            if let incident_3 = AppDelegate.sharedInstance.db?.read_tbl_lov_sub_detail(query: "SELECT * FROM \(db_lov_sub_detail) WHERE SERVER_ID_PK = '\(ticket_request!.LOV_SUBDETAIL ?? -1)'").first {
                incident_3_textfield.text = incident_3.LOV_SUBDETL_NAME
                lov_subdetail_table = incident_3
            }
            
            if ticket_request!.IS_EMP_RELATED == 1 {
                employeeRelatedBtn.borderWidth = 0
                employeeRelatedBtn.bgColor = UIColor.nativeRedColor()
                employeeRelatedBtn.buttonImage = UIImage(named:"check")
            }
            if ticket_request!.IS_FINANCIAL == 1 {
                lov_financial = financial_type(ID: 2, TYPE: "Financial")
                incident_loss_type.text = "Financial"
                loss_amount_stackview.isHidden = false
                incident_loss_amount.text = "\(ticket_request!.AMOUNT!)"
                
                
                if let recovery_type = AppDelegate.sharedInstance.db?.read_tbl_recovery_type(query: "SELECT * FROM \(db_lov_recovery_type) WHERE SERVER_ID_PK = '\(ticket_request!.RECOVERY_TYPE ?? "")'").first {
                    incident_recovery_type.text = recovery_type.NAME
                    lov_recovery_type = recovery_type
                }
            } else {
                lov_financial = financial_type(ID: 1, TYPE: "Non Financial")
                incident_loss_type.text = "Non Financial"
            }
            
            if havePermissionToEdit {
//                self.title = "Update Request"
                self.headingLabel.text = "Request Detail"
                
                classification_textfield.label.text = "*Classification"
                incident_1_textfield.label.text = "*Incident Level 1"
                incident_2_textfield.label.text = "*Incident Level 2"
                incident_3_textfield.label.text = "*Incident Level 3"
                incident_loss_amount.label.text = "*Loss Amount"
                incident_recovery_type.label.text = "*Recovery Type"
                incident_loss_amount.tag = LOSS_AMOUNT_TAG
                incident_loss_amount.delegate = self
                
                let remarks_permission = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_Add_Remarks_Line_Manager).count
                let file_attachment_permission = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_IMS_Add_Files_Line_Manager).count
                
                remarks_attachment_stackview.isHidden = true
                if remarks_permission! > 0 {
                    remarks_attachment_stackview.isHidden = false
                    remarks_view.isHidden = false
                } else if file_attachment_permission! > 0 {
                    remarks_attachment_stackview.isHidden = false
                    attachment_view.isHidden = false
                }
            } else {
//                self.title = "View Request"
                self.headingLabel.text = "View Request"
                
                classification_textfield.isUserInteractionEnabled = false
                incident_1_textfield.isUserInteractionEnabled = false
                incident_2_textfield.isUserInteractionEnabled = false
                incident_3_textfield.isUserInteractionEnabled = false
                
                incident_2_textfield.isHidden = false
                incident_3_textfield.isHidden = false
                
                incident_loss_type.isUserInteractionEnabled = false
                employeeRelatedBtn.isUserInteractionEnabled = false
                incident_loss_amount.isUserInteractionEnabled = false
                incident_recovery_type.isUserInteractionEnabled = false
                
                
                self.forwardBtn.isHidden = true
                self.rejectBtn.isHidden = true
            }
            return
        }
        if IMS_Inprogress_Hod == current_user {
            if havePermissionToEdit {
//                self.title = "Update Request"
                self.headingLabel.text = "Request Detail"
                self.investigation_required_view.isHidden = false
                self.investigation_required_switch.isUserInteractionEnabled = true
                let remarks_permission = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_Add_Remarks_Department_Head).count
                let file_attachment_permission = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_Add_Files_Department_Head).count
                
                remarks_attachment_stackview.isHidden = true
                if remarks_permission! > 0 {
                    remarks_attachment_stackview.isHidden = false
                    remarks_view.isHidden = false
                } else if file_attachment_permission! > 0 {
                    remarks_attachment_stackview.isHidden = false
                    attachment_view.isHidden = false
                }
            } else {
//                self.title = "View Request"
                self.headingLabel.text = "View Request"
                self.investigation_required_view.isHidden = false
                if self.ticket_request!.IS_INVESTIGATION == 1 {
                    self.investigation_required_switch.isOn = true
                } else {
                    self.investigation_required_switch.isOn = false
                }
                
                self.investigation_required_switch.isEnabled = false
                
                
                self.forwardBtn.isHidden = true
                self.rejectBtn.isHidden = true
            }
            return
        }
        if IMS_Inprogress_Cs == "\(current_user)" {
            self.area_view.isHidden = false
            self.assigned_to_view.isHidden = false
            
            if havePermissionToEdit {
//                self.title = "Update Request"
                self.headingLabel.text = "Request Detail"
                self.area_textfield.label.text = "*Area "
                self.assigned_to_textfield.label.text = "*Assigned To "
                self.area_textfield.delegate = self
                self.assigned_to_textfield.delegate = self
                
                self.area_textfield.tag = AREA_TAG
                self.assigned_to_textfield.tag = ASSIGNED_TO_TAG
                
                
                let remarks_permission = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_Add_Remarks_Central_Security).count
                let file_attachment_permission = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_Add_Files_Central_Security).count
                
                remarks_attachment_stackview.isHidden = true
                remarks_view.isHidden = true
                attachment_view.isHidden = true
                if remarks_permission! > 0 {
                    remarks_attachment_stackview.isHidden = false
                    remarks_view.isHidden = false
                } else if file_attachment_permission! > 0 {
                    remarks_attachment_stackview.isHidden = false
                    attachment_view.isHidden = false
                }
                
            } else {
//                self.title = "View Request"
                self.headingLabel.text = "View Request"
                self.area_textfield.isUserInteractionEnabled = false
                self.area_textfield.label.text = "Area"
                if let area = AppDelegate.sharedInstance.db?.read_tbl_area(query: "SELECT * FROM \(db_lov_area) WHERE SERVER_ID_PK = '\(self.ticket_request!.AREA!)'").first {
                    self.area_textfield.text = area.AREA_NAME
                } else {
                    self.area_textfield.text = " "
                }
                
                self.assigned_to_textfield.label.text = "Assigned To"
                if let assigned_to = AppDelegate.sharedInstance.db?.read_tbl_area_security(query: "SELECT * FROM \(db_lov_area_security) WHERE EMPNO = '\(self.ticket_request!.AREA_SEC_EMP_NO!)'").first {
                    self.assigned_to_textfield.text = assigned_to.SECURITY_PERSON
                } else {
                    self.assigned_to_textfield.text = " "
                }
               
                
                
                self.assigned_to_textfield.isUserInteractionEnabled = false
                self.forwardBtn.isHidden = true
                self.rejectBtn.isHidden = true
            }
            return
        }
        
        if IMS_Inprogress_As == "\(current_user)" {
            if havePermissionToEdit {
//                self.title = "Update Request"
                self.headingLabel.text = "Request Detail"
                self.remarks_attachment_stackview.isHidden = true
                self.attachment_view.isHidden = true
                self.remarks_view.isHidden = true
                let addRemarks = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_Add_Remarks_Area_Security)
                let addFiles   = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_Add_Files_Area_Security)
                
                
                if addRemarks!.count > 0 {
                    remarks_attachment_stackview.isHidden = false
                    remarks_view.isHidden = false
                }
                if addFiles!.count > 0 {
                    remarks_attachment_stackview.isHidden = false
                    attachment_view.isHidden = false
                }
                self.showEnterDetailLabel.text = "Enter Details"
                
            } else {
//                self.title = "View Request"
                self.headingLabel.text = "View Request"
                self.forwardBtn.isHidden = true
                self.rejectBtn.isHidden = true
                self.showEnterDetailLabel.text = "View Details"
            }
        }
        if IMS_Inprogress_Hs == "\(current_user)" || IMS_Inprogress_Rds == current_user {
            self.hod_stack_view.isHidden = false
            self.executive_summarty_view.isHidden = false
            self.recommendations_view.isHidden = false
            
            
            if havePermissionToEdit {
//                self.title = "Update Request"
                self.headingLabel.text = "Request Detail"
                self.remarks_attachment_stackview.isHidden = true
                self.attachment_view.isHidden = true
                self.remarks_view.isHidden = true
                let addRemarks = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_Add_Remarks_Head_Security)
                let addFiles   = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_Add_Files_Head_Security)
                
                if addRemarks!.count > 0 {
                    remarks_attachment_stackview.isHidden = false
                    remarks_view.isHidden = false
                }
                if addFiles!.count > 0 {
                    remarks_attachment_stackview.isHidden = false
                    attachment_view.isHidden = false
                }
                self.executive_summary_textview.isUserInteractionEnabled = true
                self.recommendations_textview.isUserInteractionEnabled = true
                
                self.recommendations_textview.delegate = self
                self.executive_summary_textview.delegate = self
            } else {
//                self.title = "View Request"
                self.headingLabel.text = "View Request"
                self.executive_summary_textview.isUserInteractionEnabled = false
                self.recommendations_textview.isUserInteractionEnabled = false
                
                self.executive_summary_textview.text = self.ticket_request?.HO_SEC_SUMMARY ?? ""
                self.recommendations_textview.text = self.ticket_request?.HO_SEC_RECOM ?? ""
                
                self.forwardBtn.isHidden = true
            }
            return
        }
        if IMS_Inprogress_Ds == "\(current_user)" {
            self.hod_stack_view.isHidden = false
            self.endoresement_view.isHidden = false
            self.recommendations_view.isHidden = false
            
            self.email_view.isHidden = false
            if havePermissionToEdit {
//                self.title = "Update Request"
                self.headingLabel.text = "Request Detail"
                self.remarks_attachment_stackview.isHidden = true
                self.attachment_view.isHidden = true
                self.remarks_view.isHidden = true
                
                let addRemarks = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_Add_Remarks_Director_Security)
                let addFiles   = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_Add_Files_Director_Security)
                
                if addRemarks!.count > 0 {
                    remarks_attachment_stackview.isHidden = false
                    remarks_view.isHidden = false
                }
                if addFiles!.count > 0 {
                    remarks_attachment_stackview.isHidden = false
                    attachment_view.isHidden = false
                }
                self.endoresement_textview.isUserInteractionEnabled = true
                self.recommendations_textview.isUserInteractionEnabled = true
//                self.email_textfield.delegate = self
                self.email_textview.delegate = self
                self.endoresement_textview.delegate = self
                self.recommendations_textview.delegate = self
            } else {
//                self.title = "View Request"
                self.headingLabel.text = "View Request"
                self.endoresement_textview.isUserInteractionEnabled = false
                self.recommendations_textview.isUserInteractionEnabled = false
                self.email_textview.isUserInteractionEnabled = false
                
                self.endoresement_textview.text = self.ticket_request?.DIR_SEC_ENDOR ?? ""
                self.recommendations_textview.text = self.ticket_request?.DIR_SEC_RECOM ?? ""
                self.email_textview.text = self.ticket_request?.DIR_NOTIFY_EMAILS ?? ""
                self.forwardBtn.isHidden = true
            }
            return
        }
        if IMS_Inprogress_Fs == "\(current_user)" {
            self.insurance_claimable_view.isHidden = false
            if ticket_request?.IS_INS_CLAIMABLE == 1 {
                self.insurance_claimable_switch.isOn = true
            } else {
                self.insurance_claimable_switch.isOn = false
            }
            
            self.claim_reference_number_textfield.text = "\(ticket_request?.INS_CLAIM_REFNO ?? "")"
            if havePermissionToEdit {
//                self.title = "Update Request"
                self.headingLabel.text = "Request Detail"
                self.remarks_attachment_stackview.isHidden = true
                self.attachment_view.isHidden = true
                self.remarks_view.isHidden = true
                
                let addRemarks = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_Add_Remarks_Financial_Services)
                let addFiles   = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_Add_Files_Financial_Services)
                
                if addRemarks!.count > 0 {
                    remarks_attachment_stackview.isHidden = false
                    remarks_view.isHidden = false
                }
                if addFiles!.count > 0 {
                    remarks_attachment_stackview.isHidden = false
                    attachment_view.isHidden = false
                }
                
                self.claim_reference_number_textfield.isUserInteractionEnabled = true
                self.claim_reference_number_textfield.delegate = self
                
            } else {
//                self.title = "View Request"
                self.headingLabel.text = "View Request"
                
                
                self.insurance_claimable_view.isHidden = false
                if ticket_request!.INS_CLAIM_REFNO == "" {
                    self.insurance_claimable_switch.isOn = false
                    self.claim_reference_number_view.isHidden = true
                } else {
                    self.insurance_claimable_switch.isOn = true
                    self.claim_reference_number_view.isHidden = false
                }
                
                self.insurance_claimable_switch.isUserInteractionEnabled = false
                self.claim_reference_number_textfield.text = "\(ticket_request?.INS_CLAIM_REFNO ?? "")"
                self.claim_reference_number_textfield.isUserInteractionEnabled = false
                
                if ticket_request!.INS_CLAIMED_AMOUNT != 0.0 {
                    self.ins_insurance_claimable_view.isHidden = false
                    self.ins_insurance_claimable_switch.isOn = true
                    self.ins_insurance_claimable_switch.isUserInteractionEnabled = false
                    
                    self.ins_claim_reference_number_view.isHidden = false
                    self.ins_claim_reference_number_textfield.isUserInteractionEnabled = false
                    self.ins_claim_reference_number_textfield.text = "\(self.ticket_request?.INS_CLAIMED_AMOUNT ?? 0.0)"
                }
                
                self.forwardBtn.isHidden = true
            }
            
        }
        
        if IMS_Inprogress_Ins == current_user {
            self.claim_reference_number_view.isHidden = false
            self.insurance_claimable_view.isHidden = false
            self.insurance_claimable_switch.isOn = true
            self.insurance_claimable_switch.isUserInteractionEnabled = false
            self.claim_reference_number_textfield.text = "\(ticket_request?.INS_CLAIM_REFNO ?? "")"
            self.claim_reference_number_textfield.isUserInteractionEnabled = false
            
            
            self.ins_insurance_claimable_view.isHidden = false
            self.ins_insurance_claimable_switch.isOn = true
            self.ins_insurance_claimable_switch.isUserInteractionEnabled = false
            
            
            self.ins_claim_reference_number_view.isHidden = false
//            if ticket_request?.IS_INS_CLAIM_PROCESS == 1 {
//
//            } else {
//                self.ins_insurance_claimable_switch.isOn = false
//            }
            
//            self.ins_claim_reference_number_textfield.text = "\(self.ticket_request?.INS_CLAIMED_AMOUNT ?? 0.0)"
            if havePermissionToEdit {
//                self.title = "Update Request"
                self.headingLabel.text = "Request Detail"
                self.remarks_attachment_stackview.isHidden = true
                self.attachment_view.isHidden = true
                self.remarks_view.isHidden = true
                
                let addRemarks = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_Add_Remarks_Financial_Services)
                let addFiles   = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_Add_Files_Financial_Services)
                
                if addRemarks!.count > 0 {
                    remarks_attachment_stackview.isHidden = false
                    remarks_view.isHidden = false
                }
                if addFiles!.count > 0 {
                    remarks_attachment_stackview.isHidden = false
                    attachment_view.isHidden = false
                }
                self.ins_claim_reference_number_textfield.isUserInteractionEnabled = true
                self.ins_claim_reference_number_textfield.tag = LOSS_AMOUNT_TAG
                self.ins_claim_reference_number_textfield.delegate = self
            } else {
//                self.title = "View Request"
                self.headingLabel.text = "View Request"
                self.ins_claim_reference_number_textfield.isUserInteractionEnabled = false
                self.ins_insurance_claimable_switch.isOn = true
                self.forwardBtn.isHidden = true
                self.ins_claim_reference_number_textfield.text = "\(self.ticket_request?.INS_CLAIMED_AMOUNT ?? 0.0)"
            }
        }
        
        if IMS_Inprogress_Hr == "\(current_user)" {
            hr_reference_number_view.isHidden = false
            hr_status_view.isHidden = false
            
            if self.ticket_request?.HR_REF_NO == "" {
                self.hr_reference_number_textfield.placeholder = "Enter Hr Reference Number"
            } else {
                self.hr_reference_number_textfield.text = self.ticket_request?.HR_REF_NO ?? ""
            }
            if self.ticket_request?.HR_STATUS == "" {
                self.hr_status_textfield.placeholder = "Enter Status"
            } else {
                self.hr_status_textfield.text = self.ticket_request?.HR_STATUS ?? ""
            }
            
            if havePermissionToEdit {
//                self.title = "Update Request"
                self.headingLabel.text = "Request Detail"
                self.hr_reference_number_textfield.isUserInteractionEnabled = true
                self.hr_status_textfield.isUserInteractionEnabled = true
                
                self.hr_status_textfield.delegate = self
                self.hr_reference_number_textfield.delegate = self
                
                self.remarks_attachment_stackview.isHidden = true
                self.attachment_view.isHidden = true
                self.remarks_view.isHidden = true
                
                let addRemarks = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_Add_Remarks_Human_Resources)
                let addFiles   = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_Add_Files_Human_Resources)
                
                if addRemarks!.count > 0 {
                    remarks_attachment_stackview.isHidden = false
                    remarks_view.isHidden = false
                }
                if addFiles!.count > 0 {
                    remarks_attachment_stackview.isHidden = false
                    attachment_view.isHidden = false
                }
            } else {
//                self.title = "View Request"
                self.headingLabel.text = "View Request"
                self.hr_reference_number_textfield.isUserInteractionEnabled = false
                self.hr_status_textfield.isUserInteractionEnabled = false
                self.forwardBtn.isHidden = true
            }
        }
        if IMS_Inprogress_Fi == "\(current_user)" {
            hr_reference_number_view.isHidden = false
            hr_status_view.isHidden = false
            if self.ticket_request?.FINANCE_GL_NO == "" {
                self.hr_reference_number_textfield.label.text = "GL Transaction Number"
                self.hr_reference_number_textfield.placeholder = "Enter GL Transaction Number"
            } else {
                self.hr_reference_number_textfield.text = self.ticket_request?.HR_REF_NO ?? ""
            }
            if self.ticket_request?.HR_STATUS == "" {
                self.hr_status_textfield.placeholder = "Enter Status"
            } else {
                self.hr_status_textfield.text = self.ticket_request?.HR_STATUS ?? ""
            }
            if havePermissionToEdit {
//                self.title = "Update Request"
                self.headingLabel.text = "Request Detail"
                self.hr_reference_number_textfield.isUserInteractionEnabled = true
                
                self.hr_status_textfield.isUserInteractionEnabled = true
                
                self.hr_status_textfield.delegate = self
                self.hr_reference_number_textfield.delegate = self
                
                self.remarks_attachment_stackview.isHidden = true
                self.attachment_view.isHidden = true
                self.remarks_view.isHidden = true
                
                let addRemarks = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_Add_Remarks_Finance)
                let addFiles   = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_Add_Files_Finance)
                
                if addRemarks!.count > 0 {
                    remarks_attachment_stackview.isHidden = false
                    remarks_view.isHidden = false
                }
                if addFiles!.count > 0 {
                    remarks_attachment_stackview.isHidden = false
                    attachment_view.isHidden = false
                }
            } else {
//                self.title = "View Request"
                self.headingLabel.text = "View Request"
                self.hr_reference_number_textfield.isUserInteractionEnabled = false
                self.hr_status_textfield.isUserInteractionEnabled = false
                self.forwardBtn.isHidden = true
            }
        }
        if IMS_Inprogress_Ca == "\(current_user)" {
            self.claim_defined_view.isHidden = false
            self.risk_remark_view.isHidden = false
            self.type_of_risk_view.isHidden = false
            self.category_of_control_view.isHidden = false
            self.type_of_control_view.isHidden = false
            self.closure_remarks_view.isHidden = false
            self.hr_status_view.isHidden = false
            
            if self.ticket_request!.IS_CONTROL_DEFINED! > 0 {
                self.claim_defined_switch.isOn = true
            } else {
                self.claim_defined_switch.isOn = false
            }
            
            
            self.hr_status_textfield.text = self.ticket_request?.HR_STATUS ?? ""
            if havePermissionToEdit {
//                self.title = "Update Request"
                self.headingLabel.text = "Request Detail"
                self.risk_remarks_textview.delegate = self
                self.closure_remarks_textview.delegate = self
                self.type_of_risk_textfield.delegate = self
                self.category_of_control_textfield.delegate = self
                self.type_of_control_textfield.delegate = self
                self.hr_status_textfield.delegate = self
                
                self.remarks_attachment_stackview.isHidden = true
                self.attachment_view.isHidden = true
                self.remarks_view.isHidden = true
                
                let addRemarks = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_Add_Remarks_Controller)
                let addFiles   = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_Add_Files_Controller)
                
                if addRemarks!.count > 0 {
                    remarks_attachment_stackview.isHidden = false
                    remarks_view.isHidden = false
                }
                if addFiles!.count > 0 {
                    remarks_attachment_stackview.isHidden = false
                    attachment_view.isHidden = false
                }
            } else {
//                self.title = "View Request"
                self.headingLabel.text = "View Request"
                self.claim_defined_switch.isEnabled = false
                
                self.risk_remarks_textview.text = self.ticket_request!.RISK_REMARKS ?? ""
                self.risk_remarks_textview.isUserInteractionEnabled = false
                self.risk_remarks_word_counter.text = "\(self.ticket_request?.RISK_REMARKS?.count ?? 0)/200"
                
                if let category = AppDelegate.sharedInstance.db?.read_tbl_control_category(query: "SELECT * FROM \(db_lov_control_category) WHERE SERVER_ID_PK = '\(self.ticket_request!.CONTROL_CATEGORY ?? "")'").first {
                    self.category_of_control_textfield.text = category.NAME
                    self.category_of_control_textfield.isUserInteractionEnabled = false
                }
                
                if let risk = AppDelegate.sharedInstance.db?.read_tbl_risk_type(query: "SELECT * FROM \(db_lov_risk_type) WHERE SERVER_ID_PK = '\(self.ticket_request!.RISK_TYPE ?? "")'").first {
                    self.type_of_risk_textfield.text = risk.NAME
                    self.type_of_risk_textfield.isUserInteractionEnabled = false
                }
                
                if let control = AppDelegate.sharedInstance.db?.read_tbl_control_type(query: "SELECT * FROM \(db_lov_control_type) WHERE SERVER_ID_PK = '\(self.ticket_request!.CONTROL_TYPE ?? "")'").first {
                    self.type_of_control_textfield.text = control.NAME
                    self.type_of_control_textfield.isUserInteractionEnabled = false
                }
                
                
                self.closure_remarks_textview.text = self.ticket_request!.HR_REMARKS ?? ""
                self.closure_remarks_textview.isUserInteractionEnabled = false
                
                self.hr_status_textfield.text = self.ticket_request!.HR_STATUS ?? ""
                self.hr_status_textfield.isUserInteractionEnabled = false
                self.forwardBtn.isHidden = true
            }
        }
        if IMS_Inprogress_Rds == "\(current_user)" {
            if havePermissionToEdit {
                
            } else {
                self.forwardBtn.isHidden = true
            }
        }
    }
    
    func setupTextfields() {
        incident_detail_employee_id.label.textColor = UIColor.nativeRedColor()
        incident_detail_employee_id.label.text = "Employee ID"
        incident_detail_employee_id.text = "\(ticket_request!.REQ_ID!)"
        incident_detail_employee_id.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        
        
        incident_detail_employee_id_hod.label.textColor = UIColor.nativeRedColor()
        incident_detail_employee_id_hod.label.text = "Employee ID"
        incident_detail_employee_id_hod.text = "\(ticket_request!.REQ_ID!)"
        incident_detail_employee_id_hod.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        
        incident_detail_employee_detail.text = ticket_request!.REQ_REMARKS!
        
        incident_detail_word_counter.text = "\(ticket_request!.REQ_REMARKS!.count)/200"
        
        incident_detail_employee_detail_hod.text = ticket_request!.REQ_REMARKS!
        incident_detail_word_counter_hod.text = "\(ticket_request!.REQ_REMARKS!.count)/200"
        
        
        incident_detail_classification.label.textColor = UIColor.nativeRedColor()
        incident_detail_classification.label.text = "Classification"
        incident_detail_classification.text = "\(ticket_request!.CLASSIFICATION!)"
        incident_detail_classification.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        
        incident_detail_incident_level_3.label.textColor = UIColor.nativeRedColor()
        incident_detail_incident_level_3.label.text = "Incident Level 3"
        incident_detail_incident_level_3.text = "\(AppDelegate.sharedInstance.db!.read_tbl_lov_sub_detail(query: "SELECT * FROM \(db_lov_sub_detail) WHERE SERVER_ID_PK = '\(ticket_request!.LOV_SUBDETAIL!)'").first?.LOV_SUBDETL_NAME ?? "")"
        incident_detail_incident_level_3.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        
        
        incident_detail_loss_type.label.textColor = UIColor.nativeRedColor()
        incident_detail_loss_type.label.text = "Loss Type"
        
        if ticket_request!.IS_FINANCIAL == 1 {
            incident_detail_loss_type.text = "Financial"
        } else {
            incident_detail_loss_type.text = "Non Financial"
        }
        incident_detail_loss_type.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        
        
        area_textfield.label.textColor = UIColor.nativeRedColor()
        area_textfield.label.text = "Area"
        area_textfield.text = "Select Area"
        area_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        
        assigned_to_textfield.textColor = UIColor.nativeRedColor()
        assigned_to_textfield.label.text = "Assigned To"
        assigned_to_textfield.text = "Select Assigned To"
        assigned_to_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        
        
        incident_detail_loss_amount.label.textColor = UIColor.nativeRedColor()
        incident_detail_loss_amount.label.text = "Loss Amount"
        incident_detail_loss_amount.text = ""
        incident_detail_loss_amount.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        
        incident_detail_recovery_type.label.textColor = UIColor.nativeRedColor()
        incident_detail_recovery_type.label.text = "Recovery Type"
        incident_detail_recovery_type.text = ""
        incident_detail_recovery_type.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        
        
        //after hod
        incident_detail_city_textfield.label.textColor = UIColor.nativeRedColor()
        incident_detail_city_textfield.label.text = "City"
        incident_detail_city_textfield.text = ""
        incident_detail_city_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        
        incident_detail_consignment_textfield.label.textColor = UIColor.nativeRedColor()
        incident_detail_consignment_textfield.label.text = "Consignment #"
        incident_detail_consignment_textfield.text = ""
        incident_detail_consignment_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        //after hod
        
        
        //before hod
        incident_detail_cityview_textfield.label.textColor = UIColor.nativeRedColor()
        incident_detail_cityview_textfield.label.text = "City"
        incident_detail_cityview_textfield.text = "\(AppDelegate.sharedInstance.db!.read_tbl_area(query: "SELECT * FROM \(db_lov_area) WHERE SERVER_ID_PK = '\(self.ticket_request!.AREA!)'").first!.AREA_NAME)"
        incident_detail_cityview_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        
        
        //before hod
        
        if self.ticket_request!.CNSGNO != "" {
            self.incident_detail_consignment_VIEW.isHidden = false
            incident_details_consignment_view_textfield.label.textColor = UIColor.nativeRedColor()
            incident_details_consignment_view_textfield.label.text = "Consignment #"
            incident_details_consignment_view_textfield.text = "\(self.ticket_request!.CNSGNO!)"
            incident_details_consignment_view_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        }
        
        classification_textfield.label.textColor = UIColor.nativeRedColor()
        classification_textfield.label.text = "Classification"
        classification_textfield.placeholder = ""
        classification_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        classification_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        classification_textfield.delegate = self
        
        incident_1_textfield.label.textColor = UIColor.nativeRedColor()
        incident_1_textfield.label.text = "Incident Level 1"
        incident_1_textfield.placeholder = ""
        incident_1_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        incident_1_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        incident_1_textfield.delegate = self
        
        incident_2_textfield.label.textColor = UIColor.nativeRedColor()
        incident_2_textfield.label.text = "Incident Level 2"
        incident_2_textfield.placeholder = ""
        incident_2_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        incident_2_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        incident_2_textfield.delegate = self
        
        incident_3_textfield.label.textColor = UIColor.nativeRedColor()
        incident_3_textfield.label.text = "Incident Level 3"
        incident_3_textfield.placeholder = ""
        incident_3_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        incident_3_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        incident_3_textfield.delegate = self
        
        incident_loss_type.label.textColor = UIColor.nativeRedColor()
        incident_loss_type.label.text = "Loss Type"
        incident_loss_type.text = "Non Financial"
        incident_loss_type.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        incident_loss_type.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        incident_loss_type.delegate = self
        
        incident_loss_amount.label.textColor = UIColor.nativeRedColor()
        incident_loss_amount.label.text = "Loss Amount"
        incident_loss_amount.placeholder = ""
        incident_loss_amount.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        incident_loss_amount.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        incident_recovery_type.label.textColor = UIColor.nativeRedColor()
        incident_recovery_type.label.text = "Recovery Type"
        incident_recovery_type.placeholder = ""
        incident_recovery_type.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        incident_recovery_type.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        incident_recovery_type.delegate = self
        
        attachment_textfield.textColor = UIColor.nativeRedColor()
        attachment_textfield.label.text = "Attachments"
        attachment_textfield.text = "choose file"
        attachment_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        attachment_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        status_textfield.label.textColor = UIColor.nativeRedColor()
        status_textfield.label.text = "Ticket Status"
        if self.ticket_request!.TICKET_STATUS == IMS_Status_Closed || self.ticket_request!.TICKET_STATUS == IMS_Status_Submitted {
            status_textfield.text = self.ticket_request!.TICKET_STATUS!
        } else {
            status_textfield.text = IMS_Status_Inprogress
        }
        
        status_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        status_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
//        email_textfield.label.textColor = UIColor.nativeRedColor()
//        email_textfield.label.text = "Emails"
//        email_textfield.placeholder = "Enter Emails  (Semi Colon Seperated)"
//        email_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
//        email_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        
        //FS
        claim_reference_number_textfield.label.textColor = UIColor.nativeRedColor()
        claim_reference_number_textfield.label.text = "Claim Ref. Number"
        claim_reference_number_textfield.placeholder = "Enter Claim Reference Number"
        claim_reference_number_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        claim_reference_number_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        //INS
        ins_claim_reference_number_textfield.label.textColor = UIColor.nativeRedColor()
        ins_claim_reference_number_textfield.label.text = "Claim Ins. Amount"
        ins_claim_reference_number_textfield.placeholder = "Enter Insurance Claim Amount"
        ins_claim_reference_number_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        ins_claim_reference_number_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        hr_reference_number_textfield.label.textColor = UIColor.nativeRedColor()
        hr_reference_number_textfield.label.text = "Hr Ref. Number"
        hr_reference_number_textfield.placeholder = "Enter HR Reference Number"
        hr_reference_number_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        hr_reference_number_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        hr_status_textfield.label.textColor = UIColor.nativeRedColor()
        hr_status_textfield.label.text = "Status"
        hr_status_textfield.placeholder = ""
        hr_status_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        hr_status_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        type_of_risk_textfield.label.textColor = UIColor.nativeRedColor()
        type_of_risk_textfield.label.text = "Type of Risk"
        type_of_risk_textfield.placeholder = ""
        type_of_risk_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        type_of_risk_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        category_of_control_textfield.label.textColor = UIColor.nativeRedColor()
        category_of_control_textfield.label.text = "Category of Control"
        category_of_control_textfield.placeholder = ""
        category_of_control_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        category_of_control_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        type_of_control_textfield.label.textColor = UIColor.nativeRedColor()
        type_of_control_textfield.label.text = "Type of Control"
        type_of_control_textfield.placeholder = ""
        type_of_control_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        type_of_control_textfield.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
    }
    
    func setupPermissions() {
        let downloadURL = Bundle.main.url(forResource: "download-fill-icon", withExtension: "svg")!
        let historyURL = Bundle.main.url(forResource: "history-icon-fill", withExtension: "svg")!

        
        _ = CALayer(SVGURL: downloadURL) { (svgLayer) in
            svgLayer.resizeToFit(self.downloadBtn.bounds)
            self.downloadBtn.layer.addSublayer(svgLayer)
        }
        _ = CALayer(SVGURL: historyURL) { (svgLayer) in
            svgLayer.resizeToFit(self.historyBtn.bounds)
            self.historyBtn.layer.addSublayer(svgLayer)
        }
        if let _ = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_Download_Permission) {
            downloadBtn.isHidden = false
            downloadBtn.addTarget(self, action: #selector(openDownloadHistory), for: .touchUpInside)
        }
        if let _ = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_History_Permission) {
            historyBtn.isHidden = false
            historyBtn.addTarget(self, action: #selector(openRemarksHistory), for: .touchUpInside)
        }
        
        if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_View_Investigation_Summary).count > 0 {
            if IMS_Inprogress_Cs == "\(current_user)" {
                if self.ticket_request?.DETAILED_INVESTIGATION == "" {
                    self.incident_investigation_view.isHidden = true
                } else {
                    self.incident_investigation_view.isHidden = false
                }
            } else {
                self.incident_investigation_view.isHidden = false
            }
        }
        
        
        if havePermissionToEdit {
            if IMS_Submitted == current_user || IMS_Inprogress_Ro == current_user || IMS_Inprogress_Rhod == current_user ||
                IMS_Inprogress_Hod == current_user ||
                IMS_Inprogress_Ds == current_user {
                if let _ = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: IMS_Reject_Permision) {
                    rejectBtn.isHidden = false
                    rejectBtn.addTarget(self, action: #selector(rejectBtnTapped), for: .touchUpInside)
                }
            }
            
        }
    }
    
    @objc func rejectBtnTapped() {
        self.isRejected = true
        self.rejectBtn.isEnabled = false
        let storyboard = UIStoryboard(name: "Popups", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ConfirmationPopViewController") as! ConfirmationPopViewController
        controller.delegate = self
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        controller.modalTransitionStyle = .crossDissolve
        Helper.topMostController().present(controller, animated: true, completion: nil)
    }
    
    @objc func openDownloadHistory() {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "IMSFilesViewController") as! IMSFilesViewController
        controller.ticket_id = ticket_request!.SERVER_ID_PK
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func openRemarksHistory() {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "IMSHistoryViewController") as! IMSHistoryViewController
        
        
        controller.ticket_id = ticket_request!.SERVER_ID_PK
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: IBActions
    @IBAction func onOffSwitch(_ sender: UISwitch) {
        
        switch sender.tag {
        case 1:
            break
            
        case 2:
            if sender.isOn {
                self.claim_reference_number_view.isHidden = false
            } else {
                self.claim_reference_number_view.isHidden = true
            }
            break
//        case 3:
//            if sender.isOn {
//                self.ins_claim_reference_number_view.isHidden = false
//            } else {
//                self.ins_claim_reference_number_view.isHidden = true
//            }
        default:
            break
        }
    }
    @IBAction func showHideDetail_Tapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            if IMS_Submitted == "\(current_user)" || IMS_Inprogress_Ro == "\(current_user)" || IMS_Inprogress_Rhod == "\(current_user)" {
                UIView.animate(withDuration: 0.2) {
                    self.incident_detail_view.isHidden = false
                    self.showHideImage.image = UIImage(named: "up_white")
                    self.showHideLabel.text = "Hide Details"
                    self.view.layoutIfNeeded()
                    
                    self.showHideImage.image = UIImage(named: "up_white")
                    self.showHideLabel.text = "Hide Details"
                    self.view.layoutIfNeeded()
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.incident_detail_view_hod.isHidden = false
                    self.incident_detail_city_textfield.text = "\(AppDelegate.sharedInstance.db!.read_tbl_area(query: "SELECT * FROM \(db_lov_area) WHERE SERVER_ID_PK = '\(self.ticket_request!.AREA!)'").first!.AREA_NAME)"
                    if self.ticket_request!.CNSGNO != "" {
                        self.incident_detail_consignment_view.isHidden = false
                        self.incident_detail_consignment_textfield.text = "\(self.ticket_request!.CNSGNO!)"
                    }
                    if self.ticket_request!.IS_FINANCIAL == 1 {
                        self.incident_detail_view_height_constraint.constant = 610
                        self.incident_detail_loss_amount_view.isHidden = false
                        self.incident_detail_loss_amount.text = "\(self.ticket_request!.AMOUNT ?? 0.0)"
                        self.incident_detail_recovery_type.text = "\(self.ticket_request!.RECOVERY_TYPE!)"
                    }
                    self.showHideImage.image = UIImage(named: "up_white")
                    self.showHideLabel.text = "Hide Details"
                    self.view.layoutIfNeeded()
                }
            }
        } else {
            if IMS_Submitted == "\(current_user)" || IMS_Inprogress_Ro == "\(current_user)" || IMS_Inprogress_Rhod == "\(current_user)" {
                UIView.animate(withDuration: 0.2) {
                    self.incident_detail_view.isHidden = true
                    self.showHideImage.image = UIImage(named: "drop_down_white")
                    self.showHideLabel.text = "Show Details"
                    self.view.layoutIfNeeded()
                    
                    self.showHideImage.image = UIImage(named: "drop_down_white")
                    self.showHideLabel.text = "Show Details"
                    self.view.layoutIfNeeded()
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.incident_detail_view_hod.isHidden = true
                    self.incident_detail_city_textfield.text = "\(AppDelegate.sharedInstance.db!.read_tbl_area(query: "SELECT * FROM \(db_lov_area) WHERE SERVER_ID_PK = '\(self.ticket_request!.AREA!)'").first!.AREA_NAME)"
                    
                    if self.ticket_request!.CNSGNO != "" {
                        self.incident_detail_consignment_view.isHidden = false
                        self.incident_detail_consignment_textfield.text = "\(self.ticket_request!.CNSGNO!)"
                    }
                    if self.ticket_request!.IS_FINANCIAL == 1 {
                        self.incident_detail_view_height_constraint.constant = 640
                        self.incident_detail_loss_amount_view.isHidden = false
                        self.incident_detail_loss_amount.text = "\(self.ticket_request!.AMOUNT ?? 0.0)"
                        self.incident_detail_recovery_type.text = "\(self.ticket_request!.RECOVERY_TYPE!)"
                    }
                    self.showHideImage.image = UIImage(named: "drop_down_white")
                    self.showHideLabel.text = "Show Details"
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    @IBAction func incidentInvestigationTapped(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "IncidentInvestigationViewController") as! IncidentInvestigationViewController
        if current_user == IMS_Inprogress_As {
            if ticket_request!.TICKET_STATUS == IMS_Status_Inprogress_As {
                controller.isEditable = true
                controller.updatedelegate = self
            }
            
        }
        controller.ticket = ticket_request
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func employeeRelatedBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            employeeRelatedBtn.borderWidth = 0
            employeeRelatedBtn.bgColor = UIColor.nativeRedColor()
            employeeRelatedBtn.buttonImage = UIImage(named:"check")
        } else {
            employeeRelatedBtn.borderWidth = 1
            employeeRelatedBtn.bgColor = UIColor.white
            employeeRelatedBtn.buttonImage = nil
        }
    }
    @IBAction func addAttachmentTapped(_ sender: Any) {
        self.showAlertActionSheet(title: "Select an image and documents", message: "", sender: sender as! UIButton)
    }
    
    @IBAction func forwardBtnTapped(_ sender: Any) {
        
        switch current_user {
        case IMS_Submitted, IMS_Inprogress_Ro, IMS_Inprogress_Rhod:
            guard let _ = setupLineManager() else {
                return
            }
            break
        case IMS_Inprogress_Hod:
            guard let _ = setupHeadOfDepartment() else {
                return
            }
            break
        case IMS_Inprogress_Cs:
            guard let _ = setupCentralSecurity() else {
                return
            }
            break
        case IMS_Inprogress_As:
            guard let _ = setupAreaSecurity() else {
                return
            }
            break
        case IMS_Inprogress_Hs, IMS_Inprogress_Rds:
            guard let _ = setupHeadOfSecurity() else {
                return
            }
            break
        case IMS_Inprogress_Ds:
            guard let _ = setupDirectorOfSecurity() else {
                return
            }
            break
        case IMS_Inprogress_Fs:
            guard let _ = setupFinancialServices() else {
                return
            }
            break
        case IMS_Inprogress_Ins:
            guard let _ = setupINSFinancialServices() else {
                return
            }
            break
        case IMS_Inprogress_Hr:
            guard let _ = setupHR() else {
                return
            }
            break
        case IMS_Inprogress_Fi:
            guard let _ = setupFinance() else {
                return
            }
            break
        case IMS_Inprogress_Ca:
            guard let _ = setupController() else {
                return
            }
            break
        default:
            break
        }
        self.forwardBtn.isEnabled = false
        let storyboard = UIStoryboard(name: "Popups", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ConfirmationPopViewController") as! ConfirmationPopViewController
        controller.delegate = self
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        if current_user == IMS_Inprogress_Hod {
            let is_investigation = self.investigation_required_switch.isOn ? true : false
            
            if is_investigation {
                controller.heading = "Currently Investigation Required is On.\nAre you sure you want to proceed?"
            } else {
                controller.heading = "Currently Investigation Required is Off.\nAre you sure you want to proceed?"
            }
        }
        
        controller.modalTransitionStyle = .crossDissolve
        Helper.topMostController().present(controller, animated: true, completion: nil)
    }
}

//MARK: Add Attachment METHODS
extension IMSViewUpdateRequestViewController {
    func showAlertActionSheet(title: String, message: String, sender: UIButton) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: { _ in
            self.camera()
        }))
        
        alert.addAction(UIAlertAction(title: "Select from Gallery", style: .default, handler: { _ in
            self.photoLibrary()
        }))
        
        alert.addAction(UIAlertAction(title: "Select Documents", style: .default, handler: { _ in
            self.addAttachments_Tapped()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
            alert.popoverPresentationController?.permittedArrowDirections = [.up, .down]
        default:
            break
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func camera() {
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            picker.sourceType = .camera
            present(picker, animated: true, completion: nil)
        } else {
            let alertWarning = UIAlertView(title:"Warning", message: "You don't have camera", delegate:nil, cancelButtonTitle:"OK", otherButtonTitles:"")
            alertWarning.show()
        }
    }
    fileprivate func photoLibrary() {
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
}

extension IMSViewUpdateRequestViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0.0
    }
}

//MARK: UITableview Datasource Delegate
extension IMSViewUpdateRequestViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.attachmentFiles?.count {
            return count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddAttachmentsCell") as! AddAttachmentsTableCell
        let data = self.attachmentFiles![indexPath.row]
        
        cell.attachment_uploadBtn.isHidden = true
        
        if !data.isUploaded {
            cell.attachment_uploadBtn.isHidden = false
            cell.attachment_discardBtn.tag = indexPath.row
            cell.attachment_uploadBtn.tag  = indexPath.row
            
            cell.attachment_discardBtn.addTarget(self, action: #selector(discard_btn_tapped(sender:)), for: .touchUpInside)
            cell.attachment_uploadBtn.addTarget(self, action: #selector(upload_btn_tapped(sender:)), for: .touchUpInside)
        } else {
            cell.attachment_discardBtn.setBackgroundImage(UIImage(named: "checked-new"), for: .normal)
        }
        cell.attachment_name.text = data.fileName
        
        return cell
    }
    
    @objc func upload_btn_tapped(sender: UIButton) {
        if !CustomReachability.isConnectedNetwork() {
            self.view.makeToast(NOINTERNETCONNECTION)
            return
        }
        self.view.makeToastActivity(.center)
        self.freezeScreen()
        let fileData = self.attachmentFiles![sender.tag]
        
        
        let fileManager = FileManager.default
        if let tDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let url = NSURL(fileURLWithPath: tDocumentDirectory.absoluteString)
            if let pathComponent = url.appendingPathComponent("\(fileData.fileName)") {
                let fileExtension: CFString = "\(fileData.fileExtension)" as CFString
                
                guard let extUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, nil)?.takeUnretainedValue() else { return }
                guard let mimeUTI = UTTypeCopyPreferredTagWithClass(extUTI, kUTTagClassMIMEType) else { return }
                
                let type = (mimeUTI.takeRetainedValue() as? NSString) as! String
                
                var data: Data?
                
                if String(type.split(separator: "/").first!) == "application" {
                    do {
                        data = try Data(contentsOf: pathComponent)
                    } catch let err {
                        print(err.localizedDescription)
                    }
                } else if String(type.split(separator: "/").first!) == "image" {
                    let image = UIImage(contentsOfFile: pathComponent.path)
                    data = image?.jpegData(compressionQuality: 100.0)
                }
                Alamofire.upload(multipartFormData: { (formData) in
                    formData.append(CURRENT_USER_LOGGED_IN_ID.data(using: .utf8)!, withName: "empno")
                    formData.append(API_KEY.data(using: .utf8)!, withName: "api_key")
                    formData.append(data!, withName: "file", fileName: fileData.fileName, mimeType: type)
                }, usingThreshold: .max, to: UPLOADFILESURL, method: .post, headers: nil) { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.uploadProgress(closure: { (progress) in
                                   print("Upload Progress: \(progress.fractionCompleted)")
                              })
                        upload.responseJSON { response in
                            if let data = response.data {
                                let json = JSON(data)
                                print(json)
                                if let returnCode = json.dictionary?[returnStatus]?.dictionary?[_code] {
                                    switch returnCode.stringValue {
                                    case "0200":
                                        if let fileSize = json.dictionary?["fileSize"] {
                                            self.attachmentFiles![sender.tag].fileSize = "\(fileSize.intValue / 1024)"
                                        }
                                        if let filePath = json.dictionary?["path"] {
                                            self.attachmentFiles![sender.tag].fileUploadedURL = filePath.stringValue
                                        }
                                        if let fileExtension = json.dictionary?["fileExtension"] {
                                            self.attachmentFiles![sender.tag].fileExtension = fileExtension.stringValue
                                        }
                                        do {
                                            try fileManager.removeItem(atPath: fileData.fileUrl)
                                        } catch let err {
                                            print(err.localizedDescription)
                                        }
                                        self.attachmentFiles![sender.tag].isUploaded = true
                                        print("SUcccessfully upload")
                                        DispatchQueue.main.async {
                                            self.unFreezeScreen()
                                            self.view.hideToastActivity()
                                            self.tableView.reloadData()
                                        }
                                        break
                                    case "0400", "0401","0402","0403","0404":
                                        DispatchQueue.main.async {
                                            self.view.hideToastActivity()
                                            self.view.makeToast("Max allowed file size is 2 MB")
                                            self.unFreezeScreen()
                                        }
                                        break
                                    default:
                                        DispatchQueue.main.async {
                                            self.view.hideToastActivity()
                                            self.view.makeToast(SOMETHINGWENTWRONG)
                                            self.unFreezeScreen()
                                        }
                                        break
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        self.view.hideToastActivity()
                                        self.view.makeToast(SOMETHINGWENTWRONG)
                                        self.unFreezeScreen()
                                    }
                                }
                            }
                        }
                        break
                    case .failure(let err):
                        print(err.localizedDescription)
                        DispatchQueue.main.async {
                            self.view.hideToastActivity()
                            self.view.makeToast(SOMETHINGWENTWRONG)
                            self.unFreezeScreen()
                        }
                        break
                    }
                }
            }
        }
    }
    
    @objc func discard_btn_tapped(sender: UIButton) {
        let fileData = self.attachmentFiles![sender.tag]
        if fileData.isUploaded {
            return
        }
        let fileManager = FileManager.default
        if let tDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let url = NSURL(fileURLWithPath: tDocumentDirectory.absoluteString)
            if let pathComponent = url.appendingPathComponent("\(fileData.fileName)") {
                do {
                    try fileManager.removeItem(atPath: pathComponent.path)
                    self.attachmentFiles!.remove(at: sender.tag)
                    self.tableView.reloadData()
                    DispatchQueue.main.async {
                        self.tableView_height_constraint.constant = 0
                        self.tableView_height_constraint.constant += CGFloat((self.attachmentFiles!.count * 60) + 10)
                        UIView.animate(withDuration: 0.2) {
                            self.attachement_view_height_constraint.constant -= 60
                            self.view.layoutIfNeeded()
                        }
                        self.tableView.reloadData()
                        
                    }
                } catch let err {
                    print(err.localizedDescription)
                }
            }
        }
    }
}


//MARK: UIImagePickerControllerDelegate
extension IMSViewUpdateRequestViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            picker.view.makeToastActivity(.center)
            image.compressTo1(1) { NewImage in
                picker.dismiss(animated: true) {
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let fileName = "\(UUID().uuidString).jpg" // name of the image to be saved
                        let fileExtension = "jpg"
                        let fileURL = documentsDirectory.appendingPathComponent(fileName)
                        if let data = NewImage.jpegData(compressionQuality: 0.2),!FileManager.default.fileExists(atPath: fileURL.path){
                            do {
                                try data.write(to: fileURL)
                                
                                print("file saved")
                                self.attachmentFiles?.append(AttachmentsList(fileName: fileName,
                                                                             fileExtension: fileExtension,
                                                                             fileUrl: fileURL.absoluteString,
                                                                             fileSize: fileURL.fileSizeString,
                                                                             fileUploadedURL: "",
                                                                             isUploaded: false,
                                                                             fileUploadedBy: "",
                                                                             createdOn: ""))
                            } catch {
                                print("error saving file:", error)
                            }
                        }
                    FileManager.default.clearTmpDirectory()
                    self.tableView.reloadData()
                    
                    DispatchQueue.main.async {
                        picker.view.hideToastActivity()
                        self.attachement_view_height_constraint.constant -= self.tableView_height_constraint.constant
                        self.tableView_height_constraint.constant = 0
                        self.tableView_height_constraint.constant += CGFloat((self.attachmentFiles!.count * 60) + 10)
                        UIView.animate(withDuration: 0.4) {
                            self.attachement_view_height_constraint.constant += self.tableView_height_constraint.constant
                            self.view.layoutIfNeeded()
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}

//MARK: UIDocumentPicker Delegate
extension IMSViewUpdateRequestViewController: UIDocumentPickerDelegate,UINavigationControllerDelegate {
    func addAttachments_Tapped() {
        let newType = ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key","public.image", "com.apple.application", "public.item", "public.content", "public.audiovisual-content", "public.movie", "public.audiovisual-content", "public.video", "public.audio", "public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content"]
        let importMenu = UIDocumentPickerViewController(documentTypes: newType, in: .import)

        if #available(iOS 11.0, *) {
            importMenu.allowsMultipleSelection = false
        }

        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet

        present(importMenu, animated: true)
    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let fileName = urls.first?.lastPathComponent
        if urls.first!.fileSize > 2048000 {
            self.view.makeToast("File size should be less than 2MB")
            return
        }
        let fileManager = FileManager.default
        if let tDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let url = NSURL(fileURLWithPath: tDocumentDirectory.absoluteString)
            if let pathComponent = url.appendingPathComponent("\(fileName!)") {
                do {
                    if fileManager.fileExists(atPath: pathComponent.path) {
                        print("file size = \(pathComponent.fileSize), \(pathComponent.fileSizeString)")
                        
                        let fileExtension = pathComponent.pathExtension
                        self.attachmentFiles?.append(AttachmentsList(fileName: fileName!,
                                                                     fileExtension: fileExtension,
                                                                     fileUrl: pathComponent.absoluteString,
                                                                     fileSize: pathComponent.fileSizeString,
                                                                     fileUploadedURL: "",
                                                                     isUploaded: false,
                                                                     fileUploadedBy: "",
                                                                     createdOn: ""))
                    } else {
                        try fileManager.copyItem(at: urls.first!, to: pathComponent)
                        let fileExtension = pathComponent.pathExtension
                        self.attachmentFiles?.append(AttachmentsList(fileName: fileName!,
                                                                     fileExtension: fileExtension,
                                                                     fileUrl: pathComponent.absoluteString,
                                                                     fileSize: pathComponent.fileSizeString,
                                                                     fileUploadedURL: "",
                                                                     isUploaded: false,
                                                                     fileUploadedBy: "",
                                                                     createdOn: ""))
                    }
                    
                    
                    self.tableView.reloadData()
                    
                    DispatchQueue.main.async {
                        self.attachement_view_height_constraint.constant -= self.tableView_height_constraint.constant
                        self.tableView_height_constraint.constant = 0
                        self.tableView_height_constraint.constant += CGFloat((self.attachmentFiles!.count * 60) + 10)
                        UIView.animate(withDuration: 0.4) {
                            self.attachement_view_height_constraint.constant += self.tableView_height_constraint.constant
                            self.view.layoutIfNeeded()
                        }
                        self.tableView.reloadData()
                    }
                } catch let err {
                    print(err.localizedDescription)
                }
            }
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}



//MARK: UITextField Delegate
extension IMSViewUpdateRequestViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case CLASSIFICATION_TAG:
            //CLASSIFICATION
            let storyboard = UIStoryboard(name: "Popups", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestListingViewController") as! NewRequestListingViewController
            let query = "SELECT * FROM \(db_lov_classification)"
            controller.lov_classification = AppDelegate.sharedInstance.db?.read_tbl_classification(query: query)
            controller.heading = "Classification"
            
            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .overFullScreen
            }
            controller.modalTransitionStyle = .crossDissolve
            controller.imsupdatedelegate = self
            Helper.topMostController().present(controller, animated: true, completion: nil)
            return false
        case INCIDENT_LEVEL_1_TAG:
            //INCIDENT LEVEL 1
            guard let _ = self.lov_classification else {
                self.view.makeToast("Classification is mandatory")
                return false
            }
            let storyboard = UIStoryboard(name: "Popups", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestListingViewController") as! NewRequestListingViewController
            let query = "SELECT * FROM \(db_lov_master)"
            controller.lov_master = AppDelegate.sharedInstance.db?.read_tbl_lov_master(query: query)
            controller.heading = "Incident Level 1"
            
            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .overFullScreen
            }
            controller.modalTransitionStyle = .crossDissolve
            controller.imsupdatedelegate = self
            Helper.topMostController().present(controller, animated: true, completion: nil)
            return false
        case INCIDENT_LEVEL_2_TAG:
            guard let _ = self.lov_master_table else {
                self.view.makeToast("Incident Level 1 is mandatory")
                return false
            }
            //INCIDENT LEVEL 2
            let storyboard = UIStoryboard(name: "Popups", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestListingViewController") as! NewRequestListingViewController
            let query = "SELECT * FROM \(db_lov_detail) WHERE MASTER_ID = '\(self.lov_master_table!.SERVER_ID_PK)'"
            controller.lov_detail = AppDelegate.sharedInstance.db?.read_tbl_lov_detail(query: query)
            controller.heading = "Incident Level 2"
            
            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .overFullScreen
            }
            controller.modalTransitionStyle = .crossDissolve
            controller.imsupdatedelegate = self
            Helper.topMostController().present(controller, animated: true, completion: nil)
            return false
        case INCIDENT_LEVEL_3_TAG:
            guard let _ = self.lov_detail_table else {
                self.view.makeToast("Incident Level 2 is mandatory")
                return false
            }
            //INCIDENT LEVEL 3
            let storyboard = UIStoryboard(name: "Popups", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestListingViewController") as! NewRequestListingViewController
            let query = "SELECT * FROM \(db_lov_sub_detail) WHERE MASTER_ID = '\(self.lov_master_table!.SERVER_ID_PK)' AND DETAIL_ID = '\(self.lov_detail_table!.SERVER_ID_PK)'"
            controller.lov_subdetail = AppDelegate.sharedInstance.db?.read_tbl_lov_sub_detail(query: query)
            controller.heading = "Incident Level 3"
            
            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .overFullScreen
            }
            controller.modalTransitionStyle = .crossDissolve
            controller.imsupdatedelegate = self
            Helper.topMostController().present(controller, animated: true, completion: nil)
            return false
        case LOSS_TYPE_TAG:
            //FINANCIAL TYPE
            let storyboard = UIStoryboard(name: "Popups", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestListingViewController") as! NewRequestListingViewController
            
            let financial = [financial_type(ID: 1, TYPE: "Non Financial"),
                             financial_type(ID: 2, TYPE: "Financial")]
            
            controller.lov_financial = financial
            controller.heading = "Financial Type"
            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .overFullScreen
            }
            controller.modalTransitionStyle = .crossDissolve
            controller.imsupdatedelegate = self
            Helper.topMostController().present(controller, animated: true, completion: nil)
            return false
        case RECOVERY_TYPE_TAG:
            //RECOVERY TYPE
            let storyboard = UIStoryboard(name: "Popups", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestListingViewController") as! NewRequestListingViewController
            
            let query = "SELECT * FROM \(db_lov_recovery_type)"
            controller.lov_recovery = AppDelegate.sharedInstance.db?.read_tbl_recovery_type(query: query)
            controller.heading = "Financial Type"
            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .overFullScreen
            }
            controller.modalTransitionStyle = .crossDissolve
            controller.imsupdatedelegate = self
            Helper.topMostController().present(controller, animated: true, completion: nil)
            return false
        
        case AREA_TAG:
            let storyboard = UIStoryboard(name: "Popups", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestListingViewController") as! NewRequestListingViewController
            
            let query = "SELECT * FROM \(db_lov_area)"
            controller.lov_area = AppDelegate.sharedInstance.db?.read_tbl_area(query: query)
            controller.heading = "Area"
            controller.isIMSUpdate = true
            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .overFullScreen
            }
            controller.modalTransitionStyle = .crossDissolve
            controller.imsupdatedelegate = self
            Helper.topMostController().present(controller, animated: true, completion: nil)
            return false
        case ASSIGNED_TO_TAG:
            guard  let _ = lov_area else {
                self.view.makeToast("Area Selection is mandatory")
                return false
            }
            let storyboard = UIStoryboard(name: "Popups", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestListingViewController") as! NewRequestListingViewController
            
            let query = "SELECT * FROM \(db_lov_area_security) WHERE AREA_CODE = '\(self.lov_area!.SERVER_ID_PK)'"
            controller.lov_assigned_to = AppDelegate.sharedInstance.db?.read_tbl_area_security(query: query)
            controller.heading = "Area Security"
            controller.isIMSUpdate = true
            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .overFullScreen
            }
            controller.modalTransitionStyle = .crossDissolve
            controller.imsupdatedelegate = self
            Helper.topMostController().present(controller, animated: true, completion: nil)
            return false
        case HR_STATUS:
            let storyboard = UIStoryboard(name: "Popups", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestListingViewController") as! NewRequestListingViewController
            
            let query = "SELECT * FROM \(db_lov_hr_status)"
//            if current_user == IMS_Inprogress_Ca {
//                query = "SELECT * FROM \(db_lov_hr_status) WHERE NAME = 'Close'"
//            } else {
//
//            }
            controller.hr_status = AppDelegate.sharedInstance.db?.read_tbl_hr_status(query: query)
            controller.heading = "Select Status"
            controller.isIMSUpdate = true
            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .overFullScreen
            }
            controller.modalTransitionStyle = .crossDissolve
            controller.imsupdatedelegate = self
            Helper.topMostController().present(controller, animated: true, completion: nil)
            return false
        
        case RISK_TYPE:
            let storyboard = UIStoryboard(name: "Popups", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestListingViewController") as! NewRequestListingViewController
            
            let query = "SELECT * FROM \(db_lov_risk_type)"
            controller.lov_risk_type = AppDelegate.sharedInstance.db?.read_tbl_risk_type(query: query)
            controller.heading = "Type of Risk"
            controller.isIMSUpdate = true
            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .overFullScreen
            }
            controller.modalTransitionStyle = .crossDissolve
            controller.imsupdatedelegate = self
            Helper.topMostController().present(controller, animated: true, completion: nil)
            return false
        case CATEGORY_CONTROL:
            let storyboard = UIStoryboard(name: "Popups", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestListingViewController") as! NewRequestListingViewController
            
            let query = "SELECT * FROM \(db_lov_control_category)"
            controller.lov_category_control = AppDelegate.sharedInstance.db?.read_tbl_control_category(query: query)
            controller.heading = "Category of Control"
            controller.isIMSUpdate = true
            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .overFullScreen
            }
            controller.modalTransitionStyle = .crossDissolve
            controller.imsupdatedelegate = self
            Helper.topMostController().present(controller, animated: true, completion: nil)
            return false
        case TYPE_CONTROL:
            let storyboard = UIStoryboard(name: "Popups", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestListingViewController") as! NewRequestListingViewController
            
            let query = "SELECT * FROM \(db_lov_control_type)"
            controller.lov_type_of_control = AppDelegate.sharedInstance.db?.read_tbl_control_type(query: query)
            controller.heading = "Type of Control"
            controller.isIMSUpdate = true
            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .overFullScreen
            }
            controller.modalTransitionStyle = .crossDissolve
            controller.imsupdatedelegate = self
            Helper.topMostController().present(controller, animated: true, completion: nil)
            return false
        default:
            return true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            return true
        }
        switch textField.tag {
        case HR_STATUS:
            let maxLength = 20
            let currentString: NSString = textField.text as! NSString
            let newString: NSString =
                    currentString.replacingCharacters(in: range, with: string) as NSString
            if newString.length <= maxLength {
                return true
            }
            return false
        case HR_REF_NUMBER:
            let maxlength = 25
            let currentString: NSString = textField.text as! NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            if newString.length <= maxlength {
                let alphaNumericRegEx = "[a-zA-Z0-9]"
                let predicate = NSPredicate(format:"SELF MATCHES %@", alphaNumericRegEx)
                return predicate.evaluate(with: string)
            }
            return false
        case LOSS_AMOUNT_TAG:
            let text = (textField.text ?? "") as NSString
            let newText = text.replacingCharacters(in: range, with: string)
            if let regex = try? NSRegularExpression(pattern: "^[0-9]{0,7}((\\.|,)[0-9]{0,2})?$", options: .caseInsensitive) {
                return regex.numberOfMatches(in: newText, options: .reportProgress, range: NSRange(location: 0, length: (newText as NSString).length)) > 0
            }
            return false
        default:
            return true
        }
    }
}


//MARK: UITextView Delegate
extension IMSViewUpdateRequestViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        switch textView.tag {
        case ENTER_REMARKS_TAG:
            if textView.text == ENTER_REMARKS {
                textView.text = ""
            }
            break
        case ENTER_EXECUTIVE_SUMMARY_TAG:
            if textView.text == ENTER_EXECUTIVE_SUMMARY {
                textView.text = ""
            }
            break
        case ENTER_RECOMMENDATIONS_TAG:
            if textView.text == ENTER_RECOMMENDATIONS {
                textView.text = ""
            }
            break
        case ENTER_ENDORESSEMENT_TAG:
            if textView.text == ENTER_ENDORESSEMENT {
                textView.text = ""
            }
            break
        case ENTER_RISK_REMARKS_TAG:
            if textView.text == ENTER_RISK_REMARKS {
                textView.text = ""
            }
            break
        case ENTER_CLOSURE_REMARKS_TAG:
            if textView.text == ENTER_CLOSURE_REMARKS {
                textView.text = ""
            }
            break
        default:
            break
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        switch textView.tag {
        case ENTER_REMARKS_TAG:
            if textView.text.count <= 0 {
                textView.text = ENTER_REMARKS
            }
            break
        case ENTER_EXECUTIVE_SUMMARY_TAG:
            if textView.text.count <= 0 {
                textView.text = ENTER_EXECUTIVE_SUMMARY
            }
            break
        case ENTER_RECOMMENDATIONS_TAG:
            if textView.text.count <= 0 {
                textView.text = ENTER_RECOMMENDATIONS
            }
            break
        case ENTER_ENDORESSEMENT_TAG:
            if textView.text.count <= 0 {
                textView.text = ENTER_ENDORESSEMENT
            }
            break
        case ENTER_CLOSURE_REMARKS_TAG:
            if textView.text.count <= 0 {
                textView.text = ENTER_CLOSURE_REMARKS
            }
            break
        case ENTER_RISK_REMARKS_TAG:
            if textView.text.count <= 0 {
                textView.text = ENTER_RISK_REMARKS
            }
            break
        default:
            break
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var maxLength = 0
        if textView.tag == 14 {
            maxLength = 20000
        } else {
            maxLength = 200
        }
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
            case ENTER_REMARKS_TAG:
                self.remarks_word_counter.text = "\(newString.length)/200"
                return true
            case ENTER_EXECUTIVE_SUMMARY_TAG:
                self.executive_summary_word_counter.text = "\(newString.length)/200"
                return true
            case ENTER_RECOMMENDATIONS_TAG:
                self.recommendations_word_counter.text = "\(newString.length)/200"
                return true
            case ENTER_ENDORESSEMENT_TAG:
                self.endoresement_word_counter.text = "\(newString.length)/200"
                return true
            case ENTER_RISK_REMARKS_TAG:
                self.risk_remarks_word_counter.text = "\(newString.length)/200"
                return true
            case ENTER_CLOSURE_REMARKS_TAG:
                self.closure_remarks_word_counter.text = "\(newString.length)/200"
                return true
            case ENTER_EMAILS_TAG:
                return true
            default:
                return false
            }
        }
        return false
    }
}



extension IMSViewUpdateRequestViewController: IMSUpdateRequestDelegate {
    
    func updateClassification(classification: tbl_lov_classification) {
        self.lov_classification = classification
        self.classification_textfield.text = classification.NAME
        
        self.incident_1_textfield.text = ""
        self.incident_2_textfield.text = ""
        self.incident_3_textfield.text = ""
        self.lov_master_table = nil
        self.lov_detail_table = nil
        self.lov_subdetail_table = nil
    }
    
    func updateIncidentLevel1(incident_level_1: tbl_lov_master) {
        self.lov_master_table = incident_level_1
        self.incident_1_textfield.text = incident_level_1.LOV_NAME
        
        self.incident_2_textfield.text = ""
        self.incident_3_textfield.text = ""
        self.lov_detail_table = nil
        self.lov_subdetail_table = nil
    }
    
    func updateIncidentLevel2(incident_level_2: tbl_lov_detail) {
        self.lov_detail_table = incident_level_2
        self.incident_2_textfield.text = incident_level_2.NAME
        
        self.incident_3_textfield.text = ""
        self.lov_subdetail_table = nil
    }
    
    func updateIncidentLevel3(incident_level_3: tbl_lov_sub_detail) {
        self.lov_subdetail_table = incident_level_3
        self.incident_3_textfield.text = incident_level_3.LOV_SUBDETL_NAME
    }
    
    func updateFinancialType(financial: financial_type) {
        self.lov_financial = financial
        if financial.TYPE == "Financial" {
            UIView.animate(withDuration: 0.2) {
                self.incident_loss_type.text = financial.TYPE
                self.loss_amount_stackview.isHidden = false
                self.view.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.incident_loss_type.text = financial.TYPE
                self.loss_amount_stackview.isHidden = true
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func updateRecoveryType(recoery_type: tbl_lov_recovery_type) {
        self.lov_recovery_type = recoery_type
        self.incident_recovery_type.text = recoery_type.NAME
    }
    
    func updateAreaType(area: tbl_lov_area) {
        self.lov_area = area
        self.area_textfield.text = area.AREA_NAME
        
        self.lov_assigned_to = nil
        self.assigned_to_textfield.label.text = "*Assigned To "
        self.assigned_to_textfield.text = "Select Assigned To"
    }
    
    func updateAssignedTo(assigned_to: tbl_lov_area_security) {
        self.lov_assigned_to = assigned_to
        self.assigned_to_textfield.text = assigned_to.SECURITY_PERSON
    }
    
    func updateHrStatus(hrstatus: tbl_lov_hr_status) {
        self.hr_status_textfield.text = hrstatus.NAME
        self.lov_hr_status = hrstatus
    }
    func updateRiskType(risk_type: tbl_lov_risk_type) {
        self.type_of_risk_textfield.text = risk_type.NAME
        self.lov_risk_type = risk_type
    }
    
    func updateCategoryControl(category_control: tbl_lov_control_category) {
        self.category_of_control_textfield.text = category_control.NAME
        self.lov_category_control = category_control
    }
    
    func updateTypeControl(type_control: tbl_lov_control_type) {
        self.type_of_control_textfield.text = type_control.NAME
        self.lov_type_control = type_control
    }
}




//MARK: Validation and Restrictions before Network Call
extension IMSViewUpdateRequestViewController {
    func getTicketFiles() -> [[String:String]]{
        var temp_ticket_files = [[String:String]]()
        for index in self.attachmentFiles! {
            let dictionary = [
                "file_url": index.fileUploadedURL,
                "file_extention": index.fileExtension,
                "file_size_kb": String(index.fileSize.split(separator: " ").first!)
            ]
            temp_ticket_files.append(dictionary)
        }
        return temp_ticket_files
    }
    
    func setupController() -> [String:Any]? {
        let control = self.claim_defined_switch.isOn ? "1" : "0"
        if self.risk_remarks_textview.text == "" || self.risk_remarks_textview.text == ENTER_RISK_REMARKS {
            self.view.makeToast("Risk Remarks is mandatory")
            return nil
        }
        guard let _ = self.lov_risk_type else {
            self.view.makeToast("Type of Risk is mandatory")
            return nil
        }
        guard let _ = self.lov_category_control else {
            self.view.makeToast("Category of Control is mandatory")
            return nil
        }
        guard let _ = self.lov_type_control else {
            self.view.makeToast("Type of Control is mandatory")
            return nil
        }
        guard let _ = self.lov_hr_status else {
            self.view.makeToast("Status is mandatory")
            return nil
        }
        if self.closure_remarks_textview.text == "" || self.closure_remarks_textview.text == ENTER_CLOSURE_REMARKS {
            self.view.makeToast("Recommendations is mandatory")
            return nil
        }
        
        if !self.remarks_view.isHidden {
            if remarks_textview.text == "" || remarks_textview.text == ENTER_REMARKS {
                self.view.makeToast("Remarks is mandatory")
                return nil
            }
        }
        if willDBInsert {
            let columns = ["IS_CONTROL_DEFINED", "RISK_REMARKS", "RISK_TYPE", "CONTROL_CATEGORY", "CONTROL_TYPE", "HR_STATUS", "HR_REMARKS", "TICKET_STATUS"]
            let values = [control,
                          self.risk_remarks_textview.text!,
                          self.lov_risk_type!.SERVER_ID_PK,
                          self.lov_category_control!.SERVER_ID_PK,
                          self.lov_type_control!.SERVER_ID_PK,
                          self.lov_hr_status!.SERVER_ID_PK,
                          self.recommendations_textview.text!,
                          IMS_Status_Closed]
            AppDelegate.sharedInstance.db?.updateTables(tableName: db_hr_request, columnName: columns, updateValue: values, onCondition: "SERVER_ID_PK = '\(self.ticket_request!.SERVER_ID_PK!)'", { _ in })
        }
        let json = [
            "hr_request": [
                "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                "tickets": [
                    "ticketid": "\(self.ticket_request!.SERVER_ID_PK!)",
                    "status": IMS_Status_Closed,
                    "loginid": "\(CURRENT_USER_LOGGED_IN_ID)",
                    "closure_remarks" : "\(self.closure_remarks_textview.text!)",
                    "is_control_defined": control,
                    "risk_type": self.lov_risk_type!.SERVER_ID_PK,
                    "risk_remarks": self.risk_remarks_textview.text!,
                    "control_category": self.lov_category_control!.SERVER_ID_PK,
                    "control_type": self.lov_type_control!.SERVER_ID_PK,
                    "hr_status": self.lov_hr_status!.SERVER_ID_PK,
                    "ticket_logs": [
                        [
                            "inputby": IMS_InputBy_Controller, //"Er_Manager"
                            "remarks": self.remarks_textview.text?.replacingOccurrences(of: "'", with: "''") ?? "",
                            "ticket_files": getTicketFiles()
                        ]
                    ]
                ]
            ]
        ]
        let params = getAPIParameter(service_name: IMSUPDATE, request_body: json)
        return params
    }
    
    func setupFinance() -> [String:Any]? {
        if hr_reference_number_textfield.text == "" {
            self.view.makeToast("GL Transaction Number is mandatory")
            return nil
        }
        guard let _ = lov_hr_status else {
            self.view.makeToast("Status is mandatory")
            return nil
        }
        if !self.remarks_view.isHidden {
            if remarks_textview.text == "" || remarks_textview.text == ENTER_REMARKS {
                self.view.makeToast("Remarks is mandatory")
                return nil
            }
        }
        
        if willDBInsert {
            let columns = ["FINANCE_GL_NO", "HR_STATUS", "TICKET_STATUS"]
            let values = [self.hr_reference_number_textfield.text!, self.lov_hr_status!.SERVER_ID_PK, IMS_Status_Inprogress_Ca]
            AppDelegate.sharedInstance.db?.updateTables(tableName: db_hr_request, columnName: columns, updateValue: values, onCondition: "SERVER_ID_PK = '\(self.ticket_request!.SERVER_ID_PK!)'", { _ in })
        }
        let json = [
            "hr_request": [
                "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                "tickets": [
                    "ticketid": "\(self.ticket_request!.SERVER_ID_PK!)",
                    "status": IMS_Status_Inprogress_Ca,
                    "loginid": "\(CURRENT_USER_LOGGED_IN_ID)",
                    "closure_remarks" : "",
                    "finance_gl_no": self.hr_reference_number_textfield.text!,
                    "hr_status": self.lov_hr_status!.SERVER_ID_PK,
                    "ticket_logs": [
                        [
                            "inputby": IMS_InputBy_Finance, //"Er_Manager"
                            "remarks": self.remarks_textview.text?.replacingOccurrences(of: "'", with: "''") ?? "",
                            "ticket_files": getTicketFiles()
                        ]
                    ]
                ]
            ]
        ]
        let params = getAPIParameter(service_name: IMSUPDATE, request_body: json)
        return params
    }
    
    func setupHR() -> [String:Any]? {
        if hr_reference_number_textfield.text == "" {
            self.view.makeToast("Reference Number is mandatory")
            return nil
        }
        guard let _ = lov_hr_status else {
            self.view.makeToast("Status is mandatory")
            return nil
        }
        if !self.remarks_view.isHidden {
            if remarks_textview.text == "" || remarks_textview.text == ENTER_REMARKS {
                self.view.makeToast("Remarks is mandatory")
                return nil
            }
        }
        var ticket_status = ""
        if ticket_request!.IS_FINANCIAL == 1 && ticket_request!.IS_EMP_RELATED == 1 {
            ticket_status = IMS_Status_Inprogress_Fi
        } else {
            ticket_status = IMS_Status_Inprogress_Ca
        }
        
        if willDBInsert {
            let columns = ["HR_REF_NO", "HR_STATUS", "TICKET_STATUS"]
            let values = [self.hr_reference_number_textfield.text!, self.lov_hr_status!.SERVER_ID_PK, ticket_status]
            AppDelegate.sharedInstance.db?.updateTables(tableName: db_hr_request, columnName: columns, updateValue: values, onCondition: "SERVER_ID_PK = '\(self.ticket_request!.SERVER_ID_PK!)'", { _ in })
        }
        let json = [
            "hr_request": [
                "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                "tickets": [
                    "ticketid": "\(self.ticket_request!.SERVER_ID_PK!)",
                    "status": ticket_status,
                    "loginid": "\(CURRENT_USER_LOGGED_IN_ID)",
                    "closure_remarks" : "",
                    "hr_ref_no": self.hr_reference_number_textfield.text!,
                    "hr_status": self.lov_hr_status!.SERVER_ID_PK,
                    "ticket_logs": [
                        [
                            "inputby": IMS_InputBy_HumanResource, //"Er_Manager"
                            "remarks": self.remarks_textview.text?.replacingOccurrences(of: "'", with: "''") ?? "",
                            "ticket_files": getTicketFiles()
                        ]
                    ]
                ]
            ]
        ]
        let params = getAPIParameter(service_name: IMSUPDATE, request_body: json)
        return params
    }
    
    func setupINSFinancialServices() -> [String:Any]? {
        
        let is_insurance_claimable = self.ins_insurance_claimable_switch.isOn ? "1" : "0"
        var claim_reference_number = ""
        if is_insurance_claimable == "1" {
            if ins_claim_reference_number_textfield.text == "" {
                self.view.makeToast("Claim Insurance Amount is mandatory")
                return nil
            } else {
                claim_reference_number = self.ins_claim_reference_number_textfield.text!
            }
        }
        if !self.remarks_view.isHidden {
            if remarks_textview.text == "" || remarks_textview.text == ENTER_REMARKS {
                self.view.makeToast("Remarks is mandatory")
                return nil
            }
        }
        
        if willDBInsert {
            let columns = ["IS_INS_CLAIM_PROCESS", "INS_CLAIMED_AMOUNT", "TICKET_STATUS"]
            let values = [is_insurance_claimable, claim_reference_number, IMS_Status_Inprogress_Hr]
            AppDelegate.sharedInstance.db?.updateTables(tableName: db_hr_request, columnName: columns, updateValue: values, onCondition: "SERVER_ID_PK = '\(self.ticket_request!.SERVER_ID_PK!)'", { _ in })
        }
        let json = [
            "hr_request": [
                "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                "tickets": [
                    "ticketid": "\(self.ticket_request!.SERVER_ID_PK!)",
                    "status": IMS_Status_Inprogress_Hr,
                    "loginid": "\(CURRENT_USER_LOGGED_IN_ID)",
                    "closure_remarks" : "",
                    "is_ins_claim_process": is_insurance_claimable,
                    "v_ins_claimed_amt": claim_reference_number,
                    "ticket_logs": [
                        [
                            "inputby": IMS_InputBy_FinancialService, //"Er_Manager"
                            "remarks": self.remarks_textview.text?.replacingOccurrences(of: "'", with: "''") ?? "",
                            "ticket_files": getTicketFiles()
                        ]
                    ]
                ]
            ]
        ]
        let params = getAPIParameter(service_name: IMSUPDATE, request_body: json)
        return params
    }
    
    func setupFinancialServices() -> [String:Any]? {
        //INS //FS (if claim zero) // HR
        let is_insurance_claimable = self.insurance_claimable_switch.isOn ? "1" : "0"
        var claim_reference_number = ""
        if is_insurance_claimable == "1" {
            if claim_reference_number_textfield.text == "" {
                self.view.makeToast("Claim Reference Number is mandatory")
                return nil
            } else {
                claim_reference_number = self.claim_reference_number_textfield.text!
            }
        }
        if !self.remarks_view.isHidden {
            if remarks_textview.text == "" || remarks_textview.text == ENTER_REMARKS {
                self.view.makeToast("Remarks is mandatory")
                return nil
            }
        }
        
        var ticket_status = IMS_Status_Inprogress_Ins
        if is_insurance_claimable == "0" {
            if self.ticket_request!.IS_FINANCIAL == 1 && self.ticket_request!.IS_EMP_RELATED == 1 {
                ticket_status = IMS_Status_Inprogress_Hr
            } else if self.ticket_request!.IS_FINANCIAL == 0 && self.ticket_request!.IS_EMP_RELATED == 1 {
                ticket_status = IMS_Status_Inprogress_Hr
            } else if self.ticket_request!.IS_FINANCIAL == 1 && self.ticket_request!.IS_EMP_RELATED == 0 {
                ticket_status = IMS_Status_Inprogress_Fi
            } else {
                ticket_status = IMS_Status_Inprogress_Ca
            }
        }
        
        
        if willDBInsert {
            let columns = ["INS_CLAIM_REFNO", "IS_INS_CLAIM_PROCESS", "TICKET_STATUS"]
            let values = [claim_reference_number, is_insurance_claimable, ticket_status]
            AppDelegate.sharedInstance.db?.updateTables(tableName: db_hr_request, columnName: columns, updateValue: values, onCondition: "SERVER_ID_PK = '\(self.ticket_request!.SERVER_ID_PK!)'", { _ in })
        }
        let json = [
            "hr_request": [
                "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                "tickets": [
                    "ticketid": "\(self.ticket_request!.SERVER_ID_PK!)",
                    "status": ticket_status,
                    "loginid": "\(CURRENT_USER_LOGGED_IN_ID)",
                    "closure_remarks" : "",
                    "is_ins_claimable": is_insurance_claimable,
                    "ins_claim_ref_no": claim_reference_number,
                    "ticket_logs": [
                        [
                            "inputby": IMS_InputBy_FinancialService, //"Er_Manager"
                            "remarks": self.remarks_textview.text?.replacingOccurrences(of: "'", with: "''") ?? "",
                            "ticket_files": getTicketFiles()
                        ]
                    ]
                ]
            ]
        ]
        let params = getAPIParameter(service_name: IMSUPDATE, request_body: json)
        return params
    }
    
    func setupDirectorOfSecurity() -> [String:Any]? {
        if self.endoresement_textview.text == ENTER_ENDORESSEMENT || self.endoresement_textview.text == "" {
            self.view.makeToast("Endoresement is mandatory")
            return nil
        }
        if self.recommendations_textview.text == ENTER_RECOMMENDATIONS || self.recommendations_textview.text == "" {
            self.view.makeToast("Recommendations is mandatory")
            return nil
        }
        if self.email_textview.text == "" {
            self.view.makeToast("Email is mandatory")
            return nil
        }
        if let emails = self.email_textview.text?.split(separator: ",") {
            for email in emails {
                if !isValidEmail(String(email)) {
                    self.view.makeToast("\(String(email)) is not a valid email.")
                    return nil
                }
            }
        } else {
            if !isValidEmail(self.email_textview.text!) {
                self.view.makeToast("\(self.email_textview.text!) is not a valid email.")
                return nil
            }
        }
        if !self.remarks_view.isHidden {
            if remarks_textview.text == "" || remarks_textview.text == ENTER_REMARKS {
                self.view.makeToast("Remarks is mandatory")
                return nil
            }
        }
        
        var ticket_status = IMS_Status_Inprogress_Fs
        
        if self.ticket_request!.IS_FINANCIAL == 1 && self.ticket_request!.IS_EMP_RELATED == 1 {
            ticket_status = IMS_Status_Inprogress_Fs
        } else if self.ticket_request!.IS_FINANCIAL == 0 && self.ticket_request!.IS_EMP_RELATED == 1 {
            ticket_status = IMS_Status_Inprogress_Hr
        } else if self.ticket_request!.IS_FINANCIAL == 1 && self.ticket_request!.IS_EMP_RELATED == 0 {
            ticket_status = IMS_Status_Inprogress_Fs
        } else {
            ticket_status = IMS_Status_Inprogress_Ca
        }
        
        if willDBInsert {
            let columns = ["DIR_SEC_ENDOR", "DIR_SEC_RECOM", "DIR_NOTIFY_EMAILS", "TICKET_STATUS"]
            let values = [self.endoresement_textview.text!, self.recommendations_textview.text!, self.email_textview.text!, ticket_status]
            AppDelegate.sharedInstance.db?.updateTables(tableName: db_hr_request, columnName: columns, updateValue: values, onCondition: "SERVER_ID_PK = '\(self.ticket_request!.SERVER_ID_PK!)'", { _ in })
        }
        let json = [
            "hr_request": [
                "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                "tickets": [
                    "ticketid": "\(self.ticket_request!.SERVER_ID_PK!)",
                    "status": ticket_status,
                    "loginid": "\(CURRENT_USER_LOGGED_IN_ID)",
                    "closure_remarks" : "",
                    "dir_sec_endors": "\(self.endoresement_textview.text!)",
                    "dir_sec_recom": "\(self.recommendations_textview.text!)",
                    "dir_sec_email": "\(self.email_textview.text!)",
                    "ticket_logs": [
                        [
                            "inputby": IMS_InputBy_DirectorSecurity, //"Er_Manager"
                            "remarks": self.remarks_textview.text?.replacingOccurrences(of: "'", with: "''") ?? "",
                            "ticket_files": getTicketFiles()
                        ]
                    ]
                ]
            ]
        ]
        let params = getAPIParameter(service_name: IMSUPDATE, request_body: json)
        return params
    }
    
    func setupHeadOfSecurity() -> [String:Any]? {
        if self.executive_summary_textview.text == ENTER_EXECUTIVE_SUMMARY || self.executive_summary_textview.text == "" {
            self.view.makeToast("Executive Summary is mandatory")
            return nil
        }
        if self.recommendations_textview.text == ENTER_RECOMMENDATIONS || self.recommendations_textview.text == "" {
            self.view.makeToast("Recommendations is mandatory")
            return nil
        }
        if !self.remarks_view.isHidden {
            if remarks_textview.text == "" || remarks_textview.text == ENTER_REMARKS {
                self.view.makeToast("Remarks is mandatory")
                return nil
            }
        }
        if willDBInsert {
            let columns = ["HO_SEC_SUMMARY", "HO_SEC_RECOM", "TICKET_STATUS"]
            let values = [self.executive_summary_textview.text!, self.recommendations_textview.text!, IMS_Status_Inprogress_Ds]
            AppDelegate.sharedInstance.db?.updateTables(tableName: db_hr_request, columnName: columns, updateValue: values, onCondition: "SERVER_ID_PK = '\(self.ticket_request!.SERVER_ID_PK!)'", { _ in })
        }
        let json = [
            "hr_request": [
                "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                "tickets": [
                    "ticketid": "\(self.ticket_request!.SERVER_ID_PK!)",
                    "status": IMS_Status_Inprogress_Ds,
                    "loginid": "\(CURRENT_USER_LOGGED_IN_ID)",
                    "closure_remarks" : "",
                    "ho_sec_summary": "\(self.executive_summary_textview.text!)",
                    "ho_sec_recom": "\(self.recommendations_textview.text!)",
                    "ticket_logs": [
                        [
                            "inputby": IMS_InputBy_HeadSecurity, //"Er_Manager"
                            "remarks": self.remarks_textview.text?.replacingOccurrences(of: "'", with: "''") ?? "",
                            "ticket_files": getTicketFiles()
                        ]
                    ]
                ]
            ]
        ]
        let params = getAPIParameter(service_name: IMSUPDATE, request_body: json)
        return params
    }
    
    func setupAreaSecurity() -> [String:Any]? {
        if self.ticket_request!.DETAILED_INVESTIGATION == "" ||
            self.ticket_request!.PROSECUTION_NARRATIVE == "" ||
            self.ticket_request!.DEFENSE_NARRATIVE == "" ||
            self.ticket_request!.CHALLENGES == "" ||
            self.ticket_request!.FACTS == "" ||
            self.ticket_request!.FINDINGS == "" ||
            self.ticket_request!.OPINION == "" {
            self.view.makeToast("Incident Investigation detail is mandatory")
            return nil
        }
        if !self.remarks_view.isHidden {
            if remarks_textview.text == "" || remarks_textview.text == ENTER_REMARKS {
                self.view.makeToast("Remarks is mandatory")
                return nil
            }
        }
        if willDBInsert {
            let columns = ["HO_SEC_SUMMARY", "HO_SEC_RECOM", "DIR_NOTIFY_EMAILS", "TICKET_STATUS"]
            let values = [self.executive_summary_textview.text!, self.recommendations_textview.text!, IMS_Status_Inprogress_Hs]
            AppDelegate.sharedInstance.db?.updateTables(tableName: db_hr_request, columnName: columns, updateValue: values, onCondition: "SERVER_ID_PK = '\(self.ticket_request!.SERVER_ID_PK!)'", { _ in })
        }
        let json = [
            "hr_request": [
                "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                "tickets": [
                    "ticketid": "\(self.ticket_request!.SERVER_ID_PK!)",
                    "status": IMS_Status_Inprogress_Hs,
                    "loginid": "\(CURRENT_USER_LOGGED_IN_ID)",
                    "closure_remarks" : "",
                    "detailed_investigation": "\(self.ticket_request!.DETAILED_INVESTIGATION!)",
                    "prosecution_narrative": "\(self.ticket_request!.PROSECUTION_NARRATIVE!)",
                    "defense_narrative": "\(self.ticket_request!.DEFENSE_NARRATIVE!)",
                    "challenges": "\(self.ticket_request!.CHALLENGES!)",
                    "facts": "\(self.ticket_request!.FACTS!)",
                    "findings": "\(self.ticket_request!.FINDINGS!)",
                    "opinion": "\(self.ticket_request!.OPINION!)",
                    "ticket_logs": [
                        [
                            "inputby": IMS_InputBy_AreaSecurity, //"Er_Manager"
                            "remarks": self.remarks_textview.text?.replacingOccurrences(of: "'", with: "''") ?? "",
                            "ticket_files": getTicketFiles()
                        ]
                    ]
                ]
            ]
        ]
        let params = getAPIParameter(service_name: IMSUPDATE, request_body: json)
        return params
    }
    
    func setupHeadOfDepartment() -> [String:Any]? {
        if !self.remarks_view.isHidden {
            if remarks_textview.text == "" || remarks_textview.text == ENTER_REMARKS{
                self.view.makeToast("Remarks is mandatory")
                return nil
            }
        }
        let is_switch = self.investigation_required_switch.isOn ? "1" : "0"
        
        
        var ticket_status = IMS_Status_Inprogress_Cs
        var json = [String:Any]()
        if is_switch == "1" {
            json = [
                "hr_request": [
                    "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                    "tickets": [
                        "ticketid": "\(self.ticket_request!.SERVER_ID_PK!)",
                        "status": IMS_Status_Inprogress_Cs,
                        "loginid": "\(CURRENT_USER_LOGGED_IN_ID)",
                        "closure_remarks" : "",
                        "is_investigation": is_switch,
                        "ticket_logs": [
                            [
                                "inputby": IMS_InputBy_Hod, //"Er_Manager"
                                "remarks": self.remarks_textview.text?.replacingOccurrences(of: "'", with: "''") ?? "",
                                "ticket_files": getTicketFiles()
                            ]
                        ]
                    ]
                ]
            ]
        } else {
            if self.ticket_request!.IS_FINANCIAL == 1 && self.ticket_request!.IS_EMP_RELATED == 1 {
                ticket_status = IMS_Status_Inprogress_Fs
            } else if self.ticket_request!.IS_FINANCIAL == 0 && self.ticket_request!.IS_EMP_RELATED == 1 {
                ticket_status = IMS_Status_Inprogress_Hr
            } else if self.ticket_request!.IS_FINANCIAL == 1 && self.ticket_request!.IS_EMP_RELATED == 0 {
                ticket_status = IMS_Status_Inprogress_Fs
            } else {
                ticket_status = IMS_Status_Inprogress_Ca
            }
            json = [
                "hr_request": [
                    "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                    "tickets": [
                        "ticketid": "\(self.ticket_request!.SERVER_ID_PK!)",
                        "status": ticket_status,
                        "loginid": "\(CURRENT_USER_LOGGED_IN_ID)",
                        "closure_remarks" : "",
                        "is_investigation": is_switch,
                        "ticket_logs": [
                            [
                                "inputby": IMS_InputBy_Hod, //"Er_Manager"
                                "remarks": self.remarks_textview.text?.replacingOccurrences(of: "'", with: "''") ?? "",
                                "ticket_files": getTicketFiles()
                            ]
                        ]
                    ]
                ]
            ]
        }
        
        if willDBInsert {
            let columns = ["IS_INVESTIGATION", "TICKET_STATUS"]
            let values = [is_switch, ticket_status]
            AppDelegate.sharedInstance.db?.updateTables(tableName: db_hr_request, columnName: columns, updateValue: values, onCondition: "SERVER_ID_PK = '\(self.ticket_request!.SERVER_ID_PK!)'", { _ in })
        }
        let params = getAPIParameter(service_name: IMSUPDATE, request_body: json)
        return params
    }
    
    func setupCentralSecurity() -> [String:Any]? {
        guard let _ = lov_area else {
            self.view.makeToast("Area is mandatory")
            return nil
        }
        guard let _ = lov_assigned_to else {
            self.view.makeToast("Assigned To is mandatory")
            return nil
        }
        if !self.remarks_view.isHidden {
            if remarks_textview.text == "" || remarks_textview.text == ENTER_REMARKS {
                self.view.makeToast("Remarks is mandatory")
                return nil
            }
        }
        
        if willDBInsert {
            let columns = ["SEC_AREA", "AREA_SEC_EMP_NO", "TICKET_STATUS"]
            let values = [self.lov_area!.SERVER_ID_PK, "\(self.lov_assigned_to!.EMP_NO)", IMS_Status_Inprogress_As]
            AppDelegate.sharedInstance.db?.updateTables(tableName: db_hr_request, columnName: columns, updateValue: values, onCondition: "SERVER_ID_PK = '\(self.ticket_request!.SERVER_ID_PK!)'", { _ in })
        }
        let json = [
            "hr_request": [
                "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                "tickets": [
                    "ticketid": "\(self.ticket_request!.SERVER_ID_PK!)",
                    "status": IMS_Status_Inprogress_As,
                    "loginid" : "\(CURRENT_USER_LOGGED_IN_ID)",
                    "closure_remarks": "",
                    "sec_area": "\(self.lov_area!.SERVER_ID_PK)",
                    "area_sec_empno": "\(self.lov_assigned_to!.EMP_NO)",
                    "ticket_logs": [
                        [
                            "inputby" : IMS_InputBy_CentralSecurity,
                            "remarks" : "",
                            "ticket_files": getTicketFiles()
                        ]
                    ]
                ]
            ]
        ]
        let params = getAPIParameter(service_name: IMSUPDATE, request_body: json)
        return params
    }
    
    func setupLineManager() -> [String:Any]? {
        guard let _ = lov_classification else {
            self.view.makeToast("Classification is mandatory")
            return nil
        }
        guard let _ = lov_master_table else {
            self.view.makeToast("Incident Level 1 is mandatory")
            return nil
        }
        guard let _ = lov_detail_table else {
            self.view.makeToast("Incident Level 2 is mandatory")
            return nil
        }
        guard let _ = lov_subdetail_table else {
            self.view.makeToast("Incident Level 3 is mandatory")
            return nil
        }
        
        if self.remarks_textview.text == ENTER_REMARKS {
            self.view.makeToast("Remarks is mandatory")
            return nil
        }
        
        var loss_amount = "0"
        let employee_related = self.employeeRelatedBtn.isSelected ? "1" : "0"
        var v_recovery_type = ""
        var is_financial = "0"
        
        if let financial = lov_financial?.TYPE {
            if financial == "Financial" {
                if self.incident_loss_amount.text == "" {
                    self.view.makeToast("Loss Amount is mandatory")
                    return nil
                } else if self.incident_recovery_type.text == "" {
                    self.view.makeToast("Recovery Type is mandatory")
                    return nil
                } else {
                    loss_amount = self.incident_loss_amount.text!
                    v_recovery_type = self.lov_recovery_type!.SERVER_ID_PK
                    is_financial = "1"
                }
            }
        }
        if self.willDBInsert {
            let columns = ["IS_FINANCIAL", "AMOUNT", "LOV_MASTER", "LOV_DETAIL", "LOV_SUBDETAIL", "IS_EMP_RELATED", "RECOVERY_TYPE", "CLASSIFICATION", "TICKET_STATUS"]
            let values = [is_financial,loss_amount, "\(self.lov_master_table!.SERVER_ID_PK)", "\(self.lov_detail_table!.SERVER_ID_PK)", "\(self.lov_subdetail_table!.LOV_SUBDETL_ID)", employee_related, v_recovery_type, self.lov_classification!.SERVER_ID_PK, IMS_Status_Inprogress_Hod]
            AppDelegate.sharedInstance.db?.updateTables(tableName: db_hr_request, columnName: columns, updateValue: values, onCondition: "SERVER_ID_PK = '\(self.ticket_request!.SERVER_ID_PK!)'", { _ in })
        }
        let json = [
            "hr_request": [
                "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                "tickets": [
                    "ticketid": "\(self.ticket_request!.SERVER_ID_PK!)",
                    "status": IMS_Status_Inprogress_Hod,
                    "is_financial": is_financial,
                    "amount": loss_amount,
                    "lov_master_val": "\(self.lov_master_table!.SERVER_ID_PK)",
                    "lov_detail_val": "\(self.lov_detail_table!.SERVER_ID_PK)",
                    "lov_subdetail_val": "\(self.lov_subdetail_table!.LOV_SUBDETL_ID)",
                    "is_emp_related": employee_related,
                    "recovery_type": v_recovery_type,
                    "classification": self.lov_classification!.SERVER_ID_PK,
                    "ticket_logs": [
                        [
                            "inputby": IMS_InputBy_LineManager, //"Er_Manager"
                            "remarks": self.remarks_textview.text?.replacingOccurrences(of: "'", with: "''") ?? "",
                            "ticket_files": getTicketFiles()
                        ]
                    ]
                ]
            ]
        ]
        let params = getAPIParameter(service_name: IMSUPDATE, request_body: json)
        return params
    }
    
    func setupRejectByLineManager() -> [String:Any]? {
        var classification = ""
        var master_detail  = ""
        var detail_detail  = ""
        var sub_detail     = ""
        var loss_amount    = ""
        
        var v_recovery_type = ""
        var is_financial = "0"
        
        if let classi = lov_classification {
            classification = classi.SERVER_ID_PK
        }
        if let master = lov_master_table {
            master_detail = "\(master.SERVER_ID_PK)"
        }
        if let detail = lov_detail_table {
            detail_detail = "\(detail.SERVER_ID_PK)"
        }
        if let sub_details = lov_subdetail_table {
            sub_detail = "\(sub_details.LOV_SUBDETL_ID)"
        }
        
        if self.remarks_textview.text == ENTER_REMARKS {
            self.view.makeToast("Remarks is mandatory")
            return nil
        }
        
        
        let employee_related = self.employeeRelatedBtn.isSelected ? "1" : "0"
        
        if let financial = lov_financial?.TYPE {
            if financial == "Financial" {
                is_financial = "1"
            }
            loss_amount = self.incident_loss_amount.text ?? "0"
            if let recovery = self.lov_recovery_type {
                v_recovery_type = recovery.SERVER_ID_PK
            }
        }
        if willDBInsert {
            let columns = ["IS_FINANCIAL", "AMOUNT", "LOV_MASTER", "LOV_DETAIL", "LOV_SUBDETAIL", "IS_EMP_RELATED", "RECOVERY_TYPE", "CLASSIFICATION", "TICKET_STATUS"]
            let values = [is_financial,loss_amount, master_detail, detail_detail, sub_detail, employee_related, v_recovery_type, classification, IMS_Status_Inprogress_Rm]
            AppDelegate.sharedInstance.db?.updateTables(tableName: db_hr_request, columnName: columns, updateValue: values, onCondition: "SERVER_ID_PK = '\(self.ticket_request!.SERVER_ID_PK!)'", { _ in })
        }
        
        let json = [
            "hr_request": [
                "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                "tickets": [
                    "ticketid": "\(self.ticket_request!.SERVER_ID_PK!)",
                    "status": IMS_Status_Inprogress_Rm,
                    "is_financial": is_financial,
                    "amount": loss_amount,
                    "lov_master_val": master_detail,
                    "lov_detail_val": detail_detail,
                    "lov_subdetail_val": sub_detail,
                    "is_emp_related": employee_related,
                    "recovery_type": v_recovery_type,
                    "classification": classification,
                    "ticket_logs": [
                        [
                            "inputby": IMS_InputBy_LineManager, //"Er_Manager"
                            "remarks": self.remarks_textview.text?.replacingOccurrences(of: "'", with: "''") ?? "",
                            "ticket_files": getTicketFiles()
                        ]
                    ]
                ]
            ]
        ]
        let params = getAPIParameter(service_name: IMSUPDATE, request_body: json)
        return params
    }
    
    func setupRejectByHOD() -> [String:Any]? {
        if !self.remarks_view.isHidden {
            if remarks_textview.text == "" || remarks_textview.text == ENTER_REMARKS {
                self.view.makeToast("Remarks is mandatory")
                return nil
            }
        }
        let is_switch = self.investigation_required_switch.isOn ? "1" : "0"
        
        if willDBInsert {
            let columns = ["IS_INVESTIGATION", "TICKET_STATUS"]
            let values = [is_switch, IMS_Status_Inprogress_Rhod]
            AppDelegate.sharedInstance.db?.updateTables(tableName: db_hr_request, columnName: columns, updateValue: values, onCondition: "SERVER_ID_PK = '\(self.ticket_request!.SERVER_ID_PK!)'", { _ in })
        }
        let json = [
            "hr_request": [
                "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                "tickets": [
                    "ticketid": "\(self.ticket_request!.SERVER_ID_PK!)",
                    "status": IMS_Status_Inprogress_Rhod,
                    "loginid": "\(CURRENT_USER_LOGGED_IN_ID)",
                    "closure_remarks" : "",
                    "is_investigation": is_switch,
                    "ticket_logs": [
                        [
                            "inputby": IMS_InputBy_Hod, //"Er_Manager"
                            "remarks": self.remarks_textview.text?.replacingOccurrences(of: "'", with: "''") ?? "",
                            "ticket_files": getTicketFiles()
                        ]
                    ]
                ]
            ]
        ]
        
        let params = getAPIParameter(service_name: IMSUPDATE, request_body: json)
        return params
    }
    
    func setupRejectDirectorOfSecurity() -> [String:Any]? {
        
        if !self.remarks_view.isHidden {
            if remarks_textview.text == "" || remarks_textview.text == ENTER_REMARKS {
                self.view.makeToast("Remarks is mandatory")
                return nil
            }
        }
        if willDBInsert {
            let columns = ["DIR_SEC_ENDOR", "DIR_SEC_RECOM", "DIR_NOTIFY_EMAILS", "TICKET_STATUS"]
            let values = [self.endoresement_textview.text ?? "", self.recommendations_textview.text ?? "", self.email_textview.text ?? "", IMS_Status_Inprogress_Rds]
            AppDelegate.sharedInstance.db?.updateTables(tableName: db_hr_request, columnName: columns, updateValue: values, onCondition: "SERVER_ID_PK = '\(self.ticket_request!.SERVER_ID_PK!)'", { _ in })
        }
        let json = [
            "hr_request": [
                "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                "tickets": [
                    "ticketid": "\(self.ticket_request!.SERVER_ID_PK!)",
                    "status": IMS_Status_Inprogress_Rds,
                    "loginid": "\(CURRENT_USER_LOGGED_IN_ID)",
                    "closure_remarks" : "",
                    "dir_sec_endors": "\(self.endoresement_textview.text ?? "")",
                    "dir_sec_recom": "\(self.recommendations_textview.text ?? "")",
                    "dir_sec_email": "\(self.email_textview.text ?? "")",
                    "ticket_logs": [
                        [
                            "inputby": IMS_InputBy_DirectorSecurity, //"Er_Manager"
                            "remarks": self.remarks_textview.text?.replacingOccurrences(of: "'", with: "''") ?? "",
                            "ticket_files": getTicketFiles()
                        ]
                    ]
                ]
            ]
        ]
        let params = getAPIParameter(service_name: IMSUPDATE, request_body: json)
        return params
    }
    
    func updateTicketRequest(response: Any) {
        let json = JSON(response)
        if let hr_files = json.dictionary?[_hr_files]?.array {
            for file in hr_files {
                AppDelegate.sharedInstance.db?.deleteRow(tableName: db_files, column: "SERVER_ID_PK", ref_id: "\(file.dictionary?["GIMG_ID"]?.int ?? 0)", handler: { _ in
                    do {
                        print("FILE: GIMG_ID: \(file.dictionary?["GIMG_ID"]?.int ?? 0) TICKET_ID: \(file.dictionary?["TICKET_ID"]?.int ?? 0)")
                        let dictionary = try file.rawData()
                        let file = try JSONDecoder().decode(HrFiles.self, from: dictionary)
                        AppDelegate.sharedInstance.db?.insert_tbl_hr_files(hrfile: file)
                    } catch let err {
                        print("File Error: \(err.localizedDescription)")
                    }
                })
            }
        }
        if let hr_log = json.dictionary?[_hr_logs]?.array {
            for log in hr_log {
                AppDelegate.sharedInstance.db?.deleteRow(tableName: db_grievance_remarks, column: "SERVER_ID_PK", ref_id: "\(log.dictionary?["GREM_ID"]?.int ?? -1)", handler: { _ in
                    do {
                        print("LOG: GREM_ID: \(log.dictionary?["GREM_ID"]?.int ?? 0) TICKET_ID: \(log.dictionary?["TICKET_ID"]?.int ?? 0)")
                        let dictionary = try log.rawData()
                        let log = try JSONDecoder().decode(HrLog.self, from: dictionary)
                        AppDelegate.sharedInstance.db?.insert_tbl_hr_grievance(hr_log: log)
                    } catch let error {
                        print("log id: \(log.dictionary?["GREM_ID"]?.intValue) \(error.localizedDescription)")
                    }
                })
            }
        }

        if let ticket_logs = json.dictionary?[_tickets_logs]?.array?.first {
            let ref_id = ticket_logs["REF_ID"].string ?? ""
            AppDelegate.sharedInstance.db?.deleteRow(tableName: db_hr_request,column: "REF_ID", ref_id: ref_id, handler: { success in
                if success {
                    do {
                        let dictionary = try ticket_logs.rawData()
                        let hrgrievance = try JSONDecoder().decode(HrRequest.self, from: dictionary)
                        
                        DispatchQueue.main.async {
                            AppDelegate.sharedInstance.db?.insert_tbl_hr_request(hrrequests: hrgrievance, { dump_succes in
                                if success {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        NotificationCenter.default.post(Notification.init(name: .refreshedViews))
                                        Helper.topMostController().view.makeToast("Request Update Successfully")
                                    }
                                    print("DUMPED IMS UPDATED TICKET")
                                }
                            })
                        }
                    } catch let err {
                        print(err.localizedDescription)
                    }
                }
            })
        }
    }
}


extension IMSViewUpdateRequestViewController: UpdateIncidentInvestigation {
    func updateIncidentInvestigation(ticket: tbl_Hr_Request_Logs) {
        self.ticket_request = ticket
    }
}


extension IMSViewUpdateRequestViewController: ConfirmationProtocol {
    func confirmationProtocol() {
        self.willDBInsert = true
        if self.isRejected {
            if IMS_Submitted == current_user || IMS_Inprogress_Ro == current_user || IMS_Inprogress_Rhod == current_user {
                if let params = setupRejectByLineManager() {
                    self.navigationController?.popViewController(animated: true)
                    NetworkCalls.updaterequestims(params: params) { success, response in
                        if success {
                            DispatchQueue.main.async {
                                self.updateTicketRequest(response: response)
                            }
                        } else {
                            print(success)
                        }
                    }
                }
            }
            if IMS_Inprogress_Hod == current_user {
                if let params = setupRejectByHOD() {
                    self.navigationController?.popViewController(animated: true)
                    NetworkCalls.updaterequestims(params: params) { success, response in
                        if success {
                            DispatchQueue.main.async {
                                self.updateTicketRequest(response: response)
                            }
                        } else {
                            print(success)
                        }
                    }
                }
            }
            if IMS_Inprogress_Ds == current_user {
                if let params = setupRejectDirectorOfSecurity() {
                    self.navigationController?.popViewController(animated: true)
                    NetworkCalls.updaterequestims(params: params) { success, response in
                        if success {
                            DispatchQueue.main.async {
                                self.updateTicketRequest(response: response)
                            }
                        } else {
                            print(success)
                        }
                    }
                }
            }
        }
        //Forward button tapped
        else {
            if current_user == IMS_Inprogress_Ca {
                if let params = self.setupController() {
                    self.navigationController?.popViewController(animated: true)
                    NetworkCalls.updaterequestims(params: params) { (success, response) in
                        if success {
                            DispatchQueue.main.async {
                                self.updateTicketRequest(response: response)
                            }
                        } else {
                            print(success)
                        }
                    }
                }
                return
            }
            if current_user == IMS_Inprogress_Fi {
                if let params = self.setupFinance() {
                    self.navigationController?.popViewController(animated: true)
                    NetworkCalls.updaterequestims(params: params) { (success, response) in
                        if success {
                            DispatchQueue.main.async {
                                self.updateTicketRequest(response: response)
                            }
                        } else {
                            print(success)
                        }
                    }
                }
                return
            }
            if current_user == IMS_Inprogress_Hr {
                if let params = self.setupHR() {
                    self.navigationController?.popViewController(animated: true)
                    NetworkCalls.updaterequestims(params: params) { (success, response) in
                        if success {
                            DispatchQueue.main.async {
                                self.updateTicketRequest(response: response)
                            }
                        } else {
                            print(success)
                        }
                    }
                }
                return
            }
            if current_user == IMS_Inprogress_Ins {
                self.navigationController?.popViewController(animated: true)
                if let params = self.setupINSFinancialServices() {
                    NetworkCalls.updaterequestims(params: params) { (success, response) in
                        if success {
                            DispatchQueue.main.async {
                                self.updateTicketRequest(response: response)
                            }
                        } else {
                            print(success)
                        }
                    }
                }
                return
            }
            if current_user == IMS_Inprogress_Fs {
                self.navigationController?.popViewController(animated: true)
                if let params = self.setupFinancialServices() {
                    NetworkCalls.updaterequestims(params: params) { (success, response) in
                        if success {
                            DispatchQueue.main.async {
                                self.updateTicketRequest(response: response)
                            }
                        } else {
                            print(success)
                        }
                    }
                }
                return
            }
            if current_user == IMS_Inprogress_Ds {
                self.navigationController?.popViewController(animated: true)
                if let params = self.setupDirectorOfSecurity() {
                    NetworkCalls.updaterequestims(params: params) { (success, response) in
                        if success {
                            DispatchQueue.main.async {
                                self.updateTicketRequest(response: response)
                            }
                        } else {
                            print(success)
                        }
                    }
                }
                return
            }
            if current_user == IMS_Inprogress_Hs {
                if let params = self.setupHeadOfSecurity() {
                    self.navigationController?.popViewController(animated: true)
                    NetworkCalls.updaterequestims(params: params) { (success, response) in
                        if success {
                            DispatchQueue.main.async {
                                self.updateTicketRequest(response: response)
                            }
                        } else {
                            print(success)
                        }
                    }
                }
                return
            }
            if current_user == IMS_Inprogress_As {
                if let params = self.setupAreaSecurity() {
                    self.navigationController?.popViewController(animated: true)
                    NetworkCalls.updaterequestims(params: params) { (success, response) in
                        if success {
                            DispatchQueue.main.async {
                                self.updateTicketRequest(response: response)
                            }
                        } else {
                            print(success)
                        }
                    }
                }
                return
            }
            
            if current_user == IMS_Inprogress_Cs {
                if let params = self.setupCentralSecurity() {
                    self.navigationController?.popViewController(animated: true)
                    NetworkCalls.updaterequestims(params: params) { (success, response) in
                        if success {
                            DispatchQueue.main.async {
                                self.updateTicketRequest(response: response)
                            }
                        } else {
                            print(success)
                        }
                    }
                }
                return
            }
            if current_user == IMS_Inprogress_Hod {
                if let params = self.setupHeadOfDepartment() {
                    self.navigationController?.popViewController(animated: true)
                    NetworkCalls.updaterequestims(params: params) { success, response in
                        if success {
                            DispatchQueue.main.async {
                                self.updateTicketRequest(response: response)
                            }
                        } else {
                            print(success)
                        }
                    }
                }
                return
            }
            
            if let params = self.setupLineManager() {
                self.navigationController?.popViewController(animated: true)
                NetworkCalls.updaterequestims(params: params) { success, response in
                    if success {
                        DispatchQueue.main.async {
                            self.updateTicketRequest(response: response)
                        }
                    } else {
                        print(success)
                    }
                }
            }
        }
    }
    func noButtonTapped() {
        self.isRejected = false
        self.forwardBtn.isEnabled = true
        self.rejectBtn.isEnabled = true
        self.downloadBtn.isEnabled = true
        self.historyBtn.isEnabled = true
    }
}


struct HrSTATUS {
    var name: String
    var isSelected: Bool
}







extension IMSViewUpdateRequestViewController: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            let currentHeight = textView.frame.size.height
            print(currentHeight)
            
            if height <= 50 {
                self.email_textview_height.constant = 50
            } else {
                let heightToAdd = height - currentHeight
                self.email_textview_height.constant += heightToAdd
            }
            
            
            self.view.layoutIfNeeded()
        }
    }
}
