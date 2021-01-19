//
//  AddNewRequest.swift
//  tcs_one_app
//
//  Created by ibs on 26/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import Foundation
import UIKit
struct TicketsLog: Codable {
    let directorEmpno: Int?
    let createdBy: String?
    let hubCode, responsibleName, reqModeDesc: String?
    let latitude, updatedDate, region, updatedBy: String?
    let reqEmailLog, reqEmailStatus: String?
    let managerEmpno, reqMode, ticketID: Int?
    let matID: Int?
    let areaCode: String?
    let remTatStatusTime: String?
    let requesterName, stationCode: String?
    let assignedTo: String?
    let reqID: Int?
    let masterQuery: String?
    let moduleID, escalateDays: Int?
    let remTatStatus: String?
    let mqID: Int?
    let ticketStatus, hrbpExists: String?
    let headEmpno, loginID: Int?
    let requesterPhone: String?
    let ticketDate: String?
    let longitude: String?
    let tatDays: Int?
    let createdDAT, responsibleDesig: String?
    let reqEmailStatusTime: String?
    let detailQuery, refID, reqRemaks: String?
    let reqEmailLogTime: String?
    let responsibleEmpno: Int?
    let createdDate: String?
    let dqID: Int?
    let hrRemarks: String?

    enum CodingKeys: String, CodingKey {
        case directorEmpno = "DIRECTOR_EMPNO"
        case createdBy = "CREATED_BY"
        case hubCode = "HUB_CODE"
        case responsibleName = "RESPONSIBLE_NAME"
        case reqModeDesc = "REQ_MODE_DESC"
        case latitude = "LATITUDE"
        case updatedDate = "UPDATED_DATE"
        case region = "REGION"
        case updatedBy = "UPDATED_BY"
        case reqEmailLog = "REQ_EMAIL_LOG"
        case reqEmailStatus = "REQ_EMAIL_STATUS"
        case managerEmpno = "MANAGER_EMPNO"
        case reqMode = "REQ_MODE"
        case ticketID = "TICKET_ID"
        case matID = "MAT_ID"
        case areaCode = "AREA_CODE"
        case remTatStatusTime = "REM_TAT_STATUS_TIME"
        case requesterName = "REQUESTER_NAME"
        case stationCode = "STATION_CODE"
        case assignedTo = "ASSIGNED_TO"
        case reqID = "REQ_ID"
        case masterQuery = "MASTER_QUERY"
        case moduleID = "MODULE_ID"
        case escalateDays = "ESCALATE_DAYS"
        case remTatStatus = "REM_TAT_STATUS"
        case mqID = "MQ_ID"
        case ticketStatus = "TICKET_STATUS"
        case hrbpExists = "HRBP_EXISTS"
        case headEmpno = "HEAD_EMPNO"
        case loginID = "LOGIN_ID"
        case requesterPhone = "REQUESTER_PHONE"
        case ticketDate = "TICKET_DATE"
        case longitude = "LONGITUDE"
        case tatDays = "TAT_DAYS"
        case createdDAT = "CREATED_DAT"
        case responsibleDesig = "RESPONSIBLE_DESIG"
        case reqEmailStatusTime = "REQ_EMAIL_STATUS_TIME"
        case detailQuery = "DETAIL_QUERY"
        case refID = "REF_ID"
        case reqRemaks = "REQ_REMAKS"
        case reqEmailLogTime = "REQ_EMAIL_LOG_TIME"
        case responsibleEmpno = "RESPONSIBLE_EMPNO"
        case createdDate = "CREATED_DATE"
        case dqID = "DQ_ID"
        case hrRemarks = "HR_REMARKS"
    }
}


struct HrFiles: Codable {
    let created: String?
    let gremID, fileSizeKB: Int?
    let fileURL: String?
    let gimgID: Int?
    let fileExtention: String?
    let ticketID: Int?

    enum CodingKeys: String, CodingKey {
        case created = "CREATED"
        case gremID = "GREM_ID"
        case fileSizeKB = "FILE_SIZE_KB"
        case fileURL = "FILE_URL"
        case gimgID = "GIMG_ID"
        case fileExtention = "FILE_EXTENTION"
        case ticketID = "TICKET_ID"
    }
}
struct HrLog: Codable {
    let emplNo: Int
    let created, refID: String?
    let gremID, ticketID: Int
    let ticketStatus: String?
    let remarks, remarksInput: String?
    

    enum CodingKeys: String, CodingKey {
        case emplNo = "EMPL_NO"
        case created = "CREATED"
        case gremID = "GREM_ID"
        case ticketID = "TICKET_ID"
        case remarksInput = "REMARKS_INPUT"
        case ticketStatus = "TICKET_STATUS"
        case remarks = "REMARKS"
        case refID = "REF_ID"
    }
}
