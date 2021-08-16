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
    
    
    @IBOutlet weak var weightStackView: UIStackView!
    @IBOutlet weak var QsrDsrStackView: UIStackView!
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var misYearlyAverage: UILabel!
    @IBOutlet weak var totalShipmentLabel: UILabel!
    @IBOutlet weak var averagePerDayLabel: UILabel!
    @IBOutlet weak var totalWeightLabel: UILabel!
    @IBOutlet weak var weightAverageLabel: UILabel!
    @IBOutlet weak var averageQSRLabel: UILabel!
    @IBOutlet weak var averageDSRLabel: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
