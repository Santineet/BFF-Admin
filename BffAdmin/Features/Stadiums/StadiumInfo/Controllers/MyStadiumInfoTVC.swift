//
//  MyStadiumInfoTVC.swift
//  BffAdmin
//
//  Created by Mairambek on 03/07/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import RxSwift
import MMProgressHUD



class MyStadiumInfoTVC: UITableViewController {
    
    //Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var descripTextView: UITextView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    
    //    MARK:    Variables
    //    MARK:    Переменные
    var stadium: Stadium?
    var currentIndex = 0
    var image = UIImage()
    let locationManager = CLLocationManager()
    var images = [Image]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    var stadiumInfoVM: StadiumInfoViewModel?
    let dispose = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTappedMap)))
        
        checkLocationService()
        self.setupStadiumInfo()
        let editItem = UIBarButtonItem(title: "Изменить", style: .plain, target: self, action: #selector(editItemSelector(sender:)))
        self.navigationItem.rightBarButtonItem = editItem
    
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getStadiumInfo()
    }
    
    //MARK: - Method
    
   
    func getStadiumInfo() {
        self.stadiumInfoVM = StadiumInfoViewModel()
        guard let stadium = self.stadium else { return }
        self.stadiumInfoVM?.getStadiumInfo(stadiumID: stadium.id)
        self.stadiumInfoVM?.stadiumInfoBR.skip(1).subscribe(onNext: { (stadiumInfo) in
             self.stadium = stadiumInfo
             self.setupStadiumInfo()
            
        }, onError: { (error) in
            print(error.localizedDescription)
        }).disposed(by: self.dispose)
    
    }
    
    @objc func editItemSelector(sender: Any){
        if self.stadium != nil {
            let stadiumEditTVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StadiumEditTVC") as! StadiumEditTVC
            stadiumEditTVC.stadium = stadium
            self.navigationController?.pushViewController(stadiumEditTVC, animated: true)
        }else{
          print("error")
        }
    }
    
  
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath:IndexPath) -> CGSize {
                return CGSize(width: size.width, height: 243)
            }
            self.collectionView.reloadData()
        } else {
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            
            func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath:IndexPath) -> CGSize {
                return CGSize(width: size.width, height: 243)
            }
            self.collectionView.reloadData()
        }
    }
    
    //    MARK:    Transfer stadium data to retail outlets
    //    MARK:    Перенос данных stadium в выходные точки
    func setupStadiumInfo() {
        if let stadium = self.stadium {
            if stadium.stadName != "" {
                self.nameLabel.text = stadium.stadName
            } else {
                self.nameLabel.text = "No name"
            }

            if stadium.stadDescription != "" {
                self.descripTextView.text = stadium.stadDescription
            } else {
                self.descripTextView.text = "No description"
            }
            
            self.images = stadium.images
            
            if self.images.count >= 2{
                pageControl.numberOfPages = self.images.count
            } else {
                pageControl.numberOfPages = 0
            }
            self.price.text = stadium.price
            self.startTime.text = "C " + stadium.startWorkTime
            self.endTime.text = "До " + stadium.endWorkTime
            navigationItem.title = stadium.stadName
            self.collectionView.reloadData()
        }
    }
    
    
    @objc func didTappedMap(){
        let stadAddressOnMappVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StadAddressOnMappVC") as! StadAddressOnMappVC
        stadAddressOnMappVC.location = stadium?.points
        stadAddressOnMappVC.stadTitle = nameLabel.text!
        self.navigationController?.pushViewController(stadAddressOnMappVC, animated: true)
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
}

//MARK: - Extensions
extension MyStadiumInfoTVC:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations  locations: [CLLocation]) {
        let regionInMeters: Double = 5000
        guard let location = locations.last else { return }
        let region = MKCoordinateRegion.init(center: location.coordinate,  latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager,  didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error\(error.localizedDescription)")
    }
}

extension MyStadiumInfoTVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageSliderCell", for: indexPath) as! ImageSliderCell
        let image = self.images[indexPath.row]
        print(image.originalUrl!)
        if image.originalUrl != "" && image.originalUrl != nil{
            cell.imageView.sd_setImage(with: URL(string: image.originalUrl!), placeholderImage: UIImage(named: "defaultImage"))
            print("slider")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath:IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / collectionView.frame.size.width)
        pageControl.currentPage = currentIndex
        if scrollView.alwaysBounceVertical == true{
        }
    }
}
