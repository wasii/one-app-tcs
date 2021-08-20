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
    
    @IBOutlet weak var totalShipmentLabel: UILabel!
    @IBOutlet weak var averagePerDayLabel: UILabel!
    @IBOutlet weak var totalWeightLabel: UILabel!
    @IBOutlet weak var averageWeightLabel: UILabel!
    @IBOutlet weak var averageQSRLabel: UILabel!
    @IBOutlet weak var averageDSRLabel: UILabel!
    
    
    @IBOutlet weak var weightStackView: UIStackView!
    @IBOutlet weak var QsrDsrStackView: UIStackView!
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
    
    var dataEntryX: [String] = [String]()
    var dataEntryY: [Double] = [Double]()
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

    }
    
    private func setupDailyOverview(region: String?) {
        self.daily_overview = nil
        self.view.makeToastActivity(.center)
        var query = ""
        
        //Get Product Name from Previous Screen (not hardcode)
        query = "SELECT ID, REGN, RPT_DATE, PRODUCT, SUM(BOOKED), SUM(WEIGHT), AVG(QSR), AVG(DSR) FROM \(db_mis_daily_overview) WHERE PRODUCT = '\(self.mis_product_data!.product)'"
        let previousDate = getPreviousDays(days: -7)
        var weekly = ""
        if startday == nil && endday == nil {
            
            weekly = previousDate.convertDateToString(date: previousDate)
            
            
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let Tempstartdate = dateFormatter.date(from: weekly.dateOnly) ?? Date()
            let Tempenddate = dateFormatter.date(from: self.getLocalCurrentDate()) ?? Date()
            
            dateFormatter.dateFormat = "dd MMM yyyy"
            
            let startDate = dateFormatter.string(from: Tempstartdate)
            let endDate = dateFormatter.string(from: Tempenddate)
            
            self.dateLabel.text = "\(startDate) - \(endDate)"
            query += " AND RPT_DATE >= '\(weekly.dateOnly)' AND RPT_DATE <= '\(self.getLocalCurrentDate().dateOnly)'"
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let Tempstartdate = dateFormatter.date(from: self.startday!.dateOnly) ?? Date()
            let Tempenddate = dateFormatter.date(from: self.endday!.dateOnly) ?? Date()
            
            dateFormatter.dateFormat = "dd MMM yyyy"
            
            let startDate = dateFormatter.string(from: Tempstartdate)
            let endDate = dateFormatter.string(from: Tempenddate)
            
            self.dateLabel.text = "\(startDate) - \(endDate)"
            query += " AND RPT_DATE >= '\(self.startday!.dateOnly)' AND RPT_DATE <= '\(self.endday!.dateOnly)'"
        }
        
        if let r = region {
            query += r
        }
        
        query += " GROUP BY RPT_DATE"
        daily_overview = AppDelegate.sharedInstance.db?.read_tbl_mis_daily_overview(query: query)
        print(query)
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
                if self.startday == nil && self.endday == nil {
                    self.setupGraphValues(startdate: weekly, enddate: self.getLocalCurrentDate())
                } else {
                    self.setupGraphValues(startdate: self.startday!, enddate: self.endday!)
                }
                self.daily_overview = self.daily_overview?.sorted(by: { d1, d2 in
                    d1.rpt_date > d2.rpt_date
                })
                self.tableView.reloadData()
                self.tableViewHeightConstraint.constant = CGFloat(count * 30) + 70
            } else {
                self.totalShipmentLabel.text = "Total Shipment: 0"
                self.averagePerDayLabel.text = "Avg. Per Day: 0"
                self.totalWeightLabel.text = "Total Weight: 0"
                self.averageWeightLabel.text = ""
                self.averageQSRLabel.text = "Avg. QSR: 0"
                self.averageDSRLabel.text = "Avg. DSR: 0"
                self.lineChart.data = nil
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
    
    private func setupGraphValues(startdate: String, enddate: String) {
        dataEntryY = [Double]()
        dataEntryX = [String]()
        var getAverageQuery = "SELECT SUM(BOOKED) as TOTAL_SHIPMENT,round(Avg(BOOKED)) as AvgPerDay,SUM(WEIGHT) as TOTAL_WEIGHT,round(Avg(QSR)) as AvgQSR,round(Avg(DSR)) as AvgDSR FROM \(db_mis_daily_overview) WHERE PRODUCT = '\(self.mis_product_data!.product)' AND RPT_DATE >= '\(startdate.dateOnly)' AND RPT_DATE <= '\(enddate.dateOnly)' GROUP BY RPT_DATE"
        
        if let selected_region = self.selectedRegion {
            getAverageQuery = "SELECT SUM(BOOKED) as TOTAL_SHIPMENT,round(Avg(BOOKED)) as AvgPerDay,SUM(WEIGHT) as TOTAL_WEIGHT,round(Avg(QSR)) as AvgQSR,round(Avg(DSR)) as AvgDSR FROM \(db_mis_daily_overview) WHERE PRODUCT = '\(self.mis_product_data!.product)' AND RPT_DATE >= '\(startdate.dateOnly)' AND RPT_DATE <= '\(enddate.dateOnly)' \(selected_region) GROUP BY RPT_DATE"
        }
        if let averageDate = AppDelegate.sharedInstance.db?.getAverageMIS(query: getAverageQuery) {
            let count = Double(averageDate.count)
            var totalShipment: Double = 0
            var averagePerDay: Double = 0
            var totalWeight: Double = 0
            var averageQSR: Double = 0
            var averageDSR: Double = 0
            
            for json in averageDate {
                totalShipment += Double(json.TOTAL_SHIPMENT)!
                totalWeight += Double(json.TOTAL_WEIGHT)!
                averageQSR += Double(json.AvgQSR)!
                averageDSR += Double(json.AvgDSR)!
            }
            averagePerDay = totalShipment / count
            averageDSR = averageDSR / count
            averageQSR = averageQSR / count
            
            self.totalShipmentLabel.text = "Total Shipment: \(totalShipment)"
            self.averagePerDayLabel.text = "Avg. Per Day: "  + String(format: "%.2f", averagePerDay)
            
            if self.isWieghtAllowed == 0 {
                self.weightStackView.isHidden = true
            } else {
                self.totalWeightLabel.text = "Total Weight: \(totalWeight)"
//                self.averageWeightLabel.text = "Avg. Per Day: \(averageDate.AvgPerDay)"
                self.weightStackView.isHidden = false
                
            }
            
            if self.isQSRAllowed == 0 {
                self.QsrDsrStackView.isHidden = true
            } else {
                self.averageQSRLabel.text = "Avg. QSR: " + String(format: "%.2f", averageQSR) + "%"
                self.averageDSRLabel.text = "Avg. DSR: " + String(format: "%.2f", averageDSR) + "%"
                self.QsrDsrStackView.isHidden = false
            }
        }
        
        var dateQuery = ""
        var countQuery = ""
        if let selected_region = self.selectedRegion {
            dateQuery = "SELECT strftime('%Y-%m-%d',RPT_DATE) as date FROM \(db_mis_daily_overview) WHERE  PRODUCT = '\(self.mis_product_data!.product)' \(selected_region) AND RPT_DATE >= '\(startdate.dateOnly)' AND RPT_DATE <= '\(enddate.dateOnly)'  group by strftime('%Y-%m-%d',RPT_DATE)"
            
            countQuery = "SELECT SUM(BOOKED) , count(BOOKED) as totalCount, strftime('%Y-%m-%d',RPT_DATE) as date FROM \(db_mis_daily_overview) WHERE  RPT_DATE >= '\(startdate.dateOnly)' AND RPT_DATE <= '\(enddate.dateOnly)' \(selected_region)  group by date"
        } else {
            dateQuery = "SELECT strftime('%Y-%m-%d',RPT_DATE) as date FROM \(db_mis_daily_overview) WHERE  PRODUCT = '\(self.mis_product_data!.product)' AND RPT_DATE >= '\(startdate.dateOnly)' AND RPT_DATE <= '\(enddate.dateOnly)'  group by strftime('%Y-%m-%d',RPT_DATE)"
            
            countQuery = "SELECT SUM(BOOKED) , count(BOOKED) as totalCount, strftime('%Y-%m-%d',RPT_DATE) as date FROM \(db_mis_daily_overview) WHERE  RPT_DATE >= '\(startdate.dateOnly)' AND RPT_DATE <= '\(enddate.dateOnly)' group by date"
        }
        
        let dateCount  = AppDelegate.sharedInstance.db?.getDates(query: dateQuery).sorted(by: { (date1, date2) -> Bool in
            date1 > date2
        })
        
        let totalCount = AppDelegate.sharedInstance.db?.getBarGraphCounts(query: countQuery).sorted(by: { (g1, g2) -> Bool in
            g1.ticket_date! > g2.ticket_date!
        })
        
        if dateCount!.count > 0 {
            dateCount!.forEach { date in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let tDate = dateFormatter.date(from: date)!.d()
                dataEntryX.append(tDate)
            }
        }
        
        if totalCount!.count > 0 {
            totalCount!.forEach { graph in
                let value = Double(graph.ticket_status!)
                dataEntryY.append(value ?? 0.0)
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
        
        var getAverageQuery = "SELECT SUM(BOOKED) AS SHIPMENT FROM \(db_mis_daily_overview) WHERE PRODUCT = '\(self.mis_product_data!.product)'"
        if let selectedRegion = self.selectedRegion {
            getAverageQuery += selectedRegion
        }
        
        getAverageQuery += " GROUP BY RPT_DATE"
        let yAxisValue = lineChart.leftAxis
        if let getAverage = AppDelegate.sharedInstance.db?.read_row(query: getAverageQuery) {
            var average: Int = 0
            for json in getAverage {
                average += (json as NSString).integerValue
            }
            average = average / getAverage.count
            let ll1 = ChartLimitLine(limit: Double(average), label: "")
            ll1.lineColor = UIColor.approvedColor()
            ll1.lineWidth = 2
            ll1.lineDashLengths = [0,0]
            yAxisValue.removeAllLimitLines()
            yAxisValue.addLimitLine(ll1)
        }

        lineChart.rightAxis.enabled = false
        

        lineChart.animate(xAxisDuration: 0.5)
        lineChart.noDataText = "You need to provide data for the chart."
        var dataEntries:[ChartDataEntry] = []
        for i in 0..<forX.count{
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(forY[i]) , data: forX as AnyObject?)
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
        xAxisValue.granularity = 1.0
        xAxisValue.granularityEnabled = true
        xAxisValue.setLabelCount(forX.count, force: true)
        xAxisValue.labelPosition = .bottom
        
        yAxisValue.valueFormatter = YAxisFormatter()
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
            cell.dateLabel.text = "Total "
            cell.shipmentBookedLabel.text = "\(self.bookedTotal)"
            cell.weightLabel.text = String(format: "%.2f", self.weightedTotal)
            cell.qsrLabel.text = String(format: "%.2f", self.qsrAverage)
            cell.dsrLabel.text = String(format: "%.2f", self.dsrAverage)
            
            cell.dateView.bgColor = UIColor.init(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1)
            cell.shipmentBooked.bgColor = UIColor.init(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1)
            cell.weightView.bgColor = UIColor.init(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1)
            cell.qsrView.bgColor = UIColor.init(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1)
            cell.dsrView.bgColor = UIColor.init(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1)
            return cell
        }
        cell.dateView.bgColor = UIColor.white
        cell.shipmentBooked.bgColor = UIColor.white
        cell.weightView.bgColor = UIColor.white
        cell.qsrView.bgColor = UIColor.white
        cell.dsrView.bgColor = UIColor.white
        
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
        if self.dataEntryX.count == 1 {
            return dataEntryX[0]
        }
        return dataEntryX[Int(value)]
    }
}
