//
//  HRRequests.swift
//  tcs_one_app
//
//  Created by ibs on 24/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import Foundation
import UIKit

struct HrRequest: Encodable, Decodable {
    var ticketID: Int?
    var ticketDate: String?
    var loginID, reqID, reqMode: Int?
    var matID: Int?
    var mqID, dqID: Int?
    var ticketStatus, createdDate, createdDAT: String?
    var createdBy: String?
    var reqRemaks, hrRemarks, updatedDate: String?
    var updatedBy: Int?
    var reqEmailLog, reqEmailLogTime, reqEmailStatus, reqEmailStatusTime: String?
    var tatDays: Int?
    var remTatStatus, remTatStatusTime, assignedTo: String?
    var refID, areaCode, stationCode, hubCode: String?
    var latitude, longitude: String?
    var moduleID: Int?
    var requesterName, requesterPhone: String?
    var responsibleEmpno: Int?
    var responsibleName, responsibleDesig, masterQuery, detailQuery: String?
    var escalateDays: Int?
    var reqModeDesc: String?
    var managerEmpno, headEmpno, directorEmpno: Int?
    var region: String?
    var srNo: Int?
    var hrbpExist: Int?
    var reqCaseDesc, hrCaseDesc: String?
    
    let amount, insClaimedAmt: Double?
    let incidentType, cnsgNo, classification, city: String?
    let area, incidentDate, department, recoveryType: String?
    var isFinancial, areaSECEmpno, isInsClaimable, isInsClaimProcess: Int?
    let lovMasterVal, lovDetailVal, lovSubdetailVal, isEmpRelated: Int?
    let detailedInvestigation: String?
    let prosecutionNarrative, defenseNarrative, challenges, facts: String?
    let findings, opinion, hoSECSummary, hoSECRecom: String?
    let dirSECEndors, dirSECRecom, insClaimRefNo: String?
    let hrRefNo, hrStatus, financeGlNo: String?
    let isControlDefined: Int?
    let riskRemarks, riskType, controlCategory, controlType: String?
    let secArea, dirNotifyEmails: String?
    let isInvestigation: Int?
    let lineManager1, lineManager2: Int?
    
    //Leadership Awaz
    let viewCount: String?
    
    enum CodingKeys: String, CodingKey {
        case ticketID = "TICKET_ID"
        case ticketDate = "TICKET_DATE"
        case loginID = "LOGIN_ID"
        case reqID = "REQ_ID"
        case reqMode = "REQ_MODE"
        case matID = "MAT_ID"
        case mqID = "MQ_ID"
        case dqID = "DQ_ID"
        case ticketStatus = "TICKET_STATUS"
        case createdDate = "CREATED_DATE"
        case createdDAT = "CREATED_DAT"
        case createdBy = "CREATED_BY"
        case reqRemaks = "REQ_REMAKS"
        case hrRemarks = "HR_REMARKS"
        case updatedDate = "UPDATED_DATE"
        case updatedBy = "UPDATED_BY"
        case reqEmailLog = "REQ_EMAIL_LOG"
        case reqEmailLogTime = "REQ_EMAIL_LOG_TIME"
        case reqEmailStatus = "REQ_EMAIL_STATUS"
        case reqEmailStatusTime = "REQ_EMAIL_STATUS_TIME"
        case tatDays = "TAT_DAYS"
        case remTatStatus = "REM_TAT_STATUS"
        case remTatStatusTime = "REM_TAT_STATUS_TIME"
        case assignedTo = "ASSIGNED_TO"
        case refID = "REF_ID"
        case areaCode = "AREA_CODE"
        case stationCode = "STATION_CODE"
        case hubCode = "HUB_CODE"
        case latitude = "LATITUDE"
        case longitude = "LONGITUDE"
        case moduleID = "MODULE_ID"
        case requesterName = "REQUESTER_NAME"
        case requesterPhone = "REQUESTER_PHONE"
        case responsibleEmpno = "RESPONSIBLE_EMPNO"
        case responsibleName = "RESPONSIBLE_NAME"
        case responsibleDesig = "RESPONSIBLE_DESIG"
        case masterQuery = "MASTER_QUERY"
        case detailQuery = "DETAIL_QUERY"
        case escalateDays = "ESCALATE_DAYS"
        case reqModeDesc = "REQ_MODE_DESC"
        case managerEmpno = "MANAGER_EMPNO"
        case headEmpno = "HEAD_EMPNO"
        case directorEmpno = "DIRECTOR_EMPNO"
        case region = "REGION"
        case srNo = "SR_NO"
        case hrbpExist = "HRBP_EXISTS"
        case reqCaseDesc = "REQ_CASE_DESC"
        case hrCaseDesc = "HR_CASE_DESC"
        case incidentType = "INCIDENT_TYPE"
        case cnsgNo = "CNSG_NO"
        case classification = "CLASSIFICATION"
        case city = "CITY"
        case area = "AREA"
        case incidentDate = "INCIDENT_DATE"
        case department = "DEPARTMENT"
        case isFinancial = "IS_FINANCIAL"
        case amount = "AMOUNT"
        case lovMasterVal = "LOV_MASTER_VAL"
        case lovDetailVal = "LOV_DETAIL_VAL"
        case lovSubdetailVal = "LOV_SUBDETAIL_VAL"
        case isEmpRelated = "IS_EMP_RELATED"
        case recoveryType = "RECOVERY_TYPE"
        case areaSECEmpno = "AREA_SEC_EMPNO"
        case detailedInvestigation = "DETAILED_INVESTIGATION"
        case prosecutionNarrative = "PROSECUTION_NARRATIVE"
        case defenseNarrative = "DEFENSE_NARRATIVE"
        case challenges = "CHALLENGES"
        case facts = "FACTS"
        case findings = "FINDINGS"
        case opinion = "OPINION"
        case hoSECSummary = "HO_SEC_SUMMARY"
        case hoSECRecom = "HO_SEC_RECOM"
        case dirSECEndors = "DIR_SEC_ENDORS"
        case dirSECRecom = "DIR_SEC_RECOM"
        case isInsClaimable = "IS_INS_CLAIMABLE"
        case insClaimRefNo = "INS_CLAIM_REF_NO"
        case isInsClaimProcess = "IS_INS_CLAIM_PROCESS"
        case insClaimedAmt = "INS_CLAIMED_AMT"
        case hrRefNo = "HR_REF_NO"
        case hrStatus = "HR_STATUS"
        case financeGlNo = "FINANCE_GL_NO"
        case isControlDefined = "IS_CONTROL_DEFINED"
        case riskRemarks = "RISK_REMARKS"
        case riskType = "RISK_TYPE"
        case controlCategory = "CONTROL_CATEGORY"
        case controlType = "CONTROL_TYPE"
        case secArea = "SEC_AREA"
        case dirNotifyEmails = "DIR_NOTIFY_EMAILS"
        case isInvestigation = "IS_INVESTIGATION"
        case lineManager1 = "LINE_MANAGER1"
        case lineManager2 = "LINE_MANAGER2"
        case viewCount = "VIEW_COUNT"
    }
}
