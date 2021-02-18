//
//  TrackHomeViewController.swift
//  tcs_one_app
//
//  Created by TCS on 15/02/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import SwiftyJSON
import ExpyTableView

class TrackHomeViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var search_textfield: UITextField!
    
    @IBOutlet weak var booking_detail_tableView: UITableView!
    @IBOutlet weak var booking_detail_tableview_height: NSLayoutConstraint!
    
    
    @IBOutlet weak var deliver_detail_tableView: UITableView!
    @IBOutlet weak var deliver_detail_tableview_height: NSLayoutConstraint!
    
    
    @IBOutlet weak var pbag_detail_tableview: UITableView!
    @IBOutlet weak var pbag_detail_tableview_height: NSLayoutConstraint!
    
    
    @IBOutlet weak var rbag_detail_tableView: UITableView!
    @IBOutlet weak var rbag_detail_tableview_height: NSLayoutConstraint!
    
    
    @IBOutlet weak var tbag_detail_tableView: UITableView!
    @IBOutlet weak var tbag_detail_tableView_height: NSLayoutConstraint!
    
    
    @IBOutlet weak var dman_detail_tableView: UITableView!
    @IBOutlet weak var dman_detail_tableview_height: NSLayoutConstraint!
    
    
    @IBOutlet var detailLabel: [UILabel]!
    @IBOutlet var arrowImages: [UIImageView]!
    
    var booking_details: [BookingDetail]?
    var delivery_details: [DeliveryDetail]?
    var pBag_details: [PbagDetail]?
    var rBag_details: [RbagDetail]?
    var tBag_details: [TbagDetail]?
    var dMan_details: [DmanDetail]?
    
    
    var SECTION = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Track"
        self.makeTopCornersRounded(roundView: self.mainView)
        self.search_textfield.delegate = self
        
//        self.search_textfield.text = "779230356834"
        
        if let v = self.view.viewWithTag(10) {
            v.isHidden = true
        }
        if let v = self.view.viewWithTag(20) {
            v.isHidden = true
        }
        if let v = self.view.viewWithTag(30) {
            v.isHidden = true
        }
        if let v = self.view.viewWithTag(40) {
            v.isHidden = true
        }
        if let v = self.view.viewWithTag(50) {
            v.isHidden = true
        }
        if let v = self.view.viewWithTag(60) {
            v.isHidden = true
        }
        
        self.detailLabel.forEach { (d) in
            d.isHidden = true
        }
        self.arrowImages.forEach { (i) in
            i.isHidden = true
        }
        
        
        self.booking_detail_tableView.register(UINib(nibName: "BookingDetailsTableCell", bundle: nil), forCellReuseIdentifier: "BookingDetailsCell")
        self.booking_detail_tableView.rowHeight = 965
        
        self.deliver_detail_tableView.register(UINib(nibName: "DeliveryDetailsTableCell", bundle: nil), forCellReuseIdentifier: "DeliveryDetailsCell")
        self.deliver_detail_tableView.rowHeight = 370
        
        self.pbag_detail_tableview.register(UINib(nibName: "PBagDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "PBagDetailsCell")
        self.pbag_detail_tableview.rowHeight = 160
        
        self.rbag_detail_tableView.register(UINib(nibName: "RBagDetailsTableCell", bundle: nil), forCellReuseIdentifier: "RBagDetailsCell")
        self.rbag_detail_tableView.rowHeight = 160
        
        self.tbag_detail_tableView.register(UINib(nibName: "TBagDetailsTableCell", bundle: nil), forCellReuseIdentifier: "TBagDetailsCell")
        self.tbag_detail_tableView.rowHeight = 200
        
        self.dman_detail_tableView.register(UINib(nibName: "DManDetailsTableCell", bundle: nil), forCellReuseIdentifier: "DManDetailsCell")
        self.dman_detail_tableView.rowHeight = 130
    }
    @IBAction func trackBtnTapped(_ sender: Any) {
        dismissKeyboard()
        if search_textfield.text == "" {
            self.view.makeToast("Please enter consignment #")
            return
        }
        if !CustomReachability.isConnectedNetwork() {
            self.view.makeToast(NOINTERNETCONNECTION)
            return
        }
        
        self.view.makeToastActivity(.center)
        self.freezeScreen()
        
        self.booking_detail_tableview_height.constant = 0
        self.deliver_detail_tableview_height.constant = 0
        self.pbag_detail_tableview_height.constant = 0
        self.rbag_detail_tableview_height.constant = 0
        self.tbag_detail_tableView_height.constant = 0
        self.dman_detail_tableview_height.constant = 0
        self.mainViewHeightConstraint.constant = 790
        
        
        self.booking_details = nil
        self.delivery_details = nil
        self.pBag_details = nil
        self.rBag_details = nil
        self.tBag_details = nil
        self.dMan_details = nil
        
        let params = [
            "eAI_MESSAGE": [
                "eAI_HEADER": [
                    "serviceName": "oneapp.consignmenttracking",
                    "client": "ibm_apiconnect",
                    "clientChannel": "system",
                    "referenceNum": "",
                    "nested": false,
                    "securityInfo": [
                        "authentication": [
                            "userId": "",
                            "password": ""
                        ]
                    ]
                ],
                "eAI_BODY": [
                    "eAI_REQUEST": [
                        "track_cn": [
                            "cn" : self.search_textfield!.text
                        ]
                    ]
                ]
            ]
        ] as [String:Any]
        NetworkCalls.getbookingdetails(params: params) { (success, response) in
            if success {
                
                DispatchQueue.main.async {
                    self.detailLabel.forEach { (d) in
                        d.isHidden = false
                    }
                    self.arrowImages.forEach { (i) in
                        i.isHidden = false
                    }
                    if let v = self.view.viewWithTag(10) {
                        v.isHidden = false
                    }
                    if let v = self.view.viewWithTag(20) {
                        v.isHidden = false
                    }
                    if let v = self.view.viewWithTag(30) {
                        v.isHidden = false
                    }
                    if let v = self.view.viewWithTag(40) {
                        v.isHidden = false
                    }
                    if let v = self.view.viewWithTag(50) {
                        v.isHidden = false
                    }
                    if let v = self.view.viewWithTag(60) {
                        v.isHidden = false
                    }
                }
                
                if let details = JSON(response).array?.first {
                    if let bd = details.dictionary?["BOOKING_DETAIL"]?.array {
                        DispatchQueue.main.async {
                            self.arrowImages[0].image = UIImage(named: "drop_down_white")
                            self.detailLabel[0].text = "Show Details"
                        }
                        self.booking_details = [BookingDetail]()
                        for index in bd {
                            do {
                                let data = try index.rawData()
                                self.booking_details?.append(try JSONDecoder().decode(BookingDetail.self, from: data))
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
                    } else {
                        DispatchQueue.main.async {
                            self.detailLabel[0].text = "No Records Found"
                            self.arrowImages[0].image = nil
                        }
                        
                    }
                    if let dd = details.dictionary?["DELIVERY_DETAIL"]?.array {
                        DispatchQueue.main.async {
                            self.arrowImages[1].image = UIImage(named: "drop_down_white")
                            self.detailLabel[1].text = "Show Details"
                        }
                        
                        self.delivery_details = [DeliveryDetail]()
                        for index in dd {
                            do {
                                let data = try index.rawData()
                                self.delivery_details?.append(try JSONDecoder().decode(DeliveryDetail.self, from: data))
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
                    }else {
                        DispatchQueue.main.async {
                            self.detailLabel[1].text = "No Records Found"
                            self.arrowImages[1].image = nil
                        }
                        
                    }
                    
                    if let pbd = details.dictionary?["PBAG_DETAIL"]?.array {
                        DispatchQueue.main.async {
                            self.arrowImages[2].image = UIImage(named: "drop_down_white")
                            self.detailLabel[2].text = "Show Details"
                        }
                        
                        self.pBag_details = [PbagDetail]()
                        for index in pbd {
                            do {
                                let data = try index.rawData()
                                self.pBag_details?.append(try JSONDecoder().decode(PbagDetail.self, from: data))
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
                    } else {
                        DispatchQueue.main.async {
                            self.detailLabel[2].text = "No Records Found"
                            self.arrowImages[2].image = nil
                        }
                        
                    }
                    
                    if let rbd = details.dictionary?["RBAG_DETAIL"]?.array {
                        DispatchQueue.main.async {
                            self.arrowImages[3].image = UIImage(named: "drop_down_white")
                            self.detailLabel[3].text = "Show Details"
                        }
                        
                        self.rBag_details = [RbagDetail]()
                        for index in rbd {
                            do {
                                let data = try index.rawData()
                                self.rBag_details?.append(try JSONDecoder().decode(RbagDetail.self, from: data))
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
                    } else {
                        DispatchQueue.main.async {
                            self.detailLabel[3].text = "No Records Found"
                            self.arrowImages[3].image = nil
                        }
                        
                    }
                    if let tbd = details.dictionary?["TBAG_DETAIL"]?.array {
                        DispatchQueue.main.async {
                            self.arrowImages[4].image = UIImage(named: "drop_down_white")
                            self.detailLabel[4].text = "Show Details"
                        }
                        
                        self.tBag_details = [TbagDetail]()
                        for index in tbd {
                            do {
                                let data = try index.rawData()
                                self.tBag_details?.append(try JSONDecoder().decode(TbagDetail.self, from: data))
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
                    } else {
                        DispatchQueue.main.async {
                            self.detailLabel[4].text = "No Records Found"
                            self.arrowImages[4].image = nil
                        }
                        
                    }
                    
                    if let dmd = details.dictionary?["DMAN_DETAIL"]?.array {
                        DispatchQueue.main.async {
                            self.arrowImages[5].image = UIImage(named: "drop_down_white")
                            self.detailLabel[5].text = "Show Details"
                        }
                        
                        self.dMan_details = [DmanDetail]()
                        for index in dmd {
                            do {
                                let data = try index.rawData()
                                self.dMan_details?.append(try JSONDecoder().decode(DmanDetail.self, from: data))
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
                    } else {
                        DispatchQueue.main.async {
                            self.detailLabel[5].text = "No Records Found"
                            self.arrowImages[5].image = nil
                        }
                        
                    }
                }
                
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    self.unFreezeScreen()
                }
            } else {
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    self.unFreezeScreen()
                    self.view.makeToast(SOMETHINGWENTWRONG)
                    
                    
                    self.booking_detail_tableview_height.constant = 0
                    self.deliver_detail_tableview_height.constant = 0
                    self.pbag_detail_tableview_height.constant = 0
                    self.rbag_detail_tableview_height.constant = 0
                    self.tbag_detail_tableView_height.constant = 0
                    self.dman_detail_tableview_height.constant = 0
                    self.mainViewHeightConstraint.constant = 790
                }
            }
        }
    }
    
    
    @IBAction func openDetails(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        switch sender.tag {
        case 0:
            if sender.isSelected {
                if let booking_detail = self.booking_details {
                    self.SECTION = 0
                    UIView.animate(withDuration: 0.3) {
                        self.arrowImages[0].image = UIImage(named: "up_white")
                        self.detailLabel[0].text = "Hide Details"
                        self.booking_detail_tableview_height.constant = CGFloat(booking_detail.count * 965)
                        self.mainViewHeightConstraint.constant += self.booking_detail_tableview_height.constant
                        self.booking_detail_tableView.reloadData()
                        self.view.layoutIfNeeded()
                    }
                    
                }
                
            } else {
                if let _ = self.booking_details {
                    UIView.animate(withDuration: 0.1) {
                        self.arrowImages[0].image = UIImage(named: "drop_down_white")
                        self.detailLabel[0].text = "Show Details"
                        self.mainViewHeightConstraint.constant -= self.booking_detail_tableview_height.constant
                        self.booking_detail_tableview_height.constant = 0
                        self.view.layoutIfNeeded()
                    }
                    
                }
            }
            
            break
        case 1:
            if sender.isSelected {
                if let delivery_detail = self.delivery_details {
                    self.SECTION = 1
                    UIView.animate(withDuration: 0.3) {
                        self.arrowImages[1].image = UIImage(named: "up_white")
                        self.detailLabel[1].text = "Hide Details"
                        self.deliver_detail_tableview_height.constant = CGFloat(delivery_detail.count * 370)
                        self.mainViewHeightConstraint.constant += self.deliver_detail_tableview_height.constant
                        self.deliver_detail_tableView.reloadData()
                        self.view.layoutIfNeeded()
                    }
                    
                    
                }
            } else {
                if let _ = self.delivery_details {
                    UIView.animate(withDuration: 0.1) {
                        self.arrowImages[1].image = UIImage(named: "drop_down_white")
                        self.detailLabel[1].text = "Show Details"
                        self.mainViewHeightConstraint.constant -= self.deliver_detail_tableview_height.constant
                        self.deliver_detail_tableview_height.constant = 0
                        self.view.layoutIfNeeded()
                    }
                }
            }
            break
        case 2:
            if sender.isSelected {
                if let pBag = self.pBag_details {
                    self.SECTION = 2
                    UIView.animate(withDuration: 0.3) {
                        self.arrowImages[2].image = UIImage(named: "up_white")
                        self.detailLabel[2].text = "Hide Details"
                        self.pbag_detail_tableview_height.constant = CGFloat(pBag.count * 160)
                        self.mainViewHeightConstraint.constant += self.pbag_detail_tableview_height.constant
                        self.pbag_detail_tableview.reloadData()
                        self.view.layoutIfNeeded()
                    }
                }
            } else {
                if let _ = self.pBag_details {
                    UIView.animate(withDuration: 0.1) {
                        self.arrowImages[2].image = UIImage(named: "drop_down_white")
                        self.detailLabel[2].text = "Show Details"
                        self.mainViewHeightConstraint.constant -= self.pbag_detail_tableview_height.constant
                        self.pbag_detail_tableview_height.constant = 0
                        self.view.layoutIfNeeded()
                    }
                }
            }
            break
        case 3:
            if sender.isSelected {
                if let rBag = self.rBag_details {
                    self.SECTION = 3
                    UIView.animate(withDuration: 0.3) {
                        self.arrowImages[3].image = UIImage(named: "up_white")
                        self.detailLabel[3].text = "Hide Details"
                        self.rbag_detail_tableview_height.constant = CGFloat(rBag.count * 160)
                        self.mainViewHeightConstraint.constant += self.rbag_detail_tableview_height.constant
                        self.rbag_detail_tableView.reloadData()
                        self.view.layoutIfNeeded()
                    }
                }
            } else {
                if let _ = self.rBag_details {
                    UIView.animate(withDuration: 0.1) {
                        self.arrowImages[3].image = UIImage(named: "drop_down_white")
                        self.detailLabel[3].text = "Show Details"
                        self.mainViewHeightConstraint.constant -= self.rbag_detail_tableview_height.constant
                        self.rbag_detail_tableview_height.constant = 0
                        self.view.layoutIfNeeded()
                    }
                }
            }
            break
        case 4:
            if sender.isSelected {
                if let tBag = self.tBag_details {
                    self.SECTION = 4
                    UIView.animate(withDuration: 0.3) {
                        self.arrowImages[4].image = UIImage(named: "up_white")
                        self.detailLabel[4].text = "Hide Details"
                        self.tbag_detail_tableView_height.constant = CGFloat(tBag.count * 200)
                        self.mainViewHeightConstraint.constant += self.tbag_detail_tableView_height.constant
                        self.tbag_detail_tableView.reloadData()
                        self.view.layoutIfNeeded()
                    }
                }
            } else {
                if let _ = self.tBag_details {
                    UIView.animate(withDuration: 0.1) {
                        self.arrowImages[4].image = UIImage(named: "drop_down_white")
                        self.detailLabel[4].text = "Show Details"
                        self.mainViewHeightConstraint.constant -= self.tbag_detail_tableView_height.constant
                        self.tbag_detail_tableView_height.constant = 0
                        self.view.layoutIfNeeded()
                    }
                }
            }
            break
        case 5:
            if sender.isSelected {
                if let dBag = self.dMan_details {
                    self.SECTION = 5
                    UIView.animate(withDuration: 0.3) {
                        self.arrowImages[5].image = UIImage(named: "up_white")
                        self.detailLabel[5].text = "Hide Details"
                        self.dman_detail_tableview_height.constant = CGFloat(dBag.count * 200)
                        self.mainViewHeightConstraint.constant += self.dman_detail_tableview_height.constant
                        self.dman_detail_tableView.reloadData()
                        self.view.layoutIfNeeded()
                    }
                }
            } else {
                if let _ = self.dMan_details {
                    UIView.animate(withDuration: 0.1) {
                        self.arrowImages[5].image = UIImage(named: "drop_down_white")
                        self.detailLabel[5].text = "Show Details"
                        self.mainViewHeightConstraint.constant -= self.dman_detail_tableview_height.constant
                        self.dman_detail_tableview_height.constant = 0
                        self.view.layoutIfNeeded()
                    }
                }
            }
            break
        default:
            break
        }
    }
}
extension TrackHomeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 12
        
        
        
        let currentString: NSString = textField.text as! NSString
        let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length <= maxLength {
            
            let emailRegEx = "[0-9]{0,12}"

            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailPred.evaluate(with: newString)
            
            
            
//            return true
        }
        return false
    }
}





extension TrackHomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.SECTION {
        case 0:
            if let count = self.booking_details?.count {
                return count
            }
            return 0
        case 1:
            if let count = self.delivery_details?.count {
                return count
            }
            return 0
        case 2:
            if let count = self.pBag_details?.count {
                return count
            }
            return 0
        case 3:
            if let count = self.rBag_details?.count {
                return count
            }
            return 0
        case 4:
            if let count = self.tBag_details?.count {
                return count
            }
            return 0
        case 5:
            if let count = self.dMan_details?.count {
                return count
            }
            return 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.SECTION {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookingDetailsCell") as! BookingDetailsTableCell
            let data = self.booking_details![indexPath.row]
            
            cell.cgsnNo.text = "\(data.cnsgNo ?? 0)"
            cell.bookingdate.text = "\(data.bkgDAT ?? "")"
            cell.pieces.text = "\(data.noPcs ?? 0)"
            cell.origin.text = "\(data.orgn ?? "-")"
            cell.destination.text = "\(data.dstn ?? "-")"
            cell.route.text = "\(data.route ?? "-")"
            cell.services.text = "\(data.service ?? "-")"
            cell.product.text = "\(data.product ?? "-")"
            cell.bookingweight.text = "\(data.wttBkg ?? 0.0)"
            
            cell.handlingInstructions.text = "\(data.hndlgInst ?? "-")"
            cell.codStatus.text = "-"
            
            cell.courierno.text = "\(data.courier ?? "-")"
            
            cell.routeNo.text = "\(data.route ?? "-")"
            
            cell.callNo.text = "-"
            
            
            cell.customerNumber.text = "\(data.cusNo ?? 0)"
            cell.customerName.text = "\(data.cusNam ?? "-")"
            
            cell.customerAddress1.text = "\(data.cusAddr1 ?? "-")"
            cell.customerAddress2.text = "\(data.cusAddr2 ?? "-")"
            cell.customerAddress3.text = "\(data.cusAddr3 ?? "-")"
            cell.customerPhone.text = "\(data.cusPhne ?? "-")"
            cell.customerFax.text = "\(data.cusFax ?? "-")"
            
            cell.consigneeName.text = "\(data.cnsgeeNam ?? "-")"
            cell.consigneeAddress1.text = "\(data.cnsgeeAddr1 ?? "-")"
            cell.consigneeAddress2.text = "\(data.cnsgeeAddr2 ?? "-")"
            cell.consigneeAddress3.text = "\(data.cnsgeeAddr3 ?? "-")"
            cell.consigneePhone.text = "\(data.cnsgeePhn ?? "-")"
            cell.consigneeFax.text = "\(data.cnsgeeFax ?? "-")"
            cell.deliveryKPI.text = "\(data.dlvryKpi ?? "-")"
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryDetailsCell") as! DeliveryDetailsTableCell
            let data = self.delivery_details![indexPath.row]
            
            cell.sheetno.text = "\(data.dlvryShtNo)"
            cell.slot.text = "\(data.slot)"
            cell.route.text = "\(data.route)"
            cell.courier.text = "\(data.courier)"
            cell.couriercell.text = "\(data.mobileNo)"
            cell.date.text = "\(data.dlvryDAT)"
            cell.time.text = "\(data.dlvTime)"
            cell.receivedBy.text = "\(data.rcvdBy)"
            cell.relation.text = "-"
            cell.status.text = "\(data.dlvStat)"
            cell.pieces.text = "\(data.noPcs)"
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PBagDetailsCell") as! PBagDetailsTableViewCell
            let data = self.pBag_details![indexPath.row]
            cell.pBagManifest.text = "\(data.manfest)"
            cell.transDate.text = "\(data.datee)"
            cell.destination.text = "\(data.dstn)"
            cell.pBagNo.text = "\(data.barcodePbag)"
            cell.mode.text = "\(data.tMode)"
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RBagDetailsCell") as! RBagDetailsTableCell
            let data = self.rBag_details![indexPath.row]
            cell.rBagManifest.text = "\(data.rbag)"
            cell.destination.text = "\(data.destn)"
            cell.transdate.text = "\(data.mdate)"
            cell.rBageNo.text = "\(data.rbagNo)"
            cell.rbagSeal.text = "\(data.seal)"
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TBagDetailsCell") as! TBagDetailsTableCell
            let data = self.tBag_details![indexPath.row]
            cell.transitManifest.text = "\(data.trsitMnsftNo)"
            cell.date.text = "\(data.datee)"
            cell.origin.text = "\(data.orgn)"
            cell.destination.text = "-"
            cell.courier.text = "\(data.courNam)"
            cell.manifesttype.text = "\(data.trsptNo)"
            cell.remarksflight.text = "-"
            cell.truck.text = "-"
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DManDetailsCell") as! DManDetailsTableCell
            let data = self.dMan_details![indexPath.row]
            cell.status.text = "\(data.status)"
            cell.date.text = "\(data.dmnfst)"
            cell.time.text = "\(data.time)"
            cell.hub.text = "\(data.dmnfstCode)"
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "")
            return cell!
        }
    }
}
