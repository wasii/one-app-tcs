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

    @IBOutlet weak var noRecordFound: UILabel!
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
    @IBOutlet var heightConstraint: [NSLayoutConstraint]!
    
    var booking_details: [BookingDetail]?
    var delivery_details: [DeliveryDetail]?
    var pBag_details: [PbagDetail]?
    var rBag_details: [RbagDetail]?
    var tBag_details: [TbagDetail]?
    var dMan_details: [DmanDetail]?
    
    
    var SECTION = -1
    
    var DSTN = [JSON]()
    var SEAL = [JSON]()
    var PHONE_NO: JSON?
    var BARCODE_PBAG: JSON?
    
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
        self.booking_detail_tableView.rowHeight = 980
        
        self.deliver_detail_tableView.register(UINib(nibName: "DeliveryDetailsTableCell", bundle: nil), forCellReuseIdentifier: "DeliveryDetailsCell")
        self.deliver_detail_tableView.rowHeight = 380
        
        self.pbag_detail_tableview.register(UINib(nibName: "PBagDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "PBagDetailsCell")
        self.pbag_detail_tableview.rowHeight = 160
        
        self.rbag_detail_tableView.register(UINib(nibName: "RBagDetailsTableCell", bundle: nil), forCellReuseIdentifier: "RBagDetailsCell")
        self.rbag_detail_tableView.rowHeight = 160
        
        self.tbag_detail_tableView.register(UINib(nibName: "TBagDetailsTableCell", bundle: nil), forCellReuseIdentifier: "TBagDetailsCell")
        self.tbag_detail_tableView.rowHeight = 260
        
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
        
        self.heightConstraint.forEach { (e) in
            e.constant = 50
        }
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
                var recoudFound = false
                
                DispatchQueue.main.async {
                    self.noRecordFound.isHidden = true
                    self.detailLabel.forEach { (d) in
                        d.isHidden = false
                    }
                    self.arrowImages.forEach { (i) in
                        i.isHidden = false
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
                            DispatchQueue.main.async {
                                if let v = self.view.viewWithTag(10) {
                                    v.isHidden = false
                                }
                            }
                            var bd = BookingDetail()
                            if let detail = index.dictionary?["CNSG_NO"] {
                                bd.cnsgNo = detail
                            }
                            if let detail = index.dictionary?["BKG_DAT"] {
                                bd.bkgDAT = detail
                            }
                            if let detail = index.dictionary?["NO_PCS"] {
                                bd.noPcs = detail
                            }
                            if let detail = index.dictionary?["ORGN"] {
                                bd.orgn = detail
                            }
                            if let detail = index.dictionary?["DSTN"] {
                                bd.dstn = detail
                            }
                            if let detail = index.dictionary?["PRODUCT"] {
                                bd.product = detail
                            }
                            if let detail = index.dictionary?["ROUTE"] {
                                bd.route = detail
                            }
                            if let detail = index.dictionary?["SERVICE"] {
                                bd.service = detail
                            }
                            if let detail = index.dictionary?["WTT_BKG"] {
                                bd.wttBkg = detail
                            }
                            if let detail = index.dictionary?["COD_STATUS"] {
                                bd.codStatus = detail
                            }
                            if let detail = index.dictionary?["COURIER"] {
                                bd.courier = detail
                            }
                            if let detail = index.dictionary?["CUS_NO"] {
                                bd.cusNo = detail
                            }
                            if let detail = index.dictionary?["CUS_NAM"] {
                                bd.cusNam = detail
                            }
                            if let detail = index.dictionary?["CUS_ADDR1"] {
                                bd.cusAddr1 = detail
                            }
                            if let detail = index.dictionary?["CUS_ADDR2"] {
                                bd.cusAddr2 = detail
                            }
                            if let detail = index.dictionary?["CUS_ADDR3"] {
                                bd.cusAddr3 = detail
                            }
                            if let detail = index.dictionary?["CUS_PHN"] {
                                bd.cusPhn = detail
                            }
                            if let detail = index.dictionary?["CUS_FAX"] {
                                bd.cusFax = detail
                            }
                            if let detail = index.dictionary?["CNSGEE_NAM"] {
                                bd.cnsgeeNam = detail
                            }
                            if let detail = index.dictionary?["CNSGEE_ADDR1"] {
                                bd.cnsgeeAddr1 = detail
                            }
                            if let detail = index.dictionary?["CNSGEE_ADDR2"] {
                                bd.cnsgeeAddr2 = detail
                            }
                            if let detail = index.dictionary?["CNSGEE_ADDR3"] {
                                bd.cnsgeeAddr3 = detail
                            }
                            if let detail = index.dictionary?["CNSGEE_PHN"] {
                                bd.cnsgeePhn = detail
                            }
                            if let detail = index.dictionary?["CNSGEE_FAX"] {
                                bd.cnsgeeFax = detail
                            }
                            if let detail = index.dictionary?["HNDLG_INST"] {
                                bd.hndlgInst = detail
                            }
                            if let detail = index.dictionary?["DLVRY_KPI"] {
                                bd.dlvryKpi = detail
                            }
                            self.booking_details?.append(bd)
                        }
                        recoudFound = true
                    } else {
                        DispatchQueue.main.async {
                            if let v = self.view.viewWithTag(10) {
                                v.isHidden = true
                            }
                        }
                        
                    }
                    if let dd = details.dictionary?["DELIVERY_DETAIL"]?.array {
                        DispatchQueue.main.async {
                            self.arrowImages[1].image = UIImage(named: "drop_down_white")
                            self.detailLabel[1].text = "Show Details"
                        }
                        
                        self.delivery_details = [DeliveryDetail]()
                        for index in dd {
                            DispatchQueue.main.async {
                                if let v = self.view.viewWithTag(20) {
                                    v.isHidden = false
                                }
                            }
                            var dd = DeliveryDetail()
                            if let detail = index.dictionary?["DLVRY_SHT_NO"] {
                                dd.dlvryShtNo = detail
                            }
                            if let detail = index.dictionary?["SLOT"] {
                                dd.slot = detail
                            }
                            if let detail = index.dictionary?["ROUTE"] {
                                dd.route = detail
                            }
                            if let detail = index.dictionary?["DLVRY_DAT"] {
                                dd.dlvryDAT = detail
                            }
                            if let detail = index.dictionary?["DLV_TIME"] {
                                dd.dlvTime = detail
                            }
                            if let detail = index.dictionary?["RCVD_BY"] {
                                dd.rcvdBy = detail
                            }
                            if let detail = index.dictionary?["DLV_STAT"] {
                                dd.dlvStat = detail
                            }
                            if let detail = index.dictionary?["NO_PCS"] {
                                dd.noPcs = detail
                            }
                            if let detail = index.dictionary?["MOBILE_NO"] {
                                dd.mobileNo = detail
                            }
                            if let detail = index.dictionary?["COURIER"] {
                                dd.courier = detail
                            }
                            if let details = index.dictionary?["RECEIVER_RELATION"] {
                                dd.rcvrRelation = details
                            }
                            self.delivery_details?.append(dd)
                        }
                        recoudFound = true
                    } else {
                        DispatchQueue.main.async {
                            if let v = self.view.viewWithTag(20) {
                                v.isHidden = true
                            }
                        }
                    }
                    
                    if let pbd = details.dictionary?["PBAG_DETAIL"]?.array {
                        DispatchQueue.main.async {
                            self.arrowImages[2].image = UIImage(named: "drop_down_white")
                            self.detailLabel[2].text = "Show Details"
                        }
                        
                        self.pBag_details = [PbagDetail]()
                        for index in pbd {
                            DispatchQueue.main.async {
                                if let v = self.view.viewWithTag(30) {
                                    v.isHidden = false
                                }
                            }
                            var pBag = PbagDetail()
                            if let detail = index.dictionary?["MANFEST"] {
                                pBag.manfest = detail
                            }
                            if let detail = index.dictionary?["DATEE"] {
                                pBag.datee = detail
                            }
                            if let detail = index.dictionary?["DSTN"] {
                                pBag.dstn = detail
                            }
                            if let detail = index.dictionary?["BARCODE_PBAG"] {
                                pBag.barcodePbag = detail
                            }
                            if let detail = index.dictionary?["T_MODE"] {
                                pBag.tMode = detail
                            }
                            
                            self.pBag_details?.append(pBag)
                        }
                        recoudFound = true
                    } else {
                        DispatchQueue.main.async {
                            if let v = self.view.viewWithTag(30) {
                                v.isHidden = true
                            }
                        }
                    }
                    
                    if let rbd = details.dictionary?["RBAG_DETAIL"]?.array {
                        DispatchQueue.main.async {
                            self.arrowImages[3].image = UIImage(named: "drop_down_white")
                            self.detailLabel[3].text = "Show Details"
                        }
                        
                        self.rBag_details = [RbagDetail]()
                        for index in rbd {
                            DispatchQueue.main.async {
                                if let v = self.view.viewWithTag(40) {
                                    v.isHidden = false
                                }
                            }
                            var rBag = RbagDetail()
                            if let detail = index.dictionary?["RBAG"] {
                                rBag.rbag = detail
                            }
                            if let detail = index.dictionary?["DESTN"] {
                                rBag.destn = detail
                            }
                            if let detail = index.dictionary?["MDATE"] {
                                rBag.mdate = detail
                            }
                            if let detail = index.dictionary?["RBAG_NO"] {
                                rBag.rbagNo = detail
                            }
                            if let detail = index.dictionary?["SEAL"] {
                                rBag.seal = detail
                            }
                            
                            self.rBag_details?.append(rBag)
                            
                        }
                        recoudFound = true
                    } else {
                        DispatchQueue.main.async {
                            if let v = self.view.viewWithTag(40) {
                                v.isHidden = true
                            }
                        }
                    }
                    if let tbd = details.dictionary?["TBAG_DETAIL"]?.array {
                        DispatchQueue.main.async {
                            self.arrowImages[4].image = UIImage(named: "drop_down_white")
                            self.detailLabel[4].text = "Show Details"
                        }
                        
                        self.tBag_details = [TbagDetail]()
                        for index in tbd {
                            DispatchQueue.main.async {
                                if let v = self.view.viewWithTag(50) {
                                    v.isHidden = false
                                }
                            }
                            var tBag = TbagDetail()
                            if let detail = index.dictionary?["TRSIT_MNSFT_NO"] {
                                tBag.trsitMnsftNo = detail
                            }
                            if let detail = index.dictionary?["DATEE"] {
                                tBag.datee = detail
                            }
                            if let detail = index.dictionary?["ORGN"] {
                                tBag.orgn = detail
                            }
                            if let detail = index.dictionary?["DSTN"] {
                                tBag.dstn = detail
                            }
                            if let detail = index.dictionary?["COUR_NAM"] {
                                tBag.courNam = detail
                            }
                            if let detail = index.dictionary?["TRSPT_NO"] {
                                tBag.trsptNo = detail
                            }
                            if let detail = index.dictionary?["TRSPT_TYP_DETL"] {
                                tBag.trsptTypDetl = detail
                            }
                            if let detail = index.dictionary?["RMKS"] {
                                tBag.rmks = detail
                            }
                            
                            self.tBag_details?.append(tBag)
                        }
                        recoudFound = true
                    } else {
                        DispatchQueue.main.async {
                            if let v = self.view.viewWithTag(50) {
                                v.isHidden = true
                            }
                        }
                    }
                    
                    if let dmd = details.dictionary?["DMAN_DETAIL"]?.array {
                        DispatchQueue.main.async {
                            self.arrowImages[5].image = UIImage(named: "drop_down_white")
                            self.detailLabel[5].text = "Show Details"
                        }
                        
                        self.dMan_details = [DmanDetail]()
                        for index in dmd {
                            DispatchQueue.main.async {
                                if let v = self.view.viewWithTag(60) {
                                    v.isHidden = false
                                }
                            }
                            var status = ""
                            var dmnfst = ""
                            var time = ""
                            var dmnfst_code = ""
                            
                            if let s = index.dictionary?["STATUS"] {
                                status = s.string ?? "-"
                            }
                            if let s = index.dictionary?["DMNFST"] {
                                dmnfst = s.string ?? "-"
                            }
                            if let s = index.dictionary?["TIME"] {
                                time = s.string ?? "-"
                            }
                            if let s = index.dictionary?["DMNFST_CODE"] {
                                dmnfst_code = s.string ?? "-"
                            }
                            
                            let data = DmanDetail(status: status, dmnfst: dmnfst, time: time, dmnfstCode: dmnfst_code)
                            self.dMan_details?.append(data)
                        }
                        recoudFound = true
                    } else {
                        DispatchQueue.main.async {
                            if let v = self.view.viewWithTag(60) {
                                v.isHidden = true
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    self.unFreezeScreen()
                    if !recoudFound {
                        self.noRecordFound.isHidden = false
                    }
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
                        self.booking_detail_tableview_height.constant = CGFloat(booking_detail.count * 980)
                        self.heightConstraint[0].constant += self.booking_detail_tableview_height.constant
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
                        self.heightConstraint[0].constant -= self.booking_detail_tableview_height.constant
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
                        self.deliver_detail_tableview_height.constant = CGFloat(delivery_detail.count * 380)
                        self.heightConstraint[1].constant += self.deliver_detail_tableview_height.constant
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
                        self.heightConstraint[1].constant -= self.deliver_detail_tableview_height.constant
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
                        self.heightConstraint[2].constant += self.pbag_detail_tableview_height.constant
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
                        self.heightConstraint[2].constant -= self.pbag_detail_tableview_height.constant
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
                        self.heightConstraint[3].constant += self.rbag_detail_tableview_height.constant
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
                        self.heightConstraint[3].constant -= self.rbag_detail_tableview_height.constant
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
                        self.tbag_detail_tableView_height.constant = CGFloat(tBag.count * 260)
                        self.heightConstraint[4].constant += self.tbag_detail_tableView_height.constant
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
                        self.heightConstraint[4].constant -= self.tbag_detail_tableView_height.constant
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
                        self.heightConstraint[5].constant += self.dman_detail_tableview_height.constant
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
                        self.heightConstraint[5].constant -= self.dman_detail_tableview_height.constant
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
            let bd = self.booking_details![indexPath.row]
            
            cell.cgsnNo.text = "-"
            if let data = bd.cnsgNo?.int {
                cell.cgsnNo.text = "\(data)"
            }
            if let data = bd.cnsgNo?.string {
                cell.cgsnNo.text = "\(data)"
            }
            
            cell.bookingdate.text = ""
            if let data = bd.bkgDAT?.int {
                cell.bookingdate.text = "\(data)"
            }
            if let data = bd.bkgDAT?.string {
                cell.bookingdate.text = "\(data)"
            }
            
            cell.pieces.text = "-"
            if let data = bd.noPcs?.int {
                cell.pieces.text = "\(data)"
            }
            if let data = bd.noPcs?.string {
                cell.pieces.text = "\(data)"
            }
            
            cell.origin.text = "-"
            if let data = bd.orgn?.int {
                cell.origin.text = "\(data)"
            }
            if let data = bd.orgn?.string {
                cell.origin.text = "\(data)"
            }
            
            cell.destination.text = "-"
            if let data = bd.dstn?.int {
                cell.destination.text = "\(data)"
            }
            if let data = bd.dstn?.string {
                cell.destination.text = "\(data)"
            }
            
            cell.route.text = "-"
            if let data = bd.route?.int {
                cell.route.text = "\(data)"
            }
            if let data = bd.route?.string {
                cell.route.text = "\(data)"
            }
            
            cell.services.text = "-"
            if let data = bd.service?.int {
                cell.services.text = "\(data)"
            }
            if let data = bd.service?.string {
                cell.services.text = "\(data)"
            }
            
            cell.product.text = "-"
            if let data = bd.product?.int {
                cell.product.text = "\(data)"
            }
            if let data = bd.product?.string {
                cell.product.text = "\(data)"
            }
            
            cell.bookingweight.text = "-"
            if let data = bd.wttBkg?.int {
                cell.bookingweight.text = "\(data)"
            }
            if let data = bd.wttBkg?.string {
                cell.bookingweight.text = "\(data)"
            }
            if let data = bd.wttBkg?.double {
                cell.bookingweight.text = "\(data)"
            }
            
            cell.handlingInstructions.text = "-"
            if let data = bd.hndlgInst?.int {
                cell.handlingInstructions.text = "\(data)"
            }
            if let data = bd.hndlgInst?.string {
                cell.handlingInstructions.text = "\(data)"
            }
            
            cell.codStatus.text = "-"
            if let data = bd.codStatus?.int {
                cell.codStatus.text = "\(data)"
            }
            if let data = bd.codStatus?.string {
                cell.codStatus.text = "\(data)"
            }
            
            
            cell.courierno.text = "-"
            if let data = bd.courier?.int {
                cell.courierno.text = "\(data)"
            }
            if let data = bd.courier?.string {
                cell.courierno.text = "\(data)"
            }
            
            
            cell.routeNo.text = "-"
            if let data = bd.route?.int {
                cell.routeNo.text = "\(data)"
            }
            if let data = bd.route?.string {
                cell.routeNo.text = "\(data)"
            }
            
            cell.callNo.text = "-"
            
            
            cell.customerNumber.text = "-"
            if let cusno = bd.cusNo?.int {
                cell.customerNumber.text = "\(cusno)"
            }
            if let cusno = bd.cusNo?.string {
                cell.customerNumber.text = "\(cusno)"
            }
            
            cell.customerName.text = "-"
            if let data = bd.cusNam?.int {
                cell.customerName.text = "\(data)"
            }
            if let data = bd.cusNam?.string {
                cell.customerName.text = "\(data)"
            }
            
            cell.customerAddress1.text = "-"
            if let data = bd.cusAddr1?.int {
                cell.customerAddress1.text = "\(data)"
            }
            if let data = bd.cusAddr1?.string {
                cell.customerAddress1.text = "\(data)"
            }
            
            cell.customerAddress2.text = "-"
            if let data = bd.cusAddr2?.int {
                cell.customerAddress2.text = "\(data)"
            }
            if let data = bd.cusAddr2?.string {
                cell.customerAddress2.text = "\(data)"
            }
            
            cell.customerAddress3.text = "-"
            if let data = bd.cusAddr3?.int {
                cell.customerAddress3.text = "\(data)"
            }
            if let data = bd.cusAddr3?.string {
                cell.customerAddress3.text = "\(data)"
            }
            
            cell.customerPhone.text = "-"
            if let cNSGEE_NAM = bd.cusPhn?.int {
                cell.customerPhone.text = "\(cNSGEE_NAM)"
            }
            if let cNSGEE_NAM = bd.cusPhn?.string {
                cell.customerPhone.text = "\(cNSGEE_NAM)"
            }
            
            cell.customerFax.text = "-"
            if let data = bd.cusFax?.int {
                cell.customerFax.text = "\(data)"
            }
            if let data = bd.cusFax?.string {
                cell.customerFax.text = "\(data)"
            }
            
            cell.consigneeName.text = "-"
            if let cNSGEE_NAM = bd.cnsgeeNam?.int {
                cell.consigneeName.text = "\(cNSGEE_NAM)"
            }
            if let cNSGEE_NAM = bd.cnsgeeNam?.string {
                cell.consigneeName.text = "\(cNSGEE_NAM)"
            }

            cell.consigneeAddress1.text = "-"
            if let data = bd.cnsgeeAddr1?.int {
                cell.consigneeAddress1.text = "\(data)"
            }
            if let data = bd.cnsgeeAddr1?.string {
                cell.consigneeAddress1.text = "\(data)"
            }
            
            cell.consigneeAddress2.text = "-"
            if let data = bd.cnsgeeAddr2?.int {
                cell.consigneeAddress2.text = "\(data)"
            }
            if let data = bd.cnsgeeAddr2?.string {
                cell.consigneeAddress2.text = "\(data)"
            }
            
            cell.consigneeAddress3.text = "-"
            if let data = bd.cnsgeeAddr3?.int {
                cell.consigneeAddress3.text = "\(data)"
            }
            if let data = bd.cnsgeeAddr3?.string {
                cell.consigneeAddress3.text = "\(data)"
            }
            
            cell.consigneeFax.text =  "-"
            if let cNSGEE_FAX = bd.cnsgeeFax?.int {
                cell.consigneeFax.text =  "\(cNSGEE_FAX)"
            }
            if let cNSGEE_FAX = bd.cnsgeeFax?.string {
                cell.consigneeFax.text =  "\(cNSGEE_FAX)"
            }
            
            cell.consigneePhone.text =  "-"
            if let cNSGEE_PHN = bd.cnsgeePhn?.int {
                cell.consigneePhone.text =  "\(cNSGEE_PHN)"
            }
            if let cNSGEE_PHN = bd.cnsgeePhn?.string {
                cell.consigneePhone.text =  "\(cNSGEE_PHN)"
            }
            
            cell.deliveryKPI.text = "-"
            if let data = bd.dlvryKpi?.int {
                cell.deliveryKPI.text = "\(data)"
            }
            if let data = bd.dlvryKpi?.string {
                cell.deliveryKPI.text = "\(data)"
            }
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryDetailsCell") as! DeliveryDetailsTableCell
            let data = self.delivery_details![indexPath.row]
            
            cell.sheetno.text = "-"
            if let detail = data.dlvryShtNo?.int {
                cell.sheetno.text = "\(detail)"
            }
            if let detail = data.dlvryShtNo?.string {
                cell.sheetno.text = "\(detail)"
            }
            
            cell.slot.text = "-"
            if let detail = data.slot?.int {
                cell.slot.text = "\(detail)"
            }
            if let detail = data.slot?.string {
                cell.slot.text = "\(detail)"
            }
            
            cell.route.text = "-"
            if let detail = data.route?.int {
                cell.route.text = "\(detail)"
            }
            if let detail = data.route?.string {
                cell.route.text = "\(detail)"
            }
            
            cell.courier.text = "-"
            if let detail = data.courier?.int {
                cell.courier.text = "\(detail)"
            }
            if let detail = data.courier?.string {
                cell.courier.text = "\(detail)"
            }
            
            cell.couriercell.text =  "-"
            if let detail = data.mobileNo?.int {
                cell.couriercell.text =  "\(detail)"
            }
            if let detail = data.mobileNo?.string {
                cell.couriercell.text =  "\(detail)"
            }
            
            cell.date.text = "-"
            if let detail = data.dlvryDAT?.int {
                cell.date.text = "\(detail)"
            }
            if let detail = data.dlvryDAT?.string {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ssZ"
                let date = dateFormatter.date(from: detail)
                dateFormatter.dateFormat = "dd-MMM-yyyy"
                let final = dateFormatter.string(from: date ?? Date())
                cell.date.text = final// "\(detail.dateOnly)"
            }
            
            cell.time.text = "-"
            if let detail = data.dlvTime?.int {
                cell.time.text = "\(detail)"
            }
            if let detail = data.dlvTime?.string {
                cell.time.text = "\(detail)"
            }
            
            cell.receivedBy.text = "-"
            if let detail = data.rcvdBy?.int {
                cell.receivedBy.text = "\(detail)"
            }
            if let detail = data.rcvdBy?.string {
                cell.receivedBy.text = "\(detail)"
            }
            
            cell.relation.text = "-"
            if let detail = data.rcvrRelation?.int {
                cell.relation.text = "\(detail)"
            }
            if let detail = data.rcvrRelation?.string {
                cell.relation.text = "\(detail)"
            }
            
            cell.status.text = "-"
            if let detail = data.dlvStat?.int {
                cell.status.text = "\(detail)"
            }
            if let detail = data.dlvStat?.string {
                cell.status.text = "\(detail)"
            }
            
            cell.pieces.text = "-"
            if let detail = data.noPcs?.int {
                cell.pieces.text = "\(detail)"
            }
            if let detail = data.noPcs?.string {
                cell.pieces.text = "\(detail)"
            }
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PBagDetailsCell") as! PBagDetailsTableViewCell
            let data = self.pBag_details![indexPath.row]
            
            cell.pBagManifest.text = "-"
            if let detail = data.manfest?.int {
                cell.pBagManifest.text = "\(detail)"
            }
            if let detail = data.manfest?.string {
                cell.pBagManifest.text = "\(detail)"
            }
            
            cell.transDate.text = "\(data.datee ?? "-")"
            if let detail = data.datee?.int {
                cell.transDate.text = "\(detail)"
            }
            if let detail = data.datee?.string {
                cell.transDate.text = "\(detail)"
            }
            
            cell.destination.text = "\(data.dstn ?? "-")"
            if let detail = data.dstn?.int {
                cell.destination.text = "\(detail)"
            }
            if let detail = data.dstn?.string {
                cell.destination.text = "\(detail)"
            }
            
            cell.pBagNo.text = "-"
            if let cNSGEE_PHN = data.barcodePbag?.int {
                cell.pBagNo.text =  "\(cNSGEE_PHN)"
            }
            if let cNSGEE_PHN = data.barcodePbag?.string {
                cell.pBagNo.text =  "\(cNSGEE_PHN)"
            }
            
            cell.mode.text = "-"
            if let detail = data.tMode?.int {
                cell.mode.text = "\(detail)"
            }
            if let detail = data.tMode?.string {
                cell.mode.text = "\(detail)"
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RBagDetailsCell") as! RBagDetailsTableCell
            let data = self.rBag_details![indexPath.row]
            
            cell.rBagManifest.text = "-"
            if let detail = data.rbag?.int {
                cell.rBagManifest.text = "\(detail)"
            }
            if let detail = data.rbag?.string {
                cell.rBagManifest.text = "\(detail)"
            }
            
            cell.destination.text = "-"
            if let detail = data.destn?.int {
                cell.destination.text = "\(detail)"
            }
            if let detail = data.destn?.string {
                cell.destination.text = "\(detail)"
            }
            
            cell.transdate.text = "-"
            if let detail = data.mdate?.int {
                cell.transdate.text = "\(detail)"
            }
            if let detail = data.mdate?.string {
                cell.transdate.text = "\(detail)"
            }
            
            cell.rBageNo.text = "-"
            if let detail = data.rbagNo?.int {
                cell.rBageNo.text = "\(detail)"
            }
            if let detail = data.rbagNo?.string {
                cell.rBageNo.text = "\(detail)"
            }
            
            cell.rbagSeal.text = "-"
            if let seal = data.seal?.int {
                cell.rbagSeal.text = "\(seal)"
            }
            if let seal = data.seal?.string {
                cell.rbagSeal.text = "\(seal)"
            }
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TBagDetailsCell") as! TBagDetailsTableCell
            let data = self.tBag_details![indexPath.row]
            
            cell.transitManifest.text = "\(data.trsitMnsftNo ?? "-")"
            if let seal = data.trsitMnsftNo?.int {
                cell.transitManifest.text = "\(seal)"
            }
            if let seal = data.trsitMnsftNo?.string {
                cell.transitManifest.text = "\(seal)"
            }
            
            cell.date.text = "\(data.datee ?? "-")"
            if let seal = data.datee?.int {
                cell.date.text = "\(seal)"
            }
            if let seal = data.datee?.string {
                cell.date.text = "\(seal)"
            }
            
            cell.origin.text = "\(data.orgn ?? "-")"
            if let seal = data.orgn?.int {
                cell.origin.text = "\(seal)"
            }
            if let seal = data.orgn?.string {
                cell.origin.text = "\(seal)"
            }
            
            cell.destination.text = "-"
            if let seal = data.dstn?.int {
                cell.destination.text = "\(seal)"
            }
            if let seal = data.dstn?.string {
                cell.destination.text = "\(seal)"
            }
            
            cell.courier.text = "\(data.courNam ?? "-")"
            if let seal = data.courNam?.int {
                cell.courier.text = "\(seal)"
            }
            if let seal = data.courNam?.string {
                cell.courier.text = "\(seal)"
            }
            
            cell.manifesttype.text = "\(data.trsptNo ?? "-")"
            if let seal = data.trsptNo?.int {
                cell.manifesttype.text = "\(seal)"
            }
            if let seal = data.trsptNo?.string {
                cell.manifesttype.text = "\(seal)"
            }
            
            cell.remarksflight.text = "-"
            if let seal = data.rmks?.int {
                cell.remarksflight.text = "\(seal)"
            }
            if let seal = data.rmks?.string {
                cell.remarksflight.text = "\(seal)"
            }
            
            cell.truck.text = "-"
            if let seal = data.trsptTypDetl?.int {
                cell.truck.text = "\(seal)"
            }
            if let seal = data.trsptTypDetl?.string {
                cell.truck.text = "\(seal)"
            }
            
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DManDetailsCell") as! DManDetailsTableCell
            let data = self.dMan_details![indexPath.row]
            cell.status.text = "\(data.status ?? "-")"
            cell.date.text = "\(data.dmnfst?.dateOnly ?? "-")"
            cell.time.text = "\(data.time ?? "-")"
            cell.hub.text = "\(data.dmnfstCode ?? "-")"
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "")
            return cell!
        }
    }
}
