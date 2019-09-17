//
//  StadAddressEditOnMapVC.swift
//  BffAdmin
//
//  Created by Mairambek on 09/07/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class StadAddressEditOnMapVC: UIViewController {
    
    @IBOutlet weak var mapCenterImage: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    let locManager = CLLocationManager()
    let regionInMeters: Double = 5000
    var location:GeoPoint?
    var stadTitle: String = ""
    var latitudeLocation: Double?
    var longitudeLocation: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if newLocation != nil{
            location = newLocation
        }
        self.navigationItem.title = "Map"
        let buttonItem = MKUserTrackingBarButtonItem(mapView: mapView)
        self.navigationItem.rightBarButtonItem = buttonItem
        checkLocationServices()
  
    }
    
    //MARK: - Method
    
    @IBAction func saveLocationButton(_ sender: UIButton) {
        let center = getCenterLocation(for: mapView)
        self.location = center
        newLocation = center
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupLocationManager() {
        locManager.desiredAccuracy = kCLLocationAccuracyBest
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
            locManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if location == nil {
                self.location = GeoPoint(latitude: self.latitudeLocation!, longitude: self.longitudeLocation!)
            }
            self.creatAnnotations(title: self.stadTitle, latitude: self.location!.latitude, longtitude: self.location!.longitude)
            locManager.startUpdatingLocation()
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


// location extension
extension StadAddressEditOnMapVC: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: self.regionInMeters, longitudinalMeters: self.regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error\(error.localizedDescription)")
    }
}

extension StadAddressEditOnMapVC: MKMapViewDelegate {
    func getCenterLocation(for mapView: MKMapView) -> GeoPoint {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return GeoPoint(latitude: latitude, longitude: longitude)
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
    }
}
