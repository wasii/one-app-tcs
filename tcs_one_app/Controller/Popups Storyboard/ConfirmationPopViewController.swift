//
//  ConfirmationPopViewController.swift
//  tcs_one_app
//
//  Created by TCS on 07/01/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class ConfirmationPopViewController: UIViewController {

    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    var delegate: ConfirmationProtocol?
    var heading: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
        if let head = heading {
            self.heightConstraint.constant = 140
            self.lbl.text = head
        }
    }
    @IBAction func yesTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.confirmationProtocol()
        }
    }
    @IBAction func noTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.noButtonTapped()
        }
    }
}
