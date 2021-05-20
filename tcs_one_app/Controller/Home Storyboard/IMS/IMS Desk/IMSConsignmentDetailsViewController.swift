//
//  IMSConsignmentDetailsViewController.swift
//  tcs_one_app
//
//  Created by TCS on 09/04/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import SwiftyJSON

class IMSConsignmentDetailsViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var dropDownImage: [UIImageView]!
    
    @IBOutlet weak var booking_tableview: UITableView!
    @IBOutlet weak var booking_tableview_height: NSLayoutConstraint!
    @IBOutlet weak var delivery_tableview: UITableView!
    @IBOutlet weak var delivery_tableview_height: NSLayoutConstraint!
    
    var booking_detail: [IMSBookingDetail]?
    var delivery_detail: [IMSDeliveryDetail]?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Consignment Details"
        self.makeTopCornersRounded(roundView: self.mainView)
        
        self.booking_tableview.register(UINib(nibName: "IMSBookingDetailTableCell", bundle: nil), forCellReuseIdentifier: "IMSBookingDetailCell")
        self.booking_tableview.rowHeight = 485
        
        self.delivery_tableview.register(UINib(nibName: "IMSDeliveryDetailsTableCell", bundle: nil), forCellReuseIdentifier: "IMSDeliveryDetailsCell")
        self.delivery_tableview.rowHeight = 410
        
        
        self.booking_tableview.reloadData()
        self.delivery_tableview.reloadData()
    }
    
    @IBAction func openDetails(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2) {
            self.booking_tableview_height.constant = 0
            self.delivery_tableview_height.constant = 0
            self.view.layoutIfNeeded()
        } completion: { _ in
            if sender.tag == 0 {
                sender.isSelected = !sender.isSelected
                if sender.isSelected {
                    UIView.animate(withDuration: 0.6) {
                        self.booking_tableview_height.constant = CGFloat(self.booking_detail!.count * 485)
                    }
                    self.view.layoutIfNeeded()
                } else {
                    UIView.animate(withDuration: 0.2) {
                        self.booking_tableview_height.constant = 0
                    }
                    self.view.layoutIfNeeded()
                }
            } else {
                sender.isSelected = !sender.isSelected
                if sender.isSelected {
                    UIView.animate(withDuration: 0.6) {
                        self.delivery_tableview_height.constant = CGFloat(self.delivery_detail!.count * 410)
                    }
                    self.view.layoutIfNeeded()
                } else {
                    UIView.animate(withDuration: 0.2) {
                        self.delivery_tableview_height.constant = 0
                    }
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
}

extension IMSConsignmentDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == booking_tableview {
            if let count = booking_detail?.count {
                return count
            }
            return 0
        } else {
            if let count = delivery_detail?.count {
                return count
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == booking_tableview {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IMSBookingDetailCell") as! IMSBookingDetailTableCell
            let data = self.booking_detail![indexPath.row]
            cell.booking_date.text = data.bookingDate ?? "-"
            cell.booking_time.text = data.bookingTime ?? "-"
            cell.product.text = data.product ?? "-"
            cell.service.text = data.service ?? "-"
            cell.account_no.text = data.accountNo ?? "-"
            cell.shipper_name.text = data.shipperName ?? "-"
            cell.origin.text = data.origin ?? "-"
            cell.destination.text = data.destination ?? "-"
            cell.payment_mode.text = data.paymentMode ?? "-"
            cell.cod_amount.text = "\(data.codAmount ?? 0)"
            cell.consignee_name.text = data.consigneeName ?? "-"
            cell.courier_code.text = data.courierCode ?? "-"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IMSDeliveryDetailsCell") as! IMSDeliveryDetailsTableCell
            let data = self.delivery_detail![indexPath.row]
            
            cell.deliverySheetNo.text = data.deliverySheetNo ?? "-"
            cell.serialNo.text = data.serialNo ?? "-"
            cell.deliveryRoute.text = data.route ?? "-"
            cell.courierCode.text = data.courierCode ?? "-"
            cell.courierName.text = data.courierName ?? "-"
            cell.courierMobile.text = data.courierMobile ?? "-"
            cell.courierPhone.text = data.courierPhone ?? "-"
            cell.deliveryDate.text = data.deliveryDate ?? "-"
            cell.deliveryTime.text = data.deliveryTime ?? "-"
            cell.receiver.text = data.receiver ?? "-"
            cell.status.text = data.status ?? "-"
            return cell
        }
    }
}



// MARK: - BookingDetail
struct IMSBookingDetail: Codable {
    var bookingDate, bookingTime, product, service: String?
    var accountNo, shipperName, origin: String?
    var destination, paymentMode, consigneeName: String?
    var courierCode: String?
    var codAmount: Int?
    
    enum CodingKeys: String, CodingKey {
        case bookingDate = "BOOKING_DATE"
        case bookingTime = "BOOKING_TIME"
        case product = "PRODUCT"
        case service = "SERVICE"
        case accountNo = "ACCOUNT_NO"
        case shipperName = "SHIPPER_NAME"
        case origin = "ORIGIN"
        case destination = "DESTINATION"
        case paymentMode = "PAYMENT_MODE"
        case codAmount = "COD_AMOUNT"
        case consigneeName = "CONSIGNEE_NAME"
        case courierCode = "COURIER_CODE"
    }
}

// MARK: - DeliveryDetail
struct IMSDeliveryDetail: Codable {
    var deliverySheetNo, serialNo, route, courierCode: String?
    var courierName: String?
    var courierMobile, courierPhone, deliveryDate, deliveryTime: String?
    var receiver: String?
    var status: String?
    
    enum CodingKeys: String, CodingKey {
        case deliverySheetNo = "DELIVERY_SHEET_NO"
        case serialNo = "SERIAL_NO"
        case route = "DELIVERY_ROUTE"
        case courierCode = "COURIER_CODE"
        case courierName = "COURIER_NAME"
        case courierMobile = "COURIER_MOBILE"
        case courierPhone = "COURIER_PHONE"
        case deliveryDate = "DELIVERY_DATE"
        case deliveryTime = "DELIVERY_TIME"
        case receiver = "RECEIVER"
        case status = "STATUS"
    }
}
