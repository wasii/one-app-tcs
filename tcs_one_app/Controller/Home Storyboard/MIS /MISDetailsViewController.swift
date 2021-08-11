//
//  MISDetailsViewController.swift
//  tcs_one_app
//
//  Created by TCS on 11/08/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class MISDetailsViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainHeading: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var isOverload: Bool = false
    var daily_overview: [tbl_mis_daily_overview]?
    
    var isWieghtAllowed: Int = 0
    var isQSRAllowed: Int = 0
    var isDSRAllowed: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "MIS"
        self.tableViewHeightConstraint.constant = 0
        
        isWieghtAllowed = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: PERMISSION_MIS_WEIGHT)
        isDSRAllowed = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: PERMISSION_MIS_DSR)
        isQSRAllowed = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: PERMISSION_MIS_QSR)
        
        tableView.register(UINib(nibName: MISDetailTableCell.description(), bundle: nil), forCellReuseIdentifier: MISDetailTableCell.description())
        tableView.delegate = self
        tableView.dataSource = self
        self.view.makeToastActivity(.center)
        tableView.rowHeight = 30
        if isOverload {
            self.mainHeading.text = "Overland Trend"
        }
        self.makeTopCornersRounded(roundView: self.mainView)
        setupDailyOverview(region: nil)
    }
    
    private func setupDailyOverview(region: String?) {
        var query = ""
        if isOverload {
            query = "SELECT * FROM \(db_mis_daily_overview) WHERE PRODUCT = 'Overland'"
        } else {
            query = "SELECT * FROM \(db_mis_daily_overview) WHERE PRODUCT = 'General & Banking'"
        }
        if let r = region {
            query += r
        }
        daily_overview = AppDelegate.sharedInstance.db?.read_tbl_mis_daily_overview(query: query)
        
        DispatchQueue.main.async {
            if let count = self.daily_overview?.count {
                self.tableViewHeightConstraint.constant = CGFloat(count * 30)
                self.view.hideToastActivity()
            }
        }
    }
}

extension MISDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.daily_overview?.count {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MISDetailTableCell.description()) as? MISDetailTableCell else {
            fatalError()
        }
        cell.weightView.isHidden = true
        if indexPath.row == 0 {
            cell.dateLabel.font = UIFont.boldSystemFont(ofSize: 12)
            print(cell.dateLabel.frame.width)
        } else {
            
            cell.dateLabel.font = UIFont.systemFont(ofSize: 10)
            cell.shipmentBookedLabel.font = UIFont.systemFont(ofSize: 10)
            cell.qsrLabel.font = UIFont.systemFont(ofSize: 10)
            cell.dsrLabel.font = UIFont.systemFont(ofSize: 10)
            
            cell.dateLabel.text = "2021-08-11"
            
            cell.shipmentBookedLabel.text = "190,562"
            cell.qsrLabel.text = "88.32"
            cell.dsrLabel.text = "88.32"
        }
        return cell
    }
}
