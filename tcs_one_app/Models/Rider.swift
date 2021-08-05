//
//  Rider.swift
//  tcs_one_app
//
//  Created by TCS on 09/07/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import Foundation

// MARK: - RiderDetail
struct RiderDetail: Codable {
    let empNo, empNam, areaNo, empTypNo: String?
    let desig, addr1, addr2, addr3: String?
    let phn, pagerNo: String?
    let stat: String?
    let staNo: String?
    let bankNo: String?
    let actNo, ntnNo, empMgr, idcard: String?
    let rutTyp: String?
    let empCloseChk, empOpenDate: String?
    let empCloseDate: String?
    let divCode, rutNo, mobileNo: String?
    let inboundIncChk: String?
    let outboundIncChk: String?
    let rutAdjAmount: String?
    let empUnvrsl: String?
    let hrEmpNo, incTrgt, rutCodeExp: String?
    let empHubCode, fieldStaff: String?
    let fuelQuata, empSalary: String?
    let dateJoining, dateBirth, pickupHub: String?
    let remarks: String?
    let lastUpdateDate: String?
    let hardRutAll, courierCodAmountLimit: String?
    let updatedBy, updateOn: String?
    let createdOn, createdBy, updatedOn: String?
    let hubCode: String?

    enum CodingKeys: String, CodingKey {
        case empNo = "EMP_NO"
        case empNam = "EMP_NAM"
        case areaNo = "AREA_NO"
        case empTypNo = "EMP_TYP_NO"
        case desig = "DESIG"
        case addr1 = "ADDR1"
        case addr2 = "ADDR2"
        case addr3 = "ADDR3"
        case phn = "PHN"
        case pagerNo = "PAGER_NO"
        case stat = "STAT"
        case staNo = "STA_NO"
        case bankNo = "BANK_NO"
        case actNo = "ACT_NO"
        case ntnNo = "NTN_NO"
        case empMgr = "EMP_MGR"
        case idcard = "IDCARD"
        case rutTyp = "RUT_TYP"
        case empCloseChk = "EMP_CLOSE_CHK"
        case empOpenDate = "EMP_OPEN_DATE"
        case empCloseDate = "EMP_CLOSE_DATE"
        case divCode = "DIV_CODE"
        case rutNo = "RUT_NO"
        case mobileNo = "MOBILE_NO"
        case inboundIncChk = "INBOUND_INC_CHK"
        case outboundIncChk = "OUTBOUND_INC_CHK"
        case rutAdjAmount = "RUT_ADJ_AMOUNT"
        case empUnvrsl = "EMP_UNVRSL"
        case hrEmpNo = "HR_EMP_NO"
        case incTrgt = "INC_TRGT"
        case rutCodeExp = "RUT_CODE_EXP"
        case empHubCode = "EMP_HUB_CODE"
        case fieldStaff = "FIELD_STAFF"
        case fuelQuata = "FUEL_QUATA"
        case empSalary = "EMP_SALARY"
        case dateJoining = "DATE_JOINING"
        case dateBirth = "DATE_BIRTH"
        case pickupHub = "PICKUP_HUB"
        case remarks = "REMARKS"
        case lastUpdateDate = "LAST_UPDATE_DATE"
        case hardRutAll = "HARD_RUT_ALL"
        case courierCodAmountLimit = "COURIER_COD_AMOUNT_LIMIT"
        case updatedBy = "UPDATED_BY"
        case updateOn = "UPDATE_ON"
        case createdOn = "CREATED_ON"
        case createdBy = "CREATED_BY"
        case updatedOn = "UPDATED_ON"
        case hubCode = "HUB_CODE"
    }
}


// MARK: - RiderDetail
struct ReceiverRelation: Codable {
    let id: Int?
    let rRelation: String?

    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case rRelation = "R_RELATION"
    }
}

//MARK: - RiderMasterDelivery
struct RiderMasterDelivery: Codable {
    let id: Int?
    let dlvryStatNo, dscrp, stat: String?
    let allowShow: String?
    let imgRequired, signReguired, reattempt, statGroup: String?

    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case dlvryStatNo = "DLVRY_STAT_NO"
        case dscrp = "DSCRP"
        case stat = "STAT"
        case allowShow = "ALLOW_SHOW"
        case imgRequired = "IMG_REQUIRED"
        case signReguired = "SIGN_REGUIRED"
        case reattempt = "REATTEMPT"
        case statGroup = "STAT_GROUP"
    }
}

//MARK: - RiderDetailDelivery
struct RiderDetailDelivery: Codable {
    let id: Int?
    let dlvryStatNo, dscrp, childStatNo: String?
    let masterDscrp: String?
    let hhtAllow: String?

    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case dlvryStatNo = "DLVRY_STAT_NO"
        case dscrp = "DSCRP"
        case childStatNo = "CHILD_STAT_NO"
        case masterDscrp = "MASTER_DSCRP"
        case hhtAllow = "HHT_ALLOW"
    }
}


//MARK: - Status Group
struct RiderStatusGroup: Codable {
    let statGroup: Int?
    let descp: String?
    let relationRequired: Int?

    enum CodingKeys: String, CodingKey {
        case statGroup = "STAT_GROUP"
        case descp = "DESCP"
        case relationRequired = "RELATION_REQUIRED"
    }
}

//MARK: - AppMasterResponse
struct AppMasterResponse: Codable {
    let condID: Int?
    let objFieldName, checkValue, valueType, detailOperator: String?
    let groupName: String?
    let condIndex: Int?
    let eventName, action: String?
    let isActive: Int?

    enum CodingKeys: String, CodingKey {
        case condID = "COND_ID"
        case objFieldName = "OBJ_FIELD_NAME"
        case checkValue = "CHECK_VALUE"
        case valueType = "VALUE_TYPE"
        case detailOperator = "OPERATOR"
        case groupName = "GROUP_NAME"
        case condIndex = "COND_INDEX"
        case eventName = "EVENT_NAME"
        case action = "ACTION"
        case isActive = "IS_ACTIVE"
    }
}

// MARK: - AppDetailResponse
struct AppDetailResponse: Codable {
    let condDetlID: Int?
    let deliveryStatus: String?
    let condID: Int?

    enum CodingKeys: String, CodingKey {
        case condDetlID = "COND_DETL_ID"
        case deliveryStatus = "DELIVERY_STATUS"
        case condID = "COND_ID"
    }
}

// MARK: - ReportToLov
struct ReportToLov: Codable {
    let rttID: Int?
    let rttDscrp, createdDate: String?
    let userID: String?

    enum CodingKeys: String, CodingKey {
        case rttID = "RTT_ID"
        case rttDscrp = "RTT_DSCRP"
        case createdDate = "CREATED_DATE"
        case userID = "USER_ID"
    }
}

// MARK: - RiderDeliverySheet
struct RiderDeliverySheet: Codable {
    let sheetno, dlvryDAT, cn: String?
    let deliverystatus: String?
    let shippername, consigneename: String?
    let srlNo, dlvrdBy: String?
    let cusPhn, cusFax: String?
    let pieces: Int?
    let weight: Double?
    let codAmt: Int?
    let htc, vrstatus, rsstatus, vendorShipmentType: String?
    let cnsgeeLat, cnsgeeLng: Double?
    let vendorCode, nicNo, syncDate: String?
    let syncStatus: Int = 0
    let riderDeliveryDetail: [RiderDeliveryDetail]?

    enum CodingKeys: String, CodingKey {
        case sheetno = "SHEETNO"
        case dlvryDAT = "DLVRY_DAT"
        case cn = "CN"
        case deliverystatus = "DELIVERYSTATUS"
        case shippername = "SHIPPERNAME"
        case consigneename = "CONSIGNEENAME"
        case srlNo = "SRL_NO"
        case dlvrdBy = "DLVRD_BY"
        case cusPhn = "CUS_PHN"
        case cusFax = "CUS_FAX"
        case pieces = "PIECES"
        case weight = "WEIGHT"
        case codAmt = "COD_AMT"
        case htc = "HTC"
        case vrstatus = "VRSTATUS"
        case rsstatus = "RSSTATUS"
        case vendorShipmentType = "VENDOR_SHIPMENT_TYPE"
        case cnsgeeLat = "CNSGEE_LAT"
        case cnsgeeLng = "CNSGEE_LNG"
        case vendorCode = "VENDOR_CODE"
        case nicNo = "NIC_NO"
        case syncDate = "SYNC_DATE"
        case syncStatus = "SYNC_STATUS"
        case riderDeliveryDetail = "DETAILS"
    }
}

// MARK: - Detail
struct RiderDeliveryDetail: Codable {
    let cn, fieldName, labelName, isRequired: String?
    let charLength: String?

    enum CodingKeys: String, CodingKey {
        case cn = "CN"
        case fieldName = "FIELD_NAME"
        case labelName = "LABEL_NAME"
        case isRequired = "IS_REQUIRED"
        case charLength = "CHAR_LENGTH"
    }
}


// MARK: - DeliveryMaster
struct BinInfo: Codable {
    let dlvryShtNo, dlvryDAT: String?
    let dlvrdBy: String?
    let dlvryRut, staNo, userid, slot: String?
    let prodNo, systemID, createdOn: String?
    let eodStatus, refid: String?
    let binDscrp: String?

    enum CodingKeys: String, CodingKey {
        case dlvryShtNo = "DLVRY_SHT_NO"
        case dlvryDAT = "DLVRY_DAT"
        case dlvrdBy = "DLVRD_BY"
        case dlvryRut = "DLVRY_RUT"
        case staNo = "STA_NO"
        case userid = "USERID"
        case slot = "SLOT"
        case prodNo = "PROD_NO"
        case systemID = "SYSTEM_ID"
        case createdOn = "CREATED_ON"
        case eodStatus = "EOD_STATUS"
        case refid = "REFID"
        case binDscrp = "BIN_DSCRP"
    }
}

struct VerifyProcess {
    var CN: String?
    var SHEETNO: String?
    var VERIFY: String?
    var REPORT_TO: String?
    var SYNC: Int?
    var SYNC_DATE: String?
}

struct QRCodes {
    var QRCODE: String = ""
    var CN: String = ""
    var SHEETNO: String = ""
    var CURRENT_USER: String = ""
}
