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
    @IBOutlet weak var gbOutlet: UIView!
    @IBOutlet weak var overlandTrend: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "MIS"
        self.makeTopCornersRounded(roundView: self.mainView)
    }
    @IBAction func buttonTapped(_ sender: UIButton) {
        let controller = self .storyboard?.instantiateViewController(withIdentifier: "MISDetailsViewController") as! MISDetailsViewController
        
        if sender.tag == 0 {
            //General and Booking Trend
        } else {
            //Overland Trend
            controller.isOverload = true
        }
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
