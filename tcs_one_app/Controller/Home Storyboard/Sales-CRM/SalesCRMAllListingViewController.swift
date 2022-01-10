//
//  SalesCRMAllListingViewController.swift
//  tcs_one_app
//
//  Created by Wasiq Saleem on 10/01/2022.
//  Copyright © 2022 Personal. All rights reserved.
//

import UIKit
import MBCircularProgressBar

class SalesCRMAllListingViewController: BaseViewController {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var searchViewTextField: UITextField!
    @IBOutlet weak var thisWeekBtn: UIButton!
    
    @IBOutlet weak var leadCircularView: MBCircularProgressBarView!
    @IBOutlet weak var eventCircularView: MBCircularProgressBarView!
    @IBOutlet weak var opportunityCircularView: MBCircularProgressBarView!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeTopCornersRounded(roundView: self.mainView)
    }
}
