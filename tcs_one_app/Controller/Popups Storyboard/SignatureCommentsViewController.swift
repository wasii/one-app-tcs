//
//  SignatureCommentsViewController.swift
//  tcs_one_app
//
//  Created by TCS on 22/06/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import SwiftSignatureView

class SignatureCommentsViewController: BaseViewController {

    @IBOutlet weak var signatureView: SwiftSignatureView!
    @IBOutlet weak var comments: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
    }
    

    @IBAction func forwardBtnTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }
    @IBAction func cancelBtnTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }
}
