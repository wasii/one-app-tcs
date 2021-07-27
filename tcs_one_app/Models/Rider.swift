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
    let id: Int
    let rRelation: String

    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case rRelation = "R_RELATION"
    }
}

//MARK: - RiderMasterDelivery
struct RiderMasterDelivery: Codable {
    let id: Int
    let dlvryStatNo, dscrp, stat: String
    let allowShow: String?
    let imgRequired, signReguired, reattempt, statGroup: String

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
    let id: Int
    let dlvryStatNo, dscrp, childStatNo: String
    let masterDscrp: String?
    let hhtAllow: String

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
    let statGroup: Int
    let descp: String
    let relationRequired: Int

    enum CodingKeys: String, CodingKey {
        case statGroup = "STAT_GROUP"
        case descp = "DESCP"
        case relationRequired = "RELATION_REQUIRED"
    }
}
