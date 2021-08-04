//
//  RiderReportToPopupViewController.swift
//  tcs_one_app
//
//  Created by TCS on 04/08/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields

class RiderReportToPopupViewController: BaseViewController {

    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var otherTextField: MDCOutlinedTextField!
    
    var reportTo: [tbl_rider_report_to_lov]?
    var lastSelected: Int = 0
    var selected_lov: tbl_rider_report_to_lov?
    var delegate: ReportToDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
        let query = "SELECT * FROM \(db_report_to_lov)"
        self.reportTo = AppDelegate.sharedInstance.db?.read_tbl_rider_report_to_lov(query: query)
        
        self.otherTextField.isHidden = true
        self.mainViewHeightConstraint.constant = 350
        otherTextField.label.textColor = UIColor.nativeRedColor()
        otherTextField.label.text = "Others"
        otherTextField.text = ""
        otherTextField.placeholder = "Enter Others"
        otherTextField.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        otherTextField.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        
        DispatchQueue.main.async {
            for (i, d) in self.reportTo!.enumerated() {
                if d.RTT_ID == self.lastSelected {
                    self.reportTo![i].isSelected = true
                }
            }
            self.tableView.dataSource = self
            self.tableView.delegate = self
            self.tableView.reloadData()
        }
    }
    
    @IBAction func checkedBtnTapped(_ sender: Any) {
        if let report_to = self.selected_lov {
            if report_to.RTT_DSCRP == "Others" {
                if otherTextField.text == "" {
                    self.view.makeToast("Cannot be left blank.")
                    return
                }
            }
            self.dismiss(animated: true) {
                self.delegate?.didSelectReportTo(report_to: report_to)
            }
        }
    }
    @IBAction func crossBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


extension RiderReportToPopupViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.reportTo?.count {
            return count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReportToCell") as? ReportToTableCell else {
            
            fatalError()
        }
        if let data = self.reportTo?[indexPath.row] {
            cell.heading.text = data.RTT_DSCRP
            if data.isSelected {
                cell.isselected.image = UIImage(named: "radioMark")
            } else {
                cell.isselected.image = UIImage(named: "radioUnmark")
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        for i in 0..<self.reportTo!.count {
            self.reportTo![i].isSelected = false
        }
        
        self.reportTo![indexPath.row].isSelected = true
        self.tableView.reloadData()
        
        self.selected_lov = self.reportTo![indexPath.row]
        if self.selected_lov?.RTT_DSCRP == "Others" {
            otherTextField.isHidden = false
            self.mainViewHeightConstraint.constant = 400
        } else {
            otherTextField.isHidden = true
            self.mainViewHeightConstraint.constant = 350
        }
    }
}
