//
//  IMSHistoryViewController.swift
//  tcs_one_app
//
//  Created by TCS on 14/01/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class IMSHistoryViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    var ticket_id: Int?
    var grievance_remarks: [tbl_Grievance_Remarks]?
    var closure_remarks: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "History"
        self.makeTopCornersRounded(roundView: self.mainView)

        // Do any additional setup after loading the view.
        self.tableView.register(UINib(nibName: "GrievancesHistoryTableCell", bundle: nil), forCellReuseIdentifier: "GrievancesHistoryCell")
        self.tableView.estimatedRowHeight = 10.0
        self.tableView.rowHeight = UITableView.automaticDimension
        
        let query = "SELECT HR_REMARKS FROM \(db_hr_request) WHERE SERVER_ID_PK = '\(ticket_id!)'"
        if let cr = AppDelegate.sharedInstance.db?.read_column(query: query) {
            closure_remarks = "\(cr)"
        }
        
        setupGrievanceRemarks { (count) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    print(self.tableView.contentSize.height)
                    let tableViewHeight = self.tableView.contentSize.height
                    if tableViewHeight > UIScreen.main.bounds.height {
                        self.mainViewHeightConstraint.constant = tableViewHeight + 100
                    } else {
                        self.mainViewHeightConstraint.constant = UIScreen.main.bounds.height + 100
                    }
                }
            }
        }
    }
    
    func setupGrievanceRemarks(_ handler: @escaping(_ count: Int) -> Void) {
        let query = "SELECT * FROM \(db_grievance_remarks) WHERE TICKET_ID = '\(self.ticket_id!)';"
        self.grievance_remarks = AppDelegate.sharedInstance.db?.read_tbl_hr_grievance(query: query)
        var isInitiator = false
        if let ticket = AppDelegate.sharedInstance.db?.read_tbl_hr_request(query: "SELECT * FROM \(db_hr_request) WHERE SERVER_ID_PK = '\(self.ticket_id!)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'").first {
            if "\(ticket.LOGIN_ID ?? 0)" == CURRENT_USER_LOGGED_IN_ID {
                isInitiator = true
            }
        }
        var temp_remarks = [tbl_Grievance_Remarks]()
        let temp = self.grievance_remarks
        if let _ = grievance_remarks?.count {
            if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_Remarks_Initiator).count > 0 {
                self.grievance_remarks = temp?.filter({ (r1) -> Bool in
                    r1.REMARKS_INPUT == IMS_InputBy_Initiator
                })
                for r in self.grievance_remarks! {
                    temp_remarks.append(r)
                }
            }
            if isInitiator {
                self.grievance_remarks = temp_remarks
                handler(self.grievance_remarks!.count)
                return
            }
            if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_Remarks_Line_Manager).count > 0 {
                self.grievance_remarks = temp?.filter({ (r1) -> Bool in
                    r1.REMARKS_INPUT == IMS_InputBy_LineManager
                })
                for r in self.grievance_remarks! {
                    temp_remarks.append(r)
                }
            }
            if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_Remarks_Department_Head).count > 0 {
                self.grievance_remarks = temp?.filter({ (r1) -> Bool in
                    r1.REMARKS_INPUT == IMS_InputBy_Hod
                })
                for r in self.grievance_remarks! {
                    temp_remarks.append(r)
                }
            }
            if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_Remarks_Central_Security).count > 0 {
                self.grievance_remarks = temp?.filter({ (r1) -> Bool in
                    r1.REMARKS_INPUT == IMS_InputBy_CentralSecurity
                })
                for r in self.grievance_remarks! {
                    temp_remarks.append(r)
                }
            }
            if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_Remarks_Area_Security).count > 0 {
                self.grievance_remarks = temp?.filter({ (r1) -> Bool in
                    r1.REMARKS_INPUT == IMS_InputBy_AreaSecurity
                })
                for r in self.grievance_remarks! {
                    temp_remarks.append(r)
                }
            }
            if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_Remarks_Head_Security).count > 0 {
                self.grievance_remarks = temp?.filter({ (r1) -> Bool in
                    r1.REMARKS_INPUT == IMS_InputBy_HeadSecurity
                })
                for r in self.grievance_remarks! {
                    temp_remarks.append(r)
                }
            }
            if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_Remarks_Director_Security).count > 0 {
                self.grievance_remarks = temp?.filter({ (r1) -> Bool in
                    r1.REMARKS_INPUT == IMS_InputBy_DirectorSecurity
                })
                for r in self.grievance_remarks! {
                    temp_remarks.append(r)
                }
            }
            if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_Remarks_Financial_Services).count > 0 {
                self.grievance_remarks = temp?.filter({ (r1) -> Bool in
                    r1.REMARKS_INPUT == IMS_InputBy_FinancialService
                })
                for r in self.grievance_remarks! {
                    temp_remarks.append(r)
                }
            }
            if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_Remarks_Finance).count > 0 {
                self.grievance_remarks = temp?.filter({ (r1) -> Bool in
                    r1.REMARKS_INPUT == IMS_InputBy_Finance
                })
                for r in self.grievance_remarks! {
                    temp_remarks.append(r)
                }
            }
            if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_Remarks_Human_Resources).count > 0 {
                self.grievance_remarks = temp?.filter({ (r1) -> Bool in
                    r1.REMARKS_INPUT == IMS_InputBy_HumanResource
                })
                for r in self.grievance_remarks! {
                    temp_remarks.append(r)
                }
            }
            if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: IMS_Remarks_Controller).count > 0 {
                self.grievance_remarks = temp?.filter({ (r1) -> Bool in
                    r1.REMARKS_INPUT == IMS_InputBy_Controller
                })
                for r in self.grievance_remarks! {
                    temp_remarks.append(r)
                }
            }
            temp_remarks = temp_remarks.sorted(by: { (remarks1, remarks2) -> Bool in
                remarks1.CREATED < remarks2.CREATED
            })
            self.grievance_remarks = temp_remarks
            handler(self.grievance_remarks!.count)
            
        } else {
            handler(0)
        }
    }
}


extension IMSHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.grievance_remarks?.count {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GrievancesHistoryCell") as! GrievancesHistoryTableCell
        let data = self.grievance_remarks![indexPath.row]
        cell.closure_remarksLabel.text = ""
        cell.roleManager.text = data.REMARKS_INPUT
        cell.dateLabel.text = data.CREATED.dateSeperateWithT
        cell.descriptions.text = data.REMARKS
        return cell
    }
}

