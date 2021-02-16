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
//    var bookingDetail: [BookingDetail]?
//    var deliveryDetail: [DeliveryDetail]?
//    var pbagDetail: [PbagDetail]?
//    var rbagDetail: [RbagDetail]?
//    var tbagDetail: [TbagDetail]?
//    var dmanDetail: [DmanDetail]?

//    enum CodingKeys: String, CodingKey {
//        case bookingDetail = "BOOKING_DETAIL"
//        case deliveryDetail = "DELIVERY_DETAIL"
//        case pbagDetail = "PBAG_DETAIL"
//        case rbagDetail = "RBAG_DETAIL"
//        case tbagDetail = "TBAG_DETAIL"
//        case dmanDetail = "DMAN_DETAIL"
//    }
}

// MARK: - BookingDetail
struct BookingDetail: Codable {
    let cnsgNo: Int
    let bkgDAT: String
    let noPcs: Int
    let orgn, dstn, route, service: String
    let product: String
    let wttBkg: Double
    let courier: String
    let cusNo: Int
    let cusNam: String
    let cnsgeeNam, dlvryKpi: Int

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
        case cnsgeeNam = "CNSGEE_NAM"
        case dlvryKpi = "DLVRY_KPI"
    }
}

// MARK: - DeliveryDetail
struct DeliveryDetail: Codable {
    let dlvryShtNo, slot, route, courier: String
    let dlvryDAT: String
    let dlvTime, rcvdBy: String
    let receiverRelation: String?
    let dlvStat: String
    let noPcs: Int
    let mobileNo: MobileNo

    enum CodingKeys: String, CodingKey {
        case dlvryShtNo = "DLVRY_SHT_NO"
        case slot = "SLOT"
        case route = "ROUTE"
        case courier = "COURIER"
        case dlvryDAT = "DLVRY_DAT"
        case dlvTime = "DLV_TIME"
        case rcvdBy = "RCVD_BY"
        case receiverRelation = "RECEIVER_RELATION"
        case dlvStat = "DLV_STAT"
        case noPcs = "NO_PCS"
        case mobileNo = "MOBILE_NO"
    }
}

enum MobileNo: Codable {
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
        throw DecodingError.typeMismatch(MobileNo.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for MobileNo"))
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
    let trsitMnsftNo, datee, orgn, dstn: String
    let courNam, trsptNo, trsptTypDetl: String

    enum CodingKeys: String, CodingKey {
        case trsitMnsftNo = "TRSIT_MNSFT_NO"
        case datee = "DATEE"
        case orgn = "ORGN"
        case dstn = "DSTN"
        case courNam = "COUR_NAM"
        case trsptNo = "TRSPT_NO"
        case trsptTypDetl = "TRSPT_TYP_DETL"
    }
}
