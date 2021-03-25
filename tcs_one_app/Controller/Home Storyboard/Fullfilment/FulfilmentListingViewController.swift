//
//  FulfilmentListingViewController.swift
//  tcs_one_app
//
//  Created by TCS on 25/03/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class FulfilmentListingViewController: BaseViewController {

    @IBOutlet weak var search_textfileld: UITextField!
    @IBOutlet weak var sorting_btn: UIButton!
    @IBOutlet weak var this_week: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Fulfilment"
        addDoubleNavigationButtons()
        
        tableView.register(UINib(nibName: "FulfilmentListingTableCell", bundle: nil), forCellReuseIdentifier: "FulfilmentListingCell")
        tableView.rowHeight = 85
        search_textfileld.delegate = self
    }
    @IBAction func sorting_btn_tapped(_ sender: Any) {
    }
    @IBAction func this_week_tapped(_ sender: Any) {
    }
}

extension FulfilmentListingViewController: UITextFieldDelegate {
    
}

extension FulfilmentListingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FulfilmentListingCell") as! FulfilmentListingTableCell
        
        return cell
    }
}
