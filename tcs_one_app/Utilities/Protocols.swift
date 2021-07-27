//
//  Protocols.swift
//  tcs_one_app
//
//  Created by ibs on 26/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit

protocol AddNewRequestDelegate {
    func updateRequestMode(requestmode: tbl_RequestModes)
    func updateMasterQuery(masterquery: tbl_MasterQuery)
    func updateDetailQuery(detailquery: tbl_DetailQuery)
    func updateRemarks(remarks: tbl_Remarks)
}

protocol DateSelectionDelegate {
    func dateSelection(numberOfDays: Int, selected_query: String)
    func dateSelection(startDate: String, endDate: String, selected_query: String)
    func requestModeSelected(selected_query: String)
}


protocol GraphListingDelegate {
    func updateGraphListingFilter(id: String, title: String)
}

protocol AddClosureRemarksDelegate {
    func addClosureRemarks(closure_remarks: String)
}



protocol IMSNewRequestDelegate {
    func updateRequestMode(requestmode: tbl_RequestModes)
    func updateIncidentType(incidentyType: tbl_lov_incident_type)
    func updateCity(city: tbl_lov_city)
    func updateArea(area: tbl_lov_area)
    func updateDepartment(department: tbl_lov_department)
}

protocol IMSUpdateRequestDelegate {
    func updateClassification(classification: tbl_lov_classification)
    func updateIncidentLevel1(incident_level_1: tbl_lov_master)
    func updateIncidentLevel2(incident_level_2: tbl_lov_detail)
    func updateIncidentLevel3(incident_level_3: tbl_lov_sub_detail)
    func updateFinancialType(financial: financial_type)
    func updateRecoveryType(recoery_type: tbl_lov_recovery_type)
    func updateAreaType(area: tbl_lov_area)
    func updateAssignedTo(assigned_to: tbl_lov_area_security)
    func updateHrStatus(hrstatus: tbl_lov_hr_status)
    func updateRiskType(risk_type: tbl_lov_risk_type)
    func updateCategoryControl(category_control: tbl_lov_control_category)
    func updateTypeControl(type_control: tbl_lov_control_type)
}


protocol LeadershipAwazDelegate {
    func updateRequestMode(requestmode: tbl_RequestModes)
    func updateMessageSubject(messagesubject: tbl_la_ad_group)
}



protocol ConfirmationProtocol {
    func confirmationProtocol()
    func noButtonTapped()
}


protocol UpdateIncidentInvestigation {
    func updateIncidentInvestigation(ticket: tbl_Hr_Request_Logs)
}


protocol MoveToRiderScreen {
    func moveToRiderScreen()
}
