//
//  AttendanceMarkingViewController.swift
//  tcs_one_app
//
//  Created by TCS on 11/03/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class AttendanceMarkingViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var slideView: CustomView!
    
    lazy var slideToLock: MTSlideToOpenView = {
        let slide = MTSlideToOpenView(frame: CGRect(x: 5, y: 4, width: 215, height: 32))
        slide.sliderViewTopDistance = 0
        slide.sliderCornerRadius = 10
        slide.thumnailImageView.backgroundColor = UIColor.nativeRedColor()
        slide.draggedView.backgroundColor = UIColor.nativeRedColor()
        slide.delegate = self
        slide.thumbnailViewStartingDistance = 10
        slide.backgroundColor = UIColor.clear
        slide.labelText = ""
        slide.thumnailImageView.image = #imageLiteral(resourceName: "slide").imageFlippedForRightToLeftLayoutDirection()
        return slide
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Attendance"
        self.makeTopCornersRounded(roundView: self.mainView)
        
        self.slideView.addSubview(slideToLock)
    }
}


extension AttendanceMarkingViewController: MTSlideToOpenDelegate {
    func mtSlideToOpenDelegateDidFinish(_ sender: MTSlideToOpenView) {
        let alertController = UIAlertController(title: "", message: "Done!", preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "Okay", style: .default) { (action) in
            sender.resetStateWithAnimation(false)
        }
        alertController.addAction(doneAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
