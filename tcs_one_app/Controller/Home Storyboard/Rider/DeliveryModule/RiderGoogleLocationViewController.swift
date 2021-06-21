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
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Rider"
        GMSServices.provideAPIKey("AIzaSyAWgNm6sVh2KWgBZfHWIhevbs3V-6cmTXM")
        self.makeTopCornersRounded(roundView: mainView)
        
        let camera = GMSCameraPosition(latitude: 24.895032036850953, longitude: 67.15626468971116 , zoom: 11.0)
        let mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: self.mapView.frame.size.width, height: self.mapView.frame.size.height), camera: camera)
        self.mapView.addSubview(mapView)
        
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 24.895032036850953, longitude: 67.15626468971116)
        marker.map = mapView
    }
}
