//
//  MISPieChartDetailViewController.swift
//  tcs_one_app
//
//  Created by TCS on 29/09/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import Charts
class MISPieChartDetailViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    var category_list: [MISCategoryList]?
    var budget_setup: tbl_mis_budget_setup?
    var mis_dashboard_detail: [tbl_mis_dashboard_detail]?
    var temp_dashboard_detail: [tbl_mis_dashboard_detail]?
    var monthInNumber: String = ""
    var monthName: String = ""
    var year: String = ""
    let df = DateFormatter()
    var productName: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "MIS"
        makeTopCornersRounded(roundView: mainView)
        tableView.register(UINib(nibName: MISPieChartTableCell.description(), bundle: nil), forCellReuseIdentifier: MISPieChartTableCell.description())
        tableView.dataSource = self
        tableView.delegate = self
        
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
        
        if let category_list = AppDelegate.sharedInstance.db?.get_mis_dashboard_type() {
            self.category_list = category_list
            self.category_list![0].isSelected = true
        }
        if var budget_setup = budget_setup {
            self.productName = budget_setup.product
            self.headingLabel.text = budget_setup.product
            if budget_setup.product.last == " " {
                _ = budget_setup.product.removeLast()
                self.headingLabel.text = "\(budget_setup.product)"
                self.productName = budget_setup.product
            }
            
        }

        reloadData()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        self.collectionView.collectionViewLayout = layout
        self.collectionView!.contentInset = UIEdgeInsets(top: 0, left: 0, bottom:0, right: 0)
        
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.itemSize = CGSize(width: self.collectionView.frame.size.width/3, height: self.collectionView.frame.size.height)
            layout.invalidateLayout()
        }
    }
    private func reloadData() {
        self.setupJSON { count in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tableViewHeightConstraint.constant = CGFloat(310 * count)
                self.tableView.reloadData()
                self.collectionView.reloadData()
            }
        }
    }
    private func setupJSON(_ handler: @escaping(Int)->Void) {
        let selectedType = self.category_list?.filter { category in
            category.isSelected == true
        }.first
        let query = "SELECT * FROM \(db_mis_dashboard_detail) WHERE TITLE = '\(self.productName)' AND TYP = '\(selectedType?.title ?? "")' AND MNTH = '\(self.monthName)' AND YEARR = '\(self.year)'"
        if let dashboard_detail = AppDelegate.sharedInstance.db?.read_tbl_mis_dashboard_detail(query: query) {
            self.mis_dashboard_detail = [tbl_mis_dashboard_detail]()
            self.temp_dashboard_detail = dashboard_detail
            let permission_query = "SELECT u.* FROM \(db_user_page) AS up INNER JOIN \(db_user_permission) AS u ON  up.PAGENAME = '\(self.productName)' AND up.SERVER_ID_PK = u.PAGEID AND u.PERMISSION LIKE '\(selectedType?.title ?? "")%'"
            if let permission = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(query: permission_query) {
                for (i,detail) in dashboard_detail.enumerated() {
                    let kpiPermissions = permission.filter { perm in
                        perm.PERMISSION == "\(detail.typ)-\(detail.product)-KPI"
                    }
                    let dlvrdPermission = permission.filter { perm in
                        perm.PERMISSION == "\(detail.typ)-\(detail.product)-DLVRD"
                    }
                    
                    if kpiPermissions.count == 1 {
                        self.temp_dashboard_detail![i].isKPIAllowed = true
                        self.mis_dashboard_detail!.append(self.temp_dashboard_detail![i])
                        continue
                    }
                    if dlvrdPermission.count == 1 {
                        self.temp_dashboard_detail![i].isKPIAllowed = false
                        self.mis_dashboard_detail!.append(self.temp_dashboard_detail![i])
                        continue
                    }
                }
            }
        }
        handler(self.mis_dashboard_detail?.count ?? 0)
    }
    @IBAction func selectionBtnTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Popups", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestListingViewController") as! NewRequestListingViewController
        if sender.tag == 0 {
            controller.mis_popop_year = AppDelegate.sharedInstance.db?.read_tbl_mis_budget_setup_year(query: "SELECT DISTINCT YEARR from \(db_mis_dashboard_detail)")
            controller.heading = "Select Year"
        } else {
            let formatter : DateFormatter = {
                let df = DateFormatter()
                df.locale = Locale(identifier: "en_US_POSIX")
                df.dateFormat = "MMMM"
                return df
            }()
            
            controller.mis_popup_mnth = AppDelegate.sharedInstance.db?.read_tbl_mis_budget_setup_month(query: "SELECT DISTINCT MNTH from \(db_mis_dashboard_detail)")?.sorted(by: { m1, m2 in
                formatter.date(from: m1.mnth)! < formatter.date(from: m2.mnth)!
            })
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

extension MISPieChartDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.mis_dashboard_detail?.count {
            return count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MISPieChartTableCell.description()) as? MISPieChartTableCell else {
            fatalError()
        }
        if let dashboard_detail = self.mis_dashboard_detail?[indexPath.row] {
            cell.headingLabel.text = dashboard_detail.product
            cell.pieChart = self.setupCell(dashboard_detail: dashboard_detail, pieChartView: cell.pieChart)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 310
    }
    private func setupCell(dashboard_detail: tbl_mis_dashboard_detail, pieChartView: PieChartView) -> PieChartView {
        pieChartView.highlightPerTapEnabled = true
        pieChartView.usePercentValuesEnabled = false
        pieChartView.drawSlicesUnderHoleEnabled = false
        pieChartView.holeRadiusPercent = 0.60
        pieChartView.chartDescription?.enabled = false
        pieChartView.drawEntryLabelsEnabled = false
        pieChartView.rotationEnabled = false
        
        pieChartView.legend.enabled = false
        pieChartView.setExtraOffsets(left: 20, top: 0, right: 20, bottom: 0)
        
        
        let count = 3
        let range: UInt32 = 10
        
        let entries = (0..<count).map { (i) -> PieChartDataEntry in
            // IMPORTANT: In a PieChart, no values (Entry) should have the same xIndex (even if from different DataSets), since no values can be drawn above each other.
            return PieChartDataEntry(value: Double(arc4random_uniform(range) + range / 5))
        }
        let set = PieChartDataSet(entries: entries, label: "")
        set.sliceSpace = 1
        set.valueLinePart1OffsetPercentage = 0.8
        set.valueLinePart1Length = 0.2
        set.valueLinePart2Length = 0.4
        
        set.yValuePosition = .outsideSlice
        
        
        set.colors = [UIColor.nativeRedColor(), UIColor.approvedColor(), UIColor.darkGray]
        let data = PieChartData(dataSet: set)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = ""
        
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        data.setValueFont(.systemFont(ofSize: 11, weight: .light))
        data.setValueTextColor(.black)
        
        pieChartView.data = data
//        pieChartView.animate(xAxisDuration: 0.4, easingOption: .easeOutBack)
        return pieChartView
    }
}


extension MISPieChartDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = self.category_list?.count {
            return count
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MISHeadingCell", for: indexPath) as? MISHeadingCollectionCell else {
            fatalError()
        }
        if let category_list = self.category_list {
            if indexPath.row == 0 {
                cell.mainView.clipsToBounds = true
                cell.mainView.layer.cornerRadius = 20
                cell.mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            } else if indexPath.row == category_list.count - 1 {
                cell.mainView.clipsToBounds = true
                cell.mainView.layer.cornerRadius = 20
                cell.mainView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            } else {
                cell.mainView.clipsToBounds = true
                cell.mainView.layer.cornerRadius = 0
            }
            
            if category_list[indexPath.row].isSelected {
                cell.mainView.backgroundColor = UIColor.nativeRedColor()
                cell.headingLabel.textColor = UIColor.white
            } else {
                cell.mainView.backgroundColor = UIColor.init(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1)
                cell.headingLabel.textColor = UIColor.black
            }
            
            cell.headingLabel.text = category_list[indexPath.row].title
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for i in 0..<self.category_list!.count {
            self.category_list![i].isSelected = false
        }
        self.category_list![indexPath.row].isSelected = true
        self.reloadData()
    }
}

extension MISPieChartDetailViewController: MISDelegate {
    func updateListing(region_date: tbl_mis_region_data) {}
    
    func updateMonth(mnth: MISPopupMonth) {
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "LLLL"  // if you need 3 letter month just use "LLL"
        if let date = df.date(from: mnth.mnth) {
            let month = Calendar.current.component(.month, from: date)
            self.monthInNumber = "\(month)"
            if monthInNumber.count == 1 {
                monthInNumber = "0\(monthInNumber)"
            }
            self.monthName = mnth.mnth
        }
        self.monthLabel.text = mnth.mnth
        self.reloadData()
    }
    
    func updateYearr(year: MISPopupYear) {
        self.yearLabel.text = year.yearr
        self.year = year.yearr
        self.reloadData()
    }
}

struct MISCategoryList {
    var title: String = ""
    var isSelected: Bool = false
}
