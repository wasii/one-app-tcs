//
//  RiderQRCodeViewController.swift
//  tcs_one_app
//
//  Created by TCS on 05/08/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class RiderQRCodeViewController: BaseViewController {

    @IBOutlet weak var qrImageView: UIImageView!
    
    var image: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
        
        if let image = self.image {
            qrImageView.image = image
        }
        searchQueryTimer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(dismissAuto), userInfo: nil, repeats: false)
    }
    @IBAction func crossBtnTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            self.searchQueryTimer?.invalidate()
        }
    }
    
    
    @objc func dismissAuto() {
        self.dismiss(animated: true) {
            self.searchQueryTimer?.invalidate()
        }
    }
}
