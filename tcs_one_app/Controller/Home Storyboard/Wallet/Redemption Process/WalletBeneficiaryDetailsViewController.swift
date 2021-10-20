//
//  WalletAddBeneficiaryViewController.swift
//  tcs_one_app
//
//  Created by TCS on 22/09/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class WalletBeneficiaryDetailsViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    var get_beneficiaries: [tbl_wallet_beneficiaries]?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallet"
        makeTopCornersRounded(roundView: self.mainView)
        self.tableView.register(UINib(nibName: WalletBeneficiaryListingTableCell.description(), bundle: nil), forCellReuseIdentifier: WalletBeneficiaryListingTableCell.description())
//        self.tableView.estimatedRowHeight = 100
//        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let query = "SELECT * FROM \(db_w_beneficiaries) WHERE CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
            if let get_beneficiaries = AppDelegate.sharedInstance.db?.read_tbl_wallet_beneficiaries(query: query) {
                self.get_beneficiaries = get_beneficiaries
                self.tableViewHeightConstraint.constant = CGFloat(get_beneficiaries.count * 90)
                self.tableView.reloadData()
            }
            
        }
    }
    @IBAction func addBeneficiaryTapped(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddNewBeneficiaryViewController") as! AddNewBeneficiaryViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension WalletBeneficiaryDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.get_beneficiaries?.count {
            return count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WalletBeneficiaryListingTableCell.description()) as? WalletBeneficiaryListingTableCell else {
            fatalError()
        }
        if let beneficiaries = self.get_beneficiaries?[indexPath.row] {
            cell.redemptionBtn.addTarget(self, action: #selector(transferPoints(sender:)), for: .touchUpInside)
            cell.redemptionBtn.tag = indexPath.row
            cell.nameLabel.text = beneficiaries.beneficiaryName
            cell.empIdLabel.text = beneficiaries.beneficiaryEmpID
            cell.cellLabel.text = beneficiaries.beneficiaryMobileNumber
        }
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    @objc func transferPoints(sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PointTransferViewController") as! PointTransferViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
