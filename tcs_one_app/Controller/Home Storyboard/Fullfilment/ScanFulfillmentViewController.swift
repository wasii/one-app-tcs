//
//  ScanFulfillmentViewController.swift
//  tcs_one_app
//
//  Created by TCS on 30/03/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import AVFoundation

protocol ScanFulfillmentProtocol {
    func didScanCode(code: String, isBucket: Bool, CN: String)
}

class ScanFulfillmentViewController: BaseViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var conditionView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerViewMessage: UILabel!
    @IBOutlet weak var headerViewImage: UIImageView!
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var captureDevice:AVCaptureDevice?
    var lastCapturedCode:String?
    
    
    var numberOfDays: String = ""
    var start_day: String = ""
    var end_day: String = ""
    
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
    
    
    var isCNScanned = false
    var isBasketScanned = false
    var isOLEExist = false
    var OLEPrefix = "OLEP"
    var DGroupPrefix = "DGroup"
    
    var isOrderReceived = false
    var receivedOrderBasket = ""
    
    
    var isAllASKT = false
    var currentCNSGIndex = 0
    var currentCNSG      = ""
    var fulfilment_orders : [tbl_fulfilments_order]?
    var orderId: String?
    
    var submit_orders: [SubmitOrder]?
    var delegate: ScanFulfillmentProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConditions()
        setupCameraView()
        title = "Fulfillment"
        if let v = view.viewWithTag(10) {
            self.videoView.bringSubviewToFront(v)
        }
        
    }
    private func setupConditions() {
        if let o = orderId {
            let query = "SELECT * FROM \(db_fulfilment_orders) WHERE ORDER_ID = '\(o)'"
            if let fulfilment_order = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orders(query: query) {
                let allPendingCount = fulfilment_order.filter({ (logs) -> Bool in
                    logs.ITEM_STATUS == "Pending"
                }).count
                if allPendingCount == fulfilment_order.count {
                    if let OLEExist = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orderId(orderId: o) {
                        if OLEExist > 0 {
                            let query = "SELECT * FROM \(db_scan_prefix) WHERE SERVICE_NO = 'OLE'"
                            if let scan_prefix = AppDelegate.sharedInstance.db?.read_tbl_scan_prefix(query: query).first {
                                self.OLEPrefix = scan_prefix.PREFIX_CODE
                                self.isOLEExist = true
                            }
                        } else {
                            let query = "SELECT * FROM \(db_scan_prefix) WHERE SERVICE_NO = 'D' OR SERVICE_NO = 'O'"
                            if let scan_prefix = AppDelegate.sharedInstance.db?.read_tbl_scan_prefix(query: query).first {
                                self.DGroupPrefix = scan_prefix.PREFIX_CODE
                                self.isOLEExist = false
                            }
                        }
                    }
                }
                
                if let temp = fulfilment_order.filter({ (logs) -> Bool in
                    logs.ITEM_STATUS == "Received" && logs.ORDER_ID == orderId!
                }).first {
                    self.isOrderReceived = true
                    self.receivedOrderBasket = temp.BASKET_BARCODE
                }
                self.fulfilment_orders = fulfilment_order
                let query = "SELECT * FROM \(db_fulfilment_orders_temp) WHERE ORDER_ID = '\(orderId!)'"
                if let temp_order = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orders_temp(query: query) {
                    let scanned_item = temp_order.filter { (log) -> Bool in
                        log.STATUS == "Scanned"
                    }
                    for (i,o) in self.fulfilment_orders!.enumerated() {
                        for si in scanned_item {
                            if o.CNSG_NO == si.CN_NUMBER {
                                if si.BASKET_NO == "" {
                                    self.fulfilment_orders![i].ITEM_STATUS = si.STATUS
                                } else {
                                    self.fulfilment_orders![i].ITEM_STATUS = si.STATUS
                                    self.fulfilment_orders![i].BASKET_BARCODE = si.BASKET_NO
                                    self.isBasketScanned = true
                                }
                                break
                            }
                        }
                    }
                }
                if isCNScanned {
                    self.headerViewImage.image = UIImage(named: "basket")
                    if self.OLEPrefix == "OLEP" {
                        self.headerViewMessage.text = "Scan Bucket"
                    } else {
                        self.headerViewMessage.text = "Scan Area"
                    }
                    self.headerView.backgroundColor = UIColor.inprocessColor()
                    for (index, order) in self.fulfilment_orders!.enumerated() {
                        if order.CNSG_NO == self.currentCNSG {
                            self.fulfilment_orders![index].ITEM_STATUS = "Scanned"
                            break
                        }
                    }
                }
            }
        }
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
                    videoPreviewLayer?.frame = videoView.layer.bounds
                    videoView.layer.addSublayer(videoPreviewLayer!)
                    
                    captureSession.startRunning()
                    
                    view.bringSubviewToFront(messageLabel)
                    
                    qrCodeFrameView = UIView()
                    qrCodeFrameView?.layer.borderColor = UIColor.red.cgColor
                    qrCodeFrameView?.layer.borderWidth = 2
                    qrCodeFrameView?.autoresizingMask = [UIView.AutoresizingMask.flexibleTopMargin, UIView.AutoresizingMask.flexibleBottomMargin, UIView.AutoresizingMask.flexibleLeftMargin, UIView.AutoresizingMask.flexibleRightMargin]
                    
                    view.addSubview(qrCodeFrameView!)
                    view.bringSubviewToFront(qrCodeFrameView!)
                }
            }
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
    }
    public override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        videoPreviewLayer?.frame = self.videoView.layer.bounds
        
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
        videoPreviewLayer?.frame = videoView.layer.bounds
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
    
    
    func scanBarCode(code: String) {
        if let _ = orderId {
            if self.isCNScanned {
                if self.receivedOrderBasket == "" {
                    let prefix = code[0..<self.OLEPrefix.count]
                    print(prefix)
                    if prefix == self.OLEPrefix {
                        for (i,_) in self.fulfilment_orders!.enumerated() {
                            self.fulfilment_orders![i].BASKET_BARCODE = code
                        }
                        DispatchQueue.main.async {
                            let _ = self.fulfilment_orders?.filter({ (log) -> Bool in
                                log.CNSG_NO == self.currentCNSG
                            }).first
                            
                            self.conditionView.backgroundColor = UIColor.approvedColor()
                            self.messageLabel.text = "Bucket # \(code) valid"
                            
                            self.headerViewImage.image = UIImage(named: "box")
                            self.headerViewMessage.text = "Scan CN Number"
                            self.headerView.backgroundColor = UIColor.pendingColor()
                            
                            self.isCNScanned = false
                            self.isBasketScanned = true
                            
                            self.isAllASKT = true
                            
                            self.receivedOrderBasket = code
                            
                            self.delegate?.didScanCode(code: code, isBucket: true, CN: self.currentCNSG)
                            self.dismissScanner()
                        }
                    } else if prefix == DGroupPrefix {
                        for (i,_) in self.fulfilment_orders!.enumerated() {
                            self.fulfilment_orders![i].BASKET_BARCODE = code
                        }
                        DispatchQueue.main.async {
                            let _ = self.fulfilment_orders?.filter({ (log) -> Bool in
                                log.CNSG_NO == self.currentCNSG
                            }).first
                            self.conditionView.backgroundColor = UIColor.approvedColor()
                            self.messageLabel.text = "Bucket # \(code) valid"
                            self.isCNScanned = false
                            self.isBasketScanned = true
                            
                            self.headerViewImage.image = UIImage(named: "box")
                            self.headerViewMessage.text = "Scan CN Number"
                            self.headerView.backgroundColor = UIColor.pendingColor()
                            
                            self.delegate?.didScanCode(code: code, isBucket: true, CN: self.currentCNSG)
                            self.dismissScanner()
                        }
                    } else {
                        self.conditionView.backgroundColor = UIColor.nativeRedColor()
                        self.messageLabel.text = "Bucket # \(code) not valid"
                    }
                } else {
                    if self.receivedOrderBasket == code {
                        DispatchQueue.main.async {
                            for (i,_) in self.fulfilment_orders!.enumerated() {
                                self.fulfilment_orders![i].BASKET_BARCODE = code
                            }
                            let _ = self.fulfilment_orders?.filter({ (log) -> Bool in
                                log.CNSG_NO == self.currentCNSG
                            }).first
                            self.conditionView.backgroundColor = UIColor.approvedColor()
                            self.messageLabel.text = "Bucket # \(code) valid"
                            self.isCNScanned = false
                            self.isBasketScanned = true
                            
                            self.headerViewImage.image = UIImage(named: "box")
                            self.headerViewMessage.text = "Scan CN Number"
                            self.headerView.backgroundColor = UIColor.pendingColor()
                            
                            self.receivedOrderBasket = code
                            
                            self.delegate?.didScanCode(code: code, isBucket: true, CN: self.currentCNSG)
                            self.dismissScanner()
                        }
                    } else {
                        self.conditionView.backgroundColor = UIColor.nativeRedColor()
                        self.messageLabel.text = "Bucket # \(code) not valid"
                        
                    }
                }
            } else {
                var isFound = false
                for (index, order) in self.fulfilment_orders!.enumerated() {
                    if order.CNSG_NO == code {
                        isFound = true
                        if self.fulfilment_orders![index].ITEM_STATUS == "Scanned" {
                            self.isBasketScanned = false
                            self.conditionView.backgroundColor = UIColor.pendingColor()
                            self.messageLabel.text = "CN # \(code) already scanned."
                            return
                        } else if self.fulfilment_orders![index].ITEM_STATUS == "Received" {
                            self.isBasketScanned = false
                            self.conditionView.backgroundColor = UIColor.pendingColor()
                            self.messageLabel.text = "CN # \(code) already received."
                            return
                        } else {
                            self.fulfilment_orders![index].ITEM_STATUS = "Scanned"
                        }
                        
                        self.headerViewImage.image = UIImage(named: "basket")
                        if self.OLEPrefix == "OLEP" {
                            self.headerViewMessage.text = "Scan Bucket"
                        } else {
                            self.headerViewMessage.text = "Scan Area"
                        }
                        self.headerView.backgroundColor = UIColor.inprocessColor()
                        
                        self.isBasketScanned = false
                        self.currentCNSG = order.CNSG_NO
                        
                        if isAllASKT {
                            self.isCNScanned = false
                        } else {
                            self.isCNScanned = true
                        }
                        self.delegate?.didScanCode(code: code, isBucket: false, CN: self.fulfilment_orders![index].CNSG_NO)
                        if self.fulfilment_orders?.count == 1 {
                            self.dismiss(animated: true, completion: nil)
                        }
                        break
                    }
                }
                if isFound {
                    self.isBasketScanned = false
                    self.conditionView.backgroundColor = UIColor.approvedColor()
                    self.messageLabel.text = "CN # \(code) valid"
                } else {
                    self.isBasketScanned = false
                    self.conditionView.backgroundColor = UIColor.nativeRedColor()
                    self.messageLabel.text = "CN # \(code) not valid"
                }
            }
        } else {
            if let orders = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orders(query: "SELECT * FROM \(db_fulfilment_orders) WHERE CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'") {
                let order = orders.filter { (logs) -> Bool in
                    logs.CNSG_NO == code
                }
                if order.count > 0 {
                    self.dismiss(animated: true) {
                        self.delegate?.didScanCode(code: order.first?.ORDER_ID ?? "", isBucket: false, CN: code)
                    }
                }
            }
        }
    }
    
    @IBAction func closeBtnTapped(_ sender: Any) {
        dismiss(animated: true) {}
    }
}


extension ScanFulfillmentViewController {
    func dismissScanner() {
        let count = self.fulfilment_orders!.filter ({ (logs) -> Bool in
            logs.BASKET_BARCODE != "" && (logs.ITEM_STATUS == "Scanned" || logs.ITEM_STATUS == "Received")
        }).count
        
        print("count: \(count) total count: \(self.fulfilment_orders?.count)")
        
        if count == self.fulfilment_orders?.count {
            dismiss(animated: true) {}
        }
    }
}
