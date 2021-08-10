//
//  DashboardViewController.swift
//  tcs_one_app
//
//  Created by ibs on 16/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit

class DashboardViewController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
//        UITabBar.appearance().selectionIndicatorImage = UIImage().makeImageWithColorAndSize(color: UIColor.clear, size: CGSize(width: self.tabBar.frame.width/5, height: 90))
        self.delegate = self
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if viewController is UINavigationController {
            if let _ = viewController.children[0] as? HomeScreenViewController {
                return true
            }
            if let _ = viewController.children[0] as? MessageViewController {
                return false
            }
            if let _ = viewController.children[0] as? MailViewController {
                return false
            }
            if let _ = viewController.children[0] as? AttendanceMarkingViewController {
                return true
            }
            if let _ = viewController.children[0] as? WalletDashboardViewController {
                return false
            }
        }
        return true
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        switch UIDevice().type {
        case .iPhone12, .iPhone12Pro, .iPhone12ProMax, .iPhone12Mini:
            tabBar.frame.size.height = 95
            tabBar.frame.origin.y = view.frame.height - 95
            break
        default:
            break
        }
    }
    func showAlert() {
        let comingsoon = self.storyboard?.instantiateViewController(withIdentifier: "ComingSoonViewController") as! ComingSoonViewController
        comingsoon.modalTransitionStyle = .crossDissolve
        if #available(iOS 13.0, *) {
            comingsoon.modalPresentationStyle = .overFullScreen
        }
        comingsoon.emp_id = CURRENT_USER_LOGGED_IN_ID
        self.present(comingsoon, animated: true, completion: nil)
    }
}


extension UIImage {
  func makeImageWithColorAndSize(color: UIColor, size: CGSize) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    color.setFill()
    UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
  }
}
