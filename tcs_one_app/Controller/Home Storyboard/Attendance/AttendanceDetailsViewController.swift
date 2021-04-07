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
        tableView.estimatedRowHeight = UITableView.automaticDimension
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
        
        let dateFormatter = DateFormatter()
        
        if data.STATUS == "1" {
            if data.TIME_IN == "00:00" {
                cell.timeIn.text = "Awaited"
                cell.timeOut.text = "Awaited"
            } else {
                let locale = NSLocale.current
                let formatter: String = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: locale)!
                var dateComponents: DateComponents?
                var fixedTime = Date()
                var timeInDate = Date()
                var stringTimeInDate = ""
                if formatter.contains("a") {
                    dateFormatter.dateFormat = "h:mm a"
                    timeInDate = dateFormatter.date(from: data.TIME_IN)!
                    fixedTime = dateFormatter.date(from: "09:15 AM")!
                } else {
                    dateFormatter.dateFormat = "h:mm a"
                    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
                    let tempTimeInDate = dateFormatter.date(from: data.TIME_IN)!
                    
                    dateFormatter.dateFormat = "HH:mm"
                    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
                    stringTimeInDate = dateFormatter.string(from: tempTimeInDate)
                    timeInDate = dateFormatter.date(from: stringTimeInDate)!
                    fixedTime = dateFormatter.date(from: "9:15")!
                }
                let calendar = Calendar.current
                dateComponents = calendar.dateComponents([Calendar.Component.minute], from: fixedTime, to: timeInDate)
                
                if dateComponents?.minute ?? 0 >= 15 {
                    cell.timeInLabel.textColor = UIColor.nativeRedColor()
                    cell.timeInImage.image = UIImage(named: "in-arrow-red")
                } else {
                    cell.timeInLabel.textColor = UIColor.approvedColor()
                    cell.timeInImage.image = UIImage(named: "in-arrow")
                }
                if stringTimeInDate == "" {
                    cell.timeIn.text = data.TIME_IN
                } else {
                    cell.timeIn.text = stringTimeInDate
                }
                cell.timeOut.text = data.TIME_OUT
            }
        } else {
            if data.TIME_IN != "00:00" {
                
                let locale = NSLocale.current
                let formatter: String = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: locale)!
                var dateComponents: DateComponents?
                var fixedTime = Date()
                var timeInDate = Date()
                if formatter.contains("a") {
                    dateFormatter.dateFormat = "h:mm a"
                    timeInDate = dateFormatter.date(from: data.TIME_IN)!
                    fixedTime = dateFormatter.date(from: "09:15 AM")!
                } else {
                    dateFormatter.dateFormat = "h:mm a"
                    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
                    let tempTimeInDate = dateFormatter.date(from: data.TIME_IN)!
                    
                    dateFormatter.dateFormat = "HH:mm"
                    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
                    let strinTimeInDate = dateFormatter.string(from: tempTimeInDate)
                    timeInDate = dateFormatter.date(from: strinTimeInDate)!
                    fixedTime = dateFormatter.date(from: "9:15")!
                }
                let calendar = Calendar.current
                dateComponents = calendar.dateComponents([Calendar.Component.minute], from: fixedTime, to: timeInDate)
                
                if dateComponents?.minute ?? 0 >= 15 {
                    cell.timeIn.textColor = UIColor.nativeRedColor()
                    cell.timeInLabel.textColor = UIColor.nativeRedColor()
                    cell.timeInImage.image = UIImage(named: "in-arrow-red")
                } else {
                    cell.timeInLabel.textColor = UIColor.approvedColor()
                    cell.timeInImage.image = UIImage(named: "in-arrow")
                }
                
            }
            cell.timeIn.text = data.TIME_IN
            cell.timeOut.text = data.TIME_OUT
        }
        
        
        
        if data.TIME_OUT != "00:00" {
            let locale = NSLocale.current
            let formatter: String = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: locale)!
            if formatter.contains("a") {
                print("12 hours format")
                dateFormatter.dateFormat = "h:mm a"

                let timeInDate = dateFormatter.date(from: data.TIME_IN)
                let timeOutDate = dateFormatter.date(from: data.TIME_OUT)

                let calendar = Calendar.current
                let dateComponents = calendar.dateComponents([Calendar.Component.hour, Calendar.Component.minute], from: timeInDate!, to: timeOutDate!)

                let hours = dateComponents.hour ?? 0

                if hours >= 9 {
                    cell.timeOutLabel.textColor = UIColor.approvedColor()
                    cell.timeOutImage.image = UIImage(named: "out-array-green")
                } else {
                    cell.timeOutLabel.textColor = UIColor.nativeRedColor()
                    cell.timeOutImage.image = UIImage(named: "out-array")
                }
            } else {
                dateFormatter.dateFormat = "h:mm a"
                dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
                
                let tempTimeInDate = dateFormatter.date(from: data.TIME_IN)
                let tempTimeOutDate = dateFormatter.date(from: data.TIME_OUT)
                
                dateFormatter.dateFormat = "HH:mm"
                dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
                let stringTimeInDate = dateFormatter.string(from: tempTimeInDate!)
                let stringTimeOutDate = dateFormatter.string(from: tempTimeOutDate!)
                
                let timeInDate = dateFormatter.date(from: stringTimeInDate)!
                let timeOutDate = dateFormatter.date(from: stringTimeOutDate)!
                
                let calendar = Calendar.current
                let dateComponents = calendar.dateComponents([Calendar.Component.hour, Calendar.Component.minute], from: timeInDate, to: timeOutDate)

                let hours = dateComponents.hour ?? 0

                if hours >= 9 {
                    cell.timeOutLabel.textColor = UIColor.approvedColor()
                    cell.timeOutImage.image = UIImage(named: "out-array-green")
                } else {
                    cell.timeOutLabel.textColor = UIColor.nativeRedColor()
                    cell.timeOutImage.image = UIImage(named: "out-array")
                }
            }
        }
        
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let date = dateFormatter.date(from: data.DATE.dateOnly)
        dateFormatter.dateFormat = "dd MMMM yyyy"
        let strDate = dateFormatter.string(from: date!)
        
        cell.date.text = strDate
        return cell
    }
}


