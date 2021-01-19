//
//  PinValidator.swift
//  tcs_one_app
//
//  Created by ibs on 22/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import Foundation
import UIKit

struct PinValidator {
    var module: [Module]
    var page: [Page]
    var permission: [Permission]
    var acess_token_id : String
    var emp_info: [User]
}


struct Permission: Codable {
    let permissionid, pageid: Int?
    let permission: String?
    let isactive: Int?

    enum CodingKeys: String, CodingKey {
        case permissionid = "PERMISSIONID"
        case pageid = "PAGEID"
        case permission = "PERMISSION"
        case isactive = "ISACTIVE"
    }
}
struct Page: Codable {
    let pageid, moduleid: Int?
    let pagename: String?
    let pageurl: String?
    let pageorder: String?
    let isactive: Int?
    let pageicon: String?
    let showonmenu: Int?
    let controller:String?
    let htmlattribute: String?
    let globalaccess: Int?
    let tagname: String?

    enum CodingKeys: String, CodingKey {
        case pageid = "PAGEID"
        case moduleid = "MODULEID"
        case pagename = "PAGENAME"
        case pageurl = "PAGEURL"
        case pageorder = "PAGEORDER"
        case isactive = "ISACTIVE"
        case pageicon = "PAGEICON"
        case showonmenu = "SHOWONMENU"
        case controller = "CONTROLLER"
        case htmlattribute = "HTMLATTRIBUTE"
        case globalaccess = "GLOBALACCESS"
        case tagname = "TAGNAME"
    }
}
struct Module: Codable {
    let moduleid: Int?
    let modulename: String?
    let isactive, moduleorder: Int?
    let moduleicon: String?
    let parentid: Int?
    let tagname: String?
    let globalAccess: Int?

    enum CodingKeys: String, CodingKey {
        case moduleid = "MODULEID"
        case modulename = "MODULENAME"
        case isactive = "ISACTIVE"
        case moduleorder = "MODULEORDER"
        case moduleicon = "MODULEICON"
        case parentid = "PARENTID"
        case tagname = "TAGNAME"
        case globalAccess = "GLOBAL_ACCESS"
    }
}
