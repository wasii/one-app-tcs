//
//  LandingViewController.swift
//  tcs_one_app
//
//  Created by TCS on 20/09/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {

    @IBOutlet weak var logoCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    
    var safeTopArea: CGFloat = 0.0
    var currentCenterConstraintPosition: CGFloat = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            safeTopArea = window?.safeAreaInsets.top ?? 0.0
        }
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            safeTopArea = window?.safeAreaInsets.top ?? 0.0
        }
        currentCenterConstraintPosition = self.logoCenterConstraint.constant
        setupAnimations()
    }
    private func setupAnimations() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let screenSize = UIScreen.main.bounds.height / 3
            
            UIView.animate(withDuration: 0.75) {
                
                self.logoCenterConstraint.constant = -screenSize + self.safeTopArea
                self.logoHeightConstraint.constant = 150
                
                self.mainViewHeightConstraint.constant = 450
                self.view.layoutIfNeeded()
            } completion: { _ in
                
            }
        }
    }
}
