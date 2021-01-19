//
//  GrievanceRemarksHistoryViewController.swift
//  tcs_one_app
//
//  Created by TCS on 19/11/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit

class GrievanceRemarksHistoryViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    var ticket_id: Int?
    var grievance_remarks: [tbl_Grievance_Remarks]?
    var closure_remarks: String = ""
    
    
    var isNotHRHelpDesk = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "History"
        self.makeTopCornersRounded(roundView: self.mainView)
        NotificationCenter.default.addObserver(self, selector: #selector(upload_pending_request), name: .networkRefreshed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigateThroughtNotify(notification:)), name: .navigateThroughNotification, object: nil)
        self.tableView.register(UINib(nibName: "GrievancesHistoryTableCell", bundle: nil), forCellReuseIdentifier: "GrievancesHistoryCell")
        self.tableView.estimatedRowHeight = 10.0
        self.tableView.rowHeight = UITableView.automaticDimension
        
//        let query = "SELECT HR_REMARKS FROM \(db_hr_request) WHERE SERVER_ID_PK = '\(ticket_id!)'"
//        if let cr = AppDelegate.sharedInstance.db?.read_column(query: query) {
//            closure_remarks = "\(cr)"
//        }
        setupMainViewHeight()
        setupGrievanceRemarks { (count) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    print(self.tableView.contentSize.height)
                    let tableViewHeight = self.tableView.contentSize.height
                    if tableViewHeight > self.mainViewHeightConstraint.constant {
                        self.mainViewHeightConstraint.constant = tableViewHeight + 100
                    } else {
                        self.mainViewHeightConstraint.constant = UIScreen.main.bounds.height
                    }
                }
            }
        }
    }
    func setupMainViewHeight() {
        self.mainViewHeightConstraint.constant = 280
        switch UIDevice().type {
        case .iPhone5, .iPhone5S, .iPhone5C, .iPhoneSE:
            self.mainViewHeightConstraint.constant = 610
            break
        case .iPhone6, .iPhone6S, .iPhone7, .iPhone8:
            self.mainViewHeightConstraint.constant = 620
            
        case .iPhone6Plus, .iPhone7Plus, .iPhone8Plus:
            self.mainViewHeightConstraint.constant = 780
            break
        case .iPhoneX, .iPhoneXR, .iPhoneXS, .iPhone11Pro, .iPhone12, .iPhone12Pro:
            self.mainViewHeightConstraint.constant = 830
            break
        case .iPhone11, .iPhoneXSMax, .iPhone11ProMax:
            self.mainViewHeightConstraint.constant = 910
            break
        case .iPhone12ProMax:
            self.mainViewHeightConstraint.constant = 920
            break
        case .iPhone12Mini:
            self.mainViewHeightConstraint.constant = 810
        default:
            break
        }
    }
    
    func setupGrievanceRemarks(_ handler: @escaping(_ count: Int) -> Void) {
        let query = "SELECT * FROM \(db_grievance_remarks) WHERE TICKET_ID = '\(self.ticket_id!)';"
        self.grievance_remarks = AppDelegate.sharedInstance.db?.read_tbl_hr_grievance(query: query)
        
        var temp_remarks = [tbl_Grievance_Remarks]()
        let temp = self.grievance_remarks
        if let _ = grievance_remarks?.count {
            if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: PERMISSION_Grievance_initiator_remarks).count > 0 {
                self.grievance_remarks = temp?.filter({ (r1) -> Bool in
                    r1.REMARKS_INPUT == "Initiator"
                })
                for r in self.grievance_remarks! {
                    temp_remarks.append(r)
                }
            }
            if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: PERMISSION_Grievance_ermanager_remarks).count > 0 {
                self.grievance_remarks = temp?.filter({ (r1) -> Bool in
                    r1.REMARKS_INPUT == "Er-Manager"
                })
                for r in self.grievance_remarks! {
                    temp_remarks.append(r)
                }
            }
            if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: PERMISSION_Grievance_erofficerr_remarks).count > 0 {
                self.grievance_remarks = temp?.filter({ (r1) -> Bool in
                    r1.REMARKS_INPUT == "Er-Officer"
                })
                for r in self.grievance_remarks! {
                    temp_remarks.append(r)
                }
            }
            if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: PERMISSION_Grievance_security_remarks).count > 0 {
                self.grievance_remarks = temp?.filter({ (r1) -> Bool in
                    r1.REMARKS_INPUT == "Security"
                })
                for r in self.grievance_remarks! {
                    temp_remarks.append(r)
                }
            }
            if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: PERMISSION_Grievance_hrbp_remarks).count > 0 {
                self.grievance_remarks = temp?.filter({ (r1) -> Bool in
                    r1.REMARKS_INPUT == "HRBP"
                })
                for r in self.grievance_remarks! {
                    temp_remarks.append(r)
                }
            }
            if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: PERMISSION_Grievance_srhrbp_remarks).count > 0 {
                self.grievance_remarks = temp?.filter({ (r1) -> Bool in
                    r1.REMARKS_INPUT == "Senior-HRBP"
                })
                for r in self.grievance_remarks! {
                    temp_remarks.append(r)
                }
            }
            if AppDelegate.sharedInstance.db!.read_tbl_UserPermission(permission: PERMISSION_Grievance_ceo_remarks).count > 0 {
                self.grievance_remarks = temp?.filter({ (r1) -> Bool in
                    r1.REMARKS_INPUT == "CEO"
                })
                for r in self.grievance_remarks! {
                    temp_remarks.append(r)
                }
            }
            temp_remarks = temp_remarks.filter({ (remarks) -> Bool in
                remarks.REF_ID != ""
            }).sorted(by: { (remarks1, remarks2) -> Bool in
                remarks1.CREATED < remarks2.CREATED
            })
//            if closure_remarks != "" {
//                let temp = self.grievance_remarks!.last!
//                temp_remarks.append(tbl_Grievance_Remarks(ID: temp.ID,
//                                                          SERVER_ID_PK: temp.SERVER_ID_PK,
//                                                          EMPL_NO: temp.EMPL_NO,
//                                                          TICKET_ID: temp.TICKET_ID,
//                                                          REMARKS: self.closure_remarks,
//                                                          REF_ID: temp.REF_ID,
//                                                          CREATED: temp.CREATED,
//                                                          REMARKS_INPUT: "Closure Remarks",
//                                                          REMARKS_SYNC: temp.REMARKS_SYNC))
//            }
            self.grievance_remarks = temp_remarks
            handler(self.grievance_remarks!.count)
            
        } else {
            handler(0)
        }
    }
}

extension GrievanceRemarksHistoryViewController: UITableViewDataSource, UITableViewDelegate {
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
        
        cell.openAttachments.tag = indexPath.row
        cell.openAttachments.addTarget(self, action: #selector(openDownloadFiles(sender:)), for: .touchUpInside)
        return cell
    }
    
    @objc func openDownloadFiles(sender: UIButton) {
        let row = self.grievance_remarks![sender.tag]
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "FilesAccordingRemarksViewController") as! FilesAccordingRemarksViewController
        
        controller.grem_id = row.SERVER_ID_PK
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
