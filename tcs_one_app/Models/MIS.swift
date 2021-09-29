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

// MARK: - DashboardDetail
struct MISDashboardDetail: Codable {
    let title, typ, mnth, yearr: String
    let product: String
    let totalShipment, whithinKpi: Int
    let wkpiAge: Double
    let afterKpi: Int
    let akpiAge: Double
    let inprocess: Int
    let inpAge: Double
    let delivered, dlvrdAge, retrn, rtnAge: Int

    enum CodingKeys: String, CodingKey {
        case title = "TITLE"
        case typ = "TYP"
        case mnth = "MNTH"
        case yearr = "YEARR"
        case product = "PRODUCT"
        case totalShipment = "TOTAL_SHIPMENT"
        case whithinKpi = "WHITHIN_KPI"
        case wkpiAge = "WKPI_AGE"
        case afterKpi = "AFTER_KPI"
        case akpiAge = "AKPI_AGE"
        case inprocess = "INPROCESS"
        case inpAge = "INP_AGE"
        case delivered = "DELIVERED"
        case dlvrdAge = "DLVRD_AGE"
        case retrn = "RETRN"
        case rtnAge = "RTN_AGE"
    }
}

//MARK: - Selection
struct MISPopupMonth {
    var mnth: String = ""
}

struct MISPopupYear {
    var yearr: String = ""
}


//MARK - MIS Detail table
struct ProductType {
    var title: String = ""
    var budgeted: String = ""
    var actual: String = ""
    var variance: String = ""
}
