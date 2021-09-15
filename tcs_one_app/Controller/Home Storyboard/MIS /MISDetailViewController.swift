//
//  MISDetailViewController.swift
//  tcs_one_app
//
//  Created by TCS on 07/09/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import Charts

class MISDetailViewController: BaseViewController {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var lineChart: LineChartView!
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    var mis_budget_setup: tbl_mis_budget_setup?
    var mis_popup_mnth: MISPopupMonth?
    var mis_popop_year: MISPopupYear?
    
    var monthInNumber: String = ""
    var monthName: String = ""
    var year: String = ""
    
    
    let df = DateFormatter()
    
    var budget_data: [tbl_mis_budget_data_details]?
    var tableView_data: [ProductType]?
    var isDualValue: Bool = false
    
    var lastObject: tbl_mis_budget_data_details = tbl_mis_budget_data_details()
    
    var dataEntryX: [String] = [String]()
    var dataEntryY: [Double] = [Double]()
    
    var monthlyTarget: Double = 0.0
    weak var axisFormatDelegate: IAxisValueFormatter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeTopCornersRounded(roundView: self.mainView)
        title = "MIS"
        if let product = mis_budget_setup?.product {
            headingLabel.text = product
        }
        collectionView.register(UINib(nibName: MISCollectionCell.description(), bundle: nil), forCellWithReuseIdentifier: MISCollectionCell.description())
        tableView.register(UINib(nibName: MISDetailTableCell.description(), bundle: nil), forCellReuseIdentifier: MISDetailTableCell.description())
        tableView.register(UINib(nibName: "MISHeaderCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "MISHeaderCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 30
        
        df.dateFormat = "MMMM"
        monthName = df.string(from: Date())
        df.dateFormat = "yyyy"
        year = df.string(from: Date())
        
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "LLLL"  // if you need 3 letter month just use "LLL"
        if let date = df.date(from: monthName) {
            let month = Calendar.current.component(.month, from: date)
            self.monthInNumber = "\(month)"
        }
        
        self.monthLabel.text = monthName
        self.yearLabel.text = year
        
        if monthInNumber.count == 1 {
            monthInNumber = "0\(monthInNumber)"
        }
        reloadData(date: "\(year)-\(monthInNumber)")
    }
    
    private func reloadData(date: String) {
        dataEntryX = [String]()
        dataEntryY = [Double]()
        self.axisFormatDelegate = self
        self.lineChart.data = nil
        self.freezeScreen()
        self.view.makeToastActivity(.center)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.unFreezeScreen()
            self.view.hideToastActivity()
            self.setupJSON(date: date) { count in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.collectionView.reloadData()
                    self.collectionViewHeightConstraint.constant = CGFloat(30 * count) + 70
                    
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.setupTableView { _ in
                        self.tableView.reloadData()
                        self.tableViewHeightConstraint.constant = CGFloat(30 * self.tableView_data!.count) + CGFloat(40)
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    //setupgraph
                    self.setupGraph()
                }
            }
        }
    }
    private func setupJSON(date: String, _ handler: @escaping(Int)->Void) {
        
        var query = ""
        if isDualValue {
            query = "SELECT PERMISSION.IS_DSR_SHOW, PERMISSION.IS_QSR_SHOW, PERMISSION.IS_SHIP_SHOW, PERMISSION.IS_WEIGHT_SHOW, group_concat(TYPE, '*') AS ALL_TYPE , GROUP_CONCAT(SHIP, '*') AS ALL_SHIP , GROUP_CONCAT(DSR, '*') AS ALL_DSR , GROUP_CONCAT(QSR, '*') AS ALL_QSR, GROUP_CONCAT(WEIGHT, '*') AS ALL_WEIGHT, AVG(DSR) AS DSR, PRODUCT, AVG(QSR) AS QSR , RPT_DATE, SUM(SHIP) AS SHIP, TYPE , SUM(WEIGHT) AS WEIGHT FROM (SELECT * FROM MIS_BUDGET_DATA WHERE PRODUCT = '\(mis_budget_setup?.product ?? "")' AND (RPT_DATE BETWEEN '\(date)-01' AND '\(date)-31') ORDER BY RPT_DATE,TYPE DESC), (SELECT AVG(DSR) > 0.0 AS IS_DSR_SHOW, AVG(QSR) > 0.0 AS IS_QSR_SHOW, SUM(SHIP) > 0 AS IS_SHIP_SHOW, SUM(WEIGHT) > 0.0 AS IS_WEIGHT_SHOW FROM MIS_BUDGET_DATA WHERE PRODUCT = '\(mis_budget_setup?.product ?? "")' AND (RPT_DATE BETWEEN '\(date)-01' AND '\(date)-31') GROUP BY PRODUCT) AS PERMISSION GROUP BY RPT_DATE"
        } else {
            query = "SELECT PERMISSION.IS_DSR_SHOW, PERMISSION.IS_QSR_SHOW, PERMISSION.IS_SHIP_SHOW, PERMISSION.IS_WEIGHT_SHOW, '' AS ALL_TYPE , '' AS ALL_SHIP , '' AS ALL_DSR , '' AS ALL_QSR, '' AS ALL_WEIGHT, AVG(DSR) AS DSR, PRODUCT, AVG(QSR) AS QSR , RPT_DATE, SUM(SHIP) AS SHIP, TYPE , SUM(WEIGHT) AS WEIGHT FROM (SELECT * FROM MIS_BUDGET_DATA WHERE PRODUCT = '\(mis_budget_setup?.product ?? "")' AND (RPT_DATE BETWEEN '\(date)-01' AND '\(date)-31') ORDER BY RPT_DATE,TYPE DESC), (SELECT AVG(DSR) > 0.0 AS IS_DSR_SHOW, AVG(QSR) > 0.0 AS IS_QSR_SHOW, SUM(SHIP) > 0 AS IS_SHIP_SHOW, SUM(WEIGHT) > 0.0 AS IS_WEIGHT_SHOW FROM MIS_BUDGET_DATA WHERE PRODUCT = '\(mis_budget_setup?.product ?? "")' AND (RPT_DATE BETWEEN '\(date)-01' AND '\(date)-31') GROUP BY PRODUCT) AS PERMISSION GROUP BY RPT_DATE"
        }
        
        if let budget_data = AppDelegate.sharedInstance.db?.read_tbl_mis_budget_data_detail(query: query) {
            //Double
            var shipmentTotal: String = String()
            var dsrTotal: String = String()
            var qsrTotal: String = String()
            var weightTotal: String = String()
            
            //Single
            var totalShip: Double = 0.0
            var totalDsr: Double = 0.0
            var totalQsr: Double = 0.0
            var totalWeight: Double = 0.0
            
            budget_data.forEach { bd in
                if isDualValue {
                    if shipmentTotal == "" {
                        shipmentTotal = bd.ALL_SHIP
                    } else {
                        let tempShipmentTotal = shipmentTotal.split(separator: "*")
                        let tempBD = bd.ALL_SHIP.split(separator: "*")
                        
                        var temp_value = ""
                        for (st,bd) in zip(tempShipmentTotal, tempBD) {
                            let t = (st as NSString).doubleValue + (bd as NSString).doubleValue
                            if temp_value == "" {
                                temp_value = "\(String(format: "%.2f", t))*"
                            } else {
                                temp_value += "\(String(format: "%.2f", t))*"
                            }
                        }
                        shipmentTotal = temp_value
                    }
                    
                    if dsrTotal == "" {
                        dsrTotal = bd.ALL_DSR
                    } else {
                        let tempDSRTotal = dsrTotal.split(separator: "*")
                        let tempBD = bd.ALL_DSR.split(separator: "*")
                        
                        var temp_value = ""
                        for (st,bd) in zip(tempDSRTotal, tempBD) {
                            let t = (st as NSString).doubleValue + (bd as NSString).doubleValue
                            if temp_value == "" {
                                temp_value = "\(String(format: "%.2f", t))*"
                            } else {
                                temp_value += "\(String(format: "%.2f", t))*"
                            }
                        }
                        dsrTotal = temp_value
                    }
                    
                    if qsrTotal == "" {
                        qsrTotal = bd.ALL_QSR
                    } else {
                        let tempQSRTotal = qsrTotal.split(separator: "*")
                        let tempBD = bd.ALL_QSR.split(separator: "*")
                        
                        var temp_value = ""
                        for (st,bd) in zip(tempQSRTotal, tempBD) {
                            let t = (st as NSString).doubleValue + (bd as NSString).doubleValue
                            if temp_value == "" {
                                temp_value = "\(String(format: "%.2f", t))*"
                            } else {
                                temp_value += "\(String(format: "%.2f", t))*"
                            }
                        }
                        qsrTotal = temp_value
                    }
                    
                    if weightTotal == "" {
                        weightTotal = bd.ALL_WEIGHT
                    } else {
                        let tempWeightTotal = weightTotal.split(separator: "*")
                        let tempBD = bd.ALL_WEIGHT.split(separator: "*")
                        
                        var temp_value = ""
                        for (st,bd) in zip(tempWeightTotal, tempBD) {
                            let t = (st as NSString).doubleValue + (bd as NSString).doubleValue
                            if temp_value == "" {
                                temp_value = "\(String(format: "%.2f", t))*"
                            } else {
                                temp_value += "\(String(format: "%.2f", t))*"
                            }
                        }
                        weightTotal = temp_value
                    }
                }
                totalDsr += (bd.DSR as NSString).doubleValue
                totalQsr += (bd.QSR as NSString).doubleValue
                totalShip += (bd.SHIP as NSString).doubleValue
                totalWeight += (bd.WEIGHT as NSString).doubleValue
            }
            var dsrTypeName = ""
            var qsrTypeName = ""
            var weightTypeName = ""
            
            if isDualValue {
                let splitType = budget_data[0].ALL_TYPE.split(separator: "*")
                for (index, data) in splitType.enumerated() {
                    if (splitType.count - 1 == index) {
                        dsrTypeName += "\(data) DSR"
                        qsrTypeName += "\(data) QSR"
                        weightTypeName += "\(data) Weight"
                    } else {
                        dsrTypeName += "\(data) DSR*"
                        qsrTypeName += "\(data) QSR*"
                        weightTypeName += "\(data) Weight*"
                    }
                }
            }
            
            let headingObject: tbl_mis_budget_data_details = tbl_mis_budget_data_details(IS_DSR_SHOW: budget_data[0].IS_DSR_SHOW, IS_QSR_SHOW: budget_data[0].IS_QSR_SHOW, IS_SHIP_SHOW: budget_data[0].IS_SHIP_SHOW, IS_WEIGHT_SHOW: budget_data[0].IS_WEIGHT_SHOW, ALL_TYPE: "", ALL_SHIP: budget_data[0].ALL_TYPE, ALL_DSR: dsrTypeName, ALL_QSR: qsrTypeName, ALL_WEIGHT: weightTypeName, DSR: "Total DSR", PRODUCT: "", QSR: "Total QSR", RPT_DATE: "Date", SHIP: "Total", TYPE: "", WEIGHT: "Total Weight")
            self.budget_data = [tbl_mis_budget_data_details]()
            self.budget_data = budget_data
            self.budget_data!.insert(headingObject, at: 0)
            if isDualValue {
                self.lastObject = tbl_mis_budget_data_details(IS_DSR_SHOW: budget_data[0].IS_DSR_SHOW,
                                                              IS_QSR_SHOW: budget_data[0].IS_QSR_SHOW,
                                                              IS_SHIP_SHOW: budget_data[0].IS_SHIP_SHOW,
                                                              IS_WEIGHT_SHOW: budget_data[0].IS_WEIGHT_SHOW,
                                                              ALL_TYPE: budget_data[0].ALL_TYPE,
                                                              ALL_SHIP: shipmentTotal,
                                                              ALL_DSR: dsrTotal,
                                                              ALL_QSR: qsrTotal,
                                                              ALL_WEIGHT: weightTotal,
                                                              DSR: String(format: "%.2f", totalDsr/Double(budget_data.count - 1)),
                                                              PRODUCT: "",
                                                              QSR: String(format: "%.2f", totalQsr/Double(budget_data.count - 1)),
                                                              RPT_DATE: "Date",
                                                              SHIP: "\(totalShip)",
                                                              TYPE: "",
                                                              WEIGHT: "\(totalWeight)")
                self.budget_data!.append(lastObject)
            } else {
                self.lastObject = tbl_mis_budget_data_details(IS_DSR_SHOW: budget_data[0].IS_DSR_SHOW,
                                                              IS_QSR_SHOW: budget_data[0].IS_QSR_SHOW,
                                                              IS_SHIP_SHOW: budget_data[0].IS_SHIP_SHOW,
                                                              IS_WEIGHT_SHOW: budget_data[0].IS_WEIGHT_SHOW,
                                                              ALL_TYPE: "",
                                                              ALL_SHIP: budget_data[0].ALL_TYPE,
                                                              ALL_DSR: dsrTypeName,
                                                              ALL_QSR: qsrTypeName,
                                                              ALL_WEIGHT: weightTypeName,
                                                              DSR: String(format: "%.2f", totalDsr/Double(budget_data.count - 1)),
                                                              PRODUCT: "",
                                                              QSR: String(format: "%.2f", totalQsr/Double(budget_data.count - 1)),
                                                              RPT_DATE: "Date",
                                                              SHIP: String(format: "%.2f", totalShip),
                                                              TYPE: "",
                                                              WEIGHT: String(format: "%.2f", totalWeight))
                self.budget_data!.append(lastObject)
            }
            handler(budget_data.count)
        }
    }
    private func setupTableView(_ handler: @escaping(Bool)->Void) {
        let query = "SELECT * FROM \(db_mis_budget_setup) WHERE PRODUCT = '\(mis_budget_setup?.product ?? "")' AND MNTH = '\(self.monthName)' AND YEARR = '\(self.year)'"
        if let budget_setup = AppDelegate.sharedInstance.db?.read_tbl_mis_budget_setup(query: query) {
//            print(budget_setup)
            self.tableView_data = [ProductType]()
            let allType = lastObject.ALL_TYPE.split(separator: "*")
            let shipment = lastObject.ALL_SHIP.split(separator: "*")
            let qsr = lastObject.ALL_QSR.split(separator: "*")
            let dsr = lastObject.ALL_DSR.split(separator: "*")
            let weight = lastObject.ALL_WEIGHT.split(separator: "*")
            
            monthlyTarget = 0.0
            
            for (i,setup) in budget_setup.enumerated() {
                
                if lastObject.IS_SHIP_SHOW == "1" {
                    monthlyTarget += Double(setup.budgeted)
                    if isDualValue {
                        let title = String("\(allType[i]) Target PM")
                        let budget = "\(setup.budgeted)"
                        let actual = String(shipment[i])
                        let variance = Int((budget as NSString).intValue) - Int((actual as NSString).intValue)
                        
                        self.tableView_data!.append(ProductType(title: title, budgeted: budget, actual: actual, variance: "\(variance)"))
                        
                        let pdtitle = String("\(allType[i]) Target PD")
                        let pdbudget = "\(setup.pdBudget)"
                        let pdactual = Int((shipment[i] as NSString).intValue) / self.budget_data!.count - 2
                        let pdvariance = Int((pdbudget as NSString).intValue) - pdactual
                        
                        self.tableView_data!.append(ProductType(title: pdtitle, budgeted: pdbudget, actual: "\(pdactual)", variance: "\(pdvariance)"))
                    } else {
                        let title = "Shipment PM"
                        let budget = "\(setup.budgeted)"
                        let actual = lastObject.SHIP
                        let variance = Int((budget as NSString).intValue) - Int((actual as NSString).intValue)
                        
                        self.tableView_data!.append(ProductType(title: title, budgeted: budget, actual: actual, variance: "\(variance)"))
                        
                        let pdtitle = "Shipment PD"
                        let pdbudget = "\(setup.pdBudget)"
                        let pdactual = Int((lastObject.SHIP as NSString).intValue) / self.budget_data!.count - 2
                        let pdvariance = Int((pdbudget as NSString).intValue) - pdactual
                        
                        self.tableView_data!.append(ProductType(title: pdtitle, budgeted: pdbudget, actual: "\(pdactual)", variance: "\(pdvariance)"))
                    }
                }
                if lastObject.IS_DSR_SHOW == "1" {
                    if isDualValue {
                        let title = String("\(allType[i]) Target DSR")
                        let budget = "\(setup.dsr)"
                        let actual = String(dsr[i])
                        let variance = Int((budget as NSString).intValue) - Int((actual as NSString).intValue)
                        
                        self.tableView_data!.append(ProductType(title: title, budgeted: budget, actual: actual, variance: "\(variance)"))
                        
                    } else {
                        let title = "Target DSR"
                        let budget = "\(setup.dsr)"
                        let actual = lastObject.DSR
                        let variance = Int((budget as NSString).intValue) - Int((actual as NSString).intValue)
                        
                        self.tableView_data!.append(ProductType(title: title, budgeted: budget, actual: actual, variance: "\(variance)"))
                    }
                }
                if lastObject.IS_QSR_SHOW == "1" {
                    if isDualValue {
                        let title = String("\(allType[i]) Target QSR")
                        let budget = "\(setup.qsr)"
                        let actual = String(qsr[i])
                        let variance = Int((budget as NSString).intValue) - Int((actual as NSString).intValue)
                        
                        self.tableView_data!.append(ProductType(title: title, budgeted: budget, actual: actual, variance: "\(variance)"))
                        
                    } else {
                        let title = "Target QSR"
                        let budget = "\(setup.qsr)"
                        let actual = lastObject.QSR
                        let variance = Int((budget as NSString).intValue) - Int((actual as NSString).intValue)
                        
                        self.tableView_data!.append(ProductType(title: title, budgeted: budget, actual: actual, variance: "\(variance)"))
                    }
                }
                if lastObject.IS_WEIGHT_SHOW == "1" {
                    monthlyTarget += Double(setup.weight)
                    if isDualValue {
                        let title = String("\(allType[i]) Weight PM")
                        let budget = "\(setup.weight)"
                        let actual = String(weight[i])
                        let variance = Int((budget as NSString).intValue) - Int((actual as NSString).intValue)
                        
                        self.tableView_data!.append(ProductType(title: title, budgeted: budget, actual: actual, variance: "\(variance)"))
                        
                        let pdtitle = String("\(allType[i]) Weight PD")
                        let pdbudget = "\(setup.pdWeight)"
                        let pdactual = Int((weight[i] as NSString).intValue) / self.budget_data!.count - 2
                        let pdvariance = Int((pdbudget as NSString).intValue) - pdactual
                        
                        self.tableView_data!.append(ProductType(title: pdtitle, budgeted: pdbudget, actual: "\(pdactual)", variance: "\(pdvariance)"))
                    } else {
                        let title = "Weight PM"
                        let budget = "\(setup.weight)"
                        let actual = lastObject.WEIGHT
                        let variance = Int((budget as NSString).intValue) - Int((actual as NSString).intValue)
                        
                        self.tableView_data!.append(ProductType(title: title, budgeted: budget, actual: actual, variance: "\(variance)"))
                        
                        let pdtitle = "Weight PD"
                        let pdbudget = "\(setup.pdWeight)"
                        let pdactual = Int((lastObject.WEIGHT as NSString).intValue) / self.budget_data!.count - 2
                        let pdvariance = Int((pdbudget as NSString).intValue) - pdactual
                        
                        self.tableView_data!.append(ProductType(title: pdtitle, budgeted: pdbudget, actual: "\(pdactual)", variance: "\(pdvariance)"))
                    }
                }
            }
            handler(true)
        }
    }
    
    private func setupGraph() {
        if var budget_data = self.budget_data {
            budget_data.removeFirst()
            budget_data.removeLast()
            
            var newDailyList = [tbl_mis_budget_data_details]()
            var finalDailyList = [tbl_mis_budget_data_details]()

            if (budget_data.count > 7) {
                if (budget_data.count % 7 == 0) {
                    let count = budget_data.count / 7
                    var tempCount = 1
                    for (_, data) in budget_data.enumerated() {
                        if (tempCount == count) {
                            let misDaily = tbl_mis_budget_data_details(IS_DSR_SHOW: data.IS_DSR_SHOW, IS_QSR_SHOW: data.IS_QSR_SHOW, IS_SHIP_SHOW: data.IS_SHIP_SHOW, IS_WEIGHT_SHOW: data.IS_WEIGHT_SHOW, ALL_TYPE: data.ALL_TYPE, ALL_SHIP: data.ALL_SHIP, ALL_DSR: data.ALL_DSR, ALL_QSR: data.ALL_QSR, ALL_WEIGHT: data.ALL_WEIGHT, DSR: data.DSR, PRODUCT: data.PRODUCT, QSR: data.QSR, RPT_DATE: data.RPT_DATE, SHIP: data.SHIP, TYPE: data.TYPE, WEIGHT: data.WEIGHT)
                            newDailyList.append(misDaily)

                            var misDailyFinal: tbl_mis_budget_data_details?

                            for (i, misDailyData) in newDailyList.enumerated() {
                                if (i == 0) {
                                    misDailyFinal = tbl_mis_budget_data_details(IS_DSR_SHOW: misDailyData.IS_DSR_SHOW,
                                                                                IS_QSR_SHOW: misDailyData.IS_QSR_SHOW,
                                                                                IS_SHIP_SHOW: misDailyData.IS_SHIP_SHOW,
                                                                                IS_WEIGHT_SHOW: misDailyData.IS_WEIGHT_SHOW,
                                                                                ALL_TYPE: misDailyData.ALL_TYPE,
                                                                                ALL_SHIP: misDailyData.ALL_SHIP,
                                                                                ALL_DSR: misDailyData.ALL_DSR,
                                                                                ALL_QSR: misDailyData.ALL_QSR,
                                                                                ALL_WEIGHT: misDailyData.ALL_WEIGHT,
                                                                                DSR: misDailyData.DSR,
                                                                                PRODUCT: misDailyData.PRODUCT,
                                                                                QSR: misDailyData.QSR,
                                                                                RPT_DATE: misDailyData.RPT_DATE,
                                                                                SHIP: misDailyData.SHIP,
                                                                                TYPE: misDailyData.TYPE,
                                                                                WEIGHT: misDailyData.WEIGHT)
                                } else {
                                    var booked: Double = 0.0
                                    var weight: Double = 0.0
                                    if data.IS_SHIP_SHOW == "1" {
                                        booked = (((misDailyFinal?.SHIP ?? "0.0") as NSString).doubleValue) + (misDailyData.SHIP as NSString).doubleValue
                                    } else {
                                        weight = (((misDailyFinal?.WEIGHT ?? "0.0") as NSString).doubleValue) + (misDailyData.WEIGHT as NSString).doubleValue
                                    }

                                    misDailyFinal = tbl_mis_budget_data_details(IS_DSR_SHOW: misDailyData.IS_DSR_SHOW,
                                                                                    IS_QSR_SHOW: misDailyData.IS_QSR_SHOW,
                                                                                    IS_SHIP_SHOW: misDailyData.IS_SHIP_SHOW,
                                                                                    IS_WEIGHT_SHOW: misDailyData.IS_WEIGHT_SHOW,
                                                                                    ALL_TYPE: misDailyData.ALL_TYPE,
                                                                                    ALL_SHIP: misDailyData.ALL_SHIP,
                                                                                    ALL_DSR: misDailyData.ALL_DSR,
                                                                                    ALL_QSR: misDailyData.ALL_QSR,
                                                                                    ALL_WEIGHT: misDailyData.ALL_WEIGHT,
                                                                                    DSR: misDailyData.DSR,
                                                                                    PRODUCT: misDailyData.PRODUCT,
                                                                                    QSR: misDailyData.QSR,
                                                                                    RPT_DATE: misDailyData.RPT_DATE,
                                                                                    SHIP: "\(booked)",
                                                                                    TYPE: misDailyData.TYPE,
                                                                                    WEIGHT: "\(weight)")
                                    
                                    
                                }
                            }

                            tempCount = 1
                            finalDailyList.append(misDailyFinal!)
                            newDailyList.removeAll()
                        } else {
                            let misDaily = tbl_mis_budget_data_details(IS_DSR_SHOW: data.IS_DSR_SHOW, IS_QSR_SHOW: data.IS_QSR_SHOW, IS_SHIP_SHOW: data.IS_SHIP_SHOW, IS_WEIGHT_SHOW: data.IS_WEIGHT_SHOW, ALL_TYPE: data.ALL_TYPE, ALL_SHIP: data.ALL_SHIP, ALL_DSR: data.ALL_DSR, ALL_QSR: data.ALL_QSR, ALL_WEIGHT: data.ALL_WEIGHT, DSR: data.DSR, PRODUCT: data.PRODUCT, QSR: data.QSR, RPT_DATE: data.RPT_DATE, SHIP: data.SHIP, TYPE: data.TYPE, WEIGHT: data.WEIGHT)
                            newDailyList.append(misDaily)

                            tempCount += 1
                        }
                    }
                } else {
                    let countDouble = Double(budget_data.count) / 7.0
                    let countTwoDecimal = String(format: "%.2f", countDouble).split(separator: ".")
                    
                    var extraCount = 0
                    var count = Int((countTwoDecimal[0] as NSString).intValue)
                    var tempCount = 1
                    switch countTwoDecimal[1] {
                        case "14" : extraCount = 6
                            break
                        case "28" : extraCount = 5
                            break
                        case "42" : extraCount = 4
                            break
                        case "57" : extraCount = 3
                            break
                        case "71" : extraCount = 2
                            break
                        case "85" : extraCount = 1
                            break
                    default: break
                    }
                    for (_, data) in budget_data.enumerated() {
                        if finalDailyList.count == extraCount {
                            count += 1
                            extraCount = 100
                        }
                        if (tempCount == count) {
                            let misDaily = tbl_mis_budget_data_details(IS_DSR_SHOW: data.IS_DSR_SHOW, IS_QSR_SHOW: data.IS_QSR_SHOW, IS_SHIP_SHOW: data.IS_SHIP_SHOW, IS_WEIGHT_SHOW: data.IS_WEIGHT_SHOW, ALL_TYPE: data.ALL_TYPE, ALL_SHIP: data.ALL_SHIP, ALL_DSR: data.ALL_DSR, ALL_QSR: data.ALL_QSR, ALL_WEIGHT: data.ALL_WEIGHT, DSR: data.DSR, PRODUCT: data.PRODUCT, QSR: data.QSR, RPT_DATE: data.RPT_DATE, SHIP: data.SHIP, TYPE: data.TYPE, WEIGHT: data.WEIGHT)
                            newDailyList.append(misDaily)

                            var misDailyFinal: tbl_mis_budget_data_details?

                            for (i, misDailyData) in newDailyList.enumerated() {
                                if (i == 0) {
                                    misDailyFinal = tbl_mis_budget_data_details(IS_DSR_SHOW: misDailyData.IS_DSR_SHOW,
                                                                                IS_QSR_SHOW: misDailyData.IS_QSR_SHOW,
                                                                                IS_SHIP_SHOW: misDailyData.IS_SHIP_SHOW,
                                                                                IS_WEIGHT_SHOW: misDailyData.IS_WEIGHT_SHOW,
                                                                                ALL_TYPE: misDailyData.ALL_TYPE,
                                                                                ALL_SHIP: misDailyData.ALL_SHIP,
                                                                                ALL_DSR: misDailyData.ALL_DSR,
                                                                                ALL_QSR: misDailyData.ALL_QSR,
                                                                                ALL_WEIGHT: misDailyData.ALL_WEIGHT,
                                                                                DSR: misDailyData.DSR,
                                                                                PRODUCT: misDailyData.PRODUCT,
                                                                                QSR: misDailyData.QSR,
                                                                                RPT_DATE: misDailyData.RPT_DATE,
                                                                                SHIP: misDailyData.SHIP,
                                                                                TYPE: misDailyData.TYPE,
                                                                                WEIGHT: misDailyData.WEIGHT)
                                } else {
                                    var booked: Double = 0.0
                                    var weight: Double = 0.0
                                    if data.IS_SHIP_SHOW == "1" {
                                        booked = (((misDailyFinal?.SHIP ?? "0.0") as NSString).doubleValue) + (misDailyData.SHIP as NSString).doubleValue
                                    } else {
                                        weight = (((misDailyFinal?.WEIGHT ?? "0.0") as NSString).doubleValue) + (misDailyData.WEIGHT as NSString).doubleValue
                                    }

                                    misDailyFinal = tbl_mis_budget_data_details(IS_DSR_SHOW: misDailyData.IS_DSR_SHOW,
                                                                                    IS_QSR_SHOW: misDailyData.IS_QSR_SHOW,
                                                                                    IS_SHIP_SHOW: misDailyData.IS_SHIP_SHOW,
                                                                                    IS_WEIGHT_SHOW: misDailyData.IS_WEIGHT_SHOW,
                                                                                    ALL_TYPE: misDailyData.ALL_TYPE,
                                                                                    ALL_SHIP: misDailyData.ALL_SHIP,
                                                                                    ALL_DSR: misDailyData.ALL_DSR,
                                                                                    ALL_QSR: misDailyData.ALL_QSR,
                                                                                    ALL_WEIGHT: misDailyData.ALL_WEIGHT,
                                                                                    DSR: misDailyData.DSR,
                                                                                    PRODUCT: misDailyData.PRODUCT,
                                                                                    QSR: misDailyData.QSR,
                                                                                    RPT_DATE: misDailyData.RPT_DATE,
                                                                                    SHIP: "\(booked)",
                                                                                    TYPE: misDailyData.TYPE,
                                                                                    WEIGHT: "\(weight)")
                                    
                                    
                                }
                            }

                            tempCount = 1
                            finalDailyList.append(misDailyFinal!)
                            newDailyList.removeAll()
                        } else {
                            let misDaily = tbl_mis_budget_data_details(IS_DSR_SHOW: data.IS_DSR_SHOW, IS_QSR_SHOW: data.IS_QSR_SHOW, IS_SHIP_SHOW: data.IS_SHIP_SHOW, IS_WEIGHT_SHOW: data.IS_WEIGHT_SHOW, ALL_TYPE: data.ALL_TYPE, ALL_SHIP: data.ALL_SHIP, ALL_DSR: data.ALL_DSR, ALL_QSR: data.ALL_QSR, ALL_WEIGHT: data.ALL_WEIGHT, DSR: data.DSR, PRODUCT: data.PRODUCT, QSR: data.QSR, RPT_DATE: data.RPT_DATE, SHIP: data.SHIP, TYPE: data.TYPE, WEIGHT: data.WEIGHT)
                            newDailyList.append(misDaily)

                            tempCount += 1
                        }
                    }
                }
            } else {
                finalDailyList = budget_data
            }
            
            
            let isWeightShow: String = self.lastObject.IS_WEIGHT_SHOW
            for data in finalDailyList {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let tDate = dateFormatter.date(from: data.RPT_DATE.dateOnly)!.dayAndMonth()
                dataEntryX.append(tDate)
                
                if isWeightShow == "1" {
                    let value = (data.WEIGHT as NSString).doubleValue
                    dataEntryY.append(value)
                } else {
                    let value = (data.SHIP as NSString).doubleValue
                    dataEntryY.append(value)
                }
            }
            self.setChart(dataEntryX: dataEntryX, dataEntryY: dataEntryY)
        }
    }
    private func setChart(dataEntryX forX:[String],dataEntryY forY: [Double]) {
        lineChart.chartDescription?.enabled = false
        lineChart.dragEnabled = true
        lineChart.setScaleEnabled(true)
        lineChart.pinchZoomEnabled = false
        
        lineChart.xAxis.gridLineDashLengths = [0, 0]
        lineChart.xAxis.gridLineDashPhase = 0
        
        let yAxisValue = lineChart.leftAxis
        yAxisValue.removeAllLimitLines()
        
        if monthlyTarget > yAxisValue.axisMaximum {
            yAxisValue.axisMaximum = monthlyTarget + monthlyTarget/8
        } else {
            yAxisValue.axisMaximum = yAxisValue.axisMaximum + yAxisValue.axisMaximum/6
        }
        
        yAxisValue.axisMinimum = 0
        
        
        let ll1 = ChartLimitLine(limit: monthlyTarget, label: "")
        ll1.lineColor = UIColor.approvedColor()
        ll1.lineWidth = 2
        ll1.lineDashLengths = [0,0]
        yAxisValue.removeAllLimitLines()
        yAxisValue.addLimitLine(ll1)

        lineChart.rightAxis.enabled = false
        

        lineChart.animate(xAxisDuration: 1.0)
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
        set1.formSize = 25
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
    
    @IBAction func selectionBtnTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Popups", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestListingViewController") as! NewRequestListingViewController
        if sender.tag == 0 {
            controller.mis_popop_year = AppDelegate.sharedInstance.db?.read_tbl_mis_budget_setup_year()
            controller.heading = "Select Year"
        } else {
            controller.mis_popup_mnth = AppDelegate.sharedInstance.db?.read_tbl_mis_budget_setup_month()
            controller.heading = "Select Month"
        }
        
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        controller.modalTransitionStyle = .crossDissolve
        controller.misdelegate = self
        Helper.topMostController().present(controller, animated: true, completion: nil)
    }
}

extension MISDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = self.budget_data?.count {
            return count
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MISCollectionCell.description(), for: indexPath) as? MISCollectionCell else {
            fatalError()
        }
        let data = self.budget_data![indexPath.row]
        if indexPath.row == self.budget_data!.count - 1 {
            cell.isLastRow = true
            cell.totalCount = Double(self.budget_data!.count - 2)
        } else {
            cell.isLastRow = false
        }
        cell.indexPath = indexPath.row
        
        cell.tbl_mis_budget_data_detail = data
        cell.isDualValue = self.isDualValue
        cell.setupCell()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
    }
}

extension MISDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = self.tableView_data?.count {
            return 1
        }
        return 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.tableView_data?.count {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MISDetailTableCell.description()) as? MISDetailTableCell else {
            fatalError()
        }
        let data = self.tableView_data![indexPath.row]
        cell.dateView.isHidden = true
        cell.shipmentBookedLabel.text = data.title
        cell.weightLabel.text = data.budgeted
        cell.qsrLabel.text = data.actual
        cell.dsrLabel.text = data.variance
        
        
        cell.shipmentBooked.bgColor = UIColor.white
        cell.weightView.bgColor = UIColor.white
        cell.dsrView.bgColor = UIColor.white
        cell.qsrView.bgColor = UIColor.white
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MISHeaderCell") as! MISHeaderCell
        if let dateView = headerCell.viewWithTag(1) as? CustomView {
            dateView.isHidden = true
        }
        if let shipmentLabel = headerCell.viewWithTag(20) as? UILabel {
            shipmentLabel.text = ""
        }
        if let budgeted = headerCell.viewWithTag(30) as? UILabel {
            budgeted.text = "Budgeted"
        }
        if let actual = headerCell.viewWithTag(40) as? UILabel {
            actual.text = "Actual"
        }
        if let variance = headerCell.viewWithTag(50) as? UILabel {
            variance.text = "Variance"
        }
        
        return headerCell
    }
}
extension MISDetailViewController: MISDelegate {
    func updateListing(region_date: tbl_mis_region_data) {}
    
    func updateMonth(mnth: MISPopupMonth) {
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "LLLL"  // if you need 3 letter month just use "LLL"
        if mnth.mnth == "Feburary" {
            monthInNumber = "02"
        }
        if let date = df.date(from: mnth.mnth) {
            let month = Calendar.current.component(.month, from: date)
            self.monthInNumber = "\(month)"
            if monthInNumber.count == 1 {
                monthInNumber = "0\(monthInNumber)"
            }
            self.monthName = mnth.mnth
        }
        self.monthLabel.text = mnth.mnth
        self.reloadData(date: "\(year)-\(monthInNumber)")
    }
    
    func updateYearr(year: MISPopupYear) {
        self.yearLabel.text = year.yearr
        self.year = year.yearr
        
        self.reloadData(date: "\(year)-\(monthInNumber)")
    }
}


extension MISDetailViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if self.dataEntryX.count == 1 {
            return dataEntryX[0]
        }
        return dataEntryX[Int(value)]
    }
}
