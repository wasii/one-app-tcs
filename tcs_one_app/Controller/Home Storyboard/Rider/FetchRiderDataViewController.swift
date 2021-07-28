//
//  FetchRiderDataViewController.swift
//  tcs_one_app
//
//  Created by TCS on 18/06/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import SwiftyJSON

class FetchRiderDataViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var courierDetail: UILabel!
    @IBOutlet weak var deliveryStatus: UILabel!
    @IBOutlet weak var deliverySheet: UILabel!
    @IBOutlet weak var pickup: UILabel!
    @IBOutlet weak var pickupSheet: UILabel!
    
    @IBOutlet var loaderView: [UIView]!
    @IBOutlet var activityIndicator: [UIActivityIndicatorView]!
    @IBOutlet var checkedImageView: [UIImageView]!
    
    var delegate: MoveToRiderScreen?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Rider"
        addDoubleNavigationButtons()
        self.makeTopCornersRounded(roundView: self.mainView)
        activityIndicator.forEach { (UIActivityIndicatorView) in
            UIActivityIndicatorView.startAnimating()
        }
        checkedImageView.forEach { (UIImageView) in
            UIImageView.isHidden = true
            UIImageView.image = UIImageView.image?.withRenderingMode(.alwaysTemplate)
            UIImageView.tintColor = UIColor.white
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.setupJSON { success in
                DispatchQueue.main.async {
                    if success {
                        self.dismiss(animated: true) {
                            self.delegate?.moveToRiderScreen()
                        }
                    } else {
                        self.view.makeToast(SOMETHINGWENTWRONG)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.dismiss(animated: true) {}
                        }
                    }
                }
            }
        }
    }
    
    func setupJSON(_ handler: @escaping(_ success: Bool)->Void) {
        courierDetail.text = "Syncing Rider Detail"
        activityIndicator[0].isHidden = false
        activityIndicator[0].startAnimating()
        
        self.setupRiderToken { granted in
            if granted {
                DispatchQueue.main.async {
                    self.courierDetail.text = "Synced Wallet Setup"
                    self.loaderView[0].backgroundColor = UIColor.nativeRedColor()
                    self.activityIndicator[0].stopAnimating()
                    self.activityIndicator[0].isHidden = true
                    self.checkedImageView[0].isHidden = false
                    
                    self.activityIndicator[1].isHidden = false
                    self.activityIndicator[1].startAnimating()
                }
                handler(true)
            } else {
                handler(false)
            }
        }
    }
    private func setupRiderToken(_ handler: @escaping(Bool)->Void){
        NetworkCalls.getridertoken { isToken in
            if isToken {
                self.setupRider { rider_granted in
                    if rider_granted {
                        handler(true)
                    } else {
                        handler(false)
                    }
                }
            } else {
                handler(false)
            }
        }
    }
    
    //MARK: - Setup Rider
    private func setupRider(_ handler: @escaping(Bool)->Void) {
        guard let token = UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN) else {
            return
        }
        let request_body = [
                "access_token": token
        ]
        let params = self.getAPIParameter(service_name: S_RIDER_SETUP, request_body: request_body)
        NetworkCalls.getridersetup(params: params) { granted, response in
            if granted {
                let json = JSON(response)
                if let riderSetupData = json.dictionary?[_riderSetupData]?.dictionary {
                    if let dial_code = json.dictionary?[_dial_code]?.int {
                        RIDER_DIAL_CODE = String(dial_code)
                    }
                    if let rider_detail = riderSetupData[_rider_detail]?.array?.first {
                        do {
                            let rawData = try rider_detail.rawData()
                            let riderDetail: RiderDetail = try JSONDecoder().decode(RiderDetail.self, from: rawData)
                            AppDelegate.sharedInstance.db?.deleteAll(tableName: db_rider_detail, handler: { _ in
                                AppDelegate.sharedInstance.db?.insert_tbl_rider_details(RiderDetail: riderDetail, { _ in })
                            })
                        } catch let DecodingError.dataCorrupted(context) {
                            print(context)
                        } catch let DecodingError.keyNotFound(key, context) {
                            print("Key '\(key)' not found:", context.debugDescription)
                            print("codingPath:", context.codingPath)
                        } catch let DecodingError.valueNotFound(value, context) {
                            print("Value '\(value)' not found:", context.debugDescription)
                            print("codingPath:", context.codingPath)
                        } catch let DecodingError.typeMismatch(type, context)  {
                            print("Type '\(type)' mismatch:", context.debugDescription)
                            print("codingPath:", context.codingPath)
                        } catch {
                            print("error: ", error)
                        }
                    }
                    
                    if let receiver_relation = riderSetupData[_receiver_relation]?.array {
                        AppDelegate.sharedInstance.db?.deleteAll(tableName: db_receiver_relation, handler: { _ in
                            for rr in receiver_relation {
                                do {
                                    let rawData = try rr.rawData()
                                    let receiverRelation: ReceiverRelation = try JSONDecoder().decode(ReceiverRelation.self, from: rawData)
                                    AppDelegate.sharedInstance.db?.insert_tbl_rider_receiver_relation(ReceiverRelation: receiverRelation, handler: { _ in })
                                } catch let DecodingError.dataCorrupted(context) {
                                    print(context)
                                } catch let DecodingError.keyNotFound(key, context) {
                                    print("Key '\(key)' not found:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                } catch let DecodingError.valueNotFound(value, context) {
                                    print("Value '\(value)' not found:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                } catch let DecodingError.typeMismatch(type, context)  {
                                    print("Type '\(type)' mismatch:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                } catch {
                                    print("error: ", error)
                                }
                            }
                        })
                    }
                    
                    if let master_delivery = riderSetupData[_master_dlvry_status]?.array {
                        AppDelegate.sharedInstance.db?.deleteAll(tableName: db_rider_master_dlvry, handler: { _ in
                            for md in master_delivery {
                                do {
                                    let rawData = try md.rawData()
                                    let RiderMasterDelivery: RiderMasterDelivery = try JSONDecoder().decode(RiderMasterDelivery.self, from: rawData)
                                    AppDelegate.sharedInstance.db?.insert_tbl_rider_master_delivery(RiderMasterDelivery: RiderMasterDelivery, handler: { _ in })
                                } catch let DecodingError.dataCorrupted(context) {
                                    print(context)
                                } catch let DecodingError.keyNotFound(key, context) {
                                    print("Key '\(key)' not found:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                } catch let DecodingError.valueNotFound(value, context) {
                                    print("Value '\(value)' not found:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                } catch let DecodingError.typeMismatch(type, context)  {
                                    print("Type '\(type)' mismatch:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                } catch {
                                    print("error: ", error)
                                }
                            }
                        })
                    }
                    if let detail_delivery = riderSetupData[_detail_dlvry_status]?.array {
                        AppDelegate.sharedInstance.db?.deleteAll(tableName: db_rider_detail_dlvry, handler: { _ in
                            for dd in detail_delivery {
                                do {
                                    let rawData = try dd.rawData()
                                    let RiderDetailDelivery: RiderDetailDelivery = try JSONDecoder().decode(RiderDetailDelivery.self, from: rawData)
                                    AppDelegate.sharedInstance.db?.insert_tbl_rider_detail_delivery(RiderDetailDelivery: RiderDetailDelivery, handler: { _ in })
                                } catch let DecodingError.dataCorrupted(context) {
                                    print(context)
                                } catch let DecodingError.keyNotFound(key, context) {
                                    print("Key '\(key)' not found:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                } catch let DecodingError.valueNotFound(value, context) {
                                    print("Value '\(value)' not found:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                } catch let DecodingError.typeMismatch(type, context)  {
                                    print("Type '\(type)' mismatch:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                } catch {
                                    print("error: ", error)
                                }
                            }
                        })
                    }
                    if let status_group = riderSetupData[_status_group]?.array {
                        AppDelegate.sharedInstance.db?.deleteAll(tableName: db_rider_status_group, handler: { _ in
                            for sg in status_group {
                                do {
                                    let rawData = try sg.rawData()
                                    let RiderStatusGroup: RiderStatusGroup = try JSONDecoder().decode(RiderStatusGroup.self, from: rawData)
                                    AppDelegate.sharedInstance.db?.insert_tbl_rider_status_group(RiderStatusGroup: RiderStatusGroup, handler: { _ in })
                                } catch let DecodingError.dataCorrupted(context) {
                                    print(context)
                                } catch let DecodingError.keyNotFound(key, context) {
                                    print("Key '\(key)' not found:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                } catch let DecodingError.valueNotFound(value, context) {
                                    print("Value '\(value)' not found:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                } catch let DecodingError.typeMismatch(type, context)  {
                                    print("Type '\(type)' mismatch:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                } catch {
                                    print("error: ", error)
                                }
                            }
                        })
                    }
                    if let app_master_response = riderSetupData[_appMasterResponse]?.array {
                        AppDelegate.sharedInstance.db?.deleteAll(tableName: db_app_master_response, handler: { _ in
                            for amr in app_master_response {
                                do {
                                    let rawData = try amr.rawData()
                                    let AppMasterResponse: AppMasterResponse = try JSONDecoder().decode(AppMasterResponse.self, from: rawData)
                                    AppDelegate.sharedInstance.db?.insert_tbl_rider_app_master_response(AppMasterResponse: AppMasterResponse, handler: { _ in })
                                } catch let DecodingError.dataCorrupted(context) {
                                    print(context)
                                } catch let DecodingError.keyNotFound(key, context) {
                                    print("Key '\(key)' not found:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                } catch let DecodingError.valueNotFound(value, context) {
                                    print("Value '\(value)' not found:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                } catch let DecodingError.typeMismatch(type, context)  {
                                    print("Type '\(type)' mismatch:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                } catch {
                                    print("error: ", error)
                                }
                            }
                        })
                    }
                    if let app_detail_response = riderSetupData[_appDetailResponse]?.array {
                        AppDelegate.sharedInstance.db?.deleteAll(tableName: db_app_detail_response, handler: { _ in
                            for adr in app_detail_response {
                                do {
                                    let rawData = try adr.rawData()
                                    let AppDetailResponse: AppDetailResponse = try JSONDecoder().decode(AppDetailResponse.self, from: rawData)
                                    AppDelegate.sharedInstance.db?.insert_tbl_rider_app_detail_response(AppDetailResponse: AppDetailResponse, handler: { _ in })
                                } catch let DecodingError.dataCorrupted(context) {
                                    print(context)
                                } catch let DecodingError.keyNotFound(key, context) {
                                    print("Key '\(key)' not found:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                } catch let DecodingError.valueNotFound(value, context) {
                                    print("Value '\(value)' not found:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                } catch let DecodingError.typeMismatch(type, context)  {
                                    print("Type '\(type)' mismatch:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                } catch {
                                    print("error: ", error)
                                }
                            }
                        })
                    }
                    if let report_to_lov = riderSetupData[_reportToLov]?.array {
                        AppDelegate.sharedInstance.db?.deleteAll(tableName: db_report_to_lov, handler: { _ in
                            for rtl in report_to_lov {
                                do {
                                    let rawData = try rtl.rawData()
                                    let ReportToLov: ReportToLov = try JSONDecoder().decode(ReportToLov.self, from: rawData)
                                    AppDelegate.sharedInstance.db?.insert_tbl_rider_report_to_lov(ReportToLov: ReportToLov, handler: { _ in })
                                } catch let DecodingError.dataCorrupted(context) {
                                    print(context)
                                } catch let DecodingError.keyNotFound(key, context) {
                                    print("Key '\(key)' not found:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                } catch let DecodingError.valueNotFound(value, context) {
                                    print("Value '\(value)' not found:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                } catch let DecodingError.typeMismatch(type, context)  {
                                    print("Type '\(type)' mismatch:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                } catch {
                                    print("error: ", error)
                                }
                            }
                        })
                    }
                    handler(true)
                } else {
                    handler(false)
                }
            } else {
                handler(false)
            }
        }
    }
    
    //MARK: - Delivery Sheet
    private func SetupDeliverySheets(_ handler: @escaping(Bool)->Void) {
        guard let token = UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN) else {
            return
        }
        let request_body = [
            "access_token": token,
            "bin_code": "",
            "ds_no": ""
        ]
        let params = self.getAPIParameter(service_name: S_DELIVERY_SHEET, request_body: request_body)
        NetworkCalls.getriderdeliverysheets(params: params) { granted, response in
            if granted {
                let json = JSON(response).dictionary
                if let riderDeliveryData = json?[_riderDeliveryData]?.dictionary {
                    if let deliverySheet = riderDeliveryData[_deliverySheet]?.array {
                        for ds in deliverySheet {
                            do {
                                let rawData = try ds.rawData()
                                let riderDeliverySheet: RiderDeliverySheet = try JSONDecoder().decode(RiderDeliverySheet.self, from: rawData)
                                if riderDeliverySheet.dlvrdBy == CURRENT_USER_LOGGED_IN_ID {
                                    let query = "SELECT * FROM \(db_rider_delivery_sheet) WHERE SHEETNO = '\(riderDeliverySheet.sheetno!)' AND CN = '\(riderDeliverySheet.cn!)'"
                                    if let sheet = AppDelegate.sharedInstance.db?.read_tbl_rider_delivery_sheet(query: query) {
                                        if sheet.first?.DELIVERYSTATUS == "" {
                                            AppDelegate.sharedInstance.db?.deleteRowWithMultipleConditions(tbl: db_rider_delivery_sheet, conditions: "SHEETNO = '\(riderDeliverySheet.sheetno!)' AND CN = '\(riderDeliverySheet.cn!)'", { _ in
                                                AppDelegate.sharedInstance.db?.insert_tbl_rider_delivery_sheet(DeliverySheet: riderDeliverySheet, handler: { _ in
                                                    if let details = riderDeliverySheet.riderDeliveryDetail {
                                                        for d in details {
                                                            AppDelegate.sharedInstance.db?.deleteRowWithMultipleConditions(tbl: db_delivery_sheet_detail, conditions: "\(d.)", <#T##handler: (Bool) -> Void##(Bool) -> Void#>)
                                                        }
                                                    }
                                                })
                                            })
                                        } else {
                                            if sheet.first?.SYNC_STATUS != 0 {
                                                AppDelegate.sharedInstance.db?.deleteRowWithMultipleConditions(tbl: db_rider_delivery_sheet, conditions: "SHEETNO = '\(riderDeliverySheet.sheetno!)' AND CN = '\(riderDeliverySheet.cn!)'", { _ in
                                                    AppDelegate.sharedInstance.db?.insert_tbl_rider_delivery_sheet(DeliverySheet: riderDeliverySheet, handler: { _ in
                                                    })
                                                })
                                            }
                                        }
                                    } else {
                                        AppDelegate.sharedInstance.db?.insert_tbl_rider_delivery_sheet(DeliverySheet: riderDeliverySheet, handler: { _ in })
                                    }
                                } else {
                                    continue
                                }
                            } catch let DecodingError.dataCorrupted(context) {
                                print(context)
                            } catch let DecodingError.keyNotFound(key, context) {
                                print("Key '\(key)' not found:", context.debugDescription)
                                print("codingPath:", context.codingPath)
                            } catch let DecodingError.valueNotFound(value, context) {
                                print("Value '\(value)' not found:", context.debugDescription)
                                print("codingPath:", context.codingPath)
                            } catch let DecodingError.typeMismatch(type, context)  {
                                print("Type '\(type)' mismatch:", context.debugDescription)
                                print("codingPath:", context.codingPath)
                            } catch {
                                print("error: ", error)
                            }
                        }
                    }
                }
                handler(true)
            } else {
                handler(false)
            }
        }
    }
}
