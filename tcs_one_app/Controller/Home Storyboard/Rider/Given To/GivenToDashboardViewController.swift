//
//  GivenToDashboardViewController.swift
//  tcs_one_app
//
//  Created by TCS on 04/08/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import SwiftyJSON
import MapKit

class GivenToDashboardViewController: BaseViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var searchTextfield: MDCOutlinedTextField!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var totalUnscanned: UILabel!
    @IBOutlet weak var totalScanned: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!

    let constant = "Enter CN Number"
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
    
    var verifiedCount: Int = 0
    var deliver_sheet: [tbl_rider_delivery_sheet]?
    
    var lat: Double = 0.0
    var lon: Double = 0.0
    var isLocationOff = false
    var clAuthorizatinStatus: CLAuthorizationStatus?
    var isDataFetched = false
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Rider"
        addDoubleNavigationButtons()
        self.makeTopCornersRounded(roundView: mainView)
        setupCameraView()
        self.tableView.register(UINib(nibName: RiderPickupListingTableCell.description(), bundle: nil), forCellReuseIdentifier: RiderPickupListingTableCell.description())
        self.tableView.rowHeight = 80
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        searchTextfield.label.textColor = UIColor.nativeRedColor()
        searchTextfield.label.text = "CN Numbers"
        searchTextfield.text = constant
        searchTextfield.placeholder = constant
        searchTextfield.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        searchTextfield.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        searchTextfield.delegate = self
        
        locationManager.delegate = self
        // 2
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupJSON() {
        if !isDataFetched {
            self.isDataFetched = true
            let query = "SELECT * FROM \(db_rider_delivery_sheet) WHERE DLVRD_BY = '\(CURRENT_USER_LOGGED_IN_ID)' AND DELIVERYSTATUS = ''"
            self.deliver_sheet = AppDelegate.sharedInstance.db?.read_tbl_rider_delivery_sheet(query: query)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                if let count = self.deliver_sheet?.count {
                    UIView.animate(withDuration: 0.3) {
                        self.tableViewHeightConstraint.constant = CGFloat(count * 80)
                        self.view.layoutIfNeeded()
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
                captureDevice.supportsSessionPreset(.medium)
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
                    self.updateBarCode(code: code)
                }
            }
        }
    }
    
    private func updateBarCode(code: String) {
        if let _ = self.deliver_sheet {
            for (i, d) in self.deliver_sheet!.enumerated() {
                if d.CN == code {
                    self.deliver_sheet![i].DELIVERYSTATUS = "1"
                    break
                }
            }
            if self.deliver_sheet!.contains(where: { d in
                d.CN == code
            }) {
                
            }
            self.tableView.reloadData()
        }
        
    }
    private func getCount() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//            if let count = self.delivery_sheets?.count {
//
//                self.verifiedCount = self.delivery_sheets!.filter { sheet in
//                    sheet.verify == "Verify"
//                }.count
//
//                if self.verifiedCount < 10 {
//                    self.totalVerify.text = "Total Verify: 0\(self.verifiedCount)"
//                } else {
//                    self.totalVerify.text = "Total Verify: \(self.verifiedCount)"
//                }
//                if (count - self.verifiedCount) < 10 {
//                    self.totalUnverify.text = "Total Unverify: 0\(count - self.verifiedCount)"
//                } else {
//                    self.totalUnverify.text = "Total Unverify: \(count - self.verifiedCount)"
//                }
//                self.tableViewHeightConstraint.constant = CGFloat(80 * count)
//                self.tableView.reloadData()
//            }
//        }
    }
    
    @IBAction func submitBtnTapped(_ sender: Any) {
        var cnList = [[String:Any]]()
        if let list = self.deliver_sheet?.filter({ d in
            d.DELIVERYSTATUS != ""
        }) {
            if list.count == 0 {
                self.view.makeToast("Scan any CN first.")
            } else {
                self.view.makeToastActivity(.center)
                self.freezeScreen()
                for l in list {
                    cnList.append([
                        "cnno": l.CN,
                        "sheet_no": l.SHEETNO
                    ])
                }
                let request_body = [
                    "access_token" : UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN)!,
                    "lat": "\(self.lat)",
                    "lng": "\(self.lon)",
                    "cn_list" : cnList
                ] as [String:Any]
                let params = self.getAPIParameter(service_name: S_RIDER_GENERATE_QRCODE, request_body: request_body)
                NetworkCalls.getriderqrcode(params: params) { granted, response in
                    if granted {
                        DispatchQueue.main.async {
                            self.view.hideToastActivity()
                            self.unFreezeScreen()
                            if let qrCode = JSON(response).string {
                                for cnlist in cnList {
                                    let cn = cnlist["cnno"] as? String
                                    let sheetno = cnlist["sheet_no"] as? String
                                    
                                    let condition = "CN = '\(cn ?? "")' AND SHEETNO = '\(sheetno ?? "")' AND QRCODE = '\(qrCode)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'"
                                    AppDelegate.sharedInstance.db?.deleteRowWithMultipleConditions(tbl: db_rider_qrcodes, conditions: condition, { _ in
                                        let qrCode = QRCodes(QRCODE: qrCode, CN: cn ?? "", SHEETNO: sheetno ?? "", CURRENT_USER: CURRENT_USER_LOGGED_IN_ID)
                                        
                                        
                                    })
                                }
                                let qrCodeImage = self.generateQRCode(from: qrCode)
                                let storyboard = UIStoryboard(name: "Popups", bundle: nil)
                                let controller = storyboard.instantiateViewController(withIdentifier: "RiderQRCodeViewController") as! RiderQRCodeViewController
                                if #available(iOS 13, *) {
                                    controller.modalPresentationStyle = .overFullScreen
                                }
                                controller.modalTransitionStyle = .crossDissolve
                                controller.image = qrCodeImage
                                Helper.topMostController().present(controller, animated: true, completion: nil)
                            } else {
                                self.view.makeToast(SOMETHINGWENTWRONG)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.view.hideToastActivity()
                            self.unFreezeScreen()
                        }
                    }
                }
            }
        }
    }
}


extension GivenToDashboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.deliver_sheet?.count {
            return count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RiderPickupListingTableCell.description()) as? RiderPickupListingTableCell else {
            fatalError()
        }
        if let data = self.deliver_sheet?[indexPath.row] {
            cell.CNNumber.text = data.CN
            cell.CODAmount.text = data.SHEETNO
            cell.Description.text = data.CONSIGNEENAME
            
            if data.DELIVERYSTATUS == "" {
                cell.StatusLabel.text = "Unscanned"
                cell.StatusLabel.textColor = UIColor.nativeRedColor()
                cell.mainView.bgColor = UIColor.white
            } else {
                cell.StatusLabel.text = "Scanned"
                cell.StatusLabel.textColor = UIColor.approvedColor()
                cell.mainView.bgColor = UIColor.riderlistingBgColor()
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension GivenToDashboardViewController: UITextFieldDelegate {
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

extension GivenToDashboardViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            self.isLocationOff = false
            locationManager.startUpdatingLocation()
            break
        case .denied, .restricted, .notDetermined:
            self.isLocationOff = true
            DispatchQueue.main.async {
                self.locationAlert()
            }
            print("location access denied")
            break
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue:CLLocationCoordinate2D = manager.location?.coordinate else {
            return
        }
        
        self.lat = locValue.latitude
        self.lon = locValue.longitude
        self.setupJSON()
    }
}
