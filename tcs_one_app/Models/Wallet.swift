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
    let headerID: Int
    let incCode, codeDescription: String

    enum CodingKeys: String, CodingKey {
        case headerID = "HEADER_ID"
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

