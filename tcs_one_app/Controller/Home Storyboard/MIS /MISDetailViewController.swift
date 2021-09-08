//
//  MISDetailViewController.swift
//  tcs_one_app
//
//  Created by TCS on 07/09/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class MISDetailViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    var mis_budget_setup: tbl_mis_budget_setup?
    var mis_popup_mnth: MISPopupMonth?
    var mis_popop_year: MISPopupYear?
    
    var monthName: String = ""
    var year: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeTopCornersRounded(roundView: self.mainView)
        title = "MIS"
        if let product = mis_budget_setup?.product {
            headingLabel.text = product
        }
        tableView.register(UINib(nibName: MISDetailTableCell.description(), bundle: nil), forCellReuseIdentifier: MISDetailTableCell.description())
        tableView.register(UINib(nibName: "MISHeaderCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "MISHeaderCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 30
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.tableViewHeightConstraint.constant = (30 * 5) + 40
        }
        
        let df = DateFormatter()
        df.dateFormat = "MMMM"
        monthName = df.string(from: Date())
        df.dateFormat = "yyyy"
        year = df.string(from: Date())
        
        self.monthLabel.text = monthName
        self.yearLabel.text = year
    }
    
    @IBAction func selectionBtnTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Popups", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestListingViewController") as! NewRequestListingViewController
        if sender.tag == 0 {
            controller.mis_popop_year = AppDelegate.sharedInstance.db?.read_tbl_mis_budget_setup_year()
            controller.heading = "Select Year"
        } else {
            controller.mis_popup_mnth = AppDelegate.sharedInstance.db?.read_tbl_mis_budget_setup_month()
            controller.heading = "Select Month"
        }
        
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        controller.modalTransitionStyle = .crossDissolve
        controller.misdelegate = self
        Helper.topMostController().present(controller, animated: true, completion: nil)
    }
}

extension MISDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MISDetailTableCell.description()) as? MISDetailTableCell else {
            fatalError()
        }
        cell.dateView.isHidden = true
        cell.shipmentBookedLabel.text = "Shipment Booked"
        cell.weightLabel.text = "Budgeted"
        cell.qsrLabel.text = "Actual"
        cell.dsrLabel.text = "Variance"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MISHeaderCell") as! MISHeaderCell
        if let dateView = headerCell.viewWithTag(1) as? CustomView {
            dateView.isHidden = true
        }
        if let shipmentLabel = headerCell.viewWithTag(20) as? UILabel {
            shipmentLabel.text = ""
        }
        if let budgeted = headerCell.viewWithTag(30) as? UILabel {
            budgeted.text = "Budgeted"
        }
        if let actual = headerCell.viewWithTag(40) as? UILabel {
            actual.text = "Actual"
        }
        if let variance = headerCell.viewWithTag(50) as? UILabel {
            variance.text = "Variance"
        }
        
        return headerCell
    }
}
extension MISDetailViewController: MISDelegate {
    func updateListing(region_date: tbl_mis_region_data) {}
    
    func updateMonth(mnth: MISPopupMonth) {
        self.monthLabel.text = mnth.mnth
    }
    
    func updateYearr(year: MISPopupYear) {
        self.yearLabel.text = year.yearr
    }
}

