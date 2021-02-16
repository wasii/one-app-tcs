//
//  TrackHomeViewController.swift
//  tcs_one_app
//
//  Created by TCS on 15/02/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import SwiftyJSON
import ExpandableCell

class TrackHomeViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var search_textfield: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var track: [Track]?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Track"
        self.makeTopCornersRounded(roundView: self.mainView)
        self.search_textfield.delegate = self
        
        self.search_textfield.text = "807011017073"
        
        self.tableView.register(UINib(nibName: "TrackerHeaderTableCell", bundle: nil), forCellReuseIdentifier: "TrackerHeaderCell")
        
        self.track = [Track]()
        self.track?.append(Track(name: "Booking Detail", isCollapsable: true, data: nil))
        self.track?.append(Track(name: "Delivery Detail", isCollapsable: true, data: nil))
        self.track?.append(Track(name: "PBag Detail", isCollapsable: true, data: nil))
        self.track?.append(Track(name: "RBag Detail", isCollapsable: true, data: nil))
        self.track?.append(Track(name: "TBag Detail", isCollapsable: true, data: nil))
        self.track?.append(Track(name: "DMan Detail", isCollapsable: true, data: nil))
        
        
        
    }
    @IBAction func trackBtnTapped(_ sender: Any) {
        dismissKeyboard()
        if search_textfield.text == "" {
            self.view.makeToast("Tracking number is mandatory")
            return
        }
        if !CustomReachability.isConnectedNetwork() {
            self.view.makeToast(NOINTERNETCONNECTION)
            return
        }
        
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
                if let details = JSON(response).array?.first {
                    var booking_detail = [BookingDetail]()
                    var delivery_detail = [DeliveryDetail]()
                    var rbag_detail = [RbagDetail]()
                    var pbag_detail = [PbagDetail]()
                    var tbag_detail = [TbagDetail]()
                    var dman_detail = [DmanDetail]()
                    if let bd = details.dictionary?["BOOKING_DETAIL"]?.array {
                        for index in bd {
                            do {
                                let data = try index.rawData()
                                booking_detail.append(try JSONDecoder().decode(BookingDetail.self, from: data))
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
//                    self.track?.append(Track(name: "Booking Detail", isCollapsable: true,d
                    self.track?.append(Track(name: "Booking Detail", isCollapsable: true, data: booking_detail))
                    if let dd = details.dictionary?["DELIVERY_DETAIL"]?.array {
                        for index in dd {
                            do {
                                let data = try index.rawData()
                                delivery_detail.append(try JSONDecoder().decode(DeliveryDetail.self, from: data))
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
                    self.track?.append(Track(name: "Delivery Detail", isCollapsable: true, data: delivery_detail))
                    if let pbd = details.dictionary?["PBAG_DETAIL"]?.array {
                        for index in pbd {
                            do {
                                let data = try index.rawData()
                                pbag_detail.append(try JSONDecoder().decode(PbagDetail.self, from: data))
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
                    self.track?.append(Track(name: "PBag Detail", isCollapsable: true, data: pbag_detail))
                    if let rbd = details.dictionary?["RBAG_DETAIL"]?.array {
                        for index in rbd {
                            do {
                                let data = try index.rawData()
                                rbag_detail.append(try JSONDecoder().decode(RbagDetail.self, from: data))
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
                    self.track?.append(Track(name: "RBag Detail", isCollapsable: true, data: rbag_detail))
                    if let tbd = details.dictionary?["TBAG_DETAIL"]?.array {
                        for index in tbd {
                            do {
                                let data = try index.rawData()
                                tbag_detail.append(try JSONDecoder().decode(TbagDetail.self, from: data))
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
                    self.track?.append(Track(name: "TBag Detail", isCollapsable: true, data: tbag_detail))
                    if let dmd = details.dictionary?["DMAN_DETAIL"]?.array {
                        for index in dmd {
                            do {
                                let data = try index.rawData()
                                dman_detail.append(try JSONDecoder().decode(DmanDetail.self, from: data))
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
                    self.track?.append(Track(name: "DMan Detail", isCollapsable: true, data: dman_detail))
                }
            } else {
                
            }
            self.tableView.reloadData()
        }
    }
}

extension TrackHomeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let count = track?.count {
            return count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                if let bd = track?[section].data as? [BookingDetail] {
                    return track![section].isCollapsable ? 0 : bd.count
                }
                return 0
            case 1:
                if let bd = track?[section].data as? [DeliveryDetail] {
                    return track![section].isCollapsable ? 0 : bd.count
                }
                return 0
            case 2:
                if let bd = track?[section].data as? [PbagDetail] {
                    return track![section].isCollapsable ? 0 : bd.count
                }
                return 0
            case 3:
                if let bd = track?[section].data as? [RbagDetail] {
                    return track![section].isCollapsable ? 0 : bd.count
                }
                return 0
            case 4:
                if let bd = track?[section].data as? [TbagDetail] {
                    return track![section].isCollapsable ? 0 : bd.count
                }
                return 0
            case 5:
                if let bd = track?[section].data as? [DmanDetail] {
                    return track![section].isCollapsable ? 0 : bd.count
                }
                return 0
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TrackerHeaderCell") as? TrackHeaderView ?? TrackerHeaderTableCell(reuseIdentifier: "TrackerHeaderCell")
        
        header.titleLabel.text = track![section].name
        
        header.setCollapsed(track![section].isCollapsable)
        
        header.section = section
        header.delegate = self
        
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        switch indexPath.section {
//        case 0:
//            <#code#>
//        default:
//            <#code#>
//        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "")
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
}

extension TrackHomeViewController: TableViewHeaderDelegate {
    
    func toggleSection(_ header: TrackHeaderView, section: Int) {
        let collapsed = !track![section].isCollapsable
        
        // Toggle collapse
        track![section].isCollapsable = collapsed
        header.setCollapsed(collapsed)
        
        tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
    }
    
}
extension TrackHomeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 12
        let currentString: NSString = textField.text as! NSString
        let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length <= maxLength {
            return true
        }
        return false
    }
}






protocol TableViewHeaderDelegate {
    func toggleSection(_ header: TrackHeaderView, section: Int)
}
