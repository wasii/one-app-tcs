//
//  ChairmenListingViewController.swift
//  tcs_one_app
//
//  Created by TCS on 25/02/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import MBCircularProgressBar

class ChairmenListingViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var search_textfield: UITextField!
    
    @IBOutlet weak var pending_circular_view: MBCircularProgressBarView!
    @IBOutlet weak var approved_circular_view: MBCircularProgressBarView!
    @IBOutlet weak var rejected_circular_view: MBCircularProgressBarView!
    
    @IBOutlet var sortedImages: [UIImageView]!
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Variables
    var isFiltered = false
    var numberOfDays = 7
    var tbl_request_logs: [tbl_Hr_Request_Logs]?
    var filtered_data: [tbl_Hr_Request_Logs]?
    
    var temp_data: [tbl_Hr_Request_Logs]?
    
    var indexPath: IndexPath?
    var selected_query: String?
    
    
    var start_day: String?
    var end_day: String?
    
    var user_permission = [tbl_UserPermission]()
    
    var filtered_status = ""
    
    
    var ifIsSearch = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.makeTopCornersRounded(roundView: self.mainView)
        self.selected_query = "Weekly"
        self.tableView.register(UINib(nibName: "RequestListingTableCell", bundle: nil), forCellReuseIdentifier: "RequestListingCell")
        self.tableView.rowHeight = 80
        self.title = "Leadership Connect"
        
        search_textfield.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if indexPath != nil {
            self.tableView.deselectRow(at: indexPath!, animated: true)
        }
        self.navigationItem.rightBarButtonItems = nil
        addDoubleNavigationButtons()
        if let btn = self.navigationItem.rightBarButtonItems?.first {
            let count = getNotificationCounts()
            if count > 0 {
                btn.addBadge(num: count)
            } else {
                btn.removeBadge()
            }
        }
        setupJSON(numberOfDays: numberOfDays, startday: start_day, endday: end_day)
        NotificationCenter.default.addObserver(self, selector: #selector(upload_pending_request), name: .networkRefreshed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshedView(notification:)), name: .refreshedViews, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigateThroughtNotify(notification:)), name: .navigateThroughNotification, object: nil)
    }
    
    @objc func refreshedView(notification: Notification) {
        self.navigationItem.rightBarButtonItems = nil
        addDoubleNavigationButtons()
        if let btn = self.navigationItem.rightBarButtonItems?.first {
            let count = getNotificationCounts()
            if count > 0 {
                btn.addBadge(num: count)
            } else {
                btn.removeBadge()
            }
        }
        self.setupJSON(numberOfDays: numberOfDays, startday: start_day, endday: end_day)
    }
    
    func setupJSON(numberOfDays: Int, startday: String?, endday: String?) {
        if !ifIsSearch {
            var query = ""
            
            if start_day == nil && end_day == nil {
                let previousDate = getPreviousDays(days: -numberOfDays)
                let weekly = previousDate.convertDateToString(date: previousDate)
                
                query = "SELECT * FROM REQUEST_LOGS WHERE CREATED_DATE >= '\(weekly)' AND CREATED_DATE <= '\(getLocalCurrentDate())' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
            } else {
                 query = "SELECT * FROM REQUEST_LOGS WHERE CREATED_DATE >= '\(startday!)' AND CREATED_DATE <= '\(endday!)' AND MODULE_ID = '\(CONSTANT_MODULE_ID)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
            }
            tbl_request_logs = AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: query)
            if let _ = tbl_request_logs {
                tbl_request_logs = tbl_request_logs?.filter({ (logs) -> Bool in
                    logs.LOGIN_ID == Int(CURRENT_USER_LOGGED_IN_ID)!
                })
                tbl_request_logs = tbl_request_logs?.sorted(by: { (l1, l2) -> Bool in
                    l1.CREATED_DATE! > l2.CREATED_DATE!
                })
            }
            
            if filtered_status == "" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.temp_data = self.tbl_request_logs
//                    self.setupCircularViews()
                    self.tableView.reloadData()
                    self.setupTableViewHeight(isFiltered: false)
                }
            } else {
                self.filteredData(status: self.filtered_status)
            }
        }
    }
    func setupTableViewHeight(isFiltered: Bool) {
        var height: CGFloat = 0.0
        if isFiltered {
            height = CGFloat((filtered_data!.count * 80) + 120)
        } else {
            height = CGFloat((tbl_request_logs!.count * 80) + 120)
        }
        self.mainViewHeightConstraint.constant = 280
        switch UIDevice().type {
        case .iPhone5, .iPhone5S, .iPhone5C, .iPhoneSE:
            if height > 570 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 570
            }
            break
        case .iPhone6, .iPhone6S, .iPhone7, .iPhone8:
            if height > 670 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 670
            }
        case .iPhone6Plus, .iPhone7Plus, .iPhone8Plus:
            if height > 740 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 740
            }
            break
        case .iPhoneX, .iPhoneXR, .iPhoneXS, .iPhone11Pro, .iPhone12, .iPhone12Pro:
            if height > 790 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 790
            }
        case .iPhone11, .iPhoneXSMax, .iPhone11ProMax:
            if height > 840 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 840
            }
            break
        case .iPhone12ProMax:
            if height > 880 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 880
            }
            break
        case .iPhone12Mini:
            if height > 770 {
                self.mainViewHeightConstraint.constant = height
            } else {
                self.mainViewHeightConstraint.constant = 770
            }
        default:
            break
        }
    }
    func setupCircularViews() {
        
        let pendingCount = self.tbl_request_logs?.filter({ (logs) -> Bool in
            logs.TICKET_STATUS == "Pending"
            }).count
        let approvedCount = self.tbl_request_logs?.filter({ (logs) -> Bool in
            logs.TICKET_STATUS == "Approved" ||
            logs.TICKET_STATUS == "approved"
        }).count
        let rejectedCount = self.tbl_request_logs?.filter({ (logs) -> Bool in
            logs.TICKET_STATUS == "Rejected" ||
            logs.TICKET_STATUS == "rejected"
        }).count
        
        self.pending_circular_view.maxValue = CGFloat(self.tbl_request_logs?.count ?? 0)
        self.approved_circular_view.maxValue = CGFloat(self.tbl_request_logs?.count ?? 0)
        self.rejected_circular_view.maxValue = CGFloat(self.tbl_request_logs?.count ?? 0)
        
        UIView.animate(withDuration: 0.5) {
            self.pending_circular_view.value = CGFloat(pendingCount ?? 0)
            self.approved_circular_view.value = CGFloat(approvedCount ?? 0)
            self.rejected_circular_view.value = CGFloat(rejectedCount ?? 0)
        }
        
    }
    func filteredData(status: String) {
        self.filtered_data = self.tbl_request_logs?.filter({ (logs) -> Bool in
            logs.TICKET_STATUS == status
        })
        self.filtered_status = status
        self.isFiltered = true
        self.tableView.reloadData()
        self.setupTableViewHeight(isFiltered: true)
    }
    
    
    @IBAction func newRequest_tapped(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "NewRequestLeadershipAwazViewController") as! NewRequestLeadershipAwazViewController
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func monitoring_tapped(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "LeadershipAwazAllRequestViewController") as! LeadershipAwazAllRequestViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func sortedBtn_Tapped(_ sender: Any) {
        let s = sender as! UIButton
        if self.sortedImages[s.tag].image != nil {
            self.sortedImages[s.tag].image = nil
            
            self.isFiltered = false
            self.tableView.reloadData()
            self.setupTableViewHeight(isFiltered: false)
            return
        } else {
            self.sortedImages.forEach { (UIImageView) in
                UIImageView.image = nil
            }
            switch s.tag {
            case 0:
                self.sortedImages[0].image = UIImage(named: "rightY")
                self.filteredData(status: "Pending")
                break
            case 1:
                self.sortedImages[1].image = UIImage(named: "rightG")
                self.filteredData(status: "Approved")
                break
            case 2:
                self.sortedImages[2].image = UIImage(named: "rightR")
                self.filteredData(status: "Rejected")
                break
            default:
                break
            }
        }
    }
}




extension ChairmenListingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltered {
            if let count = self.filtered_data?.count {
                return count
            }
            return 0
        } else {
            if let count = tbl_request_logs?.count {
                return count
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestListingCell") as! RequestListingTableCell
        
        var data : tbl_Hr_Request_Logs?
        
        if isFiltered {
            data = self.filtered_data![indexPath.row]
        } else {
            data = self.tbl_request_logs![indexPath.row]
        }
        
        cell.mainHeading.text = data!.REQ_REMARKS!
        cell.subHeading.text = ""
        cell.date.text = data!.CREATED_DATE?.dateSeperateWithT ?? ""
        
        let query = "SELECT VIEW_COUNT FROM \(db_hr_request) WHERE SERVER_ID_PK = '\(data!.SERVER_ID_PK!)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"

        let string = NSMutableAttributedString(string:"")
        
        let showviewattributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13),
                                  NSAttributedString.Key.foregroundColor:UIColor.rejectedColor()]
        
        
        if let view_count = AppDelegate.sharedInstance.db?.read_column(query: query) {
            let viewCount = NSAttributedString.init(string: "Views: \(view_count)\n", attributes: showviewattributes)
            string.append(viewCount)
        }
        
        switch data!.TICKET_STATUS?.lowercased() {
        case "pending":
            let statusAttr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),
                                      NSAttributedString.Key.foregroundColor:UIColor.pendingColor()]
            let status = NSAttributedString.init(string: "Pending", attributes: statusAttr)
            string.append(status)
            break
        case "approved":
            let statusAttr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),
                                      NSAttributedString.Key.foregroundColor:UIColor.approvedColor()]
            let status = NSAttributedString.init(string: "Broadcasted", attributes: statusAttr)
            string.append(status)
            break
        case "rejected":
            let statusAttr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),
                                      NSAttributedString.Key.foregroundColor:UIColor.rejectedColor()]
            let status = NSAttributedString.init(string: "Rejected", attributes: statusAttr)
            string.append(status)
            break
        default:
            break
        }
        
        cell.status.attributedText = string
//        cell.status.textColor = UIColor.rejectedColor()
        cell.type.text = "Leadership Connect"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var data : tbl_Hr_Request_Logs?
        
        if isFiltered {
            data = self.filtered_data![indexPath.row]
        } else {
            data = self.tbl_request_logs![indexPath.row]
        }
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "NewRequestLeadershipAwazViewController") as! NewRequestLeadershipAwazViewController
        controller.ticket_id = data!.SERVER_ID_PK!
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
}



extension ChairmenListingViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        searchQueryTimer?.invalidate()
        
        let currentText = textField.text ?? ""
        print(currentText)
        
        if (currentText as NSString).replacingCharacters(in: range, with: string).count == 0 {
            
            self.tbl_request_logs = temp_data
            
            self.tableView.reloadData()
            self.setupTableViewHeight(isFiltered: false)
            self.ifIsSearch = false
            return true
        }
        if (currentText as NSString).replacingCharacters(in: range, with: string).count >= 3 {
            searchQueryTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(performSearch), userInfo: nil, repeats: false)
        }
        return true
    }
    @objc func performSearch() {
        
        self.tbl_request_logs = self.tbl_request_logs?.filter({ (logs) -> Bool in
            self.ifIsSearch = true
            return (logs.REQ_REMARKS?.lowercased().contains(self.search_textfield.text?.lowercased() ?? "")) ?? false ||
                (String(logs.SERVER_ID_PK ?? 0).contains(self.search_textfield.text?.lowercased() ?? ""))
        })
        
        self.tableView.reloadData()
        self.setupTableViewHeight(isFiltered: false)
        
    }
}
