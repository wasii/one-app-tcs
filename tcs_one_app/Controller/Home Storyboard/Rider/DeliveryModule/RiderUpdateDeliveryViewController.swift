//
//  RiderUpdateDeliveryViewController.swift
//  tcs_one_app
//
//  Created by TCS on 22/06/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields

protocol OpenSignatureView {
    func openSignatureView()
}
class RiderUpdateDeliveryViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var CNNumber: MDCOutlinedTextField!
    @IBOutlet weak var SheetNumber: MDCOutlinedTextField!
    @IBOutlet weak var CustomerName: MDCOutlinedTextField!
    @IBOutlet weak var Address: UITextView!
    @IBOutlet weak var ReceiverName: MDCOutlinedTextField!
    @IBOutlet weak var Relation: MDCOutlinedTextField!
    @IBOutlet weak var Amount: MDCOutlinedTextField!
    @IBOutlet weak var RelationshipName: MDCOutlinedTextField!
    @IBOutlet weak var DeliveredRadioButton: UIImageView!
    @IBOutlet weak var UndeliveredRadioButton: UIImageView!
    
    
    @IBOutlet weak var StatusStackView: UIStackView!
    @IBOutlet weak var StatusOne: MDCOutlinedTextField!
    @IBOutlet weak var StatusTwo: MDCOutlinedTextField!
    @IBOutlet weak var ImageView: UIView!
    @IBOutlet weak var ProofImageView: UIImageView!
    
    var selectedDeliveredOption: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Rider"
        self.makeTopCornersRounded(roundView: self.mainView)
        
        setupTextFields()
    }
    
    func setupTextFields() {
        CNNumber.label.textColor = UIColor.nativeRedColor()
        CNNumber.label.text = "CN Number"
        CNNumber.text = ""
        CNNumber.placeholder = ""
        CNNumber.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        CNNumber.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        CNNumber.delegate = self
        
        SheetNumber.label.textColor = UIColor.nativeRedColor()
        SheetNumber.label.text = "Sheet Number"
        SheetNumber.text = ""
        SheetNumber.placeholder = ""
        SheetNumber.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        SheetNumber.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        SheetNumber.delegate = self
        
        CustomerName.label.textColor = UIColor.nativeRedColor()
        CustomerName.label.text = "Customer Name"
        CustomerName.text = ""
        CustomerName.placeholder = ""
        CustomerName.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        CustomerName.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        CustomerName.delegate = self
        
        ReceiverName.label.textColor = UIColor.nativeRedColor()
        ReceiverName.label.text = "Receiver Name"
        ReceiverName.text = ""
        ReceiverName.placeholder = ""
        ReceiverName.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        ReceiverName.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        ReceiverName.delegate = self
        
        Relation.label.textColor = UIColor.nativeRedColor()
        Relation.label.text = "Relation"
        Relation.text = ""
        Relation.placeholder = ""
        Relation.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        Relation.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        Relation.delegate = self
        
        Amount.label.textColor = UIColor.nativeRedColor()
        Amount.label.text = "Amount"
        Amount.text = ""
        Amount.placeholder = ""
        Amount.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        Amount.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        Amount.delegate = self
        
        RelationshipName.label.textColor = UIColor.nativeRedColor()
        RelationshipName.label.text = "Relationship Name"
        RelationshipName.text = ""
        RelationshipName.placeholder = ""
        RelationshipName.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        RelationshipName.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        RelationshipName.delegate = self
        
        StatusOne.label.textColor = UIColor.nativeRedColor()
        StatusOne.label.text = "Status"
        StatusOne.text = ""
        StatusOne.placeholder = ""
        StatusOne.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        StatusOne.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        StatusOne.delegate = self
        
        StatusTwo.label.textColor = UIColor.nativeRedColor()
        StatusTwo.label.text = "Status"
        StatusTwo.text = ""
        StatusTwo.placeholder = ""
        StatusTwo.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        StatusTwo.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        StatusTwo.delegate = self
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.StatusStackView.isHidden = false
//            self.mainViewHeightConstraint =  self.mainViewHeightConstraint.changeMultiplier(multiplier: 1.2)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                self.ImageView.isHidden = false
//                self.mainViewHeightConstraint = self.mainViewHeightConstraint.changeMultiplier(multiplier: 1.3)
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                    self.mainViewHeightConstraint = self.mainViewHeightConstraint.changeMultiplier(multiplier: 1.45)
//                }
//            }
//        }
    }
    
    @IBAction func DeliveredBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.tag == 0 {
            if sender.isSelected {
                self.DeliveredRadioButton.image = UIImage(named: "radioMark")
                self.UndeliveredRadioButton.image = UIImage(named: "radioUnmark")
                self.selectedDeliveredOption = 1
            } else {
                self.DeliveredRadioButton.image = UIImage(named: "radioUnmark")
                self.UndeliveredRadioButton.image = UIImage(named: "radioUnmark")
                self.selectedDeliveredOption = 0
            }
        } else {
            if sender.isSelected {
                self.DeliveredRadioButton.image = UIImage(named: "radioUnmark")
                self.UndeliveredRadioButton.image = UIImage(named: "radioMark")
                self.selectedDeliveredOption = 2
            } else {
                self.DeliveredRadioButton.image = UIImage(named: "radioUnmark")
                self.UndeliveredRadioButton.image = UIImage(named: "radioUnmark")
                self.selectedDeliveredOption = 0
            }
        }
    }
    @IBAction func cametaBtnTapped(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    @IBAction func callBtnTapped(_ sender: Any) {
        if let url = URL(string: "tel://0213111123123") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    @IBAction func forwardBtnTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Popups", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "RiderPickupUpdateListingPopupViewController") as! RiderPickupUpdateListingPopupViewController
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        controller.modalTransitionStyle = .crossDissolve
        Helper.topMostController().present(controller, animated: true, completion: nil)
    }
}

//MARK: Textfield Delegate
extension RiderUpdateDeliveryViewController: UITextFieldDelegate {}

//MARK: Camera Delegate
extension RiderUpdateDeliveryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }

        // print out the image size as a test
        print(image.size)
        self.ImageView.isHidden = false
        self.ProofImageView.image = image
        
        if StatusStackView.isHidden {
            self.mainViewHeightConstraint = self.mainViewHeightConstraint.changeMultiplier(multiplier: 1.2)
        } else {
            self.mainViewHeightConstraint = self.mainViewHeightConstraint.changeMultiplier(multiplier: 1.3)
        }
    }
}


extension RiderUpdateDeliveryViewController: OpenSignatureView {
    func openSignatureView() {
        let storyboard = UIStoryboard(name: "Popups", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SignatureCommentsViewController") as! SignatureCommentsViewController
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        controller.modalTransitionStyle = .crossDissolve
        Helper.topMostController().present(controller, animated: true, completion: nil)
    }
}
