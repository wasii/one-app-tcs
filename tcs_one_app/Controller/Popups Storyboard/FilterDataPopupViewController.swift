//
//  FilterDataPopupViewController.swift
//  tcs_one_app
//
//  Created by ibs on 19/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import DatePickerDialog

class FilterDataPopupViewController: UIViewController {
    
    @IBOutlet weak var searchApplyTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainViewHeightCOnstraint: NSLayoutConstraint!
    @IBOutlet weak var toDate_Btn: CustomButton!
    @IBOutlet weak var fromDate_Btn: CustomButton!
    @IBOutlet weak var tableView: UITableView!
    
    var json: [FilterData]?
    var fromdate: String?
    var todate: String?
    
    var selected_query: String?
    var delegate: DateSelectionDelegate?
    let datePicker = DatePickerDialog(
        textColor: .nativeRedColor(),
        buttonColor: .nativeRedColor(),
        font: UIFont.boldSystemFont(ofSize: 17),
        showCancelButton: true
    )
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
        
        self.searchApplyTopConstraint.constant = 10
        self.mainViewHeightCOnstraint.constant = 354
        
        
        self.fromDate_Btn.isEnabled = false
        self.toDate_Btn.isEnabled = false
        setupJSON()
    }
    
    func setupJSON() {
        json = [FilterData]()
        for filter_query in FILTERDATA {
            if filter_query == self.selected_query {
                json?.append(FilterData(title: filter_query, isSelected: true))
            } else {
                json?.append(FilterData(title: filter_query, isSelected: false))
            }
        }
        if self.fromdate != nil && self.todate != nil {
            self.searchApplyTopConstraint.constant = 70
            self.mainViewHeightCOnstraint.constant = 404
            
            
            self.fromDate_Btn.isEnabled = true
            self.toDate_Btn.isEnabled = true
            
            
            
            self.fromDate_Btn.setTitle(self.fromdate!.dateOnly, for: .normal)
            self.toDate_Btn.setTitle(self.todate!.dateOnly, for: .normal)
        }
        self.tableView.reloadData()
    }
    
    func openDatePicker(title: String, handler: @escaping(_ success: Bool,_ date: String) -> Void) {
        datePicker.show(title,
                        doneButtonTitle: "Done",
                        cancelButtonTitle: "Cancel",
                        maximumDate: Date(),
                        datePickerMode: .date,
                        window: self.view.window) { (date) in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                handler(true, formatter.string(from: dt))
            }
        }
    }
    
    @IBAction func toBtn_Tapped(_ sender: Any) {
        self.openDatePicker(title: "To Date") { success, date in
            if success {
                let finalDate = date.dateOnly + "T23:59:59"
                self.todate = finalDate
                self.toDate_Btn.setTitle(date.dateOnly, for: .normal)
            }
        }
    }
    @IBAction func fromBtn_Tapped(_ sender: Any) {
        self.openDatePicker(title: "From Date") { success, date in
            if success {
                let finalDate = date.dateOnly + "T00:00:00"
                self.fromDate_Btn.setTitle(date.dateOnly, for: .normal)
                self.fromdate = finalDate
                self.toDate_Btn.isEnabled = true
            }
        }
    }
    @IBAction func searchBtn_Tapped(_ sender: Any) {
        if self.selected_query == "Custom Selection" {
            if self.fromdate != nil && self.todate != nil {
                self.dismiss(animated: true) {
                    self.delegate?.dateSelection(startDate: self.fromdate!, endDate: self.todate!, selected_query: self.selected_query!)
                }
            } else {
                self.view.makeToast("Select dates first")
            }
            return
        }
        if self.selected_query == "Weekly" {
            self.dismiss(animated: true) {
                self.delegate?.dateSelection(numberOfDays: 7, selected_query: self.selected_query!)
            }
            return
        }
        if self.selected_query == "15 Days" {
            self.dismiss(animated: true) {
                self.delegate?.dateSelection(numberOfDays: 15, selected_query: self.selected_query!)
            }
            return
        }
        if self.selected_query == "Monthly" {
            self.dismiss(animated: true) {
                self.delegate?.dateSelection(numberOfDays: 30, selected_query: self.selected_query!)
            }
            return
        }
    }
    @IBAction func cancelBtn_Tapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension FilterDataPopupViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.json?.count {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterListingDataCell") as! FilterListingDataTableCell
        let data = self.json![indexPath.row]
        
        if data.isSelected {
            cell.selected_Image.image = UIImage(named: "radioMark")
        } else {
            cell.selected_Image.image = UIImage(named: "radioUnmark")
        }
        
        cell.title_Label.text = data.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        for d in 0..<self.json!.count {
            self.json![d].isSelected = false
        }
        
        self.json![indexPath.row].isSelected = true
        self.tableView.reloadData()
        
        
        if indexPath.row == 3 {
            self.searchApplyTopConstraint.constant = 70
            self.mainViewHeightCOnstraint.constant = 404
            self.fromDate_Btn.isEnabled = true
        } else {
            self.searchApplyTopConstraint.constant = 10
            self.mainViewHeightCOnstraint.constant = 354
            self.fromdate = nil
            self.todate = nil
            
            self.fromDate_Btn.setTitle("From Date", for: .normal)
            self.toDate_Btn.setTitle("To Date", for: .normal)
            self.fromDate_Btn.isEnabled = false
        }
        
        self.selected_query = self.json![indexPath.row].title
    }
}

struct FilterData {
    var title: String
    var isSelected: Bool
}
