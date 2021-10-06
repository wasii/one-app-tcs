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
    func setupTableView() {
        self.tableView.register(UINib(nibName: PieChartTableCell.description(), bundle: nil), forCellReuseIdentifier: PieChartTableCell.description())
        self.tableView.dataSource = self
        self.tableView.delegate = self
//        self.tableView.estimatedRowHeight = 30
//        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.reloadData()
    }
}
extension ChartViews: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PieChartTableCell.description()) as? PieChartTableCell else {
            fatalError()
        }
        switch indexPath.row {
        case 0:
            cell.label.text = "Attempt (KPIs)"
            break
        case 1:
            cell.label.text = "Delivery / Return (KPIs)"
            break
        case 2:
            cell.label.text = "Delivery / Returned (Ratio)"
            break
        default:
            break
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
}
