//
//  MapViewController.swift
//  tcs_one_app
//
//  Created by TCS on 11/03/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let places = Place.getPlaces()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        // 2
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        
        requestLocationAccess()
                addAnnotations()
                addPolyline()
                addPolygon()
        // Do any additional setup after loading the view.
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
        mapView.delegate = self
//        mapView.addAnnotations(places)
        
    }
    
    func addPolyline() {
//        var locations = places.map { $0.coordinate }
//        print("Number of locations: \(locations.count)")
//        let polyline = MKPolyline(coordinates: &locations, count: locations.count)
//
//        mapView.addOverlay(polyline)
    }
    
    func addPolygon() {
        var locations = places.map { $0.coordinate }
        let polygon = MKPolygon(coordinates: &locations, count: locations.count)
        mapView.addOverlay(polygon)
    }
    func userInsidePolygon(userlocation: CLLocationCoordinate2D ) -> Bool {
        var containsPoint: Bool = false
        // get every overlay on the map
        let o = self.mapView.overlays
        // loop every overlay on map
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
                    let polygonPoint = self.mapView.convert(polygonCoordinate, toPointTo: self.mapView)

                    if (i == 0){
                        polygonPath.move(to: CGPoint(x: polygonPoint.x, y: polygonPoint.y))
                    }
                    else{
                        polygonPath.addLine(to: CGPoint(x: polygonPoint.x, y: polygonPoint.y))
                    }
                }
                let mapPointAsCGP:CGPoint = self.mapView.convert(userlocation, toPointTo: self.mapView)
                containsPoint =  polygonPath.contains(mapPointAsCGP)
                if containsPoint {
                    return true
                }
            }
        }
        return containsPoint
    }

}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate

        mapView.mapType = MKMapType.standard


        let annotation = MKPointAnnotation()
        annotation.coordinate = locValue
        print("User Inside: \(self.userInsidePolygon(userlocation: locValue))")
        mapView.removeAnnotation(annotation)
        mapView.addAnnotation(annotation)
      
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        else {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") as? MKPinAnnotationView
            if annotationView == nil {
              annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
              annotationView?.canShowCallout = true
            } else {
              annotationView?.annotation = annotation
            }
            return annotationView
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 2
            return renderer
            
        } else if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 3
            return renderer
            
        } else if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
            renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 2
            return renderer
        }
        
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        guard let annotation = view.annotation as? Place, let title = annotation.title else { return }
        
        let alertController = UIAlertController(title: "Welcome to \(title)", message: "You've selected \(title)", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}


@objc class Place: NSObject {
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    static func getPlaces() -> [Place] {
        var places = [Place]()
        
        if let locations = AppDelegate.sharedInstance.db?.read_tbl_att_locations(query: "SELECT * FROM \(db_att_locations)") {
            for location in locations {
                let latitude = (location.LATITUDE as NSString).doubleValue
                let longitude = (location.LONGITUDE as NSString).doubleValue
                
                let place = Place(coordinate: CLLocationCoordinate2D(latitude: latitude,
                                                                     longitude: longitude))
                
                places.append(place)
            }
        }
        return places as [Place]
    }
}

extension Place: MKAnnotation { }
