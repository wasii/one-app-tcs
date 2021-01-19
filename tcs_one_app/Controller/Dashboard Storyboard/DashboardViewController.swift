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
//        UITabBar.appearance().selectionIndicatorImage = UIImage().makeImageWithColorAndSize(color: UIColor.nativeRedColor(), size: CGSize(width: self.tabBar.frame.width/5, height: self.tabBar.frame.height))
        self.delegate = self
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if viewController is UINavigationController {
            if let _ = viewController.children[0] as? HomeScreenViewController {
                return true
            }
            if let _ = viewController.children[0] as? MessageViewController {
//                self.showAlert()
                return false
            }
            if let _ = viewController.children[0] as? MailViewController {
//                self.showAlert()
                return false
            }
            if let _ = viewController.children[0] as? UserInfoViewController {
                self.showAlert()
                return false
            }
            
            if let _ = viewController.children[0] as? UIViewController {
                let storyboard = UIStoryboard(name: "Popups", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "LogoutPopupViewController") as! LogoutPopupViewController
                
                if #available(iOS 13.0, *) {
                    controller.modalPresentationStyle = .overFullScreen
                }
                
                controller.modalTransitionStyle = .crossDissolve
                
                Helper.topMostController().present(controller, animated: true, completion: nil)
                return false
            }
        }
        return true
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
