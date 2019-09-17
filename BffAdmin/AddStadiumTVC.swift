//
//  AddStadiumTVC.swift
//  BffAdmin
//
//  Created by Mairambek on 15/07/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import SwiftLocation
import MMProgressHUD

class AddStadiumTVC: UITableViewController,UINavigationControllerDelegate,CLLocationManagerDelegate, UITextFieldDelegate{
    
    //Outlets
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nameStadium: UITextField!
    @IBOutlet weak var descripStadium: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var startTimeOutlet: UITextField!
    @IBOutlet weak var endTimeOutlet: UITextField!
    @IBOutlet weak var priceTextOutlet: UITextField!
    
    // image
    var images = [UIImage]()
    var addStadiumVM: AddStadiumViewModel?
    
    //location
    let locationManager = CLLocationManager()
    var latitudeLocation: Double?
    var longitudeLocation: Double?
    
    //data
    var authDataResult:User? = Auth.auth().currentUser
    var originalImageUrl:URL?
    var originImageUrl:String?
    var previewImageUrl:String?
    var dateSampledPickerStart = UIDatePicker()
    var dateSampledPickerEnd = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsSelection = false

        self.createLocation()
        self.collectionView.register(UINib(nibName: "AddImagesCVCell", bundle: nil), forCellWithReuseIdentifier: "AddImagesCVCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedMapp(sender:))))
        

        createDatePicker()


    
    }
    
    //MARK: - Method
    
    
//    func elapsedTime(){
//        let startDate = dateSampledPickerStart.date
//        let endDate = dateSampledPickerEnd.date
//        let calendar = Calendar.current
//        let dateComponents = calendar.compare(startDate, to: endDate, toGranularity: .hour)
//    }
    

    
    
    func createDatePicker(){
       
        let dateSampledPickerToolBar = UIToolbar()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButtonDate = UIBarButtonItem(title: "Готово", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.donePickerDate))
        dateSampledPickerToolBar.barStyle = UIBarStyle.default
        dateSampledPickerToolBar.isTranslucent = true
        dateSampledPickerToolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        dateSampledPickerToolBar.sizeToFit()
        dateSampledPickerToolBar.setItems([spaceButton,spaceButton,doneButtonDate], animated: true)
        dateSampledPickerToolBar.isUserInteractionEnabled = true

        dateSampledPickerStart.datePickerMode = .time
        dateSampledPickerEnd.datePickerMode = .time
        dateSampledPickerStart.addTarget(self, action: #selector(self.datePickerValueChangedStart(sender:)),  for: .valueChanged)
        dateSampledPickerEnd.addTarget(self, action: #selector(self.datePickerValueChangedEnd(sender:)),  for: .valueChanged)
        
        //Outlets setting
        self.startTimeOutlet.inputView = dateSampledPickerStart
        self.startTimeOutlet.inputAccessoryView = dateSampledPickerToolBar
        self.endTimeOutlet.inputView = dateSampledPickerEnd
        self.endTimeOutlet.inputAccessoryView = dateSampledPickerToolBar

        self.startTimeOutlet.tintColor = .clear
        self.endTimeOutlet.tintColor = .clear
        
        self.startTimeOutlet.delegate = self
        self.endTimeOutlet.delegate = self

        self.startTimeOutlet.font = UIFont.boldSystemFont(ofSize: 24)
        self.startTimeOutlet.sizeToFit()
        self.endTimeOutlet.font = UIFont.boldSystemFont(ofSize: 24)
        self.endTimeOutlet.sizeToFit()
    }
    
    @objc func datePickerValueChangedStart(sender:UIDatePicker) {
        print(sender.date as Any)
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        

        self.startTimeOutlet.text = timeFormatter.string(from: dateSampledPickerStart.date)
    }
    
    @objc func datePickerValueChangedEnd(sender:UIDatePicker) {
        print(sender.date as Any)
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        self.endTimeOutlet.text = timeFormatter.string(from: dateSampledPickerEnd.date)
        
    }
    
  
    
    @objc func donePickerDate(){
        self.startTimeOutlet.resignFirstResponder()
        self.endTimeOutlet.resignFirstResponder()

    }
    
    
 
    
    //    MARK:    Did tapped doneButtonAction to publish the stadium.
    //    MARK:    Сделал прикосновение к кнопке doneButtonAction, чтобы опубликовать стадион.
    @IBAction func doneButtonAction(_ sender: Any) {
        
        let startTime = dateSampledPickerStart.date
        let endTime = dateSampledPickerEnd.date
        var interval = endTime.hours(from: startTime)
        if interval < 0 {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH"
            interval = Int(timeFormatter.string(from: startTime))! + interval + 16
        }
        

        self.doneButton.isEnabled = true
        let workTime = ["Start":startTimeOutlet.text,"End":endTimeOutlet.text]
        var price = "Договорная"
        if priceTextOutlet.text != "" {
            price = priceTextOutlet.text!
        }
        guard authDataResult != nil, nameStadium.text != "", descripStadium.text != "",
            latitudeLocation != nil, longitudeLocation != nil else {
                print("fill form")
                self.showAlert(title: "Ошибка", message: "Заполните все поля!")
                return
        }
        guard images.count != 0 else {
            self.showAlert(title: "Ошибка", message: "Добавьте фотографии стадиона!")
            return
        }
        
        
        MMProgressHUD.show(withStatus: "Загрузка")
        self.addStadiumVM = AddStadiumViewModel()
        self.addStadiumVM?.uploadImagesToFirestore(images: images, onCompletion: { (imageURL) in
            
            self.addStadiumVM?.saveStadiumData(user: self.authDataResult, stadiumName: self.nameStadium.text, description: self.descripStadium.text, location: newLocation ??  GeoPoint(latitude: self.latitudeLocation!, longitude: self.longitudeLocation!), workTime: workTime, price:price, interval: interval, startTime: startTime , imagesArray: imageURL, completion: { (error) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                    return
                }else{
                    self.doneButton.isEnabled = true
                    MMProgressHUD.dismiss(withSuccess: "Выполнено")
                    self.navigationController?.popViewController(animated: true)
                    print("Success")
                    
                }
            })
            
            
        })
    }
    
    
    // AlertController
    func showAlert(title:String,message:String){
        MMProgressHUD.dismiss()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            self.view.isUserInteractionEnabled = true
            self.view.alpha = 1
        }))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Location
    //MARK: - Локация
    @objc func didTappedMapp(sender:Any){
        let stadAddressEditOnMapVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StadAddressEditOnMapVC") as! StadAddressEditOnMapVC
        stadAddressEditOnMapVC.location = newLocation
        stadAddressEditOnMapVC.latitudeLocation = latitudeLocation
        stadAddressEditOnMapVC.longitudeLocation = longitudeLocation
        stadAddressEditOnMapVC.stadTitle = nameStadium.text ?? ""
        self.navigationController?.pushViewController(stadAddressEditOnMapVC, animated: true)
    }
    
    func createLocation(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationService() {
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
            locationManager.startUpdatingLocation()
            break
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations  locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let regionInMeters: Double = 5000
        let region = MKCoordinateRegion.init(center: location.coordinate,  latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
        let locValue: CLLocationCoordinate2D = manager.location!.coordinate
        latitudeLocation = locValue.latitude
        longitudeLocation = locValue.longitude
        
    }
    
    func locationManager(_ manager: CLLocationManager,  didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error\(error.localizedDescription)")
    }
}


