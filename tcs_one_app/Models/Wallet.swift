//
//  Wallet.swift
//  tcs_one_app
//
//  Created by TCS on 01/07/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import Foundation

// MARK: - Welcome
struct Welcome: Codable {
    let walletSetupData: WalletSetupData
}

// MARK: - WalletSetupData
struct WalletSetupData: Codable {
    let incentiveData: [IncentiveData]
    let pointType: [PointType]
    let redemptionSetup: [RedemptionSetup]
}

// MARK: - IncentiveData
struct IncentiveData: Codable {
    let headerID: Int
    let headerName, headerDescription: String
    let details: [Detail]

    enum CodingKeys: String, CodingKey {
        case headerID = "HEADER_ID"
        case headerName = "HEADER_NAME"
        case headerDescription = "HEADER_DESCRIPTION"
        case details = "DETAILS"
    }
}

// MARK: - Detail
struct Detail: Codable {
    let headerID, incId: Int
    let incCode, codeDescription: String

    enum CodingKeys: String, CodingKey {
        case headerID = "HEADER_ID"
        case incId = "INC_ID"
        case incCode = "INC_CODE"
        case codeDescription = "CODE_DESCRIPTION"
    }
}

// MARK: - PointType
struct PointType: Codable {
    let pointID, unit, equalPoint: Int

    enum CodingKeys: String, CodingKey {
        case pointID = "POINT_ID"
        case unit = "UNIT"
        case equalPoint = "EQUAL_POINT"
    }
}

// MARK: - RedemptionSetup
struct RedemptionSetup: Codable {
    let redemptionID: Int
    let redemptionCode, redemptionDescription, redemptionRemarks: String
    let imageURLAndroid: String
    let imageURLIos: String

    enum CodingKeys: String, CodingKey {
        case redemptionID = "REDEMPTION_ID"
        case redemptionCode = "REDEMPTION_CODE"
        case redemptionDescription = "REDEMPTION_DESCRIPTION"
        case redemptionRemarks = "REDEMPTION_REMARKS"
        case imageURLAndroid = "IMAGE_URL_ANDROID"
        case imageURLIos = "IMAGE_URL_IOS"
    }
}

//MARK: - WalletHistoryPoint
struct WalletHistoryPoint: Codable {
    let rid, id, cat, subCat: Int
    let employeeID, redemptionDatime: String
    let redemptionPoints: Int
    let redemptionCode: String
    let walletHistoryPointDESCRIPTION: String?

    enum CodingKeys: String, CodingKey {
        case rid = "RID"
        case id = "ID"
        case cat = "CAT"
        case subCat = "SUB_CAT"
        case employeeID = "EMPLOYEE_ID"
        case redemptionDatime = "REDEMPTION_DATIME"
        case redemptionPoints = "REDEMPTION_POINTS"
        case redemptionCode = "REDEMPTION_CODE"
        case walletHistoryPointDESCRIPTION = "DESCRIPTION"
    }
}

// MARK: - PointsSummary
struct PointsSummary: Codable {
    let employeeID, transactionDate: String
    let maturePoints, unmaturePoints, redeemPoints, netRedeemable: Int
    let pointSummaryDetails: [PointSummaryDetail]

    enum CodingKeys: String, CodingKey {
        case employeeID = "EMPLOYEE_ID"
        case transactionDate = "TRANSACTION_DATE"
        case maturePoints = "MATURE_POINTS"
        case unmaturePoints = "UNMATURE_POINTS"
        case redeemPoints = "REDEEM_POINTS"
        case netRedeemable = "NET_REDEEMABLE"
        case pointSummaryDetails = "DETAILS"
    }
}

// MARK: - Detail
struct PointSummaryDetail: Codable {
    let employeeID, transactionDate: String
    let totalShipment, cat, subCat, maturePoints: Int
    let unMaturePoints, totalPoints: Int
    
    enum CodingKeys: String, CodingKey {
        case employeeID = "EMPLOYEE_ID"
        case transactionDate = "TRANSACTION_DATE"
        case totalShipment = "TOTAL_SHIPMENT"
        case cat = "CAT"
        case subCat = "SUB_CAT"
        case maturePoints = "MATURE_POINTS"
        case unMaturePoints = "UN_MATURE_POINTS"
        case totalPoints = "TOTAL_POINTS"
    }
}

// MARK: - PointsDetail
struct PointsDetail: Codable {
    let rid: Int
    let employeeID, transactionDate: String
    let isMature: Int
    let cnsgNo: String
    let cat, subCat, points: Int

    enum CodingKeys: String, CodingKey {
        case rid = "RID"
        case employeeID = "EMPLOYEE_ID"
        case transactionDate = "TRANSACTION_DATE"
        case isMature = "IS_MATURE"
        case cnsgNo = "CNSG_NO"
        case cat = "CAT"
        case subCat = "SUB_CAT"
        case points = "POINTS"
    }
}
