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
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallet"
        makeTopCornersRounded(roundView: self.mainView)
        self.tableView.register(UINib(nibName: WalletBeneficiaryListingTableCell.description(), bundle: nil), forCellReuseIdentifier: WalletBeneficiaryListingTableCell.description())
//        self.tableView.estimatedRowHeight = 100
//        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.tableViewHeightConstraint.constant = CGFloat(90 * 50)
            self.tableView.reloadData()
        }
    }
    @IBAction func addBeneficiaryTapped(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddNewBeneficiaryViewController") as! AddNewBeneficiaryViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension WalletBeneficiaryDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WalletBeneficiaryListingTableCell.description()) as? WalletBeneficiaryListingTableCell else {
            fatalError()
        }
        cell.redemptionBtn.addTarget(self, action: #selector(transferPoints(sender:)), for: .touchUpInside)
        cell.redemptionBtn.tag = indexPath.row
        cell.nameLabel.text = "TCS One App \(indexPath.row)"
        cell.empIdLabel.text = "EMP ID:     \(CURRENT_USER_LOGGED_IN_ID)"
        cell.cellLabel.text = "CELL#:       03331231231"
        
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
