//
//  PieChartCollectionCell.swift
//  tcs_one_app
//
//  Created by ibs on 18/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import Charts

class PieChartCollectionCell: UICollectionViewCell, ChartViewDelegate {

   
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var btn: UIButton!
    var isFromHomeScreen = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pieChart.delegate = self
    }
    func setup(isLegendAllowd: Bool, isShowHeading: Bool, centerText: String) {
        
        pieChart.highlightPerTapEnabled = false
        pieChart.usePercentValuesEnabled = false
        pieChart.drawSlicesUnderHoleEnabled = false
        pieChart.holeRadiusPercent = 0.60
        pieChart.chartDescription?.enabled = false
        pieChart.drawEntryLabelsEnabled = false
        pieChart.rotationEnabled = false
        
        
        if isLegendAllowd {
            let l = pieChart.legend
            l.horizontalAlignment = .right
            l.verticalAlignment = .center
            l.orientation = .vertical
            l.xEntrySpace = 0
            l.yEntrySpace = 0
            l.yOffset = 0
        } else {
            pieChart.legend.form = .empty
        }
        manipulateChartData(isLegendAllowd: isLegendAllowd)
    }
    
    
    private func manipulateChartData(isLegendAllowd: Bool) {
        var entries = [PieChartDataEntry]()
        var set : PieChartDataSet?
        var colors = [UIColor]()
        
        let query = "select TICKET_STATUS, count(ID) as ticketTotal, TICKET_DATE from \(db_hr_request) WHERE module_id = '1' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' GROUP BY TICKET_STATUS;"
        let chart = AppDelegate.sharedInstance.db?.getCounts(query: query)
        for data in chart! {
            if isLegendAllowd {
                let chartValue = ((data.ticket_total ?? "0") as NSString).doubleValue
                let key = data.ticket_status ?? ""
                
                switch key {
                    case "Approved":
                        entries.append(PieChartDataEntry(value: chartValue, label: key))
                        break
                    case "Pending":
                        entries.append(PieChartDataEntry(value: chartValue, label: key))
                        break
                    case "Rejected":
                        entries.append(PieChartDataEntry(value: chartValue, label: key))
                        break
                    default:
                        break
                }
            } else {
                let chartValue = ((data.ticket_total ?? "0") as NSString).doubleValue
                let key = data.ticket_status ?? ""
                
                switch key {
                    case "Approved":
                        entries.append(PieChartDataEntry(value: chartValue))
                        break
                    case "Pending":
                        entries.append(PieChartDataEntry(value: chartValue))
                        break
                    case "Rejected":
                        entries.append(PieChartDataEntry(value: chartValue))
                        break
                    default:
                        break
                }
            }
        }
        
        set = PieChartDataSet(entries: entries, label: "")
        set!.drawIconsEnabled = false
        set!.sliceSpace = 0
        
        for data in chart! {
            let key = data.ticket_status ?? ""
            switch key {
                case "Approved":
                    colors.append(UIColor.approvedColor())
                    break
                case "Pending":
                    colors.append(UIColor.pendingColor())
                    break
                case "Rejected":
                    colors.append(UIColor.rejectedColor())
                    break
            default:
                break
            }
        }
        set!.colors = colors
        set!.selectionShift = 0
        let data = PieChartData(dataSet: set!)
        
        data.setValueFont(.systemFont(ofSize: 9, weight: .regular))
        data.setValueTextColor(.white)
        
        pieChart.data = data
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("HELLO")
    }
}
