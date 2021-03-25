//
//  FulfilmentDashboardViewController.swift
//  tcs_one_app
//
//  Created by TCS on 25/03/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import Charts
import MBCircularProgressBar

class FulfilmentDashboardViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var this_week: UIButton!
    @IBOutlet weak var barChart: BarChartView!
    
    @IBOutlet var sortedImages: [UIImageView]!
    @IBOutlet weak var pending_circular_view: MBCircularProgressBarView!
    @IBOutlet weak var inprocess_circular_view: MBCircularProgressBarView!
    @IBOutlet weak var readytodeliver_circular_view: MBCircularProgressBarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Fulfilment"
        addDoubleNavigationButtons()
    }
}
