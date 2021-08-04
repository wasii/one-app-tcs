//
//  RiderGivenToPopupViewController.swift
//  tcs_one_app
//
//  Created by TCS on 04/08/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class RiderGivenToPopupViewController: BaseViewController {

    var delegate: RiderGivenToDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
    }
    @IBAction func handoverTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.didSelectHandOver()
        }
    }
    @IBAction func takeOverTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.didSelectTakeOver()
        }
        
    }
    @IBAction func crossBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
