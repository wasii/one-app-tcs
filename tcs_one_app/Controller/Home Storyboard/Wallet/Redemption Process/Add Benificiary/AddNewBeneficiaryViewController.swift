//
//  AddNewBeneficiaryViewController.swift
//  tcs_one_app
//
//  Created by TCS on 22/09/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class AddNewBeneficiaryViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallet"
        makeTopCornersRounded(roundView: mainView)
    }
}
