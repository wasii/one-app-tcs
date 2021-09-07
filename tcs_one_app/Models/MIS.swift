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


// MARK: - BudgetSetup
struct BudgetSetup: Codable {
    let product: String
    let budgeted, dsr: Int
    let prodType, mnth: String
    let yearr, pdBudget, weight, qsr: Int
    let pdWeight: Int

    enum CodingKeys: String, CodingKey {
        case product = "PRODUCT"
        case budgeted = "BUDGETED"
        case dsr = "DSR"
        case prodType = "PROD_TYPE"
        case mnth = "MNTH"
        case yearr = "YEARR"
        case pdBudget = "PD_BUDGET"
        case weight = "WEIGHT"
        case qsr = "QSR"
        case pdWeight = "PD_WEIGHT"
    }
}

// MARK: - BudgetData
struct BudgetData: Codable {
    let rptDate, product: String
    let ship, dsr: Double
    let type: String
    let qsr, weight: Double

    enum CodingKeys: String, CodingKey {
        case rptDate = "RPT_DATE"
        case product = "PRODUCT"
        case ship = "SHIP"
        case dsr = "DSR"
        case type = "TYPE"
        case qsr = "QSR"
        case weight = "WEIGHT"
    }
}


//MARK: - Selection
struct MISPopupMonth {
    var mnth: String = ""
}

struct MISPopupYear {
    var yearr: String = ""
}
