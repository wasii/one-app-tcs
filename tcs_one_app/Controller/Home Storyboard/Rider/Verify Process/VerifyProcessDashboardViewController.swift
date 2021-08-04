//
//  VerifyProcessDashboardViewController.swift
//  tcs_one_app
//
//  Created by TCS on 02/08/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields

class VerifyProcessDashboardViewController: BaseViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var searchTextfield: MDCOutlinedTextField!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var totalUnverify: UILabel!
    @IBOutlet weak var totalVerify: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
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
    
    var delivery_sheets: [tbl_Delivery_Verify]?
    var verifiedCount: Int = 0
    
    var selectedCn = String()
    var selectedSheet = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Rider"
        
        self.makeTopCornersRounded(roundView: self.mainView)
        setupCameraView()
        tableView.register(UINib(nibName: VerifyProcessTableCell.description(), bundle: nil), forCellReuseIdentifier: VerifyProcessTableCell.description())
        self.tableView.rowHeight = 80
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        
        searchTextfield.label.textColor = UIColor.nativeRedColor()
        searchTextfield.label.text = "CN Number"
        searchTextfield.text = constant
        searchTextfield.placeholder = ""
        searchTextfield.setOutlineColor(UIColor.nativeRedColor(), for: .normal)
        searchTextfield.setOutlineColor(UIColor.nativeRedColor(), for: .editing)
        searchTextfield.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        self.delivery_sheets = AppDelegate.sharedInstance.db?.read_tbl_rider_delivery_and_verify_process(delivered_by: CURRENT_USER_LOGGED_IN_ID)?.filter({ delivery_sheets in
            delivery_sheets.DELIVERYSTATUS == ""
        })
        self.getCount()
    }
    private func getCount() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if let count = self.delivery_sheets?.count {
                
                self.verifiedCount = self.delivery_sheets!.filter { sheet in
                    sheet.verify == "Verify"
                }.count
                
                if self.verifiedCount < 10 {
                    self.totalVerify.text = "Total Verify: 0\(self.verifiedCount)"
                } else {
                    self.totalVerify.text = "Total Verify: \(self.verifiedCount)"
                }
                if (count - self.verifiedCount) < 10 {
                    self.totalUnverify.text = "Total Unverify: 0\(count - self.verifiedCount)"
                } else {
                    self.totalUnverify.text = "Total Unverify: \(count - self.verifiedCount)"
                }
                self.tableViewHeightConstraint.constant = CGFloat(80 * count)
                self.tableView.reloadData()
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
    
    private func updateBarCode(code:String) {
        guard let _ = self.delivery_sheets else {
            return
        }
        
        for sheet in self.delivery_sheets! {
            if sheet.CN == code {
                if let _ = AppDelegate.sharedInstance.db?.read_tbl_rider_verify_process(code: code) {
                    print("RECORD EXIST")
                } else {
                    let verify_process = VerifyProcess(CN: sheet.CN, SHEETNO: sheet.SHEETNO, VERIFY: "Verify", REPORT_TO: "", SYNC: 0, SYNC_DATE: "\(Date())")
                    AppDelegate.sharedInstance.db?.insert_tbl_rider_verify_process(verify_process: verify_process, handler: { _ in
                        self.delivery_sheets = AppDelegate.sharedInstance.db?.read_tbl_rider_delivery_and_verify_process(delivered_by: CURRENT_USER_LOGGED_IN_ID)?.filter({ delivery_sheets in
                            delivery_sheets.DELIVERYSTATUS == ""
                        })
                        self.getCount()
                    })
                }
            }
        }
    }
}


extension VerifyProcessDashboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.delivery_sheets?.count {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VerifyProcessTableCell.description()) as? VerifyProcessTableCell else {
            fatalError()
        }
        
        if let data = self.delivery_sheets?[indexPath.row] {
            cell.CNNumber.text = data.CN
            cell.SheetNumber.text = data.SHEETNO
            cell.CustomerName.text = data.CONSIGNEENAME
            
            cell.ReportTo.isHidden = true
            
            cell.EditBtn.tag = indexPath.row
            cell.EditBtn.addTarget(self, action: #selector(EditBtnTapped(sender:)), for: .touchUpInside)
            
            if data.verify == "Verify" {
                cell.VerifyLabel.text = "Verify"
                cell.VerifyLabel.textColor = UIColor.approvedColor()
                cell.MainView.bgColor = UIColor.riderlistingBgColor()
            } else {
                cell.MainView.bgColor = UIColor.white
                cell.VerifyLabel.text = "Unverify"
                cell.VerifyLabel.textColor = UIColor.nativeRedColor()
            }
            if data.report_to == "" {
                cell.ReportTo.isHidden = true
            } else {
                cell.ReportTo.text = data.report_to
                cell.ReportTo.isHidden = false
            }
        }
        return cell
    }
    
    @objc private func EditBtnTapped(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Popups", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "RiderReportToPopupViewController") as! RiderReportToPopupViewController
        
        if #available(iOS 13, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        controller.modalTransitionStyle = .crossDissolve
        controller.delegate = self
        self.selectedCn = self.delivery_sheets![sender.tag].CN
        self.selectedSheet = self.delivery_sheets![sender.tag].SHEETNO
        Helper.topMostController().present(controller, animated: true, completion: nil)
    }
}

extension VerifyProcessDashboardViewController: ReportToDelegate {
    func didSelectReportTo(report_to: tbl_rider_report_to_lov) {
        var isverify = 0
        for (i, d) in self.delivery_sheets!.enumerated() {
            if d.CN == self.selectedCn {
                self.delivery_sheets![i].report_to = report_to.RTT_DSCRP
                
                if self.delivery_sheets![i].verify == "Verify" {
                    isverify = 1
                } else {
                    isverify = 0
                }
                
                self.tableView.reloadData()
                break
            }
        }
        guard  let token = UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN) else {
            self.view.makeToast("Session Expired")
            return
        }
        let request_body = [
            "access_token": token,
            "scan_list" : [
                [
                    "cnno": self.selectedCn,
                    "sheet_no": self.selectedSheet,
                    "reason": report_to.RTT_DSCRP,
                    "isverify": isverify
                ]
            ]
        ] as [String:Any]
        let params = self.getAPIParameter(service_name: S_RIDER_REQUEST_DISPUTE, request_body: request_body)
        NetworkCalls.postriderrequestdispute(params: params) { granted, _ in
            if granted {
                let columns = ["REPORT_TO"]
                let values  = [report_to.RTT_DSCRP]
                let conditions = "CN = '\(self.selectedCn)' AND SHEETNO = '\(self.selectedSheet)'"
                AppDelegate.sharedInstance.db?.updateTables(tableName: db_rider_verify_process, columnName: columns, updateValue: values, onCondition: conditions, { _ in
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
            } else {
                DispatchQueue.main.async {
                    self.view.makeToast(SOMETHINGWENTWRONG)
                }
            }
        }
        //API HIT
    }
}
extension VerifyProcessDashboardViewController: UITextFieldDelegate {
    
}
