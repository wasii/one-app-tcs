//
//  ChartViews.swift
//  tcs_one_app
//
//  Created by TCS on 08/12/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import Charts

class ChartViews: UIView {

    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var progressBarView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    
    
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var misYearlyAverage: UILabel!
    @IBOutlet weak var lineChartBtn: UIButton!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var mis_dashboard_detail_graph: [tbl_mis_dashboard_detail_graph]?
    var isShowKpi: Bool = false
    var title: String = ""
    func setupTableView() {
        self.tableView.register(UINib(nibName: PieChartTableCell.description(), bundle: nil), forCellReuseIdentifier: PieChartTableCell.description())
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.reloadData()
    }
}
extension ChartViews: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.mis_dashboard_detail_graph?.count {
            return count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PieChartTableCell.description()) as? PieChartTableCell else {
            fatalError()
        }
        let query = "SELECT u.* FROM \(db_user_page) AS up INNER JOIN \(db_user_permission) AS u ON  up.PAGENAME = '\(title)' AND up.SERVER_ID_PK = u.PAGEID AND PERMISSION LIKE '\(mis_dashboard_detail_graph?[indexPath.row].typ ?? "")%'"
        if let data = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(query: query) {
            if let permission = data.first {
                cell.fixedGreen.clipsToBounds = true
                cell.fixedGreen.layer.cornerRadius = 5
                cell.fixedGreen.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                
                cell.fixedRed.clipsToBounds = true
                cell.fixedRed.layer.cornerRadius = 5
                cell.fixedRed.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
                
                let mis_dashboard_graph_indexpath = self.mis_dashboard_detail_graph![indexPath.row]
                cell.label.text = mis_dashboard_graph_indexpath.typ
                if permission.PERMISSION.contains("-KPI") {
                    let withinKPI = (mis_dashboard_graph_indexpath.within_kpi_per as NSString).doubleValue
                    let afterKPI = (mis_dashboard_graph_indexpath.after_kpi_per as NSString).doubleValue
                    
                    cell.withinKPILabel.text = String(format: "%.1f", afterKPI * 100)
                    cell.afterKPILabel.text = String(format: "%.1f", withinKPI * 100)
                    cell.withinKPIWidthConstraint = MyConstraint.changeMultiplier(cell.withinKPIWidthConstraint, multiplier: afterKPI)
                    cell.afterKPIWidthConstraint = MyConstraint.changeMultiplier(cell.afterKPIWidthConstraint, multiplier: withinKPI)
                    
                } else {
                    let returnKPI = (mis_dashboard_graph_indexpath.return_per as NSString).doubleValue
                    let deliveredKPI = (mis_dashboard_graph_indexpath.delivered_per as NSString).doubleValue
                    
                    cell.withinKPILabel.text = String(format: "%.1f", deliveredKPI * 100)
                    cell.afterKPILabel.text = String(format: "%.1f", returnKPI * 100)
                    
                    cell.withinKPIWidthConstraint = MyConstraint.changeMultiplier(cell.withinKPIWidthConstraint, multiplier: deliveredKPI)
                    cell.afterKPIWidthConstraint = MyConstraint.changeMultiplier(cell.afterKPIWidthConstraint, multiplier: returnKPI)
                }
                let inprocessValue = (mis_dashboard_graph_indexpath.inprocess_per as NSString).doubleValue
                cell.inprogressLabel.text = String(format: "%.1f", inprocessValue * 100)
                cell.inprogressWidthConstraint = MyConstraint.changeMultiplier(cell.inprogressWidthConstraint, multiplier: inprocessValue)
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}


struct MyConstraint {
  static func changeMultiplier(_ constraint: NSLayoutConstraint, multiplier: CGFloat) -> NSLayoutConstraint {
    let newConstraint = NSLayoutConstraint(
      item: constraint.firstItem,
      attribute: constraint.firstAttribute,
      relatedBy: constraint.relation,
      toItem: constraint.secondItem,
      attribute: constraint.secondAttribute,
      multiplier: multiplier,
      constant: constraint.constant)

    newConstraint.priority = constraint.priority

    NSLayoutConstraint.deactivate([constraint])
    NSLayoutConstraint.activate([newConstraint])

    return newConstraint
  }
}
