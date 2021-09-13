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
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    var mis_budget_setup: tbl_mis_budget_setup?
    var mis_popup_mnth: MISPopupMonth?
    var mis_popop_year: MISPopupYear?
    
    var monthName: String = ""
    var year: String = ""
    
    
    var tableSection: Int?
    var tableRow: Int?
    
    var collectionSection: Int?
    var collectionRow: Int?
    
    var budget_data: [tbl_mis_budget_data_details]?
    var isDualValue: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeTopCornersRounded(roundView: self.mainView)
        title = "MIS"
        if let product = mis_budget_setup?.product {
            headingLabel.text = product
        }
        collectionView.register(UINib(nibName: MISCollectionCell.description(), bundle: nil), forCellWithReuseIdentifier: MISCollectionCell.description())
        tableView.register(UINib(nibName: MISDetailTableCell.description(), bundle: nil), forCellReuseIdentifier: MISDetailTableCell.description())
        tableView.register(UINib(nibName: "MISHeaderCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "MISHeaderCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 30
        self.freezeScreen()
        self.view.makeToastActivity(.center)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tableRow = 5
            self.tableSection = 1
            
            self.unFreezeScreen()
            self.view.hideToastActivity()
            self.tableView.reloadData()
            self.setupJSON { count in
                self.collectionView.reloadData()
                if count > 7 {
                    self.collectionViewHeightConstraint.constant = CGFloat(30 * count) + 30
                }
            }
            
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
    
    private func setupJSON(_ handler: @escaping(Int)->Void) {
        
        var query = ""
        if isDualValue {
            query = "SELECT PERMISSION.IS_DSR_SHOW, PERMISSION.IS_QSR_SHOW, PERMISSION.IS_SHIP_SHOW, PERMISSION.IS_WEIGHT_SHOW, group_concat(TYPE, '*') AS ALL_TYPE , GROUP_CONCAT(SHIP, '*') AS ALL_SHIP , GROUP_CONCAT(DSR, '*') AS ALL_DSR , GROUP_CONCAT(QSR, '*') AS ALL_QSR, GROUP_CONCAT(WEIGHT, '*') AS ALL_WEIGHT, AVG(DSR) AS DSR, PRODUCT, AVG(QSR) AS QSR , RPT_DATE, SUM(SHIP) AS SHIP, TYPE , SUM(WEIGHT) AS WEIGHT FROM (SELECT * FROM MIS_BUDGET_DATA WHERE PRODUCT = '\(mis_budget_setup?.product ?? "")' AND (RPT_DATE BETWEEN '2021-01-01' AND '2021-01-31') ORDER BY RPT_DATE,TYPE DESC), (SELECT AVG(DSR) > 0.0 AS IS_DSR_SHOW, AVG(QSR) > 0.0 AS IS_QSR_SHOW, SUM(SHIP) > 0 AS IS_SHIP_SHOW, SUM(WEIGHT) > 0.0 AS IS_WEIGHT_SHOW FROM MIS_BUDGET_DATA WHERE PRODUCT = '\(mis_budget_setup?.product ?? "")' AND (RPT_DATE BETWEEN '2021-01-01' AND '2021-01-31') GROUP BY PRODUCT) AS PERMISSION GROUP BY RPT_DATE"
        } else {
            query = "SELECT PERMISSION.IS_DSR_SHOW, PERMISSION.IS_QSR_SHOW, PERMISSION.IS_SHIP_SHOW, PERMISSION.IS_WEIGHT_SHOW, '' AS ALL_TYPE , '' AS ALL_SHIP , '' AS ALL_DSR , '' AS ALL_QSR, '' AS ALL_WEIGHT, AVG(DSR) AS DSR, PRODUCT, AVG(QSR) AS QSR , RPT_DATE, SUM(SHIP) AS SHIP, TYPE , SUM(WEIGHT) AS WEIGHT FROM (SELECT * FROM MIS_BUDGET_DATA WHERE PRODUCT = '\(mis_budget_setup?.product ?? "")' AND (RPT_DATE BETWEEN '2021-01-01' AND '2021-01-31') ORDER BY RPT_DATE,TYPE DESC), (SELECT AVG(DSR) > 0.0 AS IS_DSR_SHOW, AVG(QSR) > 0.0 AS IS_QSR_SHOW, SUM(SHIP) > 0 AS IS_SHIP_SHOW, SUM(WEIGHT) > 0.0 AS IS_WEIGHT_SHOW FROM MIS_BUDGET_DATA WHERE PRODUCT = '\(mis_budget_setup?.product ?? "")' AND (RPT_DATE BETWEEN '2021-01-01' AND '2021-01-31') GROUP BY PRODUCT) AS PERMISSION GROUP BY RPT_DATE"
        }
        
        if let budget_data = AppDelegate.sharedInstance.db?.read_tbl_mis_budget_data_detail(query: query) {
            
            var dsrTypeName = ""
            var qsrTypeName = ""
            var weightTypeName = ""
            
            if isDualValue {
                let splitType = budget_data[0].ALL_TYPE.split(separator: "*")
                for (index, data) in splitType.enumerated() {
                    if (splitType.count - 1 == index) {
                        dsrTypeName += "\(data) DSR"
                        qsrTypeName += "\(data) QSR"
                        weightTypeName += "\(data) Weight"
                    } else {
                        dsrTypeName += "\(data) DSR*"
                        qsrTypeName += "\(data) QSR*"
                        weightTypeName += "\(data) Weight*"
                    }
                }
            }
            
            let headingObject: tbl_mis_budget_data_details = tbl_mis_budget_data_details(IS_DSR_SHOW: budget_data[0].IS_DSR_SHOW, IS_QSR_SHOW: budget_data[0].IS_QSR_SHOW, IS_SHIP_SHOW: budget_data[0].IS_SHIP_SHOW, IS_WEIGHT_SHOW: budget_data[0].IS_WEIGHT_SHOW, ALL_TYPE: "", ALL_SHIP: budget_data[0].ALL_TYPE, ALL_DSR: dsrTypeName, ALL_QSR: qsrTypeName, ALL_WEIGHT: weightTypeName, DSR: "DSR Total", PRODUCT: "", QSR: "QSR Total", RPT_DATE: "Date", SHIP: "Total", TYPE: "", WEIGHT: "Total Weight")
            self.budget_data = [tbl_mis_budget_data_details]()
            self.budget_data = budget_data
            self.budget_data!.insert(headingObject, at: 0)
            handler(budget_data.count)
        }
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

extension MISDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = self.budget_data?.count {
            return count
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MISCollectionCell.description(), for: indexPath) as? MISCollectionCell else {
            fatalError()
        }
        let data = self.budget_data![indexPath.row]
        cell.indexPath = indexPath.row
        
        cell.tbl_mis_budget_data_detail = data
        cell.isDualValue = self.isDualValue
        cell.setupCell()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
    }
}

extension MISDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let count = self.tableSection {
            return count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.tableRow {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MISDetailTableCell.description()) as? MISDetailTableCell else {
            fatalError()
        }
        cell.dateView.isHidden = true
        cell.shipmentBookedLabel.text = "S B"
        cell.weightLabel.text = "B"
        cell.qsrLabel.text = "A"
        cell.dsrLabel.text = "V"
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

