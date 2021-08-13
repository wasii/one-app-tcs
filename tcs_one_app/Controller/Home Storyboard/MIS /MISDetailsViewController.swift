//
//  MISDetailsViewController.swift
//  tcs_one_app
//
//  Created by TCS on 11/08/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import DatePickerDialog
import Charts

class MISDetailsViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainHeading: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var lineChart: LineChartView!
    
    var mis_product_data: tbl_mis_product_data?
    var mis_id: Int = 0
    var isOverload: Bool = false
    var daily_overview: [tbl_mis_daily_overview]?
    
    var isWieghtAllowed: Int = 0
    var isQSRAllowed: Int = 0
    var isDSRAllowed: Int = 0
    
    var selectedRegion: String?
    var startday: String?
    var endday: String?
    let dateFormatter = DateFormatter()
    
    var weightedTotal: Double = 0.0
    var bookedTotal: Int = 0
    var qsrAverage: Double = 0.0
    var dsrAverage: Double = 0.0
    
    var firstIndex: Date?
    var lastIndex: Date?
    let datePicker = DatePickerDialog(
        textColor: .nativeRedColor(),
        buttonColor: .nativeRedColor(),
        font: UIFont.boldSystemFont(ofSize: 17),
        showCancelButton: true
    )
    
    var months: [String]!
    var unitsSold = [Double]()
    weak var axisFormatDelegate: IAxisValueFormatter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "MIS"
        self.tableViewHeightConstraint.constant = 0
        
        self.mainHeading.text = "\(self.mis_product_data!.product) Trend"
        
        
        tableView.register(UINib(nibName: MISDetailTableCell.description(), bundle: nil), forCellReuseIdentifier: MISDetailTableCell.description())
        tableView.register(UINib(nibName: "MISHeaderCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "MISHeaderCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 30
        
        self.makeTopCornersRounded(roundView: self.mainView)
        setupDailyOverview(region: nil)
        let query = "SELECT * FROM \(db_mis_daily_overview)"
        if let data =  AppDelegate.sharedInstance.db?.read_tbl_mis_daily_overview(query: query) {
            let firstIndex = data.first?.rpt_date.dateOnly ?? ""
            let lastIndex = data.last?.rpt_date.dateOnly ?? ""
            
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            self.firstIndex = dateFormatter.date(from: firstIndex)
            self.lastIndex = dateFormatter.date(from: lastIndex)
        }
        
        super.viewDidLoad()
                // Do any additional setup after loading the view, typically from a nib.
        axisFormatDelegate = self
        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        unitsSold = [20.0, 86.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]

    }
    
    private func setupDailyOverview(region: String?) {
        self.daily_overview = nil
        self.view.makeToastActivity(.center)
        var query = ""
        
        //Get Product Name from Previous Screen (not hardcode)
        query = "SELECT * FROM \(db_mis_daily_overview) WHERE PRODUCT = '\(self.mis_product_data!.product)'"
        if startday == nil && endday == nil {
            let previousDate = getPreviousDays(days: -7)
            let weekly = previousDate.convertDateToString(date: previousDate)
            
            
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let Tempstartdate = dateFormatter.date(from: weekly.dateOnly) ?? Date()
            let Tempenddate = dateFormatter.date(from: self.getLocalCurrentDate()) ?? Date()
            
            dateFormatter.dateFormat = "dd MMM yyyy"
            
            let startDate = dateFormatter.string(from: Tempstartdate)
            let endDate = dateFormatter.string(from: Tempenddate)
            
            self.dateLabel.text = "\(startDate) - \(endDate)"
            query += " AND RPT_DATE >= '\(weekly)' AND RPT_DATE <= '\(self.getLocalCurrentDate())'"
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let Tempstartdate = dateFormatter.date(from: self.startday!.dateOnly) ?? Date()
            let Tempenddate = dateFormatter.date(from: self.endday!.dateOnly) ?? Date()
            
            dateFormatter.dateFormat = "dd MMM yyyy"
            
            let startDate = dateFormatter.string(from: Tempstartdate)
            let endDate = dateFormatter.string(from: Tempenddate)
            
            self.dateLabel.text = "\(startDate) - \(endDate)"
            query += " AND RPT_DATE >= '\(self.startday!)' AND RPT_DATE <= '\(self.endday!)'"
        }
        
        if let r = region {
            query += r
        }
        
        daily_overview = AppDelegate.sharedInstance.db?.read_tbl_mis_daily_overview(query: query)
        
        DispatchQueue.main.async {
            self.view.hideToastActivity()
            if let count = self.daily_overview?.count {
                self.bookedTotal = 0
                self.weightedTotal = 0
                var tempQSR = 0.0
                var tempDSR = 0.0
                self.daily_overview?.forEach({ d in
                    self.bookedTotal += d.booked
                    self.weightedTotal += Double(d.weight) ?? 0
                    tempQSR += Double(d.qsr) ?? 0.0
                    tempDSR += Double(d.dsr) ?? 0.0
                })
                self.qsrAverage = tempQSR / Double(count)
                self.dsrAverage = tempDSR / Double(count)
//                self.setupGraph()
                self.setChart(dataEntryX: self.months, dataEntryY: self.unitsSold)
                self.tableView.reloadData()
                self.tableViewHeightConstraint.constant = CGFloat(count * 30) + 70
            } else {
                self.tableView.reloadData()
                self.tableViewHeightConstraint.constant = 0
            }
        }
    }
    func openDatePicker(title: String, minDate: Date?, maxDate: Date?, handler: @escaping(_ success: Bool,_ date: String) -> Void) {
        datePicker.show(title,
                        doneButtonTitle: "Done",
                        cancelButtonTitle: "Cancel",
                        minimumDate: minDate,
                        maximumDate: maxDate,
                        datePickerMode: .date,
                        window: self.view.window) { (date) in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                handler(true, formatter.string(from: dt))
            } else {
                handler(false, "")
            }
        }
    }
    @IBAction func dateSelectionTapped(_ sender: Any) {
        openDatePicker(title: "Select Start Date", minDate: self.firstIndex, maxDate: self.lastIndex) { start_date_granted , start_date in
            if start_date_granted {
                self.startday = start_date
                self.openEndDate()
                return
            } else {
                self.startday = nil
            }
        }
    }
    
    private func openEndDate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.openDatePicker(title: "Select End Date", minDate: self.firstIndex, maxDate: self.lastIndex) { end_date_granted , end_date in
                if end_date_granted {
                    self.endday = end_date
                    self.setupDailyOverview(region: self.selectedRegion)
                    return
                } else {
                    self.endday = nil
                }
            }
        }
    }
    @IBAction func filterationBtnTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Popups", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestListingViewController") as! NewRequestListingViewController
        controller.mis_region_date = AppDelegate.sharedInstance.db?.read_tbl_mis_region_data(query: "SELECT * FROM \(db_mis_region_data)")
        controller.heading = "Select Region"
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        controller.modalTransitionStyle = .crossDissolve
        controller.misdelegate = self
        Helper.topMostController().present(controller, animated: true, completion: nil)
    }
    
    private func setupGraphValues() {
        var dataEntryX: [String] = [String]()
        var dataEntryY: [Double] = [Double]()
        
        if let daily_overview = self.daily_overview {
            var currentDate = ""
            for DO in daily_overview {
                if currentDate == DO.rpt_date {
                    
                } else {
                    currentDate = DO.rpt_date
                }
                
                
            }
        }
        setChart(dataEntryX: dataEntryX, dataEntryY: dataEntryY)
    }
    private func setChart(dataEntryX forX:[String],dataEntryY forY: [Double]) {
        lineChart.chartDescription?.enabled = false
        lineChart.dragEnabled = true
        lineChart.setScaleEnabled(true)
        lineChart.pinchZoomEnabled = false
        
        lineChart.xAxis.gridLineDashLengths = [0, 0]
        lineChart.xAxis.gridLineDashPhase = 0
        
        let ll1 = ChartLimitLine(limit: 150, label: "")
        ll1.lineColor = UIColor.approvedColor()
        ll1.lineWidth = 4
        ll1.lineDashLengths = [0,0]

        lineChart.rightAxis.enabled = false
        

        lineChart.animate(xAxisDuration: 0.5)
        lineChart.noDataText = "You need to provide data for the chart."
        var dataEntries:[ChartDataEntry] = []
        for i in 0..<forX.count{
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(forY[i]) , data: months as AnyObject?)
            print(dataEntry)
            dataEntries.append(dataEntry)
        }
        let set1 = LineChartDataSet(entries: dataEntries)
        set1.drawIconsEnabled = false
        set1.lineDashLengths = [0, 0]
        set1.highlightLineDashLengths = [0, 0]
        set1.setColor(UIColor.nativeRedColor())
        set1.setCircleColor(UIColor.nativeRedColor())
        set1.lineWidth = 1
        set1.circleRadius = 6
        set1.drawCircleHoleEnabled = false
        set1.valueFont = .systemFont(ofSize: 9)
        set1.formLineDashLengths = [0,0]
        set1.formLineWidth = 1
//        set1.formSize = 25
        set1.mode = .cubicBezier
        set1.fillAlpha = 0
        set1.drawValuesEnabled = false
        
        set1.drawFilledEnabled = true

        let chartData = LineChartData(dataSet: set1)// BarChartData(dataSet: chartDataSet)
        lineChart.data = chartData
        let xAxisValue = lineChart.xAxis
        xAxisValue.valueFormatter = axisFormatDelegate

    }
}

extension MISDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = self.daily_overview {
            return 1
        }
        return 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.daily_overview?.count {
            return count + 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MISDetailTableCell.description()) as? MISDetailTableCell else {
            fatalError()
        }
        if isWieghtAllowed == 0 {
            cell.weightView.isHidden = true
        } else {
            cell.weightView.isHidden = false
            cell.weightLabel.font = UIFont.systemFont(ofSize: 10)
        }
        
        if isQSRAllowed == 0 {
            cell.qsrView.isHidden = true
        } else {
            cell.qsrView.isHidden = false
            cell.qsrLabel.font = UIFont.systemFont(ofSize: 10)
        }
        
        if isDSRAllowed == 0 {
            cell.dsrView.isHidden = true
        } else {
            cell.dsrView.isHidden = false
            cell.dsrLabel.font = UIFont.systemFont(ofSize: 10)
        }
        
        //Manipulate Data
        if indexPath.row == self.daily_overview!.count {
            cell.dateLabel.text = ""
            cell.shipmentBookedLabel.text = "\(self.bookedTotal)"
            cell.weightLabel.text = String(format: "%.2f", self.weightedTotal)
            cell.qsrLabel.text = String(format: "%.2f", self.qsrAverage)
            cell.dsrLabel.text = String(format: "%.2f", self.dsrAverage)
            return cell
        }
        
        cell.dateLabel.font = UIFont.systemFont(ofSize: 10)
        cell.shipmentBookedLabel.font = UIFont.systemFont(ofSize: 10)
        
        let data = self.daily_overview![indexPath.row]
        cell.dateLabel.text = data.rpt_date.dateOnly
        cell.shipmentBookedLabel.text = "\(data.booked)"
        if let weight = Double(data.weight) {
            cell.weightLabel.text = String(format: "%.2f", weight)
        }
        if let dsr = Double(data.dsr) {
            cell.dsrLabel.text = String(format: "%.2f", dsr)
        }
        if let qsr = Double(data.qsr) {
            cell.qsrLabel.text = String(format: "%.2f", qsr)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MISHeaderCell") as! MISHeaderCell
        if isWieghtAllowed == 0 {
            if let weightView = headerCell.viewWithTag(2) as? CustomView {
                weightView.isHidden = true
            }
        }
        if isQSRAllowed == 0 {
            if let qsrView = headerCell.viewWithTag(3) as? CustomView {
                qsrView.isHidden = true
            }
        }
        
        if isDSRAllowed == 0 {
            if let dsrView = headerCell.viewWithTag(4) as? CustomView {
                dsrView.isHidden = true
            }
        }
        
        return headerCell
    }
}


extension MISDetailsViewController: MISDelegate {
    func updateListing(region_date: tbl_mis_region_data) {
        self.filterLabel.text = region_date.product
        
        if region_date.product == "Nation Wide" {
            self.selectedRegion = nil
        } else {
            self.selectedRegion = " AND REGN = '\(region_date.product)'"
        }
        
        
        self.setupDailyOverview(region: self.selectedRegion)
    }
}



extension MISDetailsViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return months[Int(value)]
    }
}
