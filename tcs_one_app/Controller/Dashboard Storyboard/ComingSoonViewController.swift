//
//  ComingSoonViewController.swift
//  tcs_one_app
//
//  Created by TCS on 03/12/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit

class ComingSoonViewController: UIViewController {

    @IBOutlet weak var comingSoonLabel: UILabel!
    var emp_id: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
        if let id = emp_id {
            comingSoonLabel.text = "Employee Id: \(id)"
        }
    }
    @IBAction func closeBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
