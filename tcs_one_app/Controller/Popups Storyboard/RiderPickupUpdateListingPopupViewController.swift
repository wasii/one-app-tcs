//
//  RiderPickupUpdateListingPopupViewController.swift
//  tcs_one_app
//
//  Created by TCS on 30/06/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields

class RiderPickupUpdateListingPopupViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    let constant = "Enter or Scan Load Sheet or CN"
    @IBOutlet weak var searchTextField: MDCOutlinedTextField!
    @IBOutlet weak var mainViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var totalUnPicked: UILabel!
    @IBOutlet weak var totalPicked: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var captureDevice:AVCaptureDevice?
    var lastCapturedCode:String?
    
    public var barcodeScanned:((String) -> ())?
    var avPlayer: AVAudioPlayer?
    
    private var allowedTypes = [AVMetadataObject.ObjectType.upce,
                                AVMetadataObject.ObjectType.code39,
                                AVMetadataObject.ObjectType.code39Mod43,
                                AVMetadataObject.ObjectType.ean13,
                                AVMetadataObject.ObjectType.ean8,
                                AVMetadataObject.ObjectType.code93,
                                AVMetadataObject.ObjectType.code128,
                                AVMetadataObject.ObjectType.pdf417,
                                AVMetadataObject.ObjectType.qr,
                                AVMetadataObject.ObjectType.aztec]
    
    let bgColor = UIColor(red: 221.0/255, green: 255.0/255.0, blue: 215.0/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch UIDevice().type {
        case .iPhoneX, .iPhoneXS, .iPhoneXR, .iPhoneXSMax, .iPhone11, .iPhone11Pro, .iPhone11ProMax, .iPhone12, .iPhone12Mini, .iPhone12Pro, .iPhone12ProMax:
            self.mainViewTopConstraint.constant = 64
        default:
            break
        }
        view.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
        tableView.register(UINib(nibName: RiderPickupListingTableCell.description(), bundle: nil), forCellReuseIdentifier: RiderPickupListingTableCell.description())
        self.tableView.rowHeight = 80
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        setupCameraView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.tableView.reloadData()
        }
        searchTextField.label.textColor = UIColor.nativeRedColor()
        searchTextField.label.text = "CN Number"
        searchTextField.text = constant
        searchTextField.placeholder = ""
        searchTextField.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        searchTextField.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        searchTextField.delegate = self
    }
    private func setupCameraView() {
        self.captureDevice = AVCaptureDevice.default(for: .video)
        
        var error:NSError?
        let input: AnyObject!
        do {
            if let captureDevice = self.captureDevice {
                input = try AVCaptureDeviceInput(device: captureDevice)
                
                if (error != nil) {
                    print("\(String(describing: error?.localizedDescription))")
                    return
                }
                captureSession = AVCaptureSession()
                captureSession?.addInput(input as! AVCaptureInput)
                
                let captureMetadataOutput = AVCaptureMetadataOutput()
                captureSession?.addOutput(captureMetadataOutput)
                
                captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                captureMetadataOutput.metadataObjectTypes = self.allowedTypes
                
                if let captureSession = captureSession {
                    videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resize
                    videoPreviewLayer?.frame = cameraView.layer.bounds
                    cameraView.layer.addSublayer(videoPreviewLayer!)
                    
                    captureSession.startRunning()
                }
            }
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
    }
    public override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        videoPreviewLayer?.frame = self.cameraView.layer.bounds
        
        let orientation = UIApplication.shared.statusBarOrientation
        
        if let videoPreviewLayer = self.videoPreviewLayer {
            switch(orientation) {
            case UIInterfaceOrientation.landscapeLeft:
                videoPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
                
            case UIInterfaceOrientation.landscapeRight:
                videoPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
                
            case UIInterfaceOrientation.portrait:
                videoPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                
            case UIInterfaceOrientation.portraitUpsideDown:
                videoPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portraitUpsideDown
                
            default:
                print("Unknown orientation state")
            }
        }
    }
    public override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        videoPreviewLayer?.frame = cameraView.layer.bounds
    }
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if self.allowedTypes.contains(metadataObj.type) {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            
            qrCodeFrameView?.frame = barCodeObject.bounds;
            
            if metadataObj.stringValue != nil {
                if let code = metadataObj.stringValue {
                    if code == lastCapturedCode {
                        return
                    }
                    lastCapturedCode = metadataObj.stringValue
                }
            }
        }
    }
    @IBAction func searchBtnTapped(_ sender: Any) {
    }
    @IBAction func checkedBtnTapped(_ sender: Any) {
    }
}


extension RiderPickupUpdateListingPopupViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RiderPickupListingTableCell.description()) as? RiderPickupListingTableCell else {
            fatalError()
        }
        
        if (indexPath.row % 2) == 0 {
            cell.mainView.bgColor = bgColor
            cell.mainView.borderColor = UIColor.approvedColor()
            cell.OptionsStackView.isHidden = false
            cell.StatusLabel.text = "Scanned"
            cell.StatusLabel.textColor = UIColor.approvedColor()
        } else {
            cell.mainView.bgColor = UIColor.white
            cell.mainView.borderColor = UIColor.rejectedColor()
            cell.OptionsStackView.isHidden = true
            cell.StatusLabel.text = "Unscanned"
            cell.StatusLabel.textColor = UIColor.rejectedColor()
        }
        cell.CameraBtn.isHidden = true
        cell.EditBtn.isHidden = true
        
        cell.OptionsStackView.isHidden = true
        
        return cell
    }
}


extension RiderPickupUpdateListingPopupViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == constant {
            textField.text = ""
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text!.count <= 0 {
            textField.text = constant
        }
    }
}

