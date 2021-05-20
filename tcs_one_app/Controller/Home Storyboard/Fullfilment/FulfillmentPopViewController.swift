//
//  FulfillmentPopViewController.swift
//  tcs_one_app
//
//  Created by TCS on 30/03/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
protocol FulFillmentPopup {
    func donePressed()
}
class FulfillmentPopViewController: UIViewController {
    var delegate: FulFillmentPopup?
    override func viewDidLoad() {
        view.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
        super.viewDidLoad()
    }
    @IBAction func donePressed(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.donePressed()
        }
    }
}
