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
    @IBOutlet weak var sorting_btn: UILabel!
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
    var temp_data: [tbl_fulfilments_order]?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Fulfilment"
        addDoubleNavigationButtons()
        self.makeTopCornersRounded(roundView: self.mainView)
        tableView.register(UINib(nibName: "FulfilmentListingTableCell", bundle: nil), forCellReuseIdentifier: "FulfilmentListingCell")
        tableView.rowHeight = 85
        search_textfileld.delegate = self
        
//        self.sorting_btn.setTitle(ticket_status, for: .normal)
        self.sorting_btn.text = ticket_status
        self.this_week.text = numberOfDaysSorting
        
        if ticket_status == "Pending" {
            self.tableView.isUserInteractionEnabled = false
        } else {
            self.tableView.isUserInteractionEnabled = true
        }
    }
    @IBAction func sorting_btn_tapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Popups", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "RequestModePopupViewController") as! RequestModePopupViewController
        
        controller.isFulfillment = true
        controller.selected_option = self.ticket_status
        controller.delegate = self
        controller.modalTransitionStyle = .crossDissolve
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        
        Helper.topMostController().present(controller, animated: true, completion: nil)
    }
    @IBAction func this_week_tapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Popups", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "FilterDataPopupViewController") as! FilterDataPopupViewController
        
        if self.numberOfDaysSorting == "Custom Selection" {
            controller.fromdate = self.start_day
            controller.todate   = self.end_day
        }
        controller.selected_query = self.numberOfDaysSorting
        if self.numberOfDaysSorting == "This Week" {
            controller.selected_query = "Weekly"
        }
        
        controller.delegate = self
        controller.modalTransitionStyle = .crossDissolve
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        
        Helper.topMostController().present(controller, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshedView(notification:)), name: .refreshedViews, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigateThroughtNotify(notification:)), name: .navigateThroughNotification, object: nil)
        self.navigationItem.rightBarButtonItems = nil
        addDoubleNavigationButtons()
        
        if let btn = self.navigationItem.rightBarButtonItems?.first {
            let count = getNotificationCounts()
            if count > 0 {
                btn.addBadge(num: count)
            } else {
                btn.removeBadge()
            }
        }
        if let _ = indexPath {
            self.tableView.deselectRow(at: indexPath!, animated: true)
        }
        setupJSON()
        if ticket_status == "Pending" {
            self.tableView.isUserInteractionEnabled = false
        } else {
            self.tableView.isUserInteractionEnabled = true
        }
    }
    @objc func refreshedView(notification: Notification) {
        self.navigationItem.rightBarButtonItems = nil
        addDoubleNavigationButtons()
        
        
        if let btn = self.navigationItem.rightBarButtonItems?.first {
            let count = getNotificationCounts()
            if count > 0 {
                btn.addBadge(num: count)
            } else {
                btn.removeBadge()
            }
        }
        self.setupJSON()
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupJSON() {
        var query = ""
        var orderIdQuery = ""
        if start_day == "" && end_day == "" {
            let previousDate = getPreviousDays(days: -Int(numberOfDays)!)
            let weekly = previousDate.convertDateToString(date: previousDate)
            orderIdQuery = "SELECT DISTINCT ORDER_ID FROM \(db_fulfilment_orders) WHERE CREATE_AT >= '\(weekly)' AND CREATE_AT <= '\(getLocalCurrentDate())' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
        } else {
            orderIdQuery = "SELECT DISTINCT ORDER_ID FROM \(db_fulfilment_orders) WHERE CREATE_AT >= '\(start_day)' AND CREATE_AT <= '\(end_day)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
        }
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
            temp_data = temp_data.sorted(by: { (logs, logs2) -> Bool in
                logs.UPDATED_AT > logs2.UPDATED_AT
            })
            self.fulfilment_orders = temp_data
            self.temp_data = temp_data
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
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        searchQueryTimer?.invalidate()
        
        let currentText = textField.text ?? ""
        print(currentText)
        
        if (currentText as NSString).replacingCharacters(in: range, with: string).count == 0 {
            
            self.fulfilment_orders = temp_data
            
            self.tableView.reloadData()
            self.setupTableViewHeight()
            return true
        }
        if (currentText as NSString).replacingCharacters(in: range, with: string).count >= 3 {
            searchQueryTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(performSearch), userInfo: nil, repeats: false)
        }
        return true
    }
    @objc func performSearch() {
        
        self.fulfilment_orders = self.fulfilment_orders?.filter({ (logs) -> Bool in
            return (logs.ORDER_ID.lowercased().contains(self.search_textfileld.text?.lowercased() ?? "")) ||
                (String(logs.CNSG_NO).contains(self.search_textfileld.text?.lowercased() ?? ""))
        })
        
        self.tableView.reloadData()
        self.setupTableViewHeight()
    }
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
        cell.date.text = data.CREATE_AT.dateSeperateWithT.replacingOccurrences(of: "Z", with: "")
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



//MARK: DateSelection Delegate
extension FulfilmentListingViewController: DateSelectionDelegate {
    func dateSelection(numberOfDays: Int, selected_query: String) {
        self.numberOfDaysSorting = selected_query
        self.this_week.text = selected_query
        
        
        self.start_day = ""
        self.end_day = ""
        
        self.numberOfDays = "\(numberOfDays)"
        self.setupJSON()
    }
    
    func dateSelection(startDate: String, endDate: String, selected_query: String) {
        self.numberOfDaysSorting = selected_query
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss"
        let sDate = dateFormatter.date(from: startDate)
        let eDate = dateFormatter.date(from: endDate)
        
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        let sDateS = dateFormatter.string(from: sDate ?? Date())
        let eDateS = dateFormatter.string(from: eDate ?? Date())
        
        self.this_week.text = "\(sDateS) TO \(eDateS)"
        self.start_day = startDate
        self.end_day   = endDate
        
        self.numberOfDays = "0"
        self.setupJSON()
    }
    
    func requestModeSelected(selected_query: String) {
        self.ticket_status = selected_query
//        self.sorting_btn.setTitle(ticket_status, for: .normal)
        self.sorting_btn.text = ticket_status
        if selected_query == "Pending" {
            ticket_status_sorting = "Pending"
        } else if selected_query == "In Process" {
            ticket_status_sorting = "Received"
        } else {
            ticket_status_sorting = ""
        }
        
        self.setupJSON()
    }
}
