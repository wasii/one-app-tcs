//
//  RiderDashboardViewController.swift
//  tcs_one_app
//
//  Created by TCS on 18/06/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class RiderDashboardViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Rider"
        self.makeTopCornersRounded(roundView: mainView)
        collectionView.register(UINib(nibName: RiderModulesCollectionCell.description(), bundle: nil), forCellWithReuseIdentifier: RiderModulesCollectionCell.description())
    }
}


extension RiderDashboardViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RiderModulesCollectionCell.description(), for: indexPath) as? RiderModulesCollectionCell else {
            fatalError()
        }
        switch indexPath.row {
        case 0:
            cell.moduleTitle.text = "Pickup"
            cell.imageView.image = UIImage(named: "pickup")
            break
        case 1:
            cell.moduleTitle.text = "Delivery"
            cell.imageView.image = UIImage(named: "delivery")
            break
        case 2:
            cell.moduleTitle.text = "Re-Attempt"
            cell.imageView.image = UIImage(named: "reatttempt")
            break
        case 3:
            cell.moduleTitle.text = "History"
            cell.imageView.image = UIImage(named: "history")
            break
        case 4:
            cell.moduleTitle.text = "Given To"
            cell.imageView.image = UIImage(named: "given_to")
            break
        case 5:
            cell.moduleTitle.text = "Verify Process"
            cell.imageView.image = UIImage(named: "verify_process")
            break
        default:
            break
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let storyboard = UIStoryboard(name: "RiderPickup", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "RiderPickupDashboardViewController") as! RiderPickupDashboardViewController
            
            self.navigationController?.pushViewController(controller, animated: true)
            return
        }
        if indexPath.row == 1 {
            let storyboard = UIStoryboard(name: "RiderDelivery", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "RiderDeliveryDashboardViewController") as! RiderDeliveryDashboardViewController
            
            self.navigationController?.pushViewController(controller, animated: true)
            return
        }
        if indexPath.row == 5 {
            let storyboard = UIStoryboard(name: "RiderVerifyProcess", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "VerifyProcessDashboardViewController") as! VerifyProcessDashboardViewController
            
            self.navigationController?.pushViewController(controller, animated: true)
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth = CGFloat(85)
//        let yourHeight = collectionView.bounds.width / 4.0
        
        return CGSize(width: yourWidth, height: 120)
    }
}

