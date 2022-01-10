//
//  SalesCRMDashboardViewController.swift
//  tcs_one_app
//
//  Created by Wasiq Saleem on 10/01/2022.
//  Copyright © 2022 Personal. All rights reserved.
//

import UIKit
import Charts
import MBCircularProgressBar

class SalesCRMDashboardViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var sortingBtn: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var thisWeekBtn: UIButton!
    @IBOutlet weak var filteredTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var filteredTableView: UITableView!
    
    @IBOutlet weak var leadCircularImageView: UIImageView!
    @IBOutlet weak var leadCircularView: MBCircularProgressBarView!
    @IBOutlet weak var eventsCircularImageView: UIImageView!
    @IBOutlet weak var eventsCircularView: MBCircularProgressBarView!
    @IBOutlet weak var opportunityCircularImageView: UIImageView!
    @IBOutlet weak var opportunityCircularView: MBCircularProgressBarView!
    
    
    @IBOutlet weak var permissionTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var permissionTableView: UITableView!
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeTopCornersRounded(roundView: self.mainView)
        title = "Sales CRM"
    }
    
    
    @IBAction func addNewLeadTapped(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SalesCRMAddNewLeadsViewController") as! SalesCRMAddNewLeadsViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
