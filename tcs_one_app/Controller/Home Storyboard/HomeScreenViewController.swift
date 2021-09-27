//
//  HomeScreenViewController.swift
//  tcs_one_app
//
//  Created by ibs on 16/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import Floaty
import SDWebImage
import Charts
import MaterialComponents.MaterialTextControls_OutlinedTextAreas
import CoreLocation
import MapKit

class HomeScreenViewController: BaseViewController, ChartViewDelegate, UIScrollViewDelegate {
    
    
    //    @IBOutlet weak var scrollViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var notification_view: CustomView!
    @IBOutlet weak var notification_label: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainChartView: CustomView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var module_CollectionView: UICollectionView!
    
    @IBOutlet weak var notificationBtn: UIButton!
    
    var floaty = Floaty()
    
    var module: [tbl_UserModule]?
    var graphCount: [GraphTotalCount]?
    
    var pieChartViews = [PieChartView]()
    
    
    var firstTimeLoaded = false
    
    var pageControllIndex = 0
    var chartViews:[ChartViews] = []
    var ViewBroadCastPermission = true
    var ModuleCount = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Dashboard"
        
        addHomeNavigationButton()
        self.makeTopCornersRounded(roundView: self.mainView)
        
        
        self.tabBarController?.viewControllers?[0].title = "Home"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.mainViewHeightConstraint.constant = self.view.frame.height
            
        }
        
        self.notificationBtn.addTarget(self, action: #selector(openNotificationViewController(sender:)), for: .touchUpInside)
        
        self.module_CollectionView.register(UINib(nibName: "ModulesCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ModulesCell")
        
        
        
        setupUserModules()
        chartViews = createChartViews()
        scrollView.delegate = self
        
        pageControl.numberOfPages = self.ModuleCount
        pageControl.currentPage = 0
        mainView.bringSubviewToFront(pageControl)
        
        self.upload_pending_request()
        
        layoutFAB()
        AppDelegate.sharedInstance.generateTATBreachedNotifications()
        
        
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 0.1
        
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        
//        loadAllGeotifications()
        Geotification.allGeotifications().forEach { (geotification) in
            stopMonitoring(geotification: geotification)
        }
        UserDefaults.standard.removeObject(forKey: PreferencesKeys.savedItems.rawValue)
        let query = "select * from \(db_att_locations)"
        if let locations = AppDelegate.sharedInstance.db?.read_tbl_att_locations(query: query) {
            for location in locations {
                let lat = (location.LATITUDE as NSString).doubleValue
                let lon = (location.LONGITUDE as NSString).doubleValue
                let crd = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                
                let radius : CLLocationDistance = CLLocationDistance(CGFloat(location.RADIUS))
                let entry = Geotification(coordinate: crd, radius: radius, identifier: UUID().uuidString, note: "Welcome to TCS", eventType: .onEntry)
                let exit  = Geotification(coordinate: crd, radius: radius, identifier: UUID().uuidString, note: "See you tomorrow", eventType: .onExit)
                
                add(entry)
                add(exit)
                
            }
        }
//        if UserDefaults.standard.data(forKey: PreferencesKeys.savedItems.rawValue) == nil {
//            let query = "select * from \(db_att_locations)"
//            if let locations = AppDelegate.sharedInstance.db?.read_tbl_att_locations(query: query) {
//                for location in locations {
//                    let lat = (location.LATITUDE as NSString).doubleValue
//                    let lon = (location.LONGITUDE as NSString).doubleValue
//                    let crd = CLLocationCoordinate2D(latitude: lat, longitude: lon)
//
//                    let radius : CLLocationDistance = 75
//                    let entry = Geotification(coordinate: crd, radius: radius, identifier: NSUUID().uuidString, note: "Welcome to TCS", eventType: .onEntry)
//                    let exit  = Geotification(coordinate: crd, radius: radius, identifier: NSUUID().uuidString, note: "You are not in TCS premises", eventType: .onExit)
//
//                    add(entry)
//                    add(exit)
//
//                }
//                UserDefaults.standard.set(true, forKey: "GeofenceAdd")
//            }
//        }
    }
    
    func loadAllGeotifications() {
        geotifications.removeAll()
        let allGeotifications = Geotification.allGeotifications()
        allGeotifications.forEach { add($0) }
    }
    func saveAllGeotifications() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(geotifications)
            UserDefaults.standard.set(data, forKey: PreferencesKeys.savedItems.rawValue)
        } catch {
            print("error encoding geotifications")
        }
    }
    func add(_ geotification: Geotification) {
        geotifications.append(geotification)
        startMonitoring(geotification: geotification)
        saveAllGeotifications()
    }
    func remove(_ geotification: Geotification) {
        guard let index = geotifications.firstIndex(of: geotification) else { return }
        geotifications.remove(at: index)
    }
    
    
    @objc func refreshedView(notification: Notification) {
        let count = getNotificationCounts()
        if count > 0 {
            self.notification_view.isHidden = false
            self.notification_label.text = "\(count)"
        } else {
            self.notification_view.isHidden = true
            self.notification_label.text = ""
        }
        chartViews = [ChartViews]()
        chartViews = createChartViews()
        
        viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(upload_pending_request), name: .networkRefreshed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshedView(notification:)), name: .refreshedViews, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigateThroughtNotify(notification:)), name: .navigateThroughNotification, object: nil)
        let count = getNotificationCounts()
        if count > 0 {
            self.notification_view.isHidden = false
            self.notification_label.text = "\(count)"
        } else {
            self.notification_view.isHidden = true
            self.notification_label.text = ""
        }
        chartViews = [ChartViews]()
        chartViews = createChartViews()
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    override func viewDidLayoutSubviews() {
        setupSlideScrollView(chartViews: chartViews)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
        self.pageControllIndex = Int(pageIndex)
    }
    func createChartViews() -> [ChartViews] {
        if let _ = self.module {
            chartViews = [ChartViews]()
            for mod in self.module! {
                if mod.TAGNAME == MODULE_TAG_TRACK || mod.TAGNAME == MODULE_TAG_LEADERSHIPAWAZ || mod.TAGNAME == MODULE_TAG_ATTENDANCE || mod.TAGNAME == MODULE_TAG_FULFILMENT || mod.TAGNAME == MODULE_TAG_CLS {
                    print(mod.MODULENAME)
                    continue
                }
                let chart:ChartViews = Bundle.main.loadNibNamed("ChartViews", owner: self, options: nil)?.first as! ChartViews
                switch mod.TAGNAME {
                case MODULE_TAG_HR:
                    chart.heading.text = "HR Dashboard"
                    chart.pieChart = self.setupGraphs(pieChartView: chart.pieChart,
                                                      module_id: mod.SERVER_ID_PK,
                                                      pending: "Pending",
                                                      approved: "Completed",
                                                      rejected: "Rejected",
                                                      tag: mod.SERVER_ID_PK,
                                                      module: MODULE_TAG_HR)
                    self.ModuleCount += 1
                    break
                case MODULE_TAG_GRIEVANCE:
                    chart.heading.text = "Awaz Dashboard"
                    chart.pieChart = self.setupGraphs(pieChartView: chart.pieChart,
                                                      module_id: mod.SERVER_ID_PK,
                                                      pending: "Submitted",
                                                      approved: INREVIEW,
                                                      rejected: "Closed",
                                                      tag: mod.SERVER_ID_PK,
                                                      module: MODULE_TAG_GRIEVANCE)
                    self.ModuleCount += 1
                    break
                case MODULE_TAG_IMS:
                    chart.heading.text = "IMS Dashboard"
                    chart.pieChart = self.setupGraphs(pieChartView: chart.pieChart,
                                                      module_id: mod.SERVER_ID_PK,
                                                      pending: "Submitted",
                                                      approved: IMS_Status_Inprogress,
                                                      rejected: "Closed",
                                                      tag: mod.SERVER_ID_PK,
                                                      module: MODULE_TAG_IMS)
                    self.ModuleCount += 1
                    break
                //                case "Leadership Connect":
                //                    chart.heading.text = "Leadership Connect Dashboard"
                //                    chart.pieChart = self.setupGraphs(pieChartView: chart.pieChart,
                //                                                      module_id: mod.SERVER_ID_PK,
                //                                                      pending: "Pending",
                //                                                      approved: "Approved",
                //                                                      rejected: "Rejected",
                //                                                      tag: mod.SERVER_ID_PK)
                //                    self.ModuleCount += 1
                //                    break
                default:
                    break
                }
                chartViews.append(chart)
            }
        }
        if ViewBroadCastPermission {
            if let appCount = AppDelegate.sharedInstance.db?.read_tbl_login_count(query: "SELECT * FROM \(db_login_count)") {
                if appCount.count > 0 {
                    let chart:ChartViews = Bundle.main.loadNibNamed("ChartViews", owner: self, options: nil)?.first as! ChartViews
                    chart.heading.text = "OneApp Installs"
                    chart.pieChart = self.setupGraphs(pieChartView: chart.pieChart,
                                                      module_id: -1,
                                                      pending: "Web",
                                                      approved: "Android",
                                                      rejected: "iOS",
                                                      tag: -1,
                                                      module: "-1")
                    self.ModuleCount += 1
                    chartViews.append(chart)
                }
            }
        }
        if let fulfilment_perssion = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: PERMISSION_FulfilmentModule).count {
            if fulfilment_perssion > 0 {
                let chart:ChartViews = Bundle.main.loadNibNamed("ChartViews", owner: self, options: nil)?.first as! ChartViews
                chart.heading.text = "Fulfilment Dashboard"
                chart.pieChart = self.setupGraphs(pieChartView: chart.pieChart,
                                                  module_id: -2,
                                                  pending: "Pending",
                                                  approved: "In Process",
                                                  rejected: "Ready to Delivery",
                                                  tag: -2,
                                                  module: "-2")
                self.ModuleCount += 1
                chartViews.append(chart)
            }
        }
        
        return chartViews
    }
    
    func setupSlideScrollView(chartViews: [ChartViews]) {
        for v in scrollView.subviews {
            v.removeFromSuperview()
        }
        scrollView.frame = CGRect(x: 0, y: 0, width: mainChartView.frame.width, height: mainChartView.frame.height)
        scrollView.contentSize = CGSize(width: mainChartView.frame.width * CGFloat(chartViews.count), height: mainChartView.frame.height)
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = true
        for i in 0 ..< chartViews.count {
            chartViews[i].frame = CGRect(x: mainChartView.frame.width * CGFloat(i),
                                         y: 0,
                                         width: mainChartView.frame.width,
                                         height: mainChartView.frame.height)
            scrollView.addSubview(chartViews[i])
        }
    }
    
    func setupGraphs(pieChartView: PieChartView, module_id: Int, pending: String, approved: String, rejected: String , tag: Int, module: String) -> PieChartView {
        
        pieChartView.highlightPerTapEnabled = true
        pieChartView.usePercentValuesEnabled = false
        pieChartView.drawSlicesUnderHoleEnabled = false
        pieChartView.holeRadiusPercent = 0.60
        pieChartView.chartDescription?.enabled = false
        pieChartView.drawEntryLabelsEnabled = false
        pieChartView.rotationEnabled = false
        pieChartView.delegate = self
        pieChartView.tag = tag
        
        let l = pieChartView.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .center
        l.orientation = .vertical
        l.xEntrySpace = 0
        l.yEntrySpace = 0
        l.yOffset = 0
        
        var entries = [PieChartDataEntry]()
        var set : PieChartDataSet?
        var colors = [UIColor]()
        
        var pendingCounter :Double = 0
        var approvedCounter :Double = 0
        var rejectedCounter :Double = 0
        
        if module == "-1" {
            let appCount = AppDelegate.sharedInstance.db?.read_tbl_login_count(query: "SELECT * FROM \(db_login_count)")
            if let data = appCount {
                for index in data {
                    switch index.application {
                    case "Web-App":
                        pendingCounter = Double(index.countXEmpno)
                        break
                    case "Android":
                        approvedCounter = Double(index.countXEmpno)
                        break
                    case "Ios-Apple":
                        rejectedCounter = Double(index.countXEmpno)
                        break
                    default:
                        break
                    }
                }
            }
        } else if module == "-2" {
            let orderIdQuery = "SELECT DISTINCT ORDER_ID FROM FULFILMENT_ORDERS WHERE CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
            if let ids = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orderId(query: orderIdQuery) {
                for id in ids {
                    let query = "SELECT * FROM \(db_fulfilment_orders) WHERE ORDER_ID = '\(id)'"
                    let orders = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orders(query: query)
                    
                    var p = 0
                    var r = 0
                    let count = orders?.count
                    for order in orders! {
                        switch order.ITEM_STATUS {
                        case "Pending":
                            p += 1
                        case "Received":
                            r += 1
                            break
                        default:
                            break
                        }
                    }
                    if p == count {
                        pendingCounter += 1
                    } else if r == count {
                        rejectedCounter += 1
                    } else {
                        approvedCounter += 1
                    }
                }
            }
            
        } else {
            let query = "select TICKET_STATUS, count(ID) as ticketTotal, TICKET_DATE from \(db_hr_request) WHERE module_id = '\(module_id)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' AND REQUEST_LOGS_SYNC_STATUS != '\(0)' GROUP BY TICKET_STATUS;"
            let chart = AppDelegate.sharedInstance.db?.getCounts(query: query)
            
            
            for data in chart! {
                let chartValue = ((data.ticket_total ?? "0") as NSString).doubleValue
                let key = data.ticket_status ?? ""
                
                switch module {
                case MODULE_TAG_HR, MODULE_TAG_LEADERSHIPAWAZ:
                    switch key {
                    case "Pending", "pending":
                        pendingCounter = chartValue
                        break
                    case "Approved", "approved":
                        approvedCounter = chartValue
                        break
                    case "Rejected", "rejected":
                        rejectedCounter = chartValue
                        break
                    default:
                        break
                    }
                    break
                case MODULE_TAG_GRIEVANCE:
                    switch key {
                    case "Submitted":
                        pendingCounter += chartValue
                        break
                    case "Inprogress-Er", "Inprogress-S", "Responded", "Investigating":
                        approvedCounter += chartValue
                        break
                    case "Closed":
                        rejectedCounter += chartValue
                        break
                    default:
                        break
                    }
                    break
                case MODULE_TAG_IMS:
                    switch key {
                    case IMS_Status_Submitted:
                        pendingCounter += chartValue
                        break
                    case IMS_Status_Inprogress, IMS_Status_Inprogress_Rds, IMS_Status_Inprogress_Ro, IMS_Status_Inprogress_Rm, IMS_Status_Inprogress_Hod, IMS_Status_Inprogress_Cs, IMS_Status_Inprogress_As , IMS_Status_Inprogress_Hs, IMS_Status_Inprogress_Ds, IMS_Status_Inprogress_Fs, IMS_Status_Inprogress_Ins, IMS_Status_Inprogress_Hr, IMS_Status_Inprogress_Fi, IMS_Status_Inprogress_Ca, IMS_Status_Inprogress_Rhod:
                        approvedCounter += chartValue
                        break
                    case IMS_Status_Closed:
                        rejectedCounter += chartValue
                        break
                    default:
                        break
                    }
                default:
                    break
                }
            }
        }
        
        entries.append(PieChartDataEntry(value: pendingCounter, label: pending))
        entries.append(PieChartDataEntry(value: approvedCounter, label: approved))
        entries.append(PieChartDataEntry(value: rejectedCounter, label: rejected))
        
        set = PieChartDataSet(entries: entries, label: "")
        set!.drawIconsEnabled = false
        set!.sliceSpace = 0
        
        for data in entries {
            switch module {
            case MODULE_TAG_HR, MODULE_TAG_LEADERSHIPAWAZ:
                switch data.label {
                case "Pending", "pending": colors.append(UIColor.pendingColor())
                    break
                case "Completed", "Approved" : colors.append(UIColor.approvedColor())
                    break
                case "Rejected", "rejected" : colors.append(UIColor.rejectedColor())
                    break
                default:
                    break
                }
                break
                
            case MODULE_TAG_GRIEVANCE, MODULE_TAG_IMS:
                switch data.label {
                case "Closed": colors.append(UIColor.rejectedColor())
                    break
                case "Submitted": colors.append(UIColor.pendingColor())
                    break
                case INREVIEW, IMS_Status_Inprogress, IMS_Status_Inprogress_Rds, IMS_Status_Inprogress_Ro, IMS_Status_Inprogress_Rm, IMS_Status_Inprogress_Hod, IMS_Status_Inprogress_Cs, IMS_Status_Inprogress_As , IMS_Status_Inprogress_Hs, IMS_Status_Inprogress_Ds, IMS_Status_Inprogress_Fs, IMS_Status_Inprogress_Ins, IMS_Status_Inprogress_Hr, IMS_Status_Inprogress_Fi, IMS_Status_Inprogress_Ca, IMS_Status_Inprogress_Rhod: colors.append(UIColor.approvedColor())
                    break
                default: break
                }
                break
            case "-1":
                switch data.label {
                case "Web": colors.append(UIColor.pendingColor()); break
                case "Android": colors.append(UIColor.approvedColor()); break
                case "iOS": colors.append(UIColor.rejectedColor()); break
                default: break
                }
            case "-2":
                switch data.label {
                case "Pending": colors.append(UIColor.pendingColor()); break
                case "In Process": colors.append(UIColor.inprocessColor()); break
                case "Ready to Delivery": colors.append(UIColor.approvedColor()); break
                default: break
                }
            default:
                break
            }
        }
        
        set!.colors = colors
        set!.selectionShift = 0
        let data = PieChartData(dataSet: set!)
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumFractionDigits = 0
        formatter.multiplier = 1.0
        formatter.zeroSymbol = ""
        data.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        
        data.setValueFont(.systemFont(ofSize: 9, weight: .regular))
        data.setValueTextColor(.white)
        
        pieChartView.data = data
        
        return pieChartView
    }
    func setupUserModules() {
        module = AppDelegate.sharedInstance.db?.read_tbl_UserModule(query: "Select * from \(db_user_module) GROUP BY SERVER_ID_PK")
        for (i, m) in module!.enumerated() {
            if m.TAGNAME == MODULE_TAG_CLS {
                self.module?.remove(at: i)
                break
            }
        }
        for (i,m) in module!.enumerated() {
            if m.TAGNAME == MODULE_TAG_ATTENDANCE {
                self.module?.remove(at: i)
            }
        }
        for (i,m) in module!.enumerated() {
            if m.TAGNAME == "RIDER" {
                self.module?.remove(at: i)
            }
        }
        if let permission = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: PERMISSION_FulfilmentModule).count {
            if permission == 0 {
                for (i, m) in module!.enumerated() {
                    if m.TAGNAME == MODULE_TAG_FULFILMENT {
                        self.module?.remove(at: i)
                        break
                    }
                }
            }
        }
        if let permission = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: PERMISSION_ViewBroadcastMode).count {
            if let emp_info = AppDelegate.sharedInstance.db?.read_tbl_UserProfile().first {
                if emp_info.HIGHNESS == "1" {
                    DispatchQueue.main.async {
                        self.module_CollectionView.reloadData()
                    }
                    self.ViewBroadCastPermission = true
                    return
                }
                if permission <= 0  {
                    for (i, m) in module!.enumerated() {
                        if m.MODULENAME == "Leadership Connect" {
                            self.module?.remove(at: i)
                            self.ViewBroadCastPermission = false
                            break
                        }
                    }
                }
            }
            
        }
        DispatchQueue.main.async {
            self.module_CollectionView.reloadData()
        }
    }
    
    func layoutFAB() {
        floaty.plusColor = UIColor.white
        floaty.buttonColor = UIColor.nativeRedColor()
        if let _ = self.module {
            for i in 0..<4  {
                switch i {
                case 3:
                    floaty.addItem("Add HR Request", icon: UIImage(named: "helpdesk")) { item in
                        CONSTANT_MODULE_ID = AppDelegate.sharedInstance.db?.read_tbl_UserModule(query: "SELECT * FROM \(db_user_module) WHERE TAGNAME = '\(MODULE_TAG_HR)';").first?.SERVER_ID_PK ?? -1
                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "NewRequestViewController") as! NewRequestViewController
                        self.navigationController?.pushViewController(controller, animated: true)
                        
                    }
                    break
                case 2:
                    floaty.addItem("Add Awaz Request", icon: UIImage(named: "helpdesk")) { item in
                        CONSTANT_MODULE_ID = AppDelegate.sharedInstance.db?.read_tbl_UserModule(query: "SELECT * FROM \(db_user_module) WHERE TAGNAME = '\(MODULE_TAG_GRIEVANCE)';").first?.SERVER_ID_PK ?? -1
                        let storyboard = UIStoryboard(name: "GrievanceStoryboard", bundle: nil)
                        let controller = storyboard.instantiateViewController(withIdentifier: "GrievanceNewRequestViewController") as! GrievanceNewRequestViewController
                        self.navigationController?.pushViewController(controller, animated: true)
                        
                    }
                    break
                case 1:
                    floaty.addItem("Track", icon: UIImage(named: "helpdesk")) { item in
                        let storyboard = UIStoryboard(name: "TrackStoryboard", bundle: nil)
                        let controller = storyboard.instantiateViewController(withIdentifier: "TrackHomeViewController") as! TrackHomeViewController
                        self.navigationController?.pushViewController(controller, animated: true)
                        
                    }
                    break
                case 0:
                    floaty.addItem("Add IMS Request", icon: UIImage(named: "helpdesk")) { item in
                        CONSTANT_MODULE_ID = AppDelegate.sharedInstance.db?.read_tbl_UserModule(query: "SELECT * FROM \(db_user_module) WHERE TAGNAME = '\(MODULE_TAG_IMS)';").first?.SERVER_ID_PK ?? -1
                        let storyboard = UIStoryboard(name: "IMSStoryboard", bundle: nil)
                        let controller = storyboard.instantiateViewController(withIdentifier: "IMSNewRequestViewController") as! IMSNewRequestViewController
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                    if ViewBroadCastPermission {
                        CONSTANT_MODULE_ID = AppDelegate.sharedInstance.db?.read_tbl_UserModule(query: "SELECT * FROM \(db_user_module) WHERE TAGNAME = '\(MODULE_TAG_LEADERSHIPAWAZ)';").first?.SERVER_ID_PK ?? -1
                        floaty.addItem("Add Leadership Connect", icon: UIImage(named: "helpdesk")) { item in
                            let storyboard = UIStoryboard(name: "LeadershipAwaz", bundle: nil)
                            let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestLeadershipAwazViewController") as! NewRequestLeadershipAwazViewController
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
                    }
                    break
                default:
                    break
                }
            }
        }
        floaty.paddingX = (UIApplication.shared.keyWindow?.safeAreaInsets.right ?? 0) + 25
        floaty.paddingY = (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) + 75
        
        self.view.addSubview(floaty)
    }
    
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        switch chartView.tag {
        case 1:
            let apppermmission = AppDelegate.sharedInstance.db?.read_tbl_UserPermission(permission: PERMISSION_HR_LISTING_MANAGEMENT_BAR).count
            if apppermmission! > 0 {
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "NewChartListingViewController") as! NewChartListingViewController
                CONSTANT_MODULE_ID = 1
                controller.title = "All Request"
                self.navigationController?.pushViewController(controller, animated: true)
            }
            break
        case 2:
            let detail_dashboard_permission = AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: PERMISSION_GRIEVANCE_GRAPH_DETAIL_DASHBOARD).count
            if detail_dashboard_permission > 0 {
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "NewChartListingViewController") as! NewChartListingViewController
                CONSTANT_MODULE_ID = 2
                controller.title = "All Request"
                self.navigationController?.pushViewController(controller, animated: true)
            }
            break
        default:
            break
        }
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        NSLog("chartValueNothingSelected");
    }
    
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        
    }
}



extension HomeScreenViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = self.module?.count {
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let moduleCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ModulesCell", for: indexPath) as! ModulesCollectionCell
        
        let module_data = self.module![indexPath.row]
        
        moduleCell.title_Label.text = module_data.MODULENAME
        moduleCell.icon_imageView.sd_setImage(with: URL(string: module_data.MODULEICON), placeholderImage: nil, options: .refreshCached, progress: nil, completed: nil)
        return moduleCell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selected_module = self.module![indexPath.row].MODULENAME
        switch selected_module {
        case "HR Help Desk":
            CONSTANT_MODULE_ID = AppDelegate.sharedInstance.db?.read_tbl_UserModule(query: "SELECT * FROM \(db_user_module) WHERE TAGNAME = '\(MODULE_TAG_HR)';").first?.SERVER_ID_PK ?? -1
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "HRHelpDeskViewController") as! HRHelpDeskViewController
            self.navigationController?.pushViewController(controller, animated: true)
            break
        case "Awaz":
            CONSTANT_MODULE_ID = AppDelegate.sharedInstance.db?.read_tbl_UserModule(query: "SELECT * FROM \(db_user_module) WHERE TAGNAME = '\(MODULE_TAG_GRIEVANCE)';").first?.SERVER_ID_PK ?? -1
            let storyboard = UIStoryboard(name: "GrievanceStoryboard", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "GrievanceHelpDeskViewController") as! GrievanceHelpDeskViewController
            self.navigationController?.pushViewController(controller, animated: true)
            break
        case "Track":
            print("Track")
            let storyboard = UIStoryboard(name: "TrackStoryboard", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "TrackHomeViewController") as! TrackHomeViewController
            self.navigationController?.pushViewController(controller, animated: true)
            break
        case "Leadership Connect":
            CONSTANT_MODULE_ID = AppDelegate.sharedInstance.db?.read_tbl_UserModule(query: "SELECT * FROM \(db_user_module) WHERE TAGNAME = '\(MODULE_TAG_LEADERSHIPAWAZ)';").first?.SERVER_ID_PK ?? -1
            let storyboard = UIStoryboard(name: "LeadershipAwaz", bundle: nil)
            if let emp_info = AppDelegate.sharedInstance.db?.read_tbl_UserProfile().first {
                if emp_info.HIGHNESS == "1" {
                    let controller = storyboard.instantiateViewController(withIdentifier: "ChairmenListingViewController") as! ChairmenListingViewController
                    self.navigationController?.pushViewController(controller, animated: true)
                } else {
                    let controller = storyboard.instantiateViewController(withIdentifier: "LeadershipListingViewController") as! LeadershipListingViewController
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
            break
        case "Fulfilment":
            CONSTANT_MODULE_ID = AppDelegate.sharedInstance.db?.read_tbl_UserModule(query: "SELECT * FROM \(db_user_module) WHERE TAGNAME = '\(MODULE_TAG_FULFILMENT)';").first?.SERVER_ID_PK ?? -1
            let storyboard = UIStoryboard(name: "Fullfillment", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "FulfilmentDashboardViewController") as! FulfilmentDashboardViewController
            
            self.navigationController?.pushViewController(controller, animated: true)
            break
        case "IMS":
            CONSTANT_MODULE_ID = AppDelegate.sharedInstance.db?.read_tbl_UserModule(query: "SELECT * FROM \(db_user_module) WHERE TAGNAME = '\(MODULE_TAG_IMS)';").first?.SERVER_ID_PK ?? -1
            let storyboard = UIStoryboard(name: "IMSStoryboard", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "IMSDashboardViewController") as! IMSDashboardViewController
            self.navigationController?.pushViewController(controller, animated: true)
            break
        case "Attendance":
            CONSTANT_MODULE_ID = AppDelegate.sharedInstance.db?.read_tbl_UserModule(query: "SELECT * FROM \(db_user_module) WHERE TAGNAME = '\(MODULE_TAG_IMS)';").first?.SERVER_ID_PK ?? -1
            let storyboard = UIStoryboard(name: "Attendance", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "AttendanceMarkingViewController") as! AttendanceMarkingViewController
            self.navigationController?.pushViewController(controller, animated: true)
            break
            
        default:
            break
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
        let yourWidth = CGFloat(80)
        let yourHeight = collectionView.bounds.width / 4.0
        
        return CGSize(width: yourWidth, height: yourHeight)
    }
    
    @objc func openChartDetails() {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ChartListingViewController") as! ChartListingViewController
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        print("Hello World")
    }
}





extension HomeScreenViewController:  CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locValue
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return
        case .denied, .restricted:
            print("location access denied")
            
        default:
            locationManager.requestAlwaysAuthorization()
        }
    }
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        guard let region = region else {
            print("Monitoring failed for unknown region")
            return
        }
        print("Monitoring failed for region with identifier: \(region.identifier)")
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
}
