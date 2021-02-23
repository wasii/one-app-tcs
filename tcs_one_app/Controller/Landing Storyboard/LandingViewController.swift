//
//  LandingViewController.swift
//  tcs_one_app
//
//  Created by TCS on 26/01/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "UserCredentials", bundle: nil)
        if UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN) != nil {
            if UserDefaults.standard.string(forKey: "CurrentUser") != nil {
                CURRENT_USER_LOGGED_IN_ID = UserDefaults.standard.string(forKey: "CurrentUser")!
                let controller = storyboard.instantiateViewController(withIdentifier: "fetchNavbar") as! UINavigationController
                if let c = controller.children.first as? FetchUserDataViewController {
                    c.isNavigate = true
                    if #available(iOS 13.0, *) {
                        controller.modalPresentationStyle = .overFullScreen
                    }
                    controller.modalTransitionStyle = .crossDissolve
                    Helper.topMostController().present(controller, animated: true, completion: nil)
                }
            }
        } else {
            let controller = storyboard.instantiateViewController(withIdentifier: "loginNavBar") as! UINavigationController
            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .overFullScreen
            }
            controller.modalTransitionStyle = .crossDissolve
            Helper.topMostController().present(controller, animated: true, completion: nil)
        }
    }
}
