//
//  MIS.swift
//  tcs_one_app
//
//  Created by TCS on 10/08/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import Foundation

// MARK: - IMSProductData
struct IMSProductData: Codable {
    let product: String

    enum CodingKeys: String, CodingKey {
        case product = "PRODUCT"
    }
}

// MARK: - IMSRegionData
struct IMSRegionData: Codable {
    let product: String

    enum CodingKeys: String, CodingKey {
        case product = "PRODUCT"
    }
}

// MARK: - MISDailyOverview
struct MISDailyOverview: Codable {
    let regn, rptDate, product: String
    let booked: Int
    let weight, qsr, dsr: Double

    enum CodingKeys: String, CodingKey {
        case regn = "REGN"
        case rptDate = "RPT_DATE"
        case product = "PRODUCT"
        case booked = "BOOKED"
        case weight = "WEIGHT"
        case qsr = "QSR"
        case dsr = "DSR"
    }
}
