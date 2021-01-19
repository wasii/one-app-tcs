//
//  LogoutPopupViewController.swift
//  tcs_one_app
//
//  Created by ibs on 03/11/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit

class LogoutPopupViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
    }
    @IBAction func yesTapped(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "CurrentUser")
        UserDefaults.standard.removeObject(forKey: USER_ACCESS_TOKEN)
        self.dismiss(animated: true) {
            NotificationCenter.default.post(Notification.init(name: .logoutUser))
        }
    }
    @IBAction func noTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
