//
//  RiderDeliveryDashboardViewController.swift
//  tcs_one_app
//
//  Created by TCS on 21/06/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields

class RiderDeliveryDashboardViewController: BaseViewController {
    let constant = "Enter CN Number or Sheet Number"
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var searchTextField: MDCOutlinedTextField!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Rider"
        self.makeTopCornersRounded(roundView: self.mainView)
        self.tableView.register(UINib(nibName: RiderDashboardTableCell.description(), bundle: nil), forCellReuseIdentifier: RiderDashboardTableCell.description())
        self.tableView.rowHeight = 80
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.reloadData()
        
        
        searchTextField.label.textColor = UIColor.nativeRedColor()
        searchTextField.label.text = "Load Sheet"
        searchTextField.text = constant
        searchTextField.placeholder = ""
        searchTextField.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        searchTextField.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        searchTextField.delegate = self
    }
}
extension RiderDeliveryDashboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RiderDashboardTableCell.description()) as? RiderDashboardTableCell else {
            fatalError()
        }
        
        cell.googlePin.tag = indexPath.row
        cell.callBtn.tag = indexPath.row
        
        cell.googlePin.addTarget(self, action: #selector(googlePinTapped(sender:)), for: .touchUpInside)
        cell.callBtn.addTarget(self, action: #selector(callBtnTapped(sender:)), for: .touchUpInside)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    @objc func googlePinTapped(sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "RiderGoogleLocationViewController") as! RiderGoogleLocationViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @objc func callBtnTapped(sender: UIButton) {
        if let url = URL(string: "tel://0213111123123") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension RiderDeliveryDashboardViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == constant {
            textField.text = ""
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text!.count <= 0 {
            textField.text = constant
        }
    }
}
