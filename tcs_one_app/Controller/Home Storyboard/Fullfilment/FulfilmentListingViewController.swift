//
//  FulfilmentListingViewController.swift
//  tcs_one_app
//
//  Created by TCS on 25/03/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class FulfilmentListingViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var search_textfileld: UITextField!
    @IBOutlet weak var sorting_btn: UIButton!
    @IBOutlet weak var this_week: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var ticket_status: String = ""
    var ticket_status_sorting: String = ""
    var numberOfDays: String = ""
    var numberOfDaysSorting: String = ""
    var start_day: String = ""
    var end_day: String = ""
    
    var indexPath: IndexPath?
    
    var fulfilment_orders: [tbl_fulfilments_order]?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Fulfillment"
        addDoubleNavigationButtons()
        self.makeTopCornersRounded(roundView: self.mainView)
        tableView.register(UINib(nibName: "FulfilmentListingTableCell", bundle: nil), forCellReuseIdentifier: "FulfilmentListingCell")
        tableView.rowHeight = 85
        search_textfileld.delegate = self
        
        self.sorting_btn.setTitle(ticket_status, for: .normal)
        self.this_week.text = numberOfDaysSorting
    }
    @IBAction func sorting_btn_tapped(_ sender: Any) {
    }
    @IBAction func this_week_tapped(_ sender: Any) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = indexPath {
            self.tableView.deselectRow(at: indexPath!, animated: true)
        }
        setupJSON()
    }
    
    func setupJSON() {
        var query = ""
//        var numberOfOrders = 0
        
        let orderIdQuery = "SELECT DISTINCT ORDER_ID FROM FULFILMENT_ORDERS WHERE CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
        
        if let ids = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orderId(query: orderIdQuery) {
            var temp_data = [tbl_fulfilments_order]()
            for id in ids {
                if start_day == "" && end_day == "" {
                    let previousDate = getPreviousDays(days: -Int(numberOfDays)!)
                    let weekly = previousDate.convertDateToString(date: previousDate)
                    
                    query = "SELECT * FROM \(db_fulfilment_orders) WHERE CREATE_AT >= '\(weekly)' AND CREATE_AT <= '\(getLocalCurrentDate())' AND ORDER_ID = '\(id)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
                } else {
                    query = "SELECT * FROM \(db_fulfilment_orders) WHERE CREATE_AT >= '\(start_day)' AND CREATE_AT <= '\(end_day)' AND ORDER_ID = '\(id)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
                }
                let orders = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orders(query: query)
                var p = 0
                var r = 0
                let count = orders?.count
                for order in orders! {
                    switch order.ITEM_STATUS {
                    case "Pending":
                        p += 1
                    case "Received":
                        r += 1
                        break
                    default:
                        break
                    }
                }
                if p == count {
                    if ticket_status == "Pending" {
                        if let o = orders?.first {
                            temp_data.append(o)
                        }
                    }
                } else if r == count {
                    if ticket_status == "Ready to Deliver" {
                        if let o = orders?.first {
                            temp_data.append(o)
                        }
                    }
                } else {
                    if ticket_status != "Pending" && ticket_status != "Ready to Deliver" {
                        if let o = orders?.first {
                            temp_data.append(o)
                        }
                    }
                }
            }
            self.fulfilment_orders = temp_data
        } else {
            self.fulfilment_orders = nil
        }
        
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.setupTableViewHeight()
        }
    }
    
    func setupTableViewHeight() {
        var height: CGFloat = 0.0
        if let count = self.fulfilment_orders?.count {
            height = CGFloat((count * 85) + 150)
        }
        self.mainViewHeightConstraint.constant = 280
        switch UIDevice().type {
        case .iPhone5, .iPhone5S, .iPhone5C, .iPhoneSE:
            if height > 570 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 570
            }
            break
        case .iPhone6, .iPhone6S, .iPhone7, .iPhone8:
            if height > 670 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 670
            }
        case .iPhone6Plus, .iPhone7Plus, .iPhone8Plus:
            if height > 740 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 740
            }
            break
        case .iPhoneX, .iPhoneXR, .iPhoneXS, .iPhone11Pro, .iPhone12, .iPhone12Pro:
            if height > 790 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 790
            }
        case .iPhone11, .iPhoneXSMax, .iPhone11ProMax:
            if height > 840 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 840
            }
            break
        case .iPhone12ProMax:
            if height > 880 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 880
            }
            break
        case .iPhone12Mini:
            if height > 770 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 770
            }
        default:
            break
        }
    }
}

extension FulfilmentListingViewController: UITextFieldDelegate {
    
}

extension FulfilmentListingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.fulfilment_orders?.count {
            return count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FulfilmentListingCell") as! FulfilmentListingTableCell
        let data = self.fulfilment_orders![indexPath.row]
        
        cell.orderId.text = "\(data.ORDER_ID)"
        cell.date.text = data.CREATE_AT.dateSeperateWithT
        cell.status.text = ticket_status
        switch ticket_status {
        case "Pending":
            
            cell.status.textColor = UIColor.pendingColor()
            break
        case "In Process":
            cell.status.textColor = UIColor.inprocessColor()
            break
        case "Ready to Deliver":
            cell.status.textColor = UIColor.approvedColor()
            break
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.indexPath = indexPath
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "FulfilmentOrderDetailViewController") as! FulfilmentOrderDetailViewController
        controller.orderId = self.fulfilment_orders![indexPath.row].ORDER_ID
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
