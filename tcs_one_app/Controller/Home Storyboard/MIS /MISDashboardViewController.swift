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
        
//        if let mis_id = AppDelegate.sharedInstance.db?.read_tbl_UserPage().filter({ user_page in
//            user_page.PAGENAME == "MIS Listing"
//        }).first?.SERVER_ID_PK {
//            print("MIS ID: \(mis_id)")
//            if let user_permissions = AppDelegate.sharedInstance.db?.read_tbl_UserPermission() {
//                mis_listing_data = [tbl_mis_product_data]()
//                let _ = AppDelegate.sharedInstance.db?.read_tbl_mis_product_data(query: "SELECT * FROM \(db_mis_product_data)")?.forEach({ pd in
//                    user_permissions.forEach { permission in
//                        if permission.PERMISSION == pd.product {
//                            self.mis_id = permission.PAGEID
//                            mis_listing_data?.append(tbl_mis_product_data(id: pd.id, product: pd.product))
//                        }
//                    }
//                })
//            }
//            self.tableView.reloadData()
//        }
        
        let query = "SELECT (CASE WHEN count(*) > 1 THEN GROUP_CONCAT(PROD_TYPE , ' + ') ELSE '' END) AS PROD_WITH_PRODTYPE,* FROM (SELECT * FROM \(db_mis_budget_setup) GROUP BY PRODUCT,PROD_TYPE ORDER BY PROD_TYPE DESC) GROUP BY PRODUCT"
//        let query = "SELECT * FROM \(db_mis_budget_setup) GROUP BY PROD_TYPE"
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
//        controller.mis_product_data = self.mis_listing_data![indexPath.row]
//        controller.mis_id = self.mis_id
//
//        if let ServerIdPk = AppDelegate.sharedInstance.db?.read_tbl_UserPage().filter({ page in
//            page.PAGENAME == self.mis_listing_data![indexPath.row].product
//        }).first?.SERVER_ID_PK {
//            AppDelegate.sharedInstance.db?.read_tbl_UserPermission().filter({ permissions in
//                permissions.PAGEID == ServerIdPk
//            }).forEach({ listing in
//                if listing.PERMISSION == "WEIGHT" {
//                    controller.isWieghtAllowed = 1
//                }
//                if listing.PERMISSION == "QSR" {
//                    controller.isQSRAllowed = 1
//                }
//                if listing.PERMISSION == "DSR" {
//                    controller.isDSRAllowed = 1
//                }
//            })
//        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
struct MISBudgetSetupListing {
    var product: String = ""
    var produt_type: String = ""
}
