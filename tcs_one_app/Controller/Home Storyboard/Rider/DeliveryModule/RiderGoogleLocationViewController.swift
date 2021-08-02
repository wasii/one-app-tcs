//
//  RiderGoogleLocationViewController.swift
//  tcs_one_app
//
//  Created by TCS on 21/06/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import GoogleMaps

class RiderGoogleLocationViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mapView: CustomView!
    
    var isLocationOff = false
    var clAuthorizatinStatus: CLAuthorizationStatus?
    var lat: Double = 0.0
    var lon: Double = 0.0
    var delivery_sheets: tbl_rider_delivery_sheet?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Rider"
        GMSServices.provideAPIKey("AIzaSyAWgNm6sVh2KWgBZfHWIhevbs3V-6cmTXM")
        self.makeTopCornersRounded(roundView: mainView)
        
        
        locationManager.delegate = self
        // 2
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidLayoutSubviews() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            let camera = GMSCameraPosition(latitude: self.lat, longitude: self.lon , zoom: 11.0)
            let mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: self.mapView.frame.size.width, height: self.mapView.frame.size.height), camera: camera)
            self.mapView.addSubview(mapView)
            var bounds = GMSCoordinateBounds()
            for i in 0..<2 {
                let marker = GMSMarker()
                if i == 0 {
                    marker.position = CLLocationCoordinate2D(latitude: self.lat, longitude: self.lon)
                    bounds = bounds.includingCoordinate(marker.position)
                } else {
                    let latDouble = Double(self.delivery_sheets?.CNSGEE_LAT ?? "0.0")
                    let lonDouble = Double(self.delivery_sheets?.CNSGEE_LNG ?? "0.0")
                    marker.position = CLLocationCoordinate2D(latitude: latDouble ?? 0.0, longitude: lonDouble ?? 0.0)
                    bounds = bounds.includingCoordinate(marker.position)
                }
                marker.map = mapView
            }
            mapView.setMinZoom(1, maxZoom: 15)//prevent to over zoom on fit and animate if bounds be too small

            let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
            mapView.animate(with: update)

            mapView.setMinZoom(1, maxZoom: 20)
        }
    }
    @IBAction func callBtnTapped(_ sender: Any) {
        var cusPhn = self.delivery_sheets!.CUS_PHN
        if cusPhn.first == "+" {
            cusPhn = cusPhn.replacingOccurrences(of: "+92", with: "0")
        } else if cusPhn.first == "9" {
            cusPhn.removeFirst()
            cusPhn.removeFirst()
            cusPhn = "0" + cusPhn
        } else if cusPhn.first != "0" {
            cusPhn = "0" + cusPhn
        }
        if let url = URL(string: "tel://\(RIDER_DIAL_CODE)\(cusPhn)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension RiderGoogleLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            self.isLocationOff = true
            locationManager.startUpdatingLocation()
            break
        case .denied, .restricted, .notDetermined:
            self.isLocationOff = false
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
    }
}
