//
//  MISDetailViewController.swift
//  tcs_one_app
//
//  Created by TCS on 07/09/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class MISDetailViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    var mis_budget_setup: tbl_mis_budget_setup?
    var mis_popup_mnth: MISPopupMonth?
    var mis_popop_year: MISPopupYear?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeTopCornersRounded(roundView: self.mainView)
        title = "MIS"
        if let product = mis_budget_setup?.product {
            headingLabel.text = product
        }
    }
    
    @IBAction func selectionBtnTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Popups", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "NewRequestListingViewController") as! NewRequestListingViewController
        if sender.tag == 0 {
            controller.mis_popop_year = AppDelegate.sharedInstance.db?.read_tbl_mis_budget_setup_year()
            controller.heading = "Select Year"
        } else {
            controller.mis_popup_mnth = AppDelegate.sharedInstance.db?.read_tbl_mis_budget_setup_month()
            controller.heading = "Select Month"
        }
        
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        controller.modalTransitionStyle = .crossDissolve
        controller.misdelegate = self
        Helper.topMostController().present(controller, animated: true, completion: nil)
    }
}


extension MISDetailViewController: MISDelegate {
    func updateListing(region_date: tbl_mis_region_data) {}
    
    func updateMonth(mnth: MISPopupMonth) {
        self.monthLabel.text = mnth.mnth
    }
    
    func updateYearr(year: MISPopupYear) {
        self.yearLabel.text = year.yearr
    }
    
    
}

