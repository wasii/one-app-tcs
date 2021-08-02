//
//  RiderBinInfoViewController.swift
//  tcs_one_app
//
//  Created by TCS on 30/07/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class RiderBinInfoViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    var bin: String = ""
    var bin_info: [tbl_rider_bin_info]?
    var delegate: BinInfoDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
        
        self.bin_info = AppDelegate.sharedInstance.db?.read_tbl_rider_bin_info(query: "SELECT * FROM \(db_rider_bin_info) WHERE BIN_DSCRP = '\(bin)'")
        
        self.tableView.reloadData()
    }
    
    @IBAction func fetchTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.fetchBinInfo()
        }
    }
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.cancel()
        }
    }
}

extension RiderBinInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.bin_info?.count {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "BinInfoCell") as? BinInfoTableCell else {
            fatalError()
        }
        
        if let data = self.bin_info?[indexPath.row] {
            cell.sheetNo.text = "Sheet No: " + data.DLVRY_SHT_NO
            cell.station.text = "Station: " + data.STA_NO
            cell.route.text = "Route: " + data.DLVRY_RUT
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
