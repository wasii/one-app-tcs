//
//  MISDashboardViewController.swift
//  tcs_one_app
//
//  Created by TCS on 11/08/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class MISDashboardViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
//    var mis_listing_data: [tbl_mis_product_data]?
    var mis_budget_setup: [tbl_mis_budget_setup]?
    var indexPath: IndexPath?
    var mis_id = 0
    override func viewDidAppear(_ animated: Bool) {
        if let indexPath = self.indexPath {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "MIS"
        self.makeTopCornersRounded(roundView: self.mainView)
        
        let query = "SELECT up.* FROM (SELECT (CASE WHEN count(*) > 1 THEN GROUP_CONCAT(PROD_TYPE , ' + ') ELSE '' END) AS PROD_WITH_PRODTYPE,* FROM (SELECT * FROM MIS_BUDGET_SETUP GROUP BY PRODUCT,PROD_TYPE ORDER BY PROD_TYPE DESC) GROUP BY PRODUCT) AS up INNER JOIN (SELECT u.PERMISSION FROM USER_PAGE AS up INNER JOIN USER_PERMISSION AS u ON  up.PAGENAME = 'MIS Listing' AND up.SERVER_ID_PK = u.PAGEID) AS permission ON permission.PERMISSION = (CASE WHEN up.PROD_WITH_PRODTYPE == '' THEN up.PRODUCT || ' - ' || up.PROD_TYPE ELSE up.PRODUCT || ' - ' || up.PROD_WITH_PRODTYPE END)"

        if let mis_budget_setup = AppDelegate.sharedInstance.db?.read_tbl_mis_budget_setup_listing(query: query) {
            self.mis_budget_setup = mis_budget_setup
            self.tableView.reloadData()
        }
    }
}

extension MISDashboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.mis_budget_setup?.count {
            return count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListingCell") else {
            fatalError()
        }
        
        if let label = cell.viewWithTag(1) as? UILabel {
            
            if mis_budget_setup![indexPath.row].prod_with_prodtype == "" {
                label.text = mis_budget_setup![indexPath.row].product
            } else {
                label.text = mis_budget_setup![indexPath.row].product + " - \(mis_budget_setup![indexPath.row].prod_with_prodtype)"
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.indexPath = indexPath
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISDetailViewController") as! MISDetailViewController
        controller.mis_budget_setup = self.mis_budget_setup![indexPath.row]
        if self.mis_budget_setup![indexPath.row].prod_with_prodtype == "" {
            controller.isDualValue = false
        } else {
            controller.isDualValue = true
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
struct MISBudgetSetupListing {
    var product: String = ""
    var produt_type: String = ""
}
