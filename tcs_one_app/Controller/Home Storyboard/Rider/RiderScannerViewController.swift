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
    var isGivenTo: Bool = false
    var givenToDelegate: RiderGivenToDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAnimations()
        setupCameraView()
        avPlayer = AVAudioPlayer()
    }
    private func setupAnimations() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView1 = UIVisualEffectView(effect: blurEffect)
        let blurEffectView2 = UIVisualEffectView(effect: blurEffect)
        let blurEffectView3 = UIVisualEffectView(effect: blurEffect)
        let blurEffectView4 = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView1.frame = v1.bounds
        blurEffectView2.frame = v2.bounds
        blurEffectView3.frame = v3.bounds
        blurEffectView4.frame = v4.bounds
        
        UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseIn) {
            self.v1.addSubview(blurEffectView1)
            self.v2.addSubview(blurEffectView2)
            self.v3.addSubview(blurEffectView3)
            self.v4.addSubview(blurEffectView4)
            self.view.layoutIfNeeded()
        } completion: { _ in }

        
    }
    override func viewDidAppear(_ animated: Bool) {
        
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
        if isGivenTo {
            self.dismiss(animated: true) {
                self.givenToDelegate?.didTakeOverReturns(code: code)
            }
        } else {
            let query = "SELECT * FROM \(db_delivery_sheet_detail) WHERE CN = '\(code)'"
            if let data = AppDelegate.sharedInstance.db?.read_tbl_rider_delivery_sheet(query: query) {
                
            } else {
                //MARK: - verify bin info API
                if !CustomReachability.isConnectedNetwork() {
                    self.view.makeToast(NOINTERNETCONNECTION)
                    return
                }
                self.view.makeToastActivity(.center)
                self.freezeScreen()
                let request_body = [
                    "access_token" : UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                    "bin_code": code
                ]
                let params = self.getAPIParameter(service_name: S_BIN_INFO, request_body: request_body)
                NetworkCalls.getriderbininfo(params: params) { granted, response in
                    if granted {
                        //MARK: - show pop with 2Button(Fetch, Cancel) with LISTING
                        let json = JSON(response).dictionary
                        if let _riderBinInfoData = json?[_riderBinInfoData]?.dictionary {
                            if let _deliveryMaster = _riderBinInfoData[_deliveryMaster]?.array {
                                AppDelegate.sharedInstance.db?.deleteRowWithMultipleConditions(tbl: db_rider_bin_info, conditions: "BIN_DSCRP = '\(code)'", { _ in
                                    for dm in _deliveryMaster {
                                        do {
                                            let rawData = try dm.rawData()
                                            let bin_info: BinInfo = try JSONDecoder().decode(BinInfo.self, from: rawData)
                                            
                                            AppDelegate.sharedInstance.db?.insert_tbl_rider_bin_info(bin_info: bin_info, handler: { _ in })
                                        } catch let DecodingError.dataCorrupted(context) {
                                            print(context)
                                        } catch let DecodingError.keyNotFound(key, context) {
                                            print("Key '\(key)' not found:", context.debugDescription)
                                            print("codingPath:", context.codingPath)
                                        } catch let DecodingError.valueNotFound(value, context) {
                                            print("Value '\(value)' not found:", context.debugDescription)
                                            print("codingPath:", context.codingPath)
                                        } catch let DecodingError.typeMismatch(type, context)  {
                                            print("Type '\(type)' mismatch:", context.debugDescription)
                                            print("codingPath:", context.codingPath)
                                        } catch {
                                            print("error: ", error)
                                        }
                                    }
                                    DispatchQueue.main.async {
                                        self.captureSession?.stopRunning()
                                        self.view.hideToastActivity()
                                        self.unFreezeScreen()
                                        let storyboard = UIStoryboard(name: "Popups", bundle: nil)
                                        let controller = storyboard.instantiateViewController(withIdentifier: "RiderBinInfoViewController") as! RiderBinInfoViewController
                                        controller.modalTransitionStyle = .crossDissolve
                                        controller.bin = code
                                        controller.delegate = self
                                        if #available(iOS 13, *) {
                                            controller.modalPresentationStyle = .overFullScreen
                                        }
                                        Helper.topMostController().present(controller, animated: true, completion: nil)
                                    }
                                })
                            } else {
                                // delivery master IF LET
                            }
                        } else {
                            //rider bin info data IF LET
                            DispatchQueue.main.async {
                                self.view.hideToastActivity()
                                self.unFreezeScreen()
                            }
                        }
                    } else {
                        //granted IF
                        DispatchQueue.main.async {
                            self.view.hideToastActivity()
                            self.unFreezeScreen()
                            self.lastCapturedCode = nil
                        }
                    }
                }
                
                
                //if success
                    //then show pop with 2Button(Fetch, Cancel)
                        // if FETCH tapped -> Call GET.DELIVERY API with BIN and TOKEN
                            // if 0200 -> call again GET.DELIVERY API without BIN
            }
        }
    }
}


extension RiderScannerViewController: BinInfoDelegate {
    func fetchBinInfo() {
        if !CustomReachability.isConnectedNetwork() {
            self.view.makeToast(NOINTERNETCONNECTION)
            return
        }
        guard let token = UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN) else {
            return
        }
        var request_body = [
            "access_token": token,
            "bin_code": "\(self.lastCapturedCode ?? "")",
            "ds_no": ""
        ]
        let params = self.getAPIParameter(service_name: S_DELIVERY_SHEET, request_body: request_body)
        RiderCalls.SetupDeliverySheets(params: params) { sheet_granted in
            if sheet_granted {
                request_body = [
                    "access_token": token,
                    "bin_code": "",
                    "ds_no": ""
                ]
                let params = self.getAPIParameter(service_name: S_DELIVERY_SHEET, request_body: request_body)
                RiderCalls.SetupDeliverySheets(params: params) { granted in
                    DispatchQueue.main.async {
                        self.dismiss(animated: true) {
                            if granted {
                                
                            }
                        }
                    }
                }
            } else {
                
            }
        }
    }
    
    func cancel() {
        self.captureSession?.startRunning()
    }
    
    
}
