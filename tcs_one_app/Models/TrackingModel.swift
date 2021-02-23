//
//  TrackingModel.swift
//  tcs_one_app
//
//  Created by TCS on 16/02/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import Foundation
import SwiftyJSON
// MARK: - Track
struct Track {
    var name: String
    var isCollapsable: Bool
    var data: Any?
}
// MARK: - BookingDetail
struct BookingDetail: Codable {
    var cnsgNo: JSON?
    var bkgDAT: JSON?
    var noPcs: JSON?
    var orgn, dstn, route, service: JSON?
    var product: JSON?
    var wttBkg: JSON?
    var codStatus: JSON?
    var courier: JSON?
    var cnsgeeNam: JSON?
    var cusNo: JSON?
    var cusNam, cusAddr1, cusAddr2,cusAddr3 : JSON?
    var cnsgeeAddr1, cnsgeeAddr2, cnsgeeAddr3: JSON?
    var cnsgeePhn, cnsgeeFax, cusPhn, cusFax: JSON?
    var hndlgInst, dlvryKpi: JSON?
    
    enum CodingKeys: String, CodingKey {
        case cnsgNo = "CNSG_NO"
        case bkgDAT = "BKG_DAT"
        case noPcs = "NO_PCS"
        case orgn = "ORGN"
        case dstn = "DSTN"
        case route = "ROUTE"
        case service = "SERVICE"
        case product = "PRODUCT"
        case wttBkg = "WTT_BKG"
        case codStatus = "COD_STATUS"
        case courier = "COURIER"
        case cusNo = "CUS_NO"
        case cusNam = "CUS_NAM"
        case cusAddr1 = "CUS_ADDR1"
        case cusAddr2 = "CUS_ADDR2"
        case cusAddr3 = "CUS_ADDR3"
        case cnsgeeNam = "CNSGEE_NAM"
        case cnsgeeAddr1 = "CNSGEE_ADDR1"
        case cnsgeeAddr2 = "CNSGEE_ADDR2"
        case cnsgeeAddr3 = "CNSGEE_ADDR3"
        case cnsgeePhn = "CNSGEE_PHN"
        case cnsgeeFax = "CNSGEE_FAX"
        case cusPhn = "CUS_PHN"
        case hndlgInst = "HNDLG_INST"
        case dlvryKpi = "DLVRY_KPI"
    }
}

// MARK: - DeliveryDetail
struct DeliveryDetail: Codable {
    var dlvryShtNo, slot, route, courier: JSON?
    var dlvryDAT: JSON?
    var dlvTime, rcvdBy, dlvStat, rcvrRelation: JSON?
    var noPcs: JSON?
    var mobileNo: JSON?
    
    enum CodingKeys: String, CodingKey {
        case dlvryShtNo = "DLVRY_SHT_NO"
        case slot = "SLOT"
        case route = "ROUTE"
        case courier = "COURIER"
        case dlvryDAT = "DLVRY_DAT"
        case dlvTime = "DLV_TIME"
        case rcvdBy = "RCVD_BY"
        case dlvStat = "DLV_STAT"
        case noPcs = "NO_PCS"
        case mobileNo = "MOBILE_NO"
        case rcvrRelation = "RECEIVER_RELATION"
    }
}

enum MobileNo: Codable {
    case integer(Int)
    case string(String)
    case double(Double)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode(Double.self) {
            self = .double(x)
            return
        }
        throw DecodingError.typeMismatch(MobileNo.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for MobileNo"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        case .double(let x):
            try container.encode(x)
        }
        
        
    }
}

// MARK: - DmanDetail
struct DmanDetail: Codable {
    let status: String?
    let dmnfst: String?
    let time, dmnfstCode: String?

    enum CodingKeys: String, CodingKey {
        case status = "STATUS"
        case dmnfst = "DMNFST"
        case time = "TIME"
        case dmnfstCode = "DMNFST_CODE"
    }
}

// MARK: - PbagDetail
struct PbagDetail: Codable {
    var manfest, datee, dstn: JSON?
    var barcodePbag: JSON?
    var tMode: JSON?
    
    enum CodingKeys: String, CodingKey {
        case manfest = "MANFEST"
        case datee = "DATEE"
        case dstn = "DSTN"
        case barcodePbag = "BARCODE_PBAG"
        case tMode = "T_MODE"
    }
}

// MARK: - RbagDetail
struct RbagDetail: Codable {
    var seal, rbag, destn, mdate, rbagNo: JSON?
    
    enum CodingKeys: String, CodingKey {
        case rbag = "RBAG"
        case destn = "DESTN"
        case mdate = "MDATE"
        case rbagNo = "RBAG_NO"
        case seal = "SEAL"
    }
}

// MARK: - TbagDetail
struct TbagDetail: Codable {
    var trsitMnsftNo, datee, orgn: JSON?
    var courNam, trsptNo, trsptTypDetl: JSON?
    var dstn, rmks: JSON?
    
    enum CodingKeys: String, CodingKey {
        case trsitMnsftNo = "TRSIT_MNSFT_NO"
        case datee = "DATEE"
        case orgn = "ORGN"
        case dstn = "DSTN"
        case courNam = "COUR_NAM"
        case trsptNo = "TRSPT_NO"
        case trsptTypDetl = "TRSPT_TYP_DETL"
        case rmks = "RMKS"
    }
}
