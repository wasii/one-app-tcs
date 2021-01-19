//
//  MultiplePieCharCollectionCell.swift
//  tcs_one_app
//
//  Created by ibs on 03/11/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import Charts
class MultiplePieCharCollectionCell: UICollectionViewCell, ChartViewDelegate {

    @IBOutlet weak var multiplePieCharts: PieChartView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        multiplePieCharts.delegate = self
    }
    
    func setup(chartListing: ChartListing) {
        multiplePieCharts.highlightPerTapEnabled = false
        multiplePieCharts.usePercentValuesEnabled = false
        multiplePieCharts.drawSlicesUnderHoleEnabled = false
        multiplePieCharts.holeRadiusPercent = 0.60
        multiplePieCharts.chartDescription?.enabled = false
        multiplePieCharts.drawEntryLabelsEnabled = false
        multiplePieCharts.rotationEnabled = false
        multiplePieCharts.legend.form = .empty
        multiplePieCharts.centerText = chartListing.month
        
        manipluateData(chartListing: chartListing)
    }
    
    func manipluateData(chartListing: ChartListing) {
        var entries = [PieChartDataEntry]()
        var set : PieChartDataSet?
        var colors = [UIColor]()
        
        for chart in chartListing.graphs {
            let chartValue = ((chart.ticket_total ?? "0") as NSString).doubleValue
            let key = chart.ticket_status ?? ""
            
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
        set = PieChartDataSet(entries: entries, label: "")
        set!.drawIconsEnabled = false
        set!.sliceSpace = 0
        for data in chartListing.graphs {
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
        
        multiplePieCharts.data = data
    }

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("HELLO")
    }
}
