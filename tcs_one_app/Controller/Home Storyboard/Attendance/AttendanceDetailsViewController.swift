//
//  AttendanceDetailsViewController.swift
//  tcs_one_app
//
//  Created by TCS on 11/03/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class AttendanceDetailsViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var user_attendance: [tbl_att_user_attendance]?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeTopCornersRounded(roundView: self.mainView)
        self.title = "Attendance"
        tableView.register(UINib(nibName: "AttendanceDetailsTableCell", bundle: nil), forCellReuseIdentifier: "AttendanceDetailsCell")
        tableView.rowHeight = 100
        let query = "SELECT * FROM \(db_att_userAttendance) WHERE CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
        user_attendance = AppDelegate.sharedInstance.db?.read_tbl_att_user_attendance(query: query)
        
        self.tableView.reloadData()
    }
}

extension AttendanceDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = user_attendance?.count {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttendanceDetailsCell") as! AttendanceDetailsTableCell
        let data = self.user_attendance![indexPath.row]
        
        cell.dayName.text = "\(data.DAYS.replacingOccurrences(of: " ", with: ""))    "
        if data.STATUS == "1" {
            if data.TIME_IN == "00:00" {
                cell.timeIn.text = "Awaited"
                cell.timeOut.text = "Awaited"
            } else {
                cell.timeIn.text = data.TIME_IN
                cell.timeOut.text = data.TIME_OUT
            }
        } else {
            cell.timeIn.text = data.TIME_IN
            cell.timeOut.text = data.TIME_OUT
        }
        
        
//        cell.date.text = data.DATE.dateOnly
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let date = dateFormatter.date(from: data.DATE.dateOnly)
        dateFormatter.dateFormat = "dd MMMM yyyy"
        let strDate = dateFormatter.string(from: date!)
        
        cell.date.text = strDate
        return cell
    }
}


