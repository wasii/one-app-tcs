//
//  RiderScannerViewController.swift
//  tcs_one_app
//
//  Created by TCS on 29/07/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON
import AVKit

class RiderScannerViewController: BaseViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var v1: UIView!
    @IBOutlet weak var v2: UIView!
    @IBOutlet weak var v3: UIView!
    @IBOutlet weak var v4: UIView!
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var captureDevice:AVCaptureDevice?
    var lastCapturedCode:String?
    
    public var barcodeScanned:((String) -> ())?
    
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
    
    var avPlayer: AVAudioPlayer?
    var detail_sheet: [tbl_rider_delivery_sheet]?
    override func viewDidLoad() {
        super.viewDidLoad()
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView1 = UIVisualEffectView(effect: blurEffect)
        let blurEffectView2 = UIVisualEffectView(effect: blurEffect)
        let blurEffectView3 = UIVisualEffectView(effect: blurEffect)
        let blurEffectView4 = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView1.frame = v1.bounds
        blurEffectView2.frame = v2.bounds
        blurEffectView3.frame = v3.bounds
        blurEffectView4.frame = v4.bounds
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        v1.addSubview(blurEffectView1)
        v2.addSubview(blurEffectView2)
        v3.addSubview(blurEffectView3)
        v4.addSubview(blurEffectView4)
        setupCameraView()
        avPlayer = AVAudioPlayer()
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
                    
//                    qrCodeFrameView = UIView()
//                    qrCodeFrameView?.autoresizingMask = [UIView.AutoresizingMask.flexibleTopMargin, UIView.AutoresizingMask.flexibleBottomMargin, UIView.AutoresizingMask.flexibleLeftMargin, UIView.AutoresizingMask.flexibleRightMargin]
//
//                    view.addSubview(qrCodeFrameView!)
//                    view.bringSubviewToFront(qrCodeFrameView!)
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
    
    public override func viewDidLayoutSubviews() {
        
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
                    self.scanBarCode(code: code)
                }
            }
        }
    }
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    private func scanBarCode(code: String) {
        let query = "SELECT * FROM \(db_delivery_sheet_detail) WHERE CN = '\(code)'"
        if let data = AppDelegate.sharedInstance.db?.read_tbl_rider_delivery_sheet(query: query) {
            
        } else {
            //verify bin info API
            
            //if success
                //then show pop with 2Button(Fetch, Cancel)
                    // if FETCH tapped -> Call GET.DELIVERY API with BIN and TOKEN
                        // if 0200 -> call again GET.DELIVERY API without BIN
        }
    }
}
