//
//  RiderDashboardViewController.swift
//  tcs_one_app
//
//  Created by TCS on 18/06/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import SwiftyJSON

class RiderDashboardViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Rider"
        self.makeTopCornersRounded(roundView: mainView)
        collectionView.register(UINib(nibName: RiderModulesCollectionCell.description(), bundle: nil), forCellWithReuseIdentifier: RiderModulesCollectionCell.description())
    }
}


extension RiderDashboardViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RiderModulesCollectionCell.description(), for: indexPath) as? RiderModulesCollectionCell else {
            fatalError()
        }
        switch indexPath.row {
        case 0:
            cell.moduleTitle.text = "Pickup"
            cell.imageView.image = UIImage(named: "pickup")
            break
        case 1:
            cell.moduleTitle.text = "Delivery"
            cell.imageView.image = UIImage(named: "delivery")
            break
        case 2:
            cell.moduleTitle.text = "Re-Attempt"
            cell.imageView.image = UIImage(named: "reatttempt")
            break
        case 3:
            cell.moduleTitle.text = "History"
            cell.imageView.image = UIImage(named: "history")
            break
        case 4:
            cell.moduleTitle.text = "Given To"
            cell.imageView.image = UIImage(named: "given_to")
            break
        case 5:
            cell.moduleTitle.text = "Verify"
            cell.imageView.image = UIImage(named: "verify_process")
            break
        default:
            break
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let storyboard = UIStoryboard(name: "RiderPickup", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "RiderPickupDashboardViewController") as! RiderPickupDashboardViewController
            
            self.navigationController?.pushViewController(controller, animated: true)
            return
        }
        if indexPath.row == 1 {
            let storyboard = UIStoryboard(name: "RiderDelivery", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "RiderDeliveryDashboardViewController") as! RiderDeliveryDashboardViewController
            
            self.navigationController?.pushViewController(controller, animated: true)
            return
        }
        if indexPath.row == 4 {
            let storyboard = UIStoryboard(name: "Popups", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "RiderGivenToPopupViewController") as! RiderGivenToPopupViewController
            
            if #available(iOS 13, *) {
                controller.modalPresentationStyle = .overFullScreen
            }
            controller.modalTransitionStyle = .crossDissolve
            controller.delegate = self
            Helper.topMostController().present(controller, animated: true, completion: nil)
        }
        if indexPath.row == 5 {
            let storyboard = UIStoryboard(name: "RiderVerifyProcess", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "VerifyProcessDashboardViewController") as! VerifyProcessDashboardViewController
            
            self.navigationController?.pushViewController(controller, animated: true)
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth = CGFloat(85)
//        let yourHeight = collectionView.bounds.width / 4.0
        
        return CGSize(width: yourWidth, height: 103)
    }
}



extension RiderDashboardViewController: RiderGivenToDelegate {
    func didSelectHandOver() {
        let storyboard = UIStoryboard(name: "RiderGivenTo", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "GivenToDashboardViewController") as! GivenToDashboardViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    func didSelectTakeOver() {
        let storyboard = UIStoryboard(name: "RiderDelivery", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "RiderScannerViewController") as! RiderScannerViewController
        
        if #available(iOS 13, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        controller.modalTransitionStyle = .crossDissolve
        controller.isGivenTo = true
        controller.givenToDelegate = self
        Helper.topMostController().present(controller, animated: true, completion: nil)
    }
    func didTakeOverReturns(code: String) {
        if !CustomReachability.isConnectedNetwork() {
            self.view.makeToast(NOINTERNETCONNECTION)
            return
        }
        
        self.view.makeToastActivity(.center)
        self.freezeScreen()
        let request_body = [
            "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
            "qrcode": String(code.split(separator: " ").first ?? "")
        ]
        let params = self.getAPIParameter(service_name: S_RIDER_NOTIFICATION, request_body: request_body)
        NetworkCalls.postriderqrcode(params: params) { notification_granted, notification_response in
            if notification_granted {
                DispatchQueue.main.async {
                    if let delivery_sheet = JSON(notification_response).string {
                        let request_body = [
                            "access_token": UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                            "bin_code": "",
                            "ds_no": "\(delivery_sheet)"
                        ]
                        let params = self.getAPIParameter(service_name: S_DELIVERY_SHEET, request_body: request_body)
                        RiderCalls.SetupDeliverySheets(params: params) { delivery_sheet_granted in
                            if delivery_sheet_granted {
                                let body = [
                                    "status":"SUCCESS",
                                    "message": SUCCESSWHILEDELIVERSHEET,
                                    "givenTo" : "Giver to \(CURRENT_USER_LOGGED_IN_ID)",
                                    "code": code
                                ]
                                let params = self.setupNotificationBody(body: body)
                                NetworkCalls.postnotification(params: params) { _ in
                                    DispatchQueue.main.async {
                                        self.view.hideToastActivity()
                                        self.unFreezeScreen()
                                        let storyboard = UIStoryboard(name: "RiderDelivery", bundle: nil)
                                        let controller = storyboard.instantiateViewController(withIdentifier: "RiderDeliveryDashboardViewController") as! RiderDeliveryDashboardViewController
                                        self.navigationController?.pushViewController(controller, animated: true)
                                    }
                                }
                                
                            } else {
                                let body = [
                                    "status":"ERROR",
                                    "message": ERRORWHILEDELIVERYSHEET,
                                    "givenTo" : "",
                                    "code": ""
                                ]
                                let params = self.setupNotificationBody(body: body)
                                NetworkCalls.postnotification(params: params) { _ in
                                    DispatchQueue.main.async {
                                        self.view.hideToastActivity()
                                        self.unFreezeScreen()
                                        self.view.makeToast(SOMETHINGWENTWRONG)
                                    }
                                }
                            }
                        }
                    } else {
                        let body = [
                            "status":"ERROR",
                            "message": ERRORWHILEQRCODE,
                            "givenTo" : "",
                            "code": ""
                        ]
                        let params = self.setupNotificationBody(body: body)
                        NetworkCalls.postnotification(params: params) { _ in
                            DispatchQueue.main.async {
                                self.view.hideToastActivity()
                                self.unFreezeScreen()
                                self.view.makeToast(SOMETHINGWENTWRONG)
                            }
                        }
                    }
                }
            } else {
                let body = [
                    "status":"ERROR",
                    "message": ERRORWHILEQRCODE,
                    "givenTo" : "",
                    "code": ""
                ]
                let params = self.setupNotificationBody(body: body)
                NetworkCalls.postnotification(params: params) { _ in
                    DispatchQueue.main.async {
                        self.view.hideToastActivity()
                        self.unFreezeScreen()
                        self.view.makeToast(SOMETHINGWENTWRONG)
                    }
                }
            }
        }
    }
}
