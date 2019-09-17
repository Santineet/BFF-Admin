//
//  StadAddressOnMappVC.swift
//  BffAdmin
//
//  Created by Mairambek on 03/07/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Firebase

class StadAddressOnMappVC: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 5000
    var location:GeoPoint?
    var stadTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Map"
        let buttonItem = MKUserTrackingBarButtonItem(mapView: mapView)
        self.navigationItem.rightBarButtonItem = buttonItem
        checkLocationServices()
    
    }
    
    func gettingDirection(latitude:Double,longtitude:Double){
        let sourceCoordinates = CLLocationCoordinate2DMake(latitude, longtitude)
        let destCoordinates = CLLocationCoordinate2DMake(42.877648, 74.589933)
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinates)
        let destPlacemark = MKPlacemark(coordinate: destCoordinates)
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destItem = MKMapItem(placemark: destPlacemark)
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceItem
        directionRequest.destination = destItem
        directionRequest.transportType = .walking
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let response = response else {
                if let error = error{
                    print("error",error.localizedDescription)
                }
                return
            }
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline,level: .aboveRoads)
            let rekt = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rekt), animated: true)
        }
    }
    
    func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: self.regionInMeters, longitudinalMeters: self.regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthorization()
        } else {
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            self.creatAnnotations(title: self.stadTitle, latitude: self.location!.latitude, longtitude: self.location!.longitude)
            //locationManager.startUpdatingLocation()
            break
        @unknown default:
            break
        }
    }
    
    func creatAnnotations(title:String,latitude:Double,longtitude:Double){
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
        mapView.layoutMargins = UIEdgeInsets(top: 0, left: 100, bottom: 0, right: 60)
    }
}


extension StadAddressOnMappVC:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: self.regionInMeters, longitudinalMeters: self.regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error\(error.localizedDescription)")
    }
    
    
}
