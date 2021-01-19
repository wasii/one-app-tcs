//
//  NewChartListingViewController.swift
//  tcs_one_app
//
//  Created by TCS on 08/11/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import Charts

class NewChartListingViewController: BaseViewController {

    @IBOutlet weak var stackWidth: NSLayoutConstraint!
    @IBOutlet weak var crossView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var lastThreeMonthsPieChartOne: PieChartView!
    @IBOutlet weak var lastThreeMonthsPieChartTwo: PieChartView!
    @IBOutlet weak var lastThreeMonthsPieChartThree: PieChartView!
    
    
    @IBOutlet weak var lastThreeMonthsTatBreachPieChartOne: PieChartView!
    @IBOutlet weak var lastThreeMonthsTatBreachPieChartTwo: PieChartView!
    @IBOutlet weak var lastThreeMonthsTatBreachPieChartThree: PieChartView!
    
    
    @IBOutlet weak var lastThreeMonthsIsTatPieChartOne: PieChartView!
    @IBOutlet weak var lastThreeMonthsIsTatPieChartTwo: PieChartView!
    @IBOutlet weak var lastThreeMonthsIsTatPieChartThree: PieChartView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet var pendingLabel: [UILabel]!
    @IBOutlet var approvedLabel: [UILabel]!
    @IBOutlet var rejectedLabel: [UILabel]!
    var circularGraph: [CircularGraphListing]?
    
    let dateFormatter = DateFormatter()
    var module_id: tbl_UserModule?
    
    var tatPendingCounter = 0
    var tatApprovedCounter = 0
    var tatRejectedCounter = 0
    
    var withInPendingCounter = 0
    var withInApprovedCounter = 0
    var withInRejectedCounter = 0
    
    var mqid = "0"
    var dqid = "0"
    
    var selected_item = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(upload_pending_request), name: .networkRefreshed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigateThroughtNotify(notification:)), name: .navigateThroughNotification, object: nil)
        self.makeTopCornersRounded(roundView: mainView)
        crossView.isHidden = true
        self.stackWidth.constant = 22
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        module_id = AppDelegate.sharedInstance.db?.read_tbl_UserModule(query: "SELECT * FROM \(db_user_module) WHERE TAGNAME = '\(MODULE_TAG_HR)';").first
        
        lastThreeMonthsPieChartOne.delegate = self
        lastThreeMonthsPieChartTwo.delegate = self
        lastThreeMonthsPieChartThree.delegate = self
        
        lastThreeMonthsTatBreachPieChartOne.delegate = self
        lastThreeMonthsTatBreachPieChartTwo.delegate = self
        lastThreeMonthsTatBreachPieChartThree.delegate = self
        
        lastThreeMonthsIsTatPieChartOne.delegate = self
        lastThreeMonthsIsTatPieChartTwo.delegate = self
        lastThreeMonthsIsTatPieChartThree.delegate = self
        
        switch CONSTANT_MODULE_ID {
        case 1:
            pendingLabel.forEach { (pending) in
                pending.text = "Pending"
            }
            approvedLabel.forEach { (approved) in
                approved.text = "Completed"
            }
            rejectedLabel.forEach { (rejected) in
                rejected.text = "Rejected"
            }
            break
        case 2:
            pendingLabel.forEach { (pending) in
                pending.text = "Submitted"
            }
            approvedLabel.forEach { (approved) in
                approved.text = INREVIEW
            }
            rejectedLabel.forEach { (rejected) in
                rejected.text = "Closed"
            }
            break
        default:
            break
        }
        self.collectionView.register(UINib(nibName: "CicrularProgressBarCollectionCell", bundle: nil), forCellWithReuseIdentifier: "CicrularProgressBarCell")
        setupViews()
        setupCircularWithoutCondition()
    }
    
    @IBAction func crossBtnTapped(_ sender: Any) {
        setupCircularWithoutCondition()
    }
    @IBAction func filterBtnTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Popups", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "GraphListingFilterPopupViewController") as! GraphListingFilterPopupViewController
        
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        controller.modalTransitionStyle = .crossDissolve
        controller.selected_item = self.selected_item
        
        controller.delegate = self
        Helper.topMostController().present(controller, animated: true, completion: nil)
    }
    func setupCircularWithConditions(id: String) {
        self.crossView.isHidden = false
        self.stackWidth.constant = 44
        let query = "SELECT M.DQ_UNIQ_ID, M.DQ_DESC as title, count(R.ID) as totalCount, M.COLOR_CODE as colorCode FROM \(db_detail_query) M LEFT OUTER JOIN \(db_hr_request) R ON M.DQ_UNIQ_ID = R.DQ_ID AND M.MQ_ID = R.MQ_ID WHERE M.MQ_ID = '\(id)' AND R.CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' GROUP by M.SERVER_ID_PK"
        
        circularGraph = AppDelegate.sharedInstance.db?.read_graphlisting(query: query)
        self.collectionView.reloadData()
    }
    func setupCircularWithoutCondition() {
        self.mqid = "0"
        self.selected_item = ""
        self.stackWidth.constant = 22
        self.crossView.isHidden = true
        let query = "SELECT M.SERVER_ID_PK , M.MQ_DESC as title, count(R.ID) as totalCount , M.COLOR_CODE as colorCode FROM \(db_master_query) M LEFT OUTER JOIN \(db_hr_request) R ON M.SERVER_ID_PK = R.MQ_ID AND R.CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' WHERE M.MODULE_ID = '\(CONSTANT_MODULE_ID)' GROUP by M.SERVER_ID_PK"
        
        self.circularGraph = AppDelegate.sharedInstance.db?.read_graphlisting(query: query)
        self.collectionView.reloadData()
    }
    func setupViews() {
        for i in 0...2 {
            switch i {
            case 0:
                self.tatPendingCounter = 0
                self.tatApprovedCounter = 0
                self.tatRejectedCounter = 0
                self.withInPendingCounter = 0
                self.withInApprovedCounter = 0
                self.withInRejectedCounter = 0
                
                let graphs = self.calculateTatBreachOrWithInTat(numberOfDays: -i,
                                                                moduleId: CONSTANT_MODULE_ID)
                
                if graphs.first!.graphs.count > 0 {
                    self.setupPieChartView(pieChart: self.lastThreeMonthsTatBreachPieChartThree,
                                           chartListing: ChartListing(month: graphs.first!.month,
                                                                      graphs: graphs.first!.graphs))
                } else {
                    self.lastThreeMonthsTatBreachPieChartThree.isHidden = true
                }
                if graphs.last!.graphs.count > 0 {
                    self.setupPieChartView(pieChart: self.lastThreeMonthsIsTatPieChartThree,
                                           chartListing: ChartListing(month: graphs.last!.month,
                                                                      graphs: graphs.last!.graphs))
                } else {
                    self.lastThreeMonthsIsTatPieChartThree.isHidden = true
                }
                
                let startingDate = Date().getCurrentMonthStart()
                let endDate = getLocalCurrentDate()
                let monthName = Date().getCurrentMonthStart()?.monthAsString()
                
                let threeMonthGraphs = AppDelegate.sharedInstance.db?.getThreeMonthGraphs(startDate: dateFormatter.string(from: startingDate!),
                                                                                          endDate: endDate)
                
                if threeMonthGraphs!.count > 0 {
                    self.setupPieChartView(pieChart: self.lastThreeMonthsPieChartThree,
                                           chartListing: ChartListing(month: monthName!,
                                                                      graphs: threeMonthGraphs!))
                } else {
                    self.lastThreeMonthsPieChartThree.isHidden = true
                }
                break
                
            case 1:
                self.tatPendingCounter = 0
                self.tatApprovedCounter = 0
                self.tatRejectedCounter = 0
                self.withInPendingCounter = 0
                self.withInApprovedCounter = 0
                self.withInRejectedCounter = 0
                
                let graphs = self.calculateTatBreachOrWithInTat(numberOfDays: -i,
                                                                moduleId: CONSTANT_MODULE_ID)
                
                if graphs.first!.graphs.count > 0 {
                    self.setupPieChartView(pieChart: self.lastThreeMonthsTatBreachPieChartTwo,
                                           chartListing: ChartListing(month: graphs.first!.month,
                                                                      graphs: graphs.first!.graphs))
                } else {
                    self.lastThreeMonthsTatBreachPieChartTwo.isHidden = true
                }
                if graphs.last!.graphs.count > 0 {
                    self.setupPieChartView(pieChart: self.lastThreeMonthsIsTatPieChartTwo,
                                           chartListing: ChartListing(month: graphs.last!.month,
                                                                      graphs: graphs.last!.graphs))
                } else {
                    self.lastThreeMonthsIsTatPieChartTwo.isHidden = true
                }
                
                let lastMonth = Calendar.current.date(byAdding: .month, value: -i, to: Date())
                
                let lastMonthEndDate = lastMonth?.endOfMonth
                let lastMonthStartDate = lastMonth?.startOfMonth
                
                let monthName = lastMonthStartDate!.monthAsString()
                
                let threeMonthGraphs = AppDelegate.sharedInstance.db?.getThreeMonthGraphs(startDate: dateFormatter.string(from: lastMonthStartDate!),
                                                                                          endDate: dateFormatter.string(from: lastMonthEndDate!))
                
                
                
                if threeMonthGraphs!.count > 0 {
                    self.setupPieChartView(pieChart: self.lastThreeMonthsPieChartTwo,
                                           chartListing: ChartListing(month: monthName,
                                                                      graphs: threeMonthGraphs!))
                } else {
                    self.lastThreeMonthsPieChartTwo.isHidden = true
                }
                
                break
            case 2:
                self.tatPendingCounter = 0
                self.tatApprovedCounter = 0
                self.tatRejectedCounter = 0
                self.withInPendingCounter = 0
                self.withInApprovedCounter = 0
                self.withInRejectedCounter = 0
                
                let graphs = self.calculateTatBreachOrWithInTat(numberOfDays: -i,
                                                                moduleId: CONSTANT_MODULE_ID)
                
                if graphs.first!.graphs.count > 0 {
                    self.setupPieChartView(pieChart: self.lastThreeMonthsTatBreachPieChartOne,
                                           chartListing: ChartListing(month: graphs.first!.month,
                                                                      graphs: graphs.first!.graphs))
                } else {
                    self.lastThreeMonthsTatBreachPieChartOne.isHidden = true
                }
                if graphs.last!.graphs.count > 0 {
                    self.setupPieChartView(pieChart: self.lastThreeMonthsIsTatPieChartOne,
                                           chartListing: ChartListing(month: graphs.last!.month,
                                                                      graphs: graphs.last!.graphs))
                } else {
                    self.lastThreeMonthsIsTatPieChartOne.isHidden = true
                }
                
                let lastMonth = Calendar.current.date(byAdding: .month, value: -i, to: Date())
                
                let lastMonthEndDate = lastMonth?.endOfMonth
                let lastMonthStartDate = lastMonth?.startOfMonth
                
                let monthName = lastMonthStartDate!.monthAsString()
                
                let threeMonthGraphs = AppDelegate.sharedInstance.db?.getThreeMonthGraphs(startDate: dateFormatter.string(from: lastMonthStartDate!),
                                                                                          endDate: dateFormatter.string(from: lastMonthEndDate!))
                
                
                if threeMonthGraphs!.count > 0 {
                    self.setupPieChartView(pieChart: self.lastThreeMonthsPieChartOne,
                                           chartListing: ChartListing(month: monthName,
                                                                      graphs: threeMonthGraphs!))
                } else {
                    self.lastThreeMonthsPieChartOne.isHidden = true
                }
                
                break
            default:
                break
            }
        }
    }
    
    func calculateTatBreachOrWithInTat(numberOfDays: Int, moduleId: Int) -> [ChartListing] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let lastMonth = Calendar.current.date(byAdding: .month, value: numberOfDays, to: Date())
        
        let lastMonthEndDate = lastMonth?.endOfMonth
        let lastMonthStartDate = lastMonth?.startOfMonth
        
        let monthName = lastMonthStartDate!.monthAsString()
        
        let request_log_query = "select * from REQUEST_LOGS WHERE module_id = '\(moduleId)' AND Created_Date >= '\(dateFormatter.string(from: lastMonthStartDate!))' AND Created_Date <= '\(dateFormatter.string(from: lastMonthEndDate!))' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
        
        var request_log = AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: request_log_query)
        switch CONSTANT_MODULE_ID {
        case 1:
            request_log =  request_log?.filter({ (logs) -> Bool in
                logs.TICKET_STATUS == "Pending" || logs.TICKET_STATUS == "Approved" || logs.TICKET_STATUS == "Rejected"
            })
            break
        case 2:
            request_log =  request_log?.filter({ (logs) -> Bool in
                logs.TICKET_STATUS == "Submitted" ||
                logs.TICKET_STATUS == "Investigating" || logs.TICKET_STATUS == "Inprogress-Er" || logs.TICKET_STATUS == "Inprogress-S" || logs.TICKET_STATUS == "Responded" ||
                logs.TICKET_STATUS == "Closed"
            })
            break
        default:
            break
        }
        
        for request in request_log! {
            let updatedDateString = request.UPDATED_DATE ?? ""
            let createdDateString = request.CREATED_DATE ?? ""
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

            if updatedDateString == "" {
                let diffComponents = Calendar.current.dateComponents([.day],
                                                                     from: dateFormatter.date(from: createdDateString)!,
                                                                     to: Date())
                
                if diffComponents.day! >= request.ESCALATE_DAYS! {
                    switch request.TICKET_STATUS!.lowercased() {
                    case "pending", "submitted":
                        self.tatPendingCounter += 1
                        break
                    case "approved", "investigating", "inprogress-er", "inprogress-s", "responded":
                        self.tatApprovedCounter += 1
                        break
                    case "rejected", "closed":
                        self.tatRejectedCounter += 1
                        break
                    default:
                        break
                    }
                } else {
                    switch request.TICKET_STATUS!.lowercased() {
                    case "pending", "submitted":
                        self.withInPendingCounter += 1
                        break
                    case "approved", "investigating", "inprogress-er", "inprogress-s", "responded":
                        self.withInApprovedCounter += 1
                        break
                    case "rejected", "closed":
                        self.withInRejectedCounter += 1
                        break
                    default:
                        break
                    }
                }
            } else {
               let diffComponents = Calendar.current.dateComponents([.day],
                                                                    from: dateFormatter.date(from: createdDateString)!,
                                                                    to: dateFormatter.date(from: updatedDateString)!)
                
                if diffComponents.day! >= request.ESCALATE_DAYS! {
                    switch request.TICKET_STATUS!.lowercased() {
                    case "pending", "submitted":
                        self.tatPendingCounter += 1
                        break
                    case "approved", "investigating", "inprogress-er", "inprogress-s", "responded":
                        self.tatApprovedCounter += 1
                        break
                    case "rejected", "closed":
                        self.tatRejectedCounter += 1
                        break
                    default:
                        break
                    }
                } else {
                    switch request.TICKET_STATUS!.lowercased() {
                    case "pending", "submitted":
                        self.withInPendingCounter += 1
                        break
                    case "approved", "investigating", "inprogress-er", "inprogress-s", "responded":
                        self.withInApprovedCounter += 1
                        break
                    case "rejected", "closed":
                        self.withInRejectedCounter += 1
                        break
                    default:
                        break
                    }
                }
            }
        }
        
        var tatBreachGraph = [MultipleGraph]()
        var withInTatGraph = [MultipleGraph]()
        switch CONSTANT_MODULE_ID {
        case 1:
            if tatPendingCounter > 0 {
                tatBreachGraph.append(MultipleGraph(ticket_status: "Pending",ticket_total: "\(self.tatPendingCounter)",ticket_date: "",escalate_days: 0,upated_date: "",created_date: ""))
            }
            if tatApprovedCounter > 0 {
                tatBreachGraph.append(MultipleGraph(ticket_status: "Approved",ticket_total: "\(self.tatApprovedCounter)",ticket_date: "",escalate_days: 0,upated_date: "",created_date: ""))
            }
            
            if tatRejectedCounter > 0 {
                tatBreachGraph.append(MultipleGraph(ticket_status: "Rejected",ticket_total: "\(self.tatRejectedCounter)",ticket_date: "",escalate_days: 0,upated_date: "",created_date: ""))
            }
            
            if withInPendingCounter > 0 {
                withInTatGraph.append(MultipleGraph(ticket_status: "Pending",ticket_total: "\(self.withInPendingCounter)",ticket_date: "",escalate_days: 0,upated_date: "",created_date: ""))
            }
            if withInApprovedCounter > 0 {
                withInTatGraph.append(MultipleGraph(ticket_status: "Approved",ticket_total: "\(self.withInApprovedCounter)",ticket_date: "",escalate_days: 0,upated_date: "",created_date: ""))
            }
            
            if withInRejectedCounter > 0 {
                withInTatGraph.append(MultipleGraph(ticket_status: "Rejected",ticket_total: "\(self.withInRejectedCounter)",ticket_date: "",escalate_days: 0,upated_date: "",created_date: ""))
            }
            break
        case 2:
            if tatPendingCounter > 0 {
                tatBreachGraph.append(MultipleGraph(ticket_status: "Submitted",ticket_total: "\(self.tatPendingCounter)",ticket_date: "",escalate_days: 0,upated_date: "",created_date: ""))
            }
            if tatApprovedCounter > 0 {
                tatBreachGraph.append(MultipleGraph(ticket_status: INREVIEW,ticket_total: "\(self.tatApprovedCounter)",ticket_date: "",escalate_days: 0,upated_date: "",created_date: ""))
            }
            
            if tatRejectedCounter > 0 {
                tatBreachGraph.append(MultipleGraph(ticket_status: "Closed",ticket_total: "\(self.tatRejectedCounter)",ticket_date: "",escalate_days: 0,upated_date: "",created_date: ""))
            }
            
            if withInPendingCounter > 0 {
                withInTatGraph.append(MultipleGraph(ticket_status: "Submitted",ticket_total: "\(self.withInPendingCounter)",ticket_date: "",escalate_days: 0,upated_date: "",created_date: ""))
            }
            if withInApprovedCounter > 0 {
                withInTatGraph.append(MultipleGraph(ticket_status: INREVIEW ,ticket_total: "\(self.withInApprovedCounter)",ticket_date: "",escalate_days: 0,upated_date: "",created_date: ""))
            }
            
            if withInRejectedCounter > 0 {
                withInTatGraph.append(MultipleGraph(ticket_status: "Closed",ticket_total: "\(self.withInRejectedCounter)",ticket_date: "",escalate_days: 0,upated_date: "",created_date: ""))
            }
            print("MONTH: \(monthName) -> TAT BREACHED COUNTER:\nP: \(self.withInPendingCounter)\nA:\(self.withInApprovedCounter)\nR:\(self.tatRejectedCounter)\n\n")
            print("MONTH: \(monthName) -> TAT COUNTER:\nP: \(self.tatPendingCounter)\nA:\(self.tatApprovedCounter)\nR:\(self.tatRejectedCounter)\n\n")
            
            break
        default:
            break
        }
        
        
        return [ChartListing(month: monthName, graphs: withInTatGraph),
                ChartListing(month: monthName, graphs: tatBreachGraph)]
        
    }
}


extension NewChartListingViewController: ChartViewDelegate {
    func setupPieChartView(pieChart: PieChartView, chartListing: ChartListing) {
        pieChart.highlightPerTapEnabled = true
        pieChart.usePercentValuesEnabled = false
        pieChart.drawSlicesUnderHoleEnabled = false
        pieChart.holeRadiusPercent = 0.60
        pieChart.chartDescription?.enabled = false
        pieChart.drawEntryLabelsEnabled = false
        pieChart.rotationEnabled = false
        pieChart.legend.form = .empty
        pieChart.centerText = chartListing.month
        
        var entries = [PieChartDataEntry]()
        var set : PieChartDataSet?
        var colors = [UIColor]()
        
        
        switch CONSTANT_MODULE_ID {
        case 1:
            for chart in chartListing.graphs {
                let chartValue = ((chart.ticket_total ?? "0") as NSString).doubleValue
                let key = chart.ticket_status ?? ""
                
                switch key {
                    case "Completed", "Approved":
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
            break
        case 2:
            var inreview : Double = 0
            for chart in chartListing.graphs {
                let chartValue = ((chart.ticket_total ?? "0") as NSString).doubleValue
                let key = chart.ticket_status ?? ""
                
                switch key {
                    case "Submitted":
                        entries.append(PieChartDataEntry(value: chartValue))
                        break
                    case INREVIEW, "Inprogress-Er", "Investigating", "Inprogress-S", "Responded":
                        inreview += chartValue
                        break
                    case "Closed":
                        entries.append(PieChartDataEntry(value: chartValue))
                        break
                    default:
                        break
                }
            }
            if inreview > 0 {
                entries.append(PieChartDataEntry(value: inreview))
            }
            break
        default:
            break
        }
        set = PieChartDataSet(entries: entries, label: "")
        set!.drawIconsEnabled = false
        set!.sliceSpace = 0
        
        switch CONSTANT_MODULE_ID {
        case 1:
            for data in chartListing.graphs {
                let key = data.ticket_status ?? ""
                switch key {
                    case "Completed", "Approved":
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
            break
        case 2:
            var inreview : Double = 0
            for data in chartListing.graphs {
                let key = data.ticket_status ?? ""
                switch key {
                    case "Submitted":
                        colors.append(UIColor.pendingColor())
                        break
                    case INREVIEW, "Inprogress-Er", "Investigating", "Inprogress-S", "Responded":
                        inreview += 1
                        break
                    case "Closed":
                        colors.append(UIColor.rejectedColor())
                        break
                default:
                    break
                }
            }
            if inreview > 0 {
                colors.append(UIColor.approvedColor())
            }
            break
        default:
            break
        }
        
        set!.colors = colors
        set!.selectionShift = 0
        let data = PieChartData(dataSet: set!)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumFractionDigits = 0
        formatter.multiplier = 1.0
        
        data.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        data.setValueFont(.systemFont(ofSize: 9, weight: .regular))
        data.setValueTextColor(.white)
        
        pieChart.data = data
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "WatchAllRequestsViewController") as! WatchAllRequestsViewController
        controller.index = chartView.tag
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        switch chartView.tag {
        case 1:
            let lastMonth = Calendar.current.date(byAdding: .month, value: -0, to: Date())
            
            let lastMonthEndDate = lastMonth?.endOfMonth
            let lastMonthStartDate = lastMonth?.startOfMonth
            
            let startingDateString = dateFormatter.string(from: lastMonthStartDate!).dateOnly
            let endingDateString   = dateFormatter.string(from: lastMonthEndDate!).dateOnly
            
            controller.dateHeading = "\(startingDateString) TO \(endingDateString)"
            
            
            let dF = DateFormatter()
            dF.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            
            let query = "SELECT * FROM \(db_hr_request) WHERE MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CREATED_DATE <= '\(getLocalCurrentDate())' AND CREATED_DATE >= '\(dF.string(from: Date().getCurrentMonthStart()!))' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"

            controller.tbl_request_logs = (AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: query))!
            controller.query = query
            controller.isAllRequests = true
            
            controller.title = "All Requests"
            break
        case 2:
            let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())
            
            let lastMonthEndDate = lastMonth?.endOfMonth
            let lastMonthStartDate = lastMonth?.startOfMonth
            
            let startingDateString = dateFormatter.string(from: lastMonthStartDate!).dateOnly
            let endingDateString   = dateFormatter.string(from: lastMonthEndDate!).dateOnly
            
            controller.dateHeading = "\(startingDateString) TO \(endingDateString)"
            let dF = DateFormatter()
            dF.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let query = "SELECT * FROM \(db_hr_request) WHERE MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CREATED_DATE >= '\(dF.string(from: lastMonthStartDate!))' AND CREATED_DATE <= '\(dF.string(from: lastMonthEndDate!))' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
            controller.query = query
            controller.isAllRequests = true
            controller.tbl_request_logs = (AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: query))!
            controller.title = "All Requests"
            break
        case 3:
            let lastMonth = Calendar.current.date(byAdding: .month, value: -2, to: Date())
            
            let lastMonthEndDate = lastMonth?.endOfMonth
            let lastMonthStartDate = lastMonth?.startOfMonth
            
            let startingDateString = dateFormatter.string(from: lastMonthStartDate!).dateOnly
            let endingDateString   = dateFormatter.string(from: lastMonthEndDate!).dateOnly
            
            controller.dateHeading = "\(startingDateString) TO \(endingDateString)"
            
            let dF = DateFormatter()
            dF.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let query = "SELECT * FROM \(db_hr_request) WHERE MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CREATED_DATE >= '\(dF.string(from: lastMonthStartDate!))' AND CREATED_DATE <= '\(dF.string(from: lastMonthEndDate!))' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
            controller.query = query
            controller.isAllRequests = true
            controller.tbl_request_logs = (AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: query))!
            controller.title = "All Requests"
            break
        case 4:
            
            let lastMonth = Calendar.current.date(byAdding: .month, value: -0, to: Date())
            
            let lastMonthEndDate = lastMonth?.endOfMonth
            let lastMonthStartDate = lastMonth?.startOfMonth
            
            let startingDateString = dateFormatter.string(from: lastMonthStartDate!).dateOnly
            let endingDateString   = dateFormatter.string(from: lastMonthEndDate!).dateOnly
            
            controller.dateHeading = "\(startingDateString) TO \(endingDateString)"
            
            controller.tbl_request_logs = self.calculateWithInTat(days: nil, month: 0, start_day: nil, end_day: nil)
            
            controller.isTAT = true
            controller.title = "TAT"
            break
        case 5:
            
            let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())
            
            let lastMonthEndDate = lastMonth?.endOfMonth
            let lastMonthStartDate = lastMonth?.startOfMonth
            
            let startingDateString = dateFormatter.string(from: lastMonthStartDate!).dateOnly
            let endingDateString   = dateFormatter.string(from: lastMonthEndDate!).dateOnly
            
            controller.dateHeading = "\(startingDateString) TO \(endingDateString)"
            
            controller.tbl_request_logs = self.calculateWithInTat(days: nil, month: 1, start_day: nil, end_day: nil)
            
            controller.isTAT = true
            controller.title = "TAT"
            break
        case 6:
            
            let lastMonth = Calendar.current.date(byAdding: .month, value: -2, to: Date())
            
            let lastMonthEndDate = lastMonth?.endOfMonth
            let lastMonthStartDate = lastMonth?.startOfMonth
            
            let startingDateString = dateFormatter.string(from: lastMonthStartDate!).dateOnly
            let endingDateString   = dateFormatter.string(from: lastMonthEndDate!).dateOnly
            
            controller.dateHeading = "\(startingDateString) TO \(endingDateString)"
            
            controller.tbl_request_logs = self.calculateWithInTat(days: nil, month: 2, start_day: nil, end_day: nil)
            
            controller.isTAT = true
            controller.title = "TAT"
            break
        case 7:
            
            let lastMonth = Calendar.current.date(byAdding: .month, value: -0, to: Date())
            
            let lastMonthEndDate = lastMonth?.endOfMonth
            let lastMonthStartDate = lastMonth?.startOfMonth
            
            let startingDateString = dateFormatter.string(from: lastMonthStartDate!).dateOnly
            let endingDateString   = dateFormatter.string(from: lastMonthEndDate!).dateOnly
            
            controller.dateHeading = "\(startingDateString) TO \(endingDateString)"
            
            controller.tbl_request_logs = self.calculateTatBreached(days: nil, month: 0, start_day: nil, end_day: nil)

            controller.isTATBreached = true
            controller.title = "TAT BREACHED"
            break
        case 8:
            
            let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())
            
            let lastMonthEndDate = lastMonth?.endOfMonth
            let lastMonthStartDate = lastMonth?.startOfMonth
            
            let startingDateString = dateFormatter.string(from: lastMonthStartDate!).dateOnly
            let endingDateString   = dateFormatter.string(from: lastMonthEndDate!).dateOnly
            
            controller.dateHeading = "\(startingDateString) TO \(endingDateString)"
            
            controller.tbl_request_logs = self.calculateTatBreached(days: nil, month: 1, start_day: nil, end_day: nil)
        
            controller.isTATBreached = true
            controller.title = "TAT BREACHED"
            break
        case 9:
            
            let lastMonth = Calendar.current.date(byAdding: .month, value: -2, to: Date())
            
            let lastMonthEndDate = lastMonth?.endOfMonth
            let lastMonthStartDate = lastMonth?.startOfMonth
            
            let startingDateString = dateFormatter.string(from: lastMonthStartDate!).dateOnly
            let endingDateString   = dateFormatter.string(from: lastMonthEndDate!).dateOnly
            
            controller.dateHeading = "\(startingDateString) TO \(endingDateString)"
            
            controller.tbl_request_logs = self.calculateTatBreached(days: nil, month: 2, start_day: nil, end_day: nil)
        
            controller.isTATBreached = true
            controller.title = "TAT BREACHED"
        default:
            break
        }
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
}



extension NewChartListingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = self.circularGraph?.count {
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let circularGraphCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CicrularProgressBarCell", for: indexPath) as! CicrularProgressBarCollectionCell
        
        let data = self.circularGraph![indexPath.row]
        
        circularGraphCell.titleLabel.text = data.Title
        circularGraphCell.circularView.progressColor = UIColor.init(hexString: data.ColorCode)
        circularGraphCell.circularView.maxValue = CGFloat(Int(data.TotalCount)! + 30)
        circularGraphCell.circularView.value = CGFloat(Int(data.TotalCount)!)
        
        return circularGraphCell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let data = self.circularGraph {
            print(data[indexPath.row].Title)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            let lastMonth = Calendar.current.date(byAdding: .month, value: -2, to: Date())
            let lastMonthStartDate = lastMonth?.startOfMonth
            
            let currentMonth = Calendar.current.date(byAdding: .month, value: 0, to: Date())
            let lastMonthEndDate = currentMonth?.endOfMonth
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "WatchAllRequestsViewController") as! WatchAllRequestsViewController
            
            var query = ""
            if self.mqid == "0" {
                query = "SELECT * FROM \(db_hr_request) WHERE CREATED_DATE >= '\(dateFormatter.string(from: lastMonthStartDate!))' AND CREATED_DATE <= '\(dateFormatter.string(from: lastMonthEndDate!))'  AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' AND (MQ_ID = \(data[indexPath.row].SERVER_ID_PK) OR DQ_ID = '\(self.dqid)' ) order by CREATED_DATE ASC "
                
                controller.mq_id = data[indexPath.row].SERVER_ID_PK
                controller.dq_id = Int(self.dqid)
            } else {
                query = "select * from \(db_hr_request) WHERE CREATED_DATE >='\(dateFormatter.string(from: lastMonthStartDate!))' AND CREATED_DATE <= '\(dateFormatter.string(from: lastMonthEndDate!))'  AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' AND (MQ_ID = '\(self.mqid)' AND DQ_ID = '\(data[indexPath.row].SERVER_ID_PK)' ) order by CREATED_DATE ASC"
//                controller.isMQ_ID = self.mqid
                controller.mq_id = Int(self.mqid)
                controller.dq_id = data[indexPath.row].SERVER_ID_PK
            }
            
            let request_log = AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: query)
            
            
            dateFormatter.dateFormat = "dd-MMM-yyyy"
            let startingDateString = dateFormatter.string(from: lastMonthStartDate!).dateOnly
            let endingDateString   = dateFormatter.string(from: lastMonthEndDate!).dateOnly
            
            
            controller.isQueryAndSubQuery = true
            controller.dateHeading = "\(startingDateString) TO \(endingDateString)"
            controller.tbl_request_logs = request_log
            controller.title = data[indexPath.row].Title
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth = collectionView.bounds.width / 3.0
        let yourHeight =  CGFloat(170)

        return CGSize(width: yourWidth, height: yourHeight)
    }
}


extension NewChartListingViewController: GraphListingDelegate {
    func updateGraphListingFilter(id: String, title: String) {
        self.mqid = id
        self.selected_item = title
        self.setupCircularWithConditions(id: id)
    }
}
