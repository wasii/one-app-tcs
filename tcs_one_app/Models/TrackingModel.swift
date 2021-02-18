//
//  TrackingModel.swift
//  tcs_one_app
//
//  Created by TCS on 16/02/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import Foundation
// MARK: - Track
struct Track {
    var name: String
    var isCollapsable: Bool
    var data: Any?
}

// MARK: - BookingDetail
struct BookingDetail: Codable {
    let cnsgNo: Int?
    let bkgDAT: String?
    let noPcs: Int?
    let orgn, dstn, route, service: String?
    let product: String?
    let wttBkg: Double?
    let courier: String?
    let cusNo: CusNo?
    let cusNam, cusAddr1, cusAddr2, cusAddr3, cusPhne, cusFax : String?
    let cnsgeeNam, cnsgeeAddr1, cnsgeeAddr2, cnsgeeAddr3, cnsgeePhn, cnsgeeFax: String?
    let dlvryKpi, hndlgInst: String?

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
        case courier = "COURIER"
        case cusNo = "CUS_NO"
        case cusNam = "CUS_NAM"
        case cusAddr1 = "CUS_ADDR1"
        case cusAddr2 = "CUS_ADDR2"
        case cusAddr3 = "CUS_ADDR3"
        case cusPhne = "CUS_PHN"
        case cusFax = "CUS_FAX"
        case cnsgeeNam = "CNSGEE_NAM"
        case cnsgeeAddr1 = "CNSGEE_ADDR1"
        case cnsgeeAddr2 = "CNSGEE_ADDR2"
        case cnsgeeAddr3 = "CNSGEE_ADDR3"
        case cnsgeePhn = "CNSGEE_PHN"
        case cnsgeeFax = "CNSGEE_FAX"
        case dlvryKpi = "DLVRY_KPI"
        case hndlgInst = "hndlg_inst"
    }
}

// MARK: - DeliveryDetail
struct DeliveryDetail: Codable {
    let dlvryShtNo, slot, route, courier: String
    let dlvryDAT: String
    let dlvTime, rcvdBy, dlvStat: String
    let noPcs: Int
    let mobileNo: String

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
    }
}

// MARK: - DmanDetail
struct DmanDetail: Codable {
    let status: String
    let dmnfst: String
    let time, dmnfstCode: String

    enum CodingKeys: String, CodingKey {
        case status = "STATUS"
        case dmnfst = "DMNFST"
        case time = "TIME"
        case dmnfstCode = "DMNFST_CODE"
    }
}

// MARK: - PbagDetail
struct PbagDetail: Codable {
    let manfest, datee, dstn, barcodePbag: String
    let tMode: String

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
    let rbag, destn, mdate, rbagNo: String
    let seal: Int

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
    let trsitMnsftNo, datee, orgn, courNam: String
    let trsptNo: String

    enum CodingKeys: String, CodingKey {
        case trsitMnsftNo = "TRSIT_MNSFT_NO"
        case datee = "DATEE"
        case orgn = "ORGN"
        case courNam = "COUR_NAM"
        case trsptNo = "TRSPT_NO"
    }
}



enum CusNo: Codable {
    case integer(Int)
    case string(String)

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
        throw DecodingError.typeMismatch(CusNo.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for MobileNo"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}
