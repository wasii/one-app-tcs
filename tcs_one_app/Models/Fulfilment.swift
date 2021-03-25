//
//  Fulfilment.swift
//  tcs_one_app
//
//  Created by TCS on 25/03/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
struct ScanPrefix: Codable {
    let prefixID: Int
    let prefixDesc: String
    let moduleID: Int
    let pageID: Int?
    let created, prefixCode, serviceNo: String

    enum CodingKeys: String, CodingKey {
        case prefixID = "PREFIX_ID"
        case prefixDesc = "PREFIX_DESC"
        case moduleID = "MODULE_ID"
        case pageID = "PAGE_ID"
        case created = "CREATED"
        case prefixCode = "PREFIX_CODE"
        case serviceNo = "SERVICE_NO"
    }
}
struct FulfilmentOrders: Codable {
    let powerappOrderID: Int
    let cnsgNo: String
    let sku: String
    let qunatity: Int
    let orderID, createAt, serviceNo: String
    let orderStatus, itemStatus, origin, destination: String
    let orgn, dstn: String
    let srNo: Int
    
    let basketBarcode, isqc, consigneeAddress, updatedAt, updateBy: String?
    enum CodingKeys: String, CodingKey {
        case powerappOrderID = "POWERAPP_ORDER_ID"
        case cnsgNo = "CNSG_NO"
        case basketBarcode = "BASKET_BARCODE"
        case sku = "SKU"
        case qunatity = "QUNATITY"
        case isqc = "ISQC"
        case orderID = "ORDER_ID"
        case createAt = "CREATE_AT"
        case serviceNo = "SERVICE_NO"
        case updatedAt = "UPDATED_AT"
        case updateBy = "UPDATE_BY"
        case orderStatus = "ORDER_STATUS"
        case itemStatus = "ITEM_STATUS"
        case origin = "ORIGIN"
        case destination = "DESTINATION"
        case orgn = "ORGN"
        case dstn = "DSTN"
        case consigneeAddress = "CONSIGNEE_ADDRESS"
        case srNo = "SR_NO"
    }
}

