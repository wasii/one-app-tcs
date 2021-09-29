//
//  MISPieChartDetailViewController.swift
//  tcs_one_app
//
//  Created by TCS on 29/09/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class MISPieChartDetailViewController: BaseViewController {

    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "MIS"
        tableView.register(UINib(nibName: MISPieChartTableCell.description(), bundle: nil), forCellReuseIdentifier: MISPieChartTableCell.description())
        tableView.dataSource = self
        tableView.delegate = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tableViewHeightConstraint.constant = 310 * 10
            self.tableView.reloadData()
        }
    }
}

extension MISPieChartDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MISPieChartTableCell.description()) as? MISPieChartTableCell else {
            fatalError()
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 310
    }
}
