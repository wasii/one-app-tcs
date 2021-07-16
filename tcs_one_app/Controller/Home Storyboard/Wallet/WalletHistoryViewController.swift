//
//  WalletHistoryViewController.swift
//  tcs_one_app
//
//  Created by TCS on 17/06/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class WalletHistoryViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lifeEarningLabel: UILabel!
    @IBOutlet weak var lifeRebursementLabel: UILabel!
    @IBOutlet weak var thisWeekBtn: UIButton!
    
    //MARK: Variables
    var fileDownloadedURL : URL?
    var selected_query: String?
    var numberOfDays = 7
    
    var indexPath: IndexPath?
    var startday: String?
    var endday: String?
    
    var tbl_history_points: [tbl_wallet_history_point]?
    var dateFormat = DateFormatter()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallet"
        addDoubleNavigationButtons()
        self.makeTopCornersRounded(roundView: self.mainView)
        
        self.tableView.register(UINib(nibName: WalletHistoryTableCell.description(), bundle: nil), forCellReuseIdentifier: WalletHistoryTableCell.description())
        self.tableView.rowHeight = 160
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        if self.selected_query == "Custom Selection" {
            self.thisWeekBtn.setTitle("\(startday!) TO \(endday!)", for: .normal)
        } else {
            self.thisWeekBtn.setTitle(selected_query!, for: .normal)
        }
        
        if let data = AppDelegate.sharedInstance.db?.read_tbl_wallet_point_summary(query: "SELECT * FROM \(db_w_pointSummary) WHERE EMPLOYEE_ID = '\(CURRENT_USER_LOGGED_IN_ID)'") {
            
            var earning = 0
            var reimburse = 0
            for d in data {
                earning += d.NET_REDEEMABLE
                reimburse += d.REDEEM_POINTS
            }
            
            self.lifeEarningLabel.text = "\(earning)"
            self.lifeRebursementLabel.text = "\(reimburse)"
        }
        dateFormat.dateFormat = "yyyy-MM-dd"
    }
    
    private func setupJSON(numberOfDays: Int, startday: String?, endday: String?) {
        var previousDate = Date()// getPreviousDays(days: -numberOfDays)
        var weekly = String()
        var query = ""
        
        self.tbl_history_points = AppDelegate.sharedInstance.db?.read_tbl_wallet_history_point(query: "")
        
        
        if startday == nil && endday == nil {
            previousDate = getPreviousDays(days: -numberOfDays)
            weekly = previousDate.convertDateToString(date: previousDate)
            
            query = "SELECT * FROM \(db_w_history_point) WHERE CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' AND (REDEMPTION_DATIME BETWEEN '\(weekly)' AND '\(getLocalCurrentDate())')"
            
        } else {
            query = "SELECT * FROM \(db_w_history_point) WHERE CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' AND (REDEMPTION_DATIME BETWEEN '\(startday!)' AND '\(endday!)')"
            
            self.thisWeekBtn.setTitle("\(startday!.dateOnly) TO \(endday!.dateOnly)", for: .normal)
        }
        print(query)
        self.tbl_history_points = AppDelegate.sharedInstance.db?.read_tbl_wallet_history_point(query: query)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(upload_pending_request), name: .networkRefreshed, object: nil)
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
        setupJSON(numberOfDays: self.numberOfDays, startday: self.startday, endday: self.endday)
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
        self.setupJSON(numberOfDays: numberOfDays, startday: startday, endday: endday)
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    @IBAction func thisWeekBtnTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Popups", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "FilterDataPopupViewController") as! FilterDataPopupViewController
        
        if self.selected_query == "Custom Selection" {
            controller.fromdate = self.startday
            controller.todate   = self.endday
        }
        controller.selected_query = self.selected_query
        controller.delegate = self
        controller.modalTransitionStyle = .crossDissolve
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        
        Helper.topMostController().present(controller, animated: true, completion: nil)
    }
}


extension WalletHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.tbl_history_points?.count {
            return count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WalletHistoryTableCell.description()) as? WalletHistoryTableCell else {
            fatalError()
        }
        let data = self.tbl_history_points![indexPath.row]
        cell.categoryLabel.text = data.DESCRIPTION
        let tempdate = dateFormat.date(from: data.REDEMPTION_DATIME.dateOnly)
        dateFormat.dateFormat = "dd/MM/yyyy"
        let finalDate = dateFormat.string(from: tempdate ?? Date())
        cell.dateLabel.text = finalDate
        cell.pointLabel.text = "\(data.REDEMPTION_POINTS)"
        cell.idLabel.text = "ID: \(data.RID)"
        return cell
    }
}

extension WalletHistoryViewController: DateSelectionDelegate {
    func dateSelection(numberOfDays: Int, selected_query: String) {
        self.selected_query = selected_query
        self.thisWeekBtn.setTitle(selected_query, for: .normal)
        
        self.startday = nil
        self.endday = nil
        
        self.numberOfDays = numberOfDays
        self.setupJSON(numberOfDays: numberOfDays,  startday: startday, endday: endday)
    }
    
    func dateSelection(startDate: String, endDate: String, selected_query: String) {
        self.selected_query = selected_query
        self.thisWeekBtn.setTitle(selected_query, for: .normal)
        
        self.startday = startDate
        self.endday   = endDate
        
        self.setupJSON(numberOfDays: 0, startday: startDate, endday: endDate)
    }
    
    func requestModeSelected(selected_query: String) {}
}
