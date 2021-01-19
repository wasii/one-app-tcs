//
//  HRNotifications.swift
//  tcs_one_app
//
//  Created by ibs on 26/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import Foundation
import UIKit

struct HRNotificationRequest: Codable {
    let titleMessage: String?
    let sendingStatus, ticketID: Int?
    let readStatusDttm: String?
    let deviceReadDttm: String?
    let moduleDscrp, notifyTitle: String?
    let readStatus: Int?
    let notifyType: String?
    let srNo, recordID: Int?
    let createdDate, notificationRequestDESCRIPTION: String?
    let moduleid, sendTo: Int?

    enum CodingKeys: String, CodingKey {
        case titleMessage = "TITLE_MESSAGE"
        case sendingStatus = "SENDING_STATUS"
        case ticketID = "TICKET_ID"
        case readStatusDttm = "READ_STATUS_DTTM"
        case deviceReadDttm = "DEVICE_READ_DTTM"
        case moduleDscrp = "MODULE_DSCRP"
        case notifyTitle = "NOTIFY_TITLE"
        case readStatus = "READ_STATUS"
        case notifyType = "NOTIFY_TYPE"
        case srNo = "SR_NO"
        case recordID = "RECORD_ID"
        case createdDate = "CREATED_DATE"
        case notificationRequestDESCRIPTION = "DESCRIPTION"
        case moduleid = "MODULEID"
        case sendTo = "SEND_TO"
    }
}
