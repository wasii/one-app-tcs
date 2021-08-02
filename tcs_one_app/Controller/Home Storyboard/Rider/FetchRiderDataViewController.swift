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
        
        RiderCalls.setupRiderToken { granted in
            if granted {
                guard let token = UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN) else {
                    return
                }
                let request_body = [
                        "access_token": token
                ]
                let params = self.getAPIParameter(service_name: S_RIDER_SETUP, request_body: request_body)
                RiderCalls.setupRider(params: params) { setup_granted in
                    if setup_granted {
                        DispatchQueue.main.async {
                            self.courierDetail.text = "Synced Wallet Setup"
                            self.loaderView[0].backgroundColor = UIColor.nativeRedColor()
                            self.activityIndicator[0].stopAnimating()
                            self.activityIndicator[0].isHidden = true
                            self.checkedImageView[0].isHidden = false
                            
                            self.activityIndicator[1].isHidden = false
                            self.activityIndicator[1].startAnimating()
                            
                            
                            guard let token = UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN) else {
                                return
                            }
                            let request_body = [
                                "access_token": token,
                                "bin_code": "",
                                "ds_no": ""
                            ]
                            let params = self.getAPIParameter(service_name: S_DELIVERY_SHEET, request_body: request_body)
                            RiderCalls.SetupDeliverySheets(params: params) { sheet_granted in
                                if sheet_granted {
                                    DispatchQueue.main.async {
                                        self.deliverySheet.text = "Synced Delivery Sheet"
                                        self.loaderView[1].backgroundColor = UIColor.nativeRedColor()
                                        self.activityIndicator[1].stopAnimating()
                                        self.activityIndicator[1].isHidden = true
                                        self.checkedImageView[1].isHidden = false
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                                            handler(true)
                                        })
                                    }
                                } else {
                                    handler(false)
                                }
                            }
                        }
                    } else {
                        handler(false)
                    }
                }
            } else {
                handler(false)
            }
        }
    }
}
