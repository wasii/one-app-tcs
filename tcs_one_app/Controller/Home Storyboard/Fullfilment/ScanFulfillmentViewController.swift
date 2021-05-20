//
//  ScanFulfillmentViewController.swift
//  tcs_one_app
//
//  Created by TCS on 30/03/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON
import AVKit

protocol ScanFulfillmentProtocol {
    func didScanCode(code: String, isBucket: Bool, CN: String)
    func didScanOrder(orders: [tbl_fulfilments_order])
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
    
    var avPlayer: AVAudioPlayer?
    
    var closeBtnDelegate: CloseButtonTapped?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConditions()
        setupCameraView()
        title = "Fulfilment"
        if let v = view.viewWithTag(10) {
            self.videoView.bringSubviewToFront(v)
        }
        avPlayer = AVAudioPlayer()
    }
    private func playSound(soundName: String) {
        let url = Bundle.main.url(forResource: soundName, withExtension: "mp3")

        do {
            avPlayer = try AVAudioPlayer(contentsOf: url!)
            self.avPlayer?.play()

        } catch let error as NSError {
            print(error.description)
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
                        self.headerViewMessage.text = "Scan Basket"
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
//                    qrCodeFrameView?.layer.borderColor = UIColor.red.cgColor
//                    qrCodeFrameView?.layer.borderWidth = 2
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
                            self.playSound(soundName: "beep")
                            self.startHapticTouch(type: .success)
                            self.conditionView.backgroundColor = UIColor.approvedColor()
                            self.messageLabel.text = "Basket # \(code) valid"
                            
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
                            self.playSound(soundName: "beep")
                            self.startHapticTouch(type: .success)
                            self.conditionView.backgroundColor = UIColor.approvedColor()
                            self.messageLabel.text = "Basket # \(code) valid"
                            self.isCNScanned = false
                            self.isBasketScanned = true
                            
                            self.headerViewImage.image = UIImage(named: "box")
                            self.headerViewMessage.text = "Scan CN Number"
                            self.headerView.backgroundColor = UIColor.pendingColor()
                            
                            self.delegate?.didScanCode(code: code, isBucket: true, CN: self.currentCNSG)
                            self.dismissScanner()
                        }
                    } else {
                        self.playSound(soundName: "buzzer")
                        self.startHapticTouch(type: .error)
                        self.conditionView.backgroundColor = UIColor.nativeRedColor()
                        self.messageLabel.text = "Basket # \(code) not valid"
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
                            self.playSound(soundName: "beep")
                            self.startHapticTouch(type: .success)
                            self.conditionView.backgroundColor = UIColor.approvedColor()
                            self.messageLabel.text = "Basket # \(code) valid"
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
                        self.playSound(soundName: "buzzer")
                        self.startHapticTouch(type: .error)
                        self.conditionView.backgroundColor = UIColor.nativeRedColor()
                        self.messageLabel.text = "Basket # \(code) not valid"
                        
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
                            if order.BASKET_BARCODE == "" {
                                self.headerViewImage.image = UIImage(named: "basket")
                                if self.OLEPrefix == "OLEP" {
                                    self.headerViewMessage.text = "Scan Basket"
                                } else {
                                    self.headerViewMessage.text = "Scan Area"
                                }
                                self.headerView.backgroundColor = UIColor.inprocessColor()
                                self.isCNScanned = true
                            } else {
                                return
                            }
                            self.playSound(soundName: "buzzer")
                            self.startHapticTouch(type: .error)
                        } else if self.fulfilment_orders![index].ITEM_STATUS == "Received" {
                            self.isBasketScanned = false
                            self.conditionView.backgroundColor = UIColor.pendingColor()
                            self.messageLabel.text = "Shipment # \(code) already delivered."
                            self.playSound(soundName: "buzzer")
                            self.startHapticTouch(type: .error)
                            return
                        } else {
                            self.fulfilment_orders![index].ITEM_STATUS = "Scanned"
                        }
                        
                        self.headerViewImage.image = UIImage(named: "basket")
                        if self.OLEPrefix == "OLEP" {
                            self.headerViewMessage.text = "Scan Basket"
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
                    self.playSound(soundName: "beep")
                    self.startHapticTouch(type: .success)
                    self.isBasketScanned = false
                    self.conditionView.backgroundColor = UIColor.approvedColor()
                    self.messageLabel.text = "CN # \(code) valid"
                } else {
                    self.playSound(soundName: "buzzer")
                    self.startHapticTouch(type: .error)
                    self.isBasketScanned = false
                    self.conditionView.backgroundColor = UIColor.nativeRedColor()
                    self.messageLabel.text = "CN # \(code) not valid"
                }
            }
        } else {
            if let _ = fulfilment_orders {
                if isCNScanned {
                    for order in self.fulfilment_orders! {
                        if order.CNSG_NO == currentCNSG {
                            if var ordersAgainstId = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orders(query: "SELECT * FROM \(db_fulfilment_orders) WHERE ORDER_ID = '\(order.ORDER_ID)'") {
                                
                                if ordersAgainstId.filter({ (logs) -> Bool in
                                    logs.BASKET_BARCODE == ""
                                }).count == ordersAgainstId.count {
                                    let query = "select * from \(db_fulfilment_orders) where BASKET_BARCODE = '\(code)'"
                                    let t = AppDelegate.sharedInstance.db!.read_tbl_fulfilment_orders(query: query)
                                    
                                    if t.count > 0 {
                                        for tt in t {
                                            if tt.ITEM_STATUS == "Pending" {
                                                self.playSound(soundName: "buzzer")
                                                self.startHapticTouch(type: .error)
                                                self.conditionView.backgroundColor = UIColor.rejectedColor()
                                                self.messageLabel.text = "Basket # \(code) already is in used."
                                                return
                                            }
                                        }
                                    }
                                    let prefix = code[0..<self.OLEPrefix.count]
                                    print(prefix)
                                    if prefix == self.OLEPrefix {
                                        for (i,_) in ordersAgainstId.enumerated() {
                                            ordersAgainstId[i].BASKET_BARCODE = code
                                            AppDelegate.sharedInstance.db?.updateTables(tableName: db_fulfilment_orders, columnName: ["BASKET_BARCODE"], updateValue: [code], onCondition: "CNSG_NO = '\(ordersAgainstId[i].CNSG_NO)'", { _ in })
                                        }
                                        DispatchQueue.main.async {
                                            self.playSound(soundName: "beep")
                                            self.startHapticTouch(type: .success)
                                            let o = ordersAgainstId.filter({ (log) -> Bool in
                                                log.CNSG_NO == self.currentCNSG
                                            }).first
                                            
                                            self.conditionView.backgroundColor = UIColor.approvedColor()
                                            self.messageLabel.text = "Basket # \(code) valid"
                                            
                                            self.headerViewImage.image = UIImage(named: "box")
                                            self.headerViewMessage.text = "Scan CN Number"
                                            self.headerView.backgroundColor = UIColor.pendingColor()
                                            
                                            self.isCNScanned = false
                                            self.isBasketScanned = true
                                            
                                            self.isAllASKT = true

                                            self.isCNScanned = false
                                            self.HIT_API(order: o!)
                                        }
                                    } else if prefix == DGroupPrefix {
                                        for (i,_) in ordersAgainstId.enumerated() {
                                            ordersAgainstId[i].BASKET_BARCODE = code
                                            AppDelegate.sharedInstance.db?.updateTables(tableName: db_fulfilment_orders, columnName: ["BASKET_BARCODE"], updateValue: [code], onCondition: "CNSG_NO = '\(ordersAgainstId[i].CNSG_NO)'", { _ in })
                                        }
                                        DispatchQueue.main.async {
                                            self.playSound(soundName: "beep")
                                            self.startHapticTouch(type: .success)
                                            let o = ordersAgainstId.filter({ (log) -> Bool in
                                                log.CNSG_NO == self.currentCNSG
                                            }).first
                                            self.conditionView.backgroundColor = UIColor.approvedColor()
                                            self.messageLabel.text = "Basket # \(code) valid"
                                            self.isCNScanned = false
                                            self.isBasketScanned = true
                                            
                                            self.headerViewImage.image = UIImage(named: "box")
                                            self.headerViewMessage.text = "Scan CN Number"
                                            self.headerView.backgroundColor = UIColor.pendingColor()
                                            self.isCNScanned = false
                                            self.HIT_API(order: o!)
                                        }
                                    } else {
                                        self.playSound(soundName: "buzzer")
                                        self.startHapticTouch(type: .error)
                                        self.conditionView.backgroundColor = UIColor.nativeRedColor()
                                        self.messageLabel.text = "Basket # \(code) not valid"
                                    }
                                } else {
                                    let bucket = ordersAgainstId.filter { (logs) -> Bool in
                                        logs.BASKET_BARCODE != ""
                                    }.first
                                    
                                    if bucket?.BASKET_BARCODE == code {
                                        DispatchQueue.main.async {
                                            for (i,_) in ordersAgainstId.enumerated() {
                                                ordersAgainstId[i].BASKET_BARCODE = code
                                                AppDelegate.sharedInstance.db?.updateTables(tableName: db_fulfilment_orders, columnName: ["BASKET_BARCODE"], updateValue: [code], onCondition: "CNSG_NO = '\(ordersAgainstId[i].CNSG_NO)'", { _ in })
                                            }
                                            let o = ordersAgainstId.filter({ (log) -> Bool in
                                                log.CNSG_NO == self.currentCNSG
                                            }).first
                                            self.playSound(soundName: "beep")
                                            self.startHapticTouch(type: .success)
                                            self.conditionView.backgroundColor = UIColor.approvedColor()
                                            self.messageLabel.text = "Basket # \(code) valid"
                                            self.isCNScanned = false
                                            self.isBasketScanned = true
                                            
                                            self.headerViewImage.image = UIImage(named: "box")
                                            self.headerViewMessage.text = "Scan CN Number"
                                            self.headerView.backgroundColor = UIColor.pendingColor()
                                            
                                            self.receivedOrderBasket = code
                                            self.isCNScanned = false
                                            self.HIT_API(order: o!)
                                        }
                                    } else {
                                        self.playSound(soundName: "buzzer")
                                        self.startHapticTouch(type: .error)
                                        self.conditionView.backgroundColor = UIColor.nativeRedColor()
                                        self.messageLabel.text = "Basket # \(code) not valid"
                                    }
                                }
                            }
                            break
                        }
                    }
                } else {
                    var CNFound = false
                    for (index,order) in self.fulfilment_orders!.enumerated() {
                        if order.CNSG_NO == code {
                            SETUP_PERMISSION(order: order)
                            currentCNSG = order.CNSG_NO
                            CNFound = true
                            if order.ITEM_STATUS.lowercased() == "scanned" {
                                self.isBasketScanned = false
                                self.conditionView.backgroundColor = UIColor.pendingColor()
                                self.messageLabel.text = "CN # \(code) already scanned."
                                self.playSound(soundName: "buzzer")
                                self.startHapticTouch(type: .error)
                                if order.BASKET_BARCODE == "" {
                                    self.headerViewImage.image = UIImage(named: "basket")
                                    if self.OLEPrefix == "OLEP" {
                                        self.headerViewMessage.text = "Scan Basket"
                                    } else {
                                        self.headerViewMessage.text = "Scan Area"
                                    }
                                    self.headerView.backgroundColor = UIColor.inprocessColor()
                                    self.isCNScanned = true
                                } else {
                                    self.headerViewImage.image = UIImage(named: "basket")
                                    if self.OLEPrefix == "OLEP" {
                                        self.headerViewMessage.text = "Scan Basket - \(order.BASKET_BARCODE)"
                                    } else {
                                        self.headerViewMessage.text = "Scan Area - \(order.BASKET_BARCODE)"
                                    }
                                    self.headerView.backgroundColor = UIColor.inprocessColor()
                                    self.isCNScanned = true
                                    return
                                }
                            } else if order.ITEM_STATUS.lowercased() == "received" {
                                self.isBasketScanned = false
                                self.conditionView.backgroundColor = UIColor.pendingColor()
                                self.messageLabel.text = "Shipment # \(code) already delivered."
                                self.playSound(soundName: "buzzer")
                                self.startHapticTouch(type: .error)
                                return
                                
                            } else {
                                isCNScanned = true
                                self.conditionView.backgroundColor = UIColor.approvedColor()
                                self.messageLabel.text = "CN # \(code) scanned."
                                self.fulfilment_orders![index].ITEM_STATUS = "Scanned"
                                
                                
                                AppDelegate.sharedInstance.db?.updateTables(tableName: db_fulfilment_orders,
                                                                            columnName: ["ITEM_STATUS"],
                                                                            updateValue: ["Scanned"],
                                                                            onCondition: "CNSG_NO = '\(order.CNSG_NO)'", { _ in })
                                
                                if let orderAgainstId = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orders(query: "SELECT * FROM \(db_fulfilment_orders) WHERE ORDER_ID = '\(order.ORDER_ID)'") {
                                    let count = orderAgainstId.filter { (logs) -> Bool in
                                        logs.ITEM_STATUS.lowercased() == "received" || logs.ITEM_STATUS.lowercased() == "scanned"
                                    }.count
                                    
                                    if orderAgainstId.count == 1 {
                                        self.playSound(soundName: "beep")
                                        self.startHapticTouch(type: .success)
                                        dismiss(animated: true) {
                                            AppDelegate.sharedInstance.db?.updateTables(tableName: db_fulfilment_orders,
                                                                                        columnName: ["BASKET_BARCODE"],
                                                                                        updateValue: ["0"],
                                                                                        onCondition: "CNSG_NO = '\(order.CNSG_NO)'", { _ in })
                                            self.delegate?.didScanCode(code: orderAgainstId.first?.ORDER_ID ?? "",
                                                                       isBucket: false,
                                                                       CN: orderAgainstId.first?.CNSG_NO ?? "")
                                        }
                                    } else {
                                        if count == orderAgainstId.count {
                                            self.playSound(soundName: "beep")
                                            self.startHapticTouch(type: .success)
                                            self.delegate?.didScanOrder(orders: orderAgainstId)
//                                            if var noBasket = orderAgainstId.filter({ (logs) -> Bool in
//                                                logs.BASKET_BARCODE == ""
//                                            }).first {
//                                                noBasket.BASKET_BARCODE = orderAgainstId.first?.BASKET_BARCODE ?? ""
//                                                AppDelegate.sharedInstance.db?.updateTables(tableName: db_fulfilment_orders, columnName: ["BASKET_BARCODE"], updateValue: [orderAgainstId.first?.BASKET_BARCODE ?? ""], onCondition: "CNSG_NO = '\(noBasket.CNSG_NO)'", { _ in
//                                                    if let orders = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orders(query: "SELECT * FROM \(db_fulfilment_orders) WHERE ORDER_ID = '\(orderAgainstId.first?.ORDER_ID ?? "")'") {
//                                                        self.delegate?.didScanOrder(orders: orders)
//                                                    }
//                                                })
//                                            }
//                                            if let order = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orders(query: "SELECT * FROM \(db_fulfilment_orders) WHERE CNSG_NO = '\(code)'") {
//                                                
//                                            }
                                            dismiss(animated: true) {
                                                NotificationCenter.default.post(Notification.init(name: .refreshedViews))
                                            }
                                        }
                                    }
                                    let basket_barcode = orderAgainstId.filter { (logs) -> Bool in
                                        logs.BASKET_BARCODE != ""
                                    }.first
                                    self.playSound(soundName: "beep")
                                    self.startHapticTouch(type: .success)
                                    self.headerViewImage.image = UIImage(named: "basket")
                                    if self.OLEPrefix == "OLEP" {
                                        self.headerViewMessage.text = "Scan Basket - \(basket_barcode?.BASKET_BARCODE ?? "")"
                                    } else {
                                        self.headerViewMessage.text = "Scan Area - \(basket_barcode?.BASKET_BARCODE ?? "")"
                                    }
                                    self.headerView.backgroundColor = UIColor.inprocessColor()
                                }
                                self.fulfilment_orders = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orders(query: "SELECT * FROM \(db_fulfilment_orders)")
                            }
                            break
                        }
                    }
                    if !CNFound {
                        self.conditionView.backgroundColor = UIColor.nativeRedColor()
                        self.messageLabel.text = "Wrong CN Scanned"
                        self.playSound(soundName: "buzzer")
                        self.startHapticTouch(type: .error)
                    }
                }
            }
        }
    }
    
    @IBAction func closeBtnTapped(_ sender: Any) {
        dismiss(animated: true) {
            self.closeBtnDelegate?.closeButtonTapped()
        }
    }
    
    
    private func SETUP_PERMISSION(order: tbl_fulfilments_order) {
        if let orderAgainstId = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orders(query: "SELECT * FROM \(db_fulfilment_orders) WHERE ORDER_ID = '\(order.ORDER_ID)'") {
            if let OLEExist = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orderId(orderId: order.ORDER_ID) {
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
            
            
            if let temp = orderAgainstId.filter({ (logs) -> Bool in
                logs.ITEM_STATUS.lowercased() == "received" && logs.ORDER_ID == order.ORDER_ID
            }).first {
                self.isOrderReceived = true
                self.receivedOrderBasket = temp.BASKET_BARCODE
            }
        }
    }
    
    private func HIT_API(order: tbl_fulfilments_order) {
        if !CustomReachability.isConnectedNetwork() {
            let orders = SubmitOrder(ORDER_ID: order.ORDER_ID,
                                     STATUS: "Scanned",
                                     CN_NUMBER: order.CNSG_NO,
                                     BASKET_NO: order.BASKET_BARCODE)
            AppDelegate.sharedInstance.db?.insert_tbl_fulfilment_orders_temp(orders: orders, handler: { _ in })
            return
        }
        
        guard let access_token = UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN) else {
            let orders = SubmitOrder(ORDER_ID: order.ORDER_ID,
                                     STATUS: "Scanned",
                                     CN_NUMBER: order.CNSG_NO,
                                     BASKET_NO: order.BASKET_BARCODE)
            AppDelegate.sharedInstance.db?.insert_tbl_fulfilment_orders_temp(orders: orders, handler: { _ in })
            return
        }
        
        let temp = NSMutableDictionary()
        temp.setValue(order.ORDER_ID, forKey: "order_id")
        temp.setValue("Received", forKey: "status")
        temp.setValue(order.CNSG_NO, forKey: "cn_number")
        temp.setValue(order.BASKET_BARCODE, forKey: "basket_no")
        let json = [
            "update_request": [
                "access_token" : access_token,
                "orders" : [temp]
            ]
        ] as [String:Any]
        let params = getAPIParameters(service_name: UPDATEORDERFULFILMENT, request_body: json)
        updateFulfilmentOrder(params: params)
    }
    func updateFulfilmentOrder(params: [String:Any]) {
        NetworkCalls.updatefulfillmentorder(params: params) { (granted, response) in
            if granted {
                if let orders = JSON(response).array {
                    let basket_code = orders.filter { (json) -> Bool in
                        json.dictionary?["BASKET_BARCODE"]?.string ?? "" != ""
                    }
                    let basket_barcode = basket_code.first?.dictionary?["BASKET_BARCODE"]?.string ?? ""
                    for order in orders {
                        AppDelegate.sharedInstance.db?.deleteRow(tableName: db_fulfilment_orders, column: "CNSG_NO", ref_id: order["CNSG_NO"].stringValue, handler: { _ in
                            do {
                                let data = try order.rawData()
                                let fulfilment_order = try JSONDecoder().decode(FulfilmentOrders.self, from: data)
                                AppDelegate.sharedInstance.db?.insert_tbl_fulfilment_orders(fulfilment_orders: fulfilment_order, handler: { _ in
                                    AppDelegate.sharedInstance.db?.updateTables(tableName: db_fulfilment_orders, columnName: ["BASKET_BARCODE"], updateValue: [basket_barcode], onCondition: "CNSG_NO = '\(fulfilment_order.cnsgNo)'", { _ in })
                                })
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
                        })
                    }
                    self.fulfilment_orders = AppDelegate.sharedInstance.db?.read_tbl_fulfilment_orders(query: "SELECT * FROM \(db_fulfilment_orders) WHERE CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'")
                }
            } else {
                print("ERROR")
            }
        }
    }
    private func getAPIParameters(service_name: String, request_body: [String:Any]) -> [String:Any] {
        let params = [
            "eAI_MESSAGE": [
                "eAI_HEADER": [
                    "serviceName": service_name,
                    "client": "ibm_apiconnect",
                    "clientChannel": "MOB",
                    "referenceNum": "",
                    "securityInfo": [
                        "authentication": [
                            "userId": "",
                            "password": ""
                        ]
                    ]
                ],
                "eAI_BODY": [
                    "eAI_REQUEST": request_body
                ]
            ]
        ]
        return params as [String: Any]
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
