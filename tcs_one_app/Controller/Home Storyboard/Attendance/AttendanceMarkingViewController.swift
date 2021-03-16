//
//  AttendanceMarkingViewController.swift
//  tcs_one_app
//
//  Created by TCS on 11/03/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import SwiftyJSON
import DatePickerDialog
import MapKit

class AttendanceMarkingViewController: BaseViewController, MKMapViewDelegate {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var slideView: CustomView!
    
    @IBOutlet weak var checkInTime: UILabel!
    @IBOutlet weak var checkInBtn: UIButton!
    
    @IBOutlet weak var checkOutTime: UILabel!
    @IBOutlet weak var checkOutBtn: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    //    var mapView: MKMapView?
    let places = Place.getPlaces()
    var isUserInsideFence = false
    var slideText = ""
    var lat: String = "0.0"
    var lon: String = "0.0"
    
    lazy var slideToLock: MTSlideToOpenView = {
        let slide = MTSlideToOpenView(frame: CGRect(x: 5, y: 4, width: 270, height: 52))
        slide.sliderViewTopDistance = 0
        slide.sliderCornerRadius = 26
        slide.thumnailImageView.backgroundColor = UIColor.nativeRedColor()
        slide.draggedView.backgroundColor = UIColor.nativeRedColor()
        slide.delegate = self
        slide.thumnailImageView.backgroundColor = UIColor.clear
        slide.thumbnailViewStartingDistance = 10
        slide.sliderBackgroundColor = UIColor.clear
        slide.labelText = slideText
        slide.textLabelLeadingDistance = 20
        slide.thumnailImageView.image = #imageLiteral(resourceName: "slide").imageFlippedForRightToLeftLayoutDirection()
        return slide
    }()
    let datePicker = DatePickerDialog(
        textColor: .nativeRedColor(),
        buttonColor: .nativeRedColor(),
        font: UIFont.boldSystemFont(ofSize: 17),
        showCancelButton: true
    )
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Attendance"
        self.makeTopCornersRounded(roundView: self.mainView)
        addDoubleNavigationButtons()
        
        setupMapView()
        fetchAttendance()
        
    }
    
    func fetchAttendance() {
        guard let access_token = UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN) else {
            return
        }
        self.freezeScreen()
        self.view.makeToastActivity(.center)
        let json = [
            "fetchattendance" : [
                "access_token" : access_token
            ]
        ]
        let params = self.getAPIParameter(service_name: FETCHATTENDANCE, request_body: json)
        NetworkCalls.fetch_attendance(params: params) { (granted, response) in
            if granted {
                if let attendance = JSON(response).array {
                    self.updateLocalDatabase(attendance: attendance) {
                        DispatchQueue.main.async {
                            self.slideView.addSubview(self.slideToLock)
                        }
                    }
                } else {
                    self.view.hideToastActivity()
                    self.view.makeToast(SOMETHINGWENTWRONG)
                    self.unFreezeScreen()
                }
            } else {
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    self.view.makeToast(SOMETHINGWENTWRONG)
                    self.unFreezeScreen()
                }
            }
        }
    }
    
    func updateLocalDatabase(attendance:[JSON], _ handler: @escaping()->Void) {
        AppDelegate.sharedInstance.db?.deleteRow(tableName: db_att_userAttendance, column: "CURRENT_USER", ref_id: "\(CURRENT_USER_LOGGED_IN_ID)", handler: { _ in })
        for att in attendance {
            var user_attendace: AttUserAttendance?
            do {
                let data = try att.rawData()
                user_attendace = try JSONDecoder().decode(AttUserAttendance.self, from: data)
                if let _ = user_attendace {
                    AppDelegate.sharedInstance.db?.insert_tbl_att_user_attendance(att_location: user_attendace!)
                }
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
            if user_attendace?.status == "1" {
                DispatchQueue.main.async {
                    if user_attendace?.timeIn == "00:00" {
                        self.checkInTime.text =  "Awaited"
                    } else {
                        self.checkInTime.text =  "\(user_attendace?.date.dateOnly ?? "") - \(user_attendace?.timeIn ?? "")"
                    }
                    if user_attendace?.timeOut == "00:00" {
                        self.checkOutTime.text = "Awaited"
                    } else {
                        self.checkOutTime.text = "\(user_attendace?.date.dateOnly ?? "") - \(user_attendace?.timeOut ?? "")"
                    }
                    
                    
                    if self.checkInTime.text == "Awaited" {
                        self.slideText = "Slide to Check In"
                    } else {
                        self.slideText = "Slide to Check Out"
                    }
                    handler()
                }
            }
        }
        DispatchQueue.main.async {
            self.view.hideToastActivity()
            self.unFreezeScreen()
        }
    }
    
    
    func setupMapView() {
        mapView?.delegate = self
        locationManager.delegate = self
        // 2
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        
        requestLocationAccess()
        addAnnotations()
        addPolygon()
    }
    
    func openDatePicker(title: String, handler: @escaping(_ success: Bool,_ date: String) -> Void) {
        datePicker.show(title,
                        doneButtonTitle: "Done",
                        cancelButtonTitle: "Cancel",
                        datePickerMode: .time,
                        window: self.view.window) { (date) in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                handler(true, formatter.string(from: dt))
            }
        }
    }
    func requestLocationAccess() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return
            
        case .denied, .restricted:
            print("location access denied")
            
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func addAnnotations() {
        mapView?.delegate = self
    }
    
    func addPolygon() {
        var locations = places.map { $0.coordinate }
        let polygon = MKPolygon(coordinates: &locations, count: locations.count)
        mapView?.addOverlay(polygon)
    }
    func userInsidePolygon(userlocation: CLLocationCoordinate2D ) -> Bool {
        var containsPoint: Bool = false
        // get every overlay on the map
        if let o = self.mapView?.overlays {
            for overlay in o {
                // handle only polygon
                if overlay is MKPolygon{
                    let polygon:MKPolygon =  overlay as! MKPolygon
                    let polygonPath:CGMutablePath  = CGMutablePath()
                    // get points of polygon
                    let arrPoints = polygon.points()
                    // create cgpath
                    for i in 0..<polygon.pointCount {

                        let polygonMapPoint: MKMapPoint = arrPoints[i]
                        let polygonCoordinate = polygonMapPoint.coordinate
                        let polygonPoint = self.mapView?.convert(polygonCoordinate, toPointTo: self.mapView)

                        if (i == 0){
                            polygonPath.move(to: CGPoint(x: polygonPoint!.x, y: polygonPoint!.y))
                        }
                        else{
                            polygonPath.addLine(to: CGPoint(x: polygonPoint!.x, y: polygonPoint!.y))
                        }
                    }
                    let mapPointAsCGP:CGPoint = self.mapView!.convert(userlocation, toPointTo: self.mapView)
                    containsPoint =  polygonPath.contains(mapPointAsCGP)
                    if containsPoint {
                        return true
                    }
                }
            }
        }
        // loop every overlay on map
        
        return containsPoint
    }
    
    @IBAction func checkInTapped(_ sender: Any) {
        if self.checkInTime.text != "00:00" {
            return
        }
    }
    @IBAction func checkOutTapped(_ sender: Any) {
        if self.checkInTime.text == "00:00" {
            return
        }
    }
    @IBAction func historyBtnTapped(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AttendanceDetailsViewController") as! AttendanceDetailsViewController
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func markAttendance(_ handler: @escaping() -> Void) {
        if !CustomReachability.isConnectedNetwork() {
            self.view.makeToast(NOINTERNETCONNECTION)
            handler()
            return
        }
        
        guard let access_token = UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN) else {
            self.view.makeToast("Session Expired")
            return
        }
        self.view.makeToastActivity(.center)
        self.freezeScreen()
        let json = [
            "attendance_request" : [
                "access_token" : access_token,
                "latitude": self.lat,
                "longitude": self.lon,
                "app_datime" : getAttendanceMarkingTime()
            ]
        ]
        let params = self.getAPIParameter(service_name: MARKATTENDANCE, request_body: json)
        NetworkCalls.mark_attendance(params: params) { (granted, response) in
            if granted {
                if let attendance = JSON(response).array {
                    self.updateLocalDatabase(attendance: attendance) {
                        DispatchQueue.main.async {
                            self.slideToLock.removeFromSuperview()
                            self.slideView.addSubview(self.slideToLock)
                        }
                        handler()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    self.view.makeToast(SOMETHINGWENTWRONG)
                    self.unFreezeScreen()
                }
            }
        }
    }
}


extension AttendanceMarkingViewController: MTSlideToOpenDelegate {
    func mtSlideToOpenDelegateDidFinish(_ sender: MTSlideToOpenView) {
        if self.checkInTime.text == "Awaited" {
            if self.isUserInsideFence {
                markAttendance {
                    DispatchQueue.main.async {
                        sender.resetStateWithAnimation(false)
                    }
                }
            } else {
                self.view.makeToast("Out of Fence.")
            }
        } else {
            if self.isUserInsideFence {
                markAttendance {
                    DispatchQueue.main.async {
                        sender.resetStateWithAnimation(false)
                    }
                }
            } else {
                self.view.makeToast("Out of Fence.")
            }
        }
    }
}


extension AttendanceMarkingViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate

        self.lat = "\(locValue.latitude)"
        self.lon = "\(locValue.longitude)"
        
        print("Lat: \(lat) Lon: \(lon)")
//        print(lon)
        mapView?.mapType = MKMapType.standard
        self.isUserInsideFence = self.userInsidePolygon(userlocation: locValue)
        if self.isUserInsideFence {
            self.slideView.isUserInteractionEnabled = true
        } else {
            self.slideView.isUserInteractionEnabled = false
        }
        print("UserInside Fence: \(self.isUserInsideFence)")
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
        renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
        renderer.strokeColor = UIColor.orange
        renderer.lineWidth = 2
        return renderer
    }
}
