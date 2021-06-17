//
//  WalletHistoryViewController.swift
//  tcs_one_app
//
//  Created by TCS on 17/06/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class WalletHistoryViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallet"
        self.makeTopCornersRounded(roundView: self.mainView)
        
        self.tableView.register(UINib(nibName: WalletHistoryTableCell.description(), bundle: nil), forCellReuseIdentifier: WalletHistoryTableCell.description())
        self.tableView.rowHeight = 160
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
}


extension WalletHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WalletHistoryTableCell.description()) as? WalletHistoryTableCell else {
            fatalError()
        }
        
        return cell
    }
}
