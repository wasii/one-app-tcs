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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Dashboard"
        
        addSingleNavigationButton()
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
        
        pageControl.numberOfPages = module!.count
        pageControl.currentPage = 0
        mainView.bringSubviewToFront(pageControl)
        
        self.upload_pending_request()
        
        layoutFAB()
        AppDelegate.sharedInstance.generateTATBreachedNotifications()
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
        var chartViews = [ChartViews]()
        for module in self.module! {
            let chart:ChartViews = Bundle.main.loadNibNamed("ChartViews", owner: self, options: nil)?.first as! ChartViews
            chart.heading.text = module.MODULENAME
            
            switch module.MODULENAME {
            case "HR Help Desk":
                chart.pieChart = self.setupGraphs(pieChartView: chart.pieChart,
                                                  module_id: module.SERVER_ID_PK,
                                                  pending: "Pending",
                                                  approved: "Completed",
                                                  rejected: "Rejected",
                                                  tag: module.SERVER_ID_PK)
                break
            case "Grievance":
                chart.pieChart = self.setupGraphs(pieChartView: chart.pieChart,
                                                  module_id: module.SERVER_ID_PK,
                                                  pending: "Submitted",
                                                  approved: INREVIEW,
                                                  rejected: "Closed",
                                                  tag: module.SERVER_ID_PK)
                break
//            case "IMS":
//                chart.pieChart = self.setupGraphs(pieChartView: chart.pieChart,
//                                                  module_id: module.SERVER_ID_PK,
//                                                  pending: "Submitted",
//                                                  approved: INREVIEW,
//                                                  rejected: "Closed",
//                                                  tag: module.SERVER_ID_PK)
//            break
            default:
                break
            }
            
            chartViews.append(chart)
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
    
    func setupGraphs(pieChartView: PieChartView, module_id: Int, pending: String, approved: String, rejected: String , tag: Int) -> PieChartView {
        
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

        let query = "select TICKET_STATUS, count(ID) as ticketTotal, TICKET_DATE from \(db_hr_request) WHERE module_id = '\(module_id)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' AND REQUEST_LOGS_SYNC_STATUS != '\(0)' GROUP BY TICKET_STATUS;"
        let chart = AppDelegate.sharedInstance.db?.getCounts(query: query)
        
        var pendingCounter :Double = 0
        var approvedCounter :Double = 0
        var rejectedCounter :Double = 0
        for data in chart! {
            let chartValue = ((data.ticket_total ?? "0") as NSString).doubleValue
            let key = data.ticket_status ?? ""

            switch tag {
            case 1:
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
            case 2:
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
            case 3:
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
        entries.append(PieChartDataEntry(value: pendingCounter, label: pending))
        entries.append(PieChartDataEntry(value: approvedCounter, label: approved))
        entries.append(PieChartDataEntry(value: rejectedCounter, label: rejected))
        
        set = PieChartDataSet(entries: entries, label: "")
        set!.drawIconsEnabled = false
        set!.sliceSpace = 0

        for data in entries {
            switch tag {
            case 1:
                switch data.label {
                case "Pending", "pending": colors.append(UIColor.pendingColor())
                    break
                case "Completed" : colors.append(UIColor.approvedColor())
                    break
                case "Rejected", "rejected" : colors.append(UIColor.rejectedColor())
                    break
                default:
                    break
                }
            break
                
            case 2, 3:
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
        DispatchQueue.main.async {
//            self.module?.removeLast()
            self.module_CollectionView.reloadData()
        }
    }
    
    func layoutFAB() {
        floaty.plusColor = UIColor.white
        floaty.buttonColor = UIColor.nativeRedColor()
        if let modules = self.module {
            for (index,_) in modules.enumerated() {
                switch index {
//                case 0:
//                    floaty.addItem("Add IMS Request", icon: UIImage(named: "helpdesk")) { item in
//                        CONSTANT_MODULE_ID = AppDelegate.sharedInstance.db?.read_tbl_UserModule(query: "SELECT * FROM \(db_user_module) WHERE TAGNAME = '\(MODULE_TAG_IMS)';").first?.SERVER_ID_PK ?? -1
//                        let storyboard = UIStoryboard(name: "IMSStoryboard", bundle: nil)
//                        let controller = storyboard.instantiateViewController(withIdentifier: "IMSNewRequestViewController") as! IMSNewRequestViewController
//                        self.navigationController?.pushViewController(controller, animated: true)
//
//                    }
//                    break
                case 1:
                    floaty.addItem("Add Grievance Request", icon: UIImage(named: "helpdesk")) { item in
                        CONSTANT_MODULE_ID = AppDelegate.sharedInstance.db?.read_tbl_UserModule(query: "SELECT * FROM \(db_user_module) WHERE TAGNAME = '\(MODULE_TAG_GRIEVANCE)';").first?.SERVER_ID_PK ?? -1
                        let storyboard = UIStoryboard(name: "GrievanceStoryboard", bundle: nil)
                        let controller = storyboard.instantiateViewController(withIdentifier: "GrievanceNewRequestViewController") as! GrievanceNewRequestViewController
                        self.navigationController?.pushViewController(controller, animated: true)
                      
                    }
                    break
                case 2:
                    floaty.addItem("Add HR Request", icon: UIImage(named: "helpdesk")) { item in
                        CONSTANT_MODULE_ID = AppDelegate.sharedInstance.db?.read_tbl_UserModule(query: "SELECT * FROM \(db_user_module) WHERE TAGNAME = '\(MODULE_TAG_HR)';").first?.SERVER_ID_PK ?? -1
                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "NewRequestViewController") as! NewRequestViewController
                        self.navigationController?.pushViewController(controller, animated: true)
                      
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
        case "Grievance":
            CONSTANT_MODULE_ID = AppDelegate.sharedInstance.db?.read_tbl_UserModule(query: "SELECT * FROM \(db_user_module) WHERE TAGNAME = '\(MODULE_TAG_GRIEVANCE)';").first?.SERVER_ID_PK ?? -1
            let storyboard = UIStoryboard(name: "GrievanceStoryboard", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "GrievanceHelpDeskViewController") as! GrievanceHelpDeskViewController
            self.navigationController?.pushViewController(controller, animated: true)
            break
//        case "IMS":
//            CONSTANT_MODULE_ID = AppDelegate.sharedInstance.db?.read_tbl_UserModule(query: "SELECT * FROM \(db_user_module) WHERE TAGNAME = '\(MODULE_TAG_IMS)';").first?.SERVER_ID_PK ?? -1
//            let storyboard = UIStoryboard(name: "IMSStoryboard", bundle: nil)
//            let controller = storyboard.instantiateViewController(withIdentifier: "IMSDashboardViewController") as! IMSDashboardViewController
//            self.navigationController?.pushViewController(controller, animated: true)
//            break
            
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
