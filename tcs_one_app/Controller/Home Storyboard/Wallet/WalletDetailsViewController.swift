//
//  WalletDetailsViewController.swift
//  tcs_one_app
//
//  Created by TCS on 16/06/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class WalletDetailsViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallet"
        self.makeTopCornersRounded(roundView: self.mainView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.tableViewHeightConstraint.constant = 1000// CGFloat(70 * 10) + 50
        }
    }
}


extension WalletDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            fatalError()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
