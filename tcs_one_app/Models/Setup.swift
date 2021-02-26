//
//  Setup.swift
//  tcs_one_app
//
//  Created by ibs on 23/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import Foundation
import UIKit


struct Setup {
    let remarks: [Remarks]
    let query_matrix: [QueryMatrix]
    let master_query: [MasterQuery]
    let detail_query: [DetailQuery]
    let search_keyword: [SearchKeyword]
    let app_request_mode: [AppRequestMode]
    
    let synced_date: String
}
struct Remarks: Codable {
    let remID, sqID: Int?
    let hrRemarks, createdDate, createdBy: String?
    let mqID, dqID, moduleID: Int?
    let remarksType, syncDate: String?

    enum CodingKeys: String, CodingKey {
        case remID = "REM_ID"
        case sqID = "SQ_ID"
        case hrRemarks = "HR_REMARKS"
        case createdDate = "CREATED_DATE"
        case createdBy = "CREATED_BY"
        case mqID = "MQ_ID"
        case dqID = "DQ_ID"
        case moduleID = "MODULE_ID"
        case remarksType = "REMARKS_TYPE"
        case syncDate = "SYNC_DATE"
    }
}

struct QueryMatrix: Codable {
    let region, masterQuery, detailQuery, personDesig: String?
    let lineManagerDesig, headDesig, responsibility, lineManager: String?
    let head: String?
    let mqID, dqID: Int?
    let createdBy: String?
    let createdDate: String?
    let matID, esclateDay, responsibleEmpno, managerEmpno: Int?
    let headEmpno, directorEmpno: Int?
    let colourCode, area: String?
    let moduleID: Int?
    let syncDate: String?
    let tempID: Int?

    enum CodingKeys: String, CodingKey {
        case region = "REGION"
        case masterQuery = "MASTER_QUERY"
        case detailQuery = "DETAIL_QUERY"
        case personDesig = "PERSON_DESIG"
        case lineManagerDesig = "LINE_MANAGER_DESIG"
        case headDesig = "HEAD_DESIG"
        case responsibility = "RESPONSIBILITY"
        case lineManager = "LINE_MANAGER"
        case head = "HEAD"
        case mqID = "MQ_ID"
        case dqID = "DQ_ID"
        case createdBy = "CREATED_BY"
        case createdDate = "CREATED_DATE"
        case matID = "MAT_ID"
        case esclateDay = "ESCLATE_DAY"
        case responsibleEmpno = "RESPONSIBLE_EMPNO"
        case managerEmpno = "MANAGER_EMPNO"
        case headEmpno = "HEAD_EMPNO"
        case directorEmpno = "DIRECTOR_EMPNO"
        case colourCode = "COLOUR_CODE"
        case area = "AREA"
        case moduleID = "MODULE_ID"
        case syncDate = "SYNC_DATE"
        case tempID = "TEMP_ID"
    }
}


struct MasterQuery: Codable {
    let mqID: Int?
    let mqDesc: String?
    let createdBy: String?
    let createdDate: String?
    let moduleID: Int?
    let syncDate, colorCode: String?

    enum CodingKeys: String, CodingKey {
        case mqID = "MQ_ID"
        case mqDesc = "MQ_DESC"
        case createdBy = "CREATED_BY"
        case createdDate = "CREATED_DATE"
        case moduleID = "MODULE_ID"
        case syncDate = "SYNC_DATE"
        case colorCode = "COLOR_CODE"
    }
}


struct DetailQuery: Codable {
    let mqID, dqID: Int?
    let dqDesc: String?
    let createdBy: String?
    let createDate, syncDate, colorCode: String?
    let esclateDay, dqUniqID: Int?

    enum CodingKeys: String, CodingKey {
        case mqID = "MQ_ID"
        case dqID = "DQ_ID"
        case dqDesc = "DQ_DESC"
        case createdBy = "CREATED_BY"
        case createDate = "CREATE_DATE"
        case syncDate = "SYNC_DATE"
        case colorCode = "COLOR_CODE"
        case esclateDay = "ESCLATE_DAY"
        case dqUniqID = "DQ_UNIQ_ID"
    }
}

struct SearchKeyword: Codable {
    let keywordID: Int?
    let keyword: String?
    let pageID, moduleID: Int?
    let syncDate: String?

    enum CodingKeys: String, CodingKey {
        case keywordID = "KEYWORD_ID"
        case keyword = "KEYWORD"
        case pageID = "PAGE_ID"
        case moduleID = "MODULE_ID"
        case syncDate = "SYNC_DATE"
    }
}

struct AppRequestMode: Codable {
    let reqModeID: Int?
    let reqModeDesc: String?
    let createdBy: String?
    let createdDate: String?
    let moduleid: Int?

    enum CodingKeys: String, CodingKey {
        case reqModeID = "REQ_MODE_ID"
        case reqModeDesc = "REQ_MODE_DESC"
        case createdBy = "CREATED_BY"
        case createdDate = "CREATED_DATE"
        case moduleid = "MODULEID"
    }
}




//MARK: IMS SETUP
struct LovMaster: Codable {
    let lovID: Int
    let lovCode, lovName: String

    enum CodingKeys: String, CodingKey {
        case lovID = "LOV_ID"
        case lovCode = "LOV_CODE"
        case lovName = "LOV_NAME"
    }
}
// MARK: - LovDetail
struct LovDetail: Codable {
    let lovDetlID, lovID: Int
    let lovDetlCode, lovDetlName: String

    enum CodingKeys: String, CodingKey {
        case lovDetlID = "LOV_DETL_ID"
        case lovID = "LOV_ID"
        case lovDetlCode = "LOV_DETL_CODE"
        case lovDetlName = "LOV_DETL_NAME"
    }
}

struct LovSubdetail: Codable {
    let lovSubdetlID, lovDetlID, lovID: Int
    let lovSubdetlCode, lovSubdetlName: String

    enum CodingKeys: String, CodingKey {
        case lovSubdetlID = "LOV_SUBDETL_ID"
        case lovDetlID = "LOV_DETL_ID"
        case lovID = "LOV_ID"
        case lovSubdetlCode = "LOV_SUBDETL_CODE"
        case lovSubdetlName = "LOV_SUBDETL_NAME"
    }
}

struct Area: Codable {
    let areaCode, areaName: String

    enum CodingKeys: String, CodingKey {
        case areaCode = "AREA_CODE"
        case areaName = "AREA_NAME"
    }
}

struct City: Codable {
    let areaNo, cityCode, cityName: String

    enum CodingKeys: String, CodingKey {
        case areaNo = "AREA_NO"
        case cityCode = "CITY_CODE"
        case cityName = "CITY_NAME"
    }
}
struct AreaSecurity: Codable {
    let secID: Int
    let areaCode, securityPerson, created: String?
    let empNo: Int

    enum CodingKeys: String, CodingKey {
        case secID = "SEC_ID"
        case areaCode = "AREA_CODE"
        case securityPerson = "SECURITY_PERSON"
        case created = "CREATED"
        case empNo = "EMP_NO"
    }
}
struct Department: Codable {
    let deptID: Int
    let depatName: String
    let createdBy: String?
    let createdDate: String

    enum CodingKeys: String, CodingKey {
        case deptID = "DEPT_ID"
        case depatName = "DEPAT_NAME"
        case createdBy = "CREATED_BY"
        case createdDate = "CREATED_DATE"
    }
}
struct IncidentType: Codable {
    let lovCode, lovName: String

    enum CodingKeys: String, CodingKey {
        case lovCode = "LOV_CODE"
        case lovName = "LOV_NAME"
    }
}
struct Classification: Codable {
    let lovCode, lovName: String

    enum CodingKeys: String, CodingKey {
        case lovCode = "LOV_CODE"
        case lovName = "LOV_NAME"
    }
}
struct RecoveryType: Codable {
    let lovCode, lovName: String

    enum CodingKeys: String, CodingKey {
        case lovCode = "LOV_CODE"
        case lovName = "LOV_NAME"
    }
}
struct HrStatus: Codable {
    let lovCode, lovName: String

    enum CodingKeys: String, CodingKey {
        case lovCode = "LOV_CODE"
        case lovName = "LOV_NAME"
    }
}

struct ControlCategory: Codable {
    let lovCode, lovName: String

    enum CodingKeys: String, CodingKey {
        case lovCode = "LOV_CODE"
        case lovName = "LOV_NAME"
    }
}
struct RiskType: Codable {
    let lovCode, lovName: String

    enum CodingKeys: String, CodingKey {
        case lovCode = "LOV_CODE"
        case lovName = "LOV_NAME"
    }
}
struct ControlType: Codable {
    let lovCode, lovName: String

    enum CodingKeys: String, CodingKey {
        case lovCode = "LOV_CODE"
        case lovName = "LOV_NAME"
    }
}



// MARK: - AdGroup
struct LeadershipAwazAdGroup: Codable {
    let adMastID: Int
    let adGroupName, adGroupEmailID, status, createdDate: String?
    let createdBy, updatedDate, updatedBy: String?

    enum CodingKeys: String, CodingKey {
        case adMastID = "AD_MAST_ID"
        case adGroupName = "AD_GROUP_NAME"
        case adGroupEmailID = "AD_GROUP_EMAIL_ID"
        case status = "STATUS"
        case createdDate = "CREATED_DATE"
        case createdBy = "CREATED_BY"
        case updatedDate = "UPDATED_DATE"
        case updatedBy = "UPDATED_BY"
    }
}

// MARK: - LoginCount
struct LoginCount: Codable {
    let application: String
    let countXEmpno: Int

    enum CodingKeys: String, CodingKey {
        case application = "APPLICATION"
        case countXEmpno = "COUNT(X.EMPNO)"
    }
}
