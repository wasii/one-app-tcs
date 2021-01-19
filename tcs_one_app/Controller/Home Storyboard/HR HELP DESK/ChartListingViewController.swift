//
//  ChartListingViewController.swift
//  tcs_one_app
//
//  Created by ibs on 20/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit

class ChartListingViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    
    var multipleCharts : [MultipleCharts]?
    
    var isTat = [ChartListing]()
    var isTatBreach = [ChartListing]()
    
    
    var tatPendingCounter = 0
    var tatApprovedCounter = 0
    var tatRejectedCounter = 0
    
    var withInPendingCounter = 0
    var withInApprovedCounter = 0
    var withInRejectedCounter = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Dashboard"
        
        self.makeTopCornersRounded(roundView: self.mainView)
        
        DispatchQueue.main.async {
        self.setTitle(title: "Dashboard")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.mainViewHeightConstraint.constant += 1080
            self.mainView.layoutIfNeeded()
            
        }
        
        self.tableView.register(UINib(nibName: "GraphListingTableCell", bundle: nil), forCellReuseIdentifier: "GraphListingCell")
        
        self.tableView.rowHeight = 250.0
        
        
        setupGraphs()
    }
    
    func setupGraphs() {
        let module_id = AppDelegate.sharedInstance.db?.read_tbl_UserModule(query: "SELECT * FROM \(db_user_module) WHERE TAGNAME = '\(MODULE_TAG_HR)';").first
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        multipleCharts = [MultipleCharts]()
        
        var sections = [ChartListing]()
        for i in 0...2 {
            switch i {
            case 0:
                let startingDate = Date().getCurrentMonthStart()
                let endDate = getLocalCurrentDate()
                let monthName = Date().getCurrentMonthStart()?.monthAsString()
                
                let graph = AppDelegate.sharedInstance.db?.getThreeMonthGraphs(
                                                   startDate: dateFormatter.string(from: startingDate!),
                                                   endDate: endDate)
                
                if graph!.count > 0 {
                    sections.append(ChartListing(month: monthName!, graphs: graph!))
                }
                break
                
            case 1:
                let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())
                
                let lastMonthEndDate = lastMonth?.endOfMonth
                let lastMonthStartDate = lastMonth?.startOfMonth
                
                let monthName = lastMonthStartDate!.monthAsString()
                
                let graph = AppDelegate.sharedInstance.db?.getThreeMonthGraphs(
                                                   startDate: dateFormatter.string(from: lastMonthStartDate!),
                                                   endDate: dateFormatter.string(from: lastMonthEndDate!))
                
                
                
                if graph!.count > 0 {
                    sections.append(ChartListing(month: monthName, graphs: graph!))
                }
                break
            case 2:
                let lastMonth = Calendar.current.date(byAdding: .month, value: -2, to: Date())
                
                let lastMonthEndDate = lastMonth?.endOfMonth
                let lastMonthStartDate = lastMonth?.startOfMonth
                
                let monthName = lastMonthStartDate!.monthAsString()
                
                let graph = AppDelegate.sharedInstance.db?.getThreeMonthGraphs(
                                                   startDate: dateFormatter.string(from: lastMonthStartDate!),
                                                   endDate: dateFormatter.string(from: lastMonthEndDate!))
                
                
                if graph!.count > 0 {
                    sections.append(ChartListing(month: monthName, graphs: graph!))
                }
                
                break
            default:
                break
            }
        }
        multipleCharts?.append(MultipleCharts(chartListing: sections, count: sections.count, title: "Request Status (Last three month)"))
        
        for i in 0...1 {
            switch i {
            case 0:
                sections = [ChartListing]()
                for j in 0...2 {
                    self.tatPendingCounter = 0
                    self.tatApprovedCounter = 0
                    self.tatRejectedCounter = 0
                    sections.append(self.calculateTatBreach(numberOfDays: -j, moduleId: module_id!.SERVER_ID_PK))
                }
                multipleCharts?.append(MultipleCharts(chartListing: sections, count: sections.count, title: "Request Status TAT BREACHED (Last three months)"))
                break
            case 1:
                sections = [ChartListing]()
                for j in 0...2 {
                    self.withInRejectedCounter = 0
                    self.withInApprovedCounter = 0
                    self.withInPendingCounter = 0
                    sections.append(self.calculateWithBreach(numberOfDays: -j, module_id: module_id!.SERVER_ID_PK))
                }
                multipleCharts?.append(MultipleCharts(chartListing: sections, count: sections.count, title: "Reqeust Status TAT (Last three months)"))
                break
            default:
                break
            }
        }
        
        self.tableView.reloadData()
    }
    
    
    func calculateWithBreach(numberOfDays: Int, module_id: Int) -> ChartListing {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let lastMonth = Calendar.current.date(byAdding: .month, value: numberOfDays, to: Date())
        
        let lastMonthEndDate = lastMonth?.endOfMonth
        let lastMonthStartDate = lastMonth?.startOfMonth
        
        let monthName = lastMonthStartDate!.monthAsString()
        
        
        let request_log_query = "select * from REQUEST_LOGS WHERE module_id = '\(module_id)' AND Created_Date >= '\(dateFormatter.string(from: lastMonthStartDate!))' AND Created_Date <= '\(dateFormatter.string(from: lastMonthEndDate!))' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
        
        let request_log = AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: request_log_query)
        
        
        for request in request_log! {
            let updatedDateString = request.UPDATED_DATE ?? ""
            let createdDateString = request.CREATED_DATE ?? ""
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

            if updatedDateString == "" {
                let diffComponents = Calendar.current.dateComponents([.day],
                                                                     from: dateFormatter.date(from: createdDateString)!,
                                                                     to: Date())
                
                if diffComponents.day! <= request.ESCALATE_DAYS! {
                    print("within tat")
                    switch request.TICKET_STATUS!.lowercased() {
                    case "pending":
                        self.withInPendingCounter += 1
                        break
                    case "approved":
                        self.withInApprovedCounter += 1
                        break
                    case "rejected":
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
                
                if diffComponents.day! <= request.ESCALATE_DAYS! {
                    print("within tat")
                    switch request.TICKET_STATUS!.lowercased() {
                    case "pending":
                        self.withInPendingCounter += 1
                        break
                    case "approved":
                        self.withInApprovedCounter += 1
                        break
                    case "rejected":
                        self.withInRejectedCounter += 1
                        break
                    default:
                        break
                    }
                }
            }
        }
        
        var g = [MultipleGraph]()
        
        if withInPendingCounter > 0 {
            g.append(MultipleGraph(ticket_status: "Pending",ticket_total: "\(self.tatPendingCounter)",ticket_date: "",escalate_days: 0,upated_date: "",created_date: ""))
        }
        if withInApprovedCounter > 0 {
            g.append(MultipleGraph(ticket_status: "Approved",ticket_total: "\(self.tatApprovedCounter)",ticket_date: "",escalate_days: 0,upated_date: "",created_date: ""))
        }
        
        if withInRejectedCounter > 0 {
            g.append(MultipleGraph(ticket_status: "Rejected",ticket_total: "\(self.tatRejectedCounter)",ticket_date: "",escalate_days: 0,upated_date: "",created_date: ""))
        }
        
        return ChartListing(month: monthName, graphs: g)
    }
    
    func calculateTatBreach(numberOfDays: Int, moduleId: Int) -> ChartListing {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let lastMonth = Calendar.current.date(byAdding: .month, value: numberOfDays, to: Date())
        
        let lastMonthEndDate = lastMonth?.endOfMonth
        let lastMonthStartDate = lastMonth?.startOfMonth
        
        let monthName = lastMonthStartDate!.monthAsString()
        
        let request_log_query = "select * from REQUEST_LOGS WHERE module_id = '\(moduleId)' AND Created_Date >= '\(dateFormatter.string(from: lastMonthStartDate!))' AND Created_Date <= '\(dateFormatter.string(from: lastMonthEndDate!))' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
        
        let request_log = AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: request_log_query)
        
        
        for request in request_log! {
            let updatedDateString = request.UPDATED_DATE ?? ""
            let createdDateString = request.CREATED_DATE ?? ""
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

            if updatedDateString == "" {
                let diffComponents = Calendar.current.dateComponents([.day],
                                                                     from: dateFormatter.date(from: createdDateString)!,
                                                                     to: Date())
                
                if diffComponents.day! > request.ESCALATE_DAYS! {
                    print("tat breach")
                    switch request.TICKET_STATUS!.lowercased() {
                    case "pending":
                        self.tatPendingCounter += 1
                        break
                    case "approved":
                        self.tatApprovedCounter += 1
                        break
                    case "rejected":
                        self.tatRejectedCounter += 1
                        break
                    default:
                        break
                    }
                }
            } else {
               let diffComponents = Calendar.current.dateComponents([.day],
                                                                    from: dateFormatter.date(from: createdDateString)!,
                                                                    to: dateFormatter.date(from: updatedDateString)!)
                
                if diffComponents.day! > request.ESCALATE_DAYS! {
                    print("tat breach")
                    switch request.TICKET_STATUS!.lowercased() {
                    case "pending":
                        self.tatPendingCounter += 1
                        break
                    case "approved":
                        self.tatApprovedCounter += 1
                        break
                    case "rejected":
                        self.tatRejectedCounter += 1
                        break
                    default:
                        break
                    }
                }
            }
        }
        
        var g = [MultipleGraph]()
        
        if tatPendingCounter > 0 {
            g.append(MultipleGraph(ticket_status: "Pending",ticket_total: "\(self.tatPendingCounter)",ticket_date: "",escalate_days: 0,upated_date: "",created_date: ""))
        }
        if tatApprovedCounter > 0 {
            g.append(MultipleGraph(ticket_status: "Approved",ticket_total: "\(self.tatApprovedCounter)",ticket_date: "",escalate_days: 0,upated_date: "",created_date: ""))
        }
        
        if tatRejectedCounter > 0 {
            g.append(MultipleGraph(ticket_status: "Rejected",ticket_total: "\(self.tatRejectedCounter)",ticket_date: "",escalate_days: 0,upated_date: "",created_date: ""))
        }
        
        return ChartListing(month: monthName, graphs: g)
    }
}


extension ChartListingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.multipleCharts?.count {
            return count + 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GraphListingCell") as! GraphListingTableCell
        cell.crossBtn.isHidden = true
        cell.filterBtn.isHidden = true
        
        if indexPath.row == self.multipleCharts!.count {
            cell.crossBtn.isHidden = false
            cell.filterBtn.isHidden = false
            cell.setupCircular()
            return cell
        }
        

        
        let multipleChart = self.multipleCharts![indexPath.row]
        cell.mainHeading_Label.text = multipleChart.title
        cell.multipleCharts = [multipleChart]
        cell.setup()
        return cell
    }
}



struct MultipleCharts {
    var chartListing: [ChartListing]
    var count: Int
    var title: String
}
struct ChartListing {
    var month: String
    var graphs: [MultipleGraph]
}
