//
//  NewRequestListingViewController.swift
//  tcs_one_app
//
//  Created by ibs on 22/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit

class NewRequestListingViewController: UIViewController {

    @IBOutlet weak var topHeading: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    
    var heading: String?
    var delegate: AddNewRequestDelegate?
    
    var imsdelegate: IMSNewRequestDelegate?
    var imsupdatedelegate: IMSUpdateRequestDelegate?
    
    var leadershipawazdelegate: LeadershipAwazDelegate?
    
    var request_mode: [tbl_RequestModes]?
    var master_query: [tbl_MasterQuery]?
    var detail_query: [tbl_DetailQuery]?
    var remarks:      [tbl_Remarks]?
    
    //IMS TABLES
    var incident_type:  [tbl_lov_incident_type]?
    var lov_city:       [tbl_lov_city]?
    var lov_area:       [tbl_lov_area]?
    var lov_department: [tbl_lov_department]?
    
    //IMS Update Request
    var lov_classification:     [tbl_lov_classification]?
    var lov_master:             [tbl_lov_master]?
    var lov_detail:             [tbl_lov_detail]?
    var lov_subdetail:          [tbl_lov_sub_detail]?
    var lov_financial:          [financial_type]?
    var lov_recovery:           [tbl_lov_recovery_type]?
    
    var lov_assigned_to:        [tbl_lov_area_security]?
    
    var hr_status:              [tbl_lov_hr_status]?
    
    var lov_risk_type:          [tbl_lov_risk_type]?
    var lov_category_control:   [tbl_lov_control_category]?
    var lov_type_of_control:    [tbl_lov_control_type]?
    
    var sendertag: Int?
    var isIMSUpdate = false
    
    //LeadershipAwaz
    var la_ad_group:            [tbl_la_ad_group]?
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeading.text = heading ?? ""
        view.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
        tableView.register(UINib(nibName: "NewRequestsListingTableCell", bundle: nil), forCellReuseIdentifier: "NewRequestListingCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 40
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if let count = self.request_mode?.count {
                if count > 12 {
                    self.mainViewHeightConstraint.constant = 540
                } else {
                    self.mainViewHeightConstraint.constant += self.tableView.contentSize.height//(CGFloat(count) * 50) - 30
                }
            }
            if let count = self.master_query?.count {
                if count >= 12 {
                    self.mainViewHeightConstraint.constant = 540
                } else {
                    self.mainViewHeightConstraint.constant += self.tableView.contentSize.height//(CGFloat(count) * 50) - 30
                }
            }
            if let count = self.detail_query?.count {
                if count >= 12 {
                    self.mainViewHeightConstraint.constant = 540
                } else {
                    self.mainViewHeightConstraint.constant += self.tableView.contentSize.height//(CGFloat(count) * 50) - 30
                }
            }
            if let count = self.remarks?.count {
                if count > 12 {
                    self.mainViewHeightConstraint.constant = 540
                } else {
                    self.mainViewHeightConstraint.constant += self.tableView.contentSize.height//(CGFloat(count) * 50) - 30
                }
            }
            
            //MARK: IMS
            if let count = self.incident_type?.count {
                if count > 12 {
                    self.mainViewHeightConstraint.constant = 540
                } else {
                    self.mainViewHeightConstraint.constant += self.tableView.contentSize.height//(CGFloat(count) * 50) - 30
                }
            }
            if let count = self.lov_city?.count {
                if count > 12 {
                    self.mainViewHeightConstraint.constant = 540
                } else {
                    self.mainViewHeightConstraint.constant += self.tableView.contentSize.height//(CGFloat(count) * 50) - 30
                }
            }
            if let count = self.lov_area?.count {
                if count > 12 {
                    self.mainViewHeightConstraint.constant = 540
                } else {
                    self.mainViewHeightConstraint.constant += self.tableView.contentSize.height//(CGFloat(count) * 50) - 30
                }
            }
            if let count = self.lov_department?.count {
                if count > 12 {
                    self.mainViewHeightConstraint.constant = 540
                } else {
                    self.mainViewHeightConstraint.constant += self.tableView.contentSize.height//(CGFloat(count) * 50) - 30
                }
            }
            //IMS UPDATE
            if let count = self.lov_classification?.count {
                if count > 12 {
                    self.mainViewHeightConstraint.constant = 540
                } else {
                    self.mainViewHeightConstraint.constant += self.tableView.contentSize.height//(CGFloat(count) * 50) - 30
                }
            }
            if let count = self.lov_master?.count {
                if count > 12 {
                    self.mainViewHeightConstraint.constant = 540
                } else {
                    self.mainViewHeightConstraint.constant += self.tableView.contentSize.height//(CGFloat(count) * 50) - 30
                }
            }
            if let count = self.lov_detail?.count {
                if count > 12 {
                    self.mainViewHeightConstraint.constant = 540
                } else {
                    self.mainViewHeightConstraint.constant += self.tableView.contentSize.height//(CGFloat(count) * 50) - 30
                }
            }
            if let count = self.lov_subdetail?.count {
                if count > 12 {
                    self.mainViewHeightConstraint.constant = 540
                } else {
                    self.mainViewHeightConstraint.constant += self.tableView.contentSize.height//(CGFloat(count) * 50) - 30
                }
            }
            if let count = self.lov_financial?.count {
                if count > 12 {
                    self.mainViewHeightConstraint.constant = 540
                } else {
                    self.mainViewHeightConstraint.constant += self.tableView.contentSize.height//(CGFloat(count) * 50) - 30
                }
            }
            if let count = self.lov_recovery?.count {
                if count > 12 {
                    self.mainViewHeightConstraint.constant = 540
                } else {
                    self.mainViewHeightConstraint.constant += self.tableView.contentSize.height//(CGFloat(count) * 50) - 30
                }
            }
            if let count = self.lov_assigned_to?.count {
                if count > 12 {
                    self.mainViewHeightConstraint.constant = 540
                } else {
                    self.mainViewHeightConstraint.constant += self.tableView.contentSize.height//(CGFloat(count) * 50) - 30
                }
            }
            
            if let count = self.hr_status?.count {
                if count > 12 {
                    self.mainViewHeightConstraint.constant = 540
                } else {
                    self.mainViewHeightConstraint.constant += self.tableView.contentSize.height//(CGFloat(count) * 50) - 30
                }
            }
            if let count = self.lov_risk_type?.count {
                if count > 12 {
                    self.mainViewHeightConstraint.constant = 540
                } else {
                    self.mainViewHeightConstraint.constant += self.tableView.contentSize.height//(CGFloat(count) * 50) - 30
                }
            }
            if let count = self.lov_category_control?.count {
                if count > 12 {
                    self.mainViewHeightConstraint.constant = 540
                } else {
                    self.mainViewHeightConstraint.constant += self.tableView.contentSize.height//(CGFloat(count) * 50) - 30
                }
            }
            if let count = self.lov_type_of_control?.count {
                if count > 12 {
                    self.mainViewHeightConstraint.constant = 540
                } else {
                    self.mainViewHeightConstraint.constant += self.tableView.contentSize.height//(CGFloat(count) * 50) - 30
                }
            }
            
            //LeadershipAwaz
            if let count = self.la_ad_group?.count {
                if count > 12 {
                    self.mainViewHeightConstraint.constant = 540
                } else {
                    self.mainViewHeightConstraint.constant += self.tableView.contentSize.height//(CGFloat(count) * 50) - 30
                }
            }
        }
        
//        tableView.estimatedRowHeight = 45
//        tableView.rowHeight = UITableView.automaticDimension
    }
    @IBAction func crossBtn_Tapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


extension NewRequestListingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.request_mode?.count {
            return count
        }
        if let count = self.master_query?.count {
            return count
        }
        if let count = self.detail_query?.count {
            return count
        }
        if let count = self.remarks?.count {
            return count
        }
        
        //MARK: IMS
        if let count = self.incident_type?.count {
            return count
        }
        if let count = self.lov_city?.count {
            return count
        }
        if let count = self.lov_area?.count {
            return count
        }
        if let count = self.lov_department?.count {
            return count
        }
        
        //IMS Update
        if let count = self.lov_classification?.count {
            return count
        }
        if let count = self.lov_master?.count {
            return count
        }
        if let count = self.lov_detail?.count {
            return count
        }
        if let count = self.lov_subdetail?.count {
            return count
        }
        if let count = self.lov_financial?.count {
            return count
        }
        if let count = self.lov_recovery?.count {
            return count
        }
        if let count = self.lov_assigned_to?.count {
            return count
        }
        if let count = self.hr_status?.count {
            return count
        }
        if let count = self.lov_risk_type?.count {
            return count
        }
        if let count = self.lov_type_of_control?.count {
            return count
        }
        if let count = self.lov_category_control?.count {
            return count
        }
        
        //LeadershipAwaz
        if let count = self.la_ad_group?.count {
            return count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewRequestListingCell") as! NewRequestsListingTableCell
        
        if request_mode != nil {
            let data = self.request_mode![indexPath.row]
            cell.headingLabel.text = data.REQ_MODE_DESC
        }
        
        if master_query != nil {
            let data = self.master_query![indexPath.row]
            cell.headingLabel.text = data.MQ_DESC
        }
        
        if detail_query != nil {
            let data = self.detail_query![indexPath.row]
            cell.headingLabel.text = data.DQ_DESC
        }
        
        if remarks != nil {
            let data = self.remarks![indexPath.row]
            cell.headingLabel.text = data.HR_REMARKS
        }
        
        //MARK: IMS
        if incident_type != nil {
            let data = self.incident_type![indexPath.row]
            cell.headingLabel.text = data.NAME
        }
        if lov_city != nil {
            let data = self.lov_city![indexPath.row]
            cell.headingLabel.text = data.CITY_NAME
        }
        if lov_area != nil {
            let data = self.lov_area![indexPath.row]
            cell.headingLabel.text = data.AREA_NAME
        }
        if lov_department != nil {
            let data = self.lov_department![indexPath.row]
            cell.headingLabel.text = data.DEPAT_NAME
        }
        //IMS Update
        if lov_classification != nil {
            let data = self.lov_classification![indexPath.row]
            cell.headingLabel.text = data.NAME
        }
        if lov_master != nil {
            let data = self.lov_master![indexPath.row]
            cell.headingLabel.text = data.LOV_NAME
        }
        if lov_detail != nil {
            let data = self.lov_detail![indexPath.row]
            cell.headingLabel.text = data.NAME
        }
        if lov_subdetail != nil {
            let data = self.lov_subdetail![indexPath.row]
            cell.headingLabel.text = data.LOV_SUBDETL_NAME
        }
        if lov_financial != nil {
            let data = self.lov_financial![indexPath.row]
            cell.headingLabel.text = data.TYPE
        }
        if lov_recovery != nil {
            let data = self.lov_recovery![indexPath.row]
            cell.headingLabel.text = data.NAME
        }
        if lov_assigned_to != nil {
            let data = self.lov_assigned_to![indexPath.row]
            cell.headingLabel.text = data.SECURITY_PERSON
        }
        if hr_status != nil {
            let data = self.hr_status![indexPath.row]
            cell.headingLabel.text = data.NAME
        }
        if lov_risk_type != nil {
            let data = self.lov_risk_type![indexPath.row]
            cell.headingLabel.text = data.NAME
        }
        if lov_category_control != nil {
            let data = self.lov_category_control![indexPath.row]
            cell.headingLabel.text = data.NAME
        }
        if lov_type_of_control != nil {
            let data = self.lov_type_of_control![indexPath.row]
            cell.headingLabel.text = data.NAME
        }
        
        //LeadershipAwaz
        if la_ad_group != nil {
            let data = self.la_ad_group![indexPath.row]
            cell.headingLabel.text = data.AD_GROUP_NAME
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if request_mode != nil {
            dismiss(animated: true) {
                let requestmode = self.request_mode![indexPath.row]
                switch CONSTANT_MODULE_ID {
                case 4:
                    self.leadershipawazdelegate?.updateRequestMode(requestmode: requestmode)
                case 3:
                    self.imsdelegate?.updateRequestMode(requestmode: requestmode)
                    break
                default:
                    self.delegate?.updateRequestMode(requestmode: requestmode)
                    break
                }
                
                return
            }
        }
        if master_query != nil {
            dismiss(animated: true) {
                let masterquery = self.master_query![indexPath.row]
                self.delegate?.updateMasterQuery(masterquery: masterquery)
                return
            }
        }
        if detail_query != nil {
            dismiss(animated: true) {
                let detailquery = self.detail_query![indexPath.row]
                self.delegate?.updateDetailQuery(detailquery: detailquery)
                return
            }
        }
        if remarks != nil {
            dismiss(animated: true) {
                let remarks = self.remarks![indexPath.row]
                self.delegate?.updateRemarks(remarks: remarks)
                return
            }
        }
        
        //MARK: IMS
        if incident_type != nil {
            dismiss(animated: true) {
                let incidenttype = self.incident_type![indexPath.row]
                self.imsdelegate?.updateIncidentType(incidentyType: incidenttype)
            }
        }
        if lov_city != nil {
            dismiss(animated: true) {
                let city = self.lov_city![indexPath.row]
                self.imsdelegate?.updateCity(city: city)
            }
        }
        if lov_area != nil {
            dismiss(animated: true) {
                let area = self.lov_area![indexPath.row]
                if self.isIMSUpdate {
                    self.imsupdatedelegate?.updateAreaType(area: area)
                } else {
                    self.imsdelegate?.updateArea(area: area)
                }
            }
        }
        if lov_department != nil {
            dismiss(animated: true) {
                let department = self.lov_department![indexPath.row]
                self.imsdelegate?.updateDepartment(department: department)
            }
        }
        
        //ims update
        if lov_classification != nil {
            dismiss(animated: true) {
                let classification = self.lov_classification![indexPath.row]
                self.imsupdatedelegate?.updateClassification(classification: classification)
            }
        }
        if lov_master != nil {
            dismiss(animated: true) {
                let master = self.lov_master![indexPath.row]
                self.imsupdatedelegate?.updateIncidentLevel1(incident_level_1: master)
            }
        }
        if lov_detail != nil {
            dismiss(animated: true) {
                let detail = self.lov_detail![indexPath.row]
                self.imsupdatedelegate?.updateIncidentLevel2(incident_level_2: detail)
            }
        }
        if lov_subdetail != nil {
            dismiss(animated: true) {
                let sub_detail = self.lov_subdetail![indexPath.row]
                self.imsupdatedelegate?.updateIncidentLevel3(incident_level_3: sub_detail)
            }
        }
        if lov_financial != nil {
            dismiss(animated: true) {
                let finance = self.lov_financial![indexPath.row]
                self.imsupdatedelegate?.updateFinancialType(financial: finance)
            }
        }
        if lov_recovery != nil {
            dismiss(animated: true) {
                let recovery = self.lov_recovery![indexPath.row]
                self.imsupdatedelegate?.updateRecoveryType(recoery_type: recovery)
            }
        }
        if lov_assigned_to != nil {
            dismiss(animated: true) {
                let assigned_to = self.lov_assigned_to![indexPath.row]
                self.imsupdatedelegate?.updateAssignedTo(assigned_to: assigned_to)
            }
        }
        if hr_status != nil {
            dismiss(animated: true) {
                let status = self.hr_status![indexPath.row]
                self.imsupdatedelegate?.updateHrStatus(hrstatus: status)
            }
        }
        if lov_risk_type != nil {
            dismiss(animated: true) {
                let risk_type = self.lov_risk_type![indexPath.row]
                self.imsupdatedelegate?.updateRiskType(risk_type: risk_type)
            }
        }
        if lov_category_control != nil {
            dismiss(animated: true) {
                let category_control = self.lov_category_control![indexPath.row]
                self.imsupdatedelegate?.updateCategoryControl(category_control: category_control)
            }
        }
        if lov_type_of_control != nil {
            dismiss(animated: true) {
                let type_of_control = self.lov_type_of_control![indexPath.row]
                self.imsupdatedelegate?.updateTypeControl(type_control: type_of_control)
            }
        }
        
        if la_ad_group != nil {
            dismiss(animated: true) {
                let la_ad_group = self.la_ad_group![indexPath.row]
                self.leadershipawazdelegate?.updateMessageSubject(messagesubject: la_ad_group)
            }
        }
    }
}
