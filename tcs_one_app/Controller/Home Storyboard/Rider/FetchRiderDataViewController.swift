//
//  FetchRiderDataViewController.swift
//  tcs_one_app
//
//  Created by TCS on 18/06/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import SwiftyJSON

var DIAL_CODE = ""
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
                if success {
                    self.dismiss(animated: true) {
                        self.delegate?.moveToRiderScreen()
                    }
                }
            }
        }
    }
    
    func setupJSON(_ handler: @escaping(_ success: Bool)->Void) {
        courierDetail.text = "Syncing Courier Detail"
        activityIndicator[0].isHidden = false
        activityIndicator[0].startAnimating()
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.courierDetail.text = "Synced Courier Detail"
            self.activityIndicator[0].isHidden = true
            self.activityIndicator[0].stopAnimating()
            self.loaderView[0].backgroundColor = UIColor.nativeRedColor()
            self.checkedImageView[0].isHidden = false
            
            
            self.deliveryStatus.text = "Syncing Delivery Status"
            self.activityIndicator[1].isHidden = false
            self.activityIndicator[1].startAnimating()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.deliveryStatus.text = "Synced Delivery Detail"
                self.activityIndicator[1].isHidden = true
                self.activityIndicator[1].stopAnimating()
                self.loaderView[1].backgroundColor = UIColor.nativeRedColor()
                self.checkedImageView[1].isHidden = false
                
                self.deliverySheet.text = "Syncing Delivery Sheet"
                self.activityIndicator[2].isHidden = false
                self.activityIndicator[2].startAnimating()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.deliverySheet.text = "Synced Delivery Sheet"
                    self.activityIndicator[2].isHidden = true
                    self.activityIndicator[2].stopAnimating()
                    self.loaderView[2].backgroundColor = UIColor.nativeRedColor()
                    self.checkedImageView[2].isHidden = false
                    
                    self.pickup.text = "Syncing Pickup"
                    self.activityIndicator[3].isHidden = false
                    self.activityIndicator[3].startAnimating()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.pickup.text = "Synced Pickup"
                        self.activityIndicator[3].isHidden = true
                        self.activityIndicator[3].stopAnimating()
                        self.loaderView[3].backgroundColor = UIColor.nativeRedColor()
                        self.checkedImageView[3].isHidden = false
                        
                        self.pickupSheet.text = "Syncing Pickup Sheet"
                        self.activityIndicator[4].isHidden = false
                        self.activityIndicator[4].startAnimating()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.pickupSheet.text = "Synced Pickup Sheet"
                            self.activityIndicator[4].isHidden = true
                            self.activityIndicator[4].stopAnimating()
                            self.loaderView[4].backgroundColor = UIColor.nativeRedColor()
                            self.checkedImageView[4].isHidden = false
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                handler(true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setupCourierDetails(_ handler: @escaping(Bool)->Void) {
        guard let token = UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN) else {
            return
        }
        let request_body = [
            "attendance_request" : [
                "access_token": token
            ]
        ]
        let params = self.getAPIParameter(service_name: RIDERSETUP, request_body: request_body)
        NetworkCalls.getridersetup(params: params) { granted, response in
            if granted {
                let json = JSON(response)
                if let dial_code = json.dictionary?[_dial_code]?.string {
                    DIAL_CODE = dial_code
                }
                if let receiver_relation = json.dictionary?[_receiver_relation]?.array {
                    
                }
                if let rider_detail = json.dictionary?[_rider_detail]?.array?.first {
                    do {
                        let rawData = try rider_detail.rawData()
                        let riderDetail: RiderDetail = try JSONDecoder().decode(RiderDetail.self, from: rawData)
                    } catch let err {
                        print(err.localizedDescription)
                    }
                }
                if let master_delivery = json.dictionary?[_master_dlvry_status]?.array {
                    
                }
                if let detail_delivery = json.dictionary?[_detail_dlvry_status]?.array {
                    
                }
                if let status_group = json.dictionary?[_status_group]?.array {
                    
                }
            } else {
                
            }
        }
    }
}
