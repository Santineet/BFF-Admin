//
//  StadiumEditTVC.swift
//  BffAdmin
//
//  Created by Mairambek on 08/07/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import UIKit
import Firebase
import SwiftLocation
import Photos
import BSImagePicker
import MapKit
import MMProgressHUD

class StadiumEditTVC: UITableViewController,CLLocationManagerDelegate {
    
    //Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nameStadField: UITextField!
    @IBOutlet weak var descripTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    // variables
//    var images = [Image]()
    var stadium: Stadium?
    var allImages = [UIImage]()
    let locManager = CLLocationManager()
    let regionInMeters: Double = 5000
    var oldimages = [UIImage]()
    
    var stadiumEditVM: StadiumEditViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.nameStadField.text  = self.stadium?.stadName ?? ""
        self.descripTextView.text = self.stadium?.stadDescription ?? ""
        self.collectionView.register(UINib(nibName: "AddImagesCVCell", bundle: nil), forCellWithReuseIdentifier: "AddImagesCVCell")
        imageDownload()
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedMapp(sender:))))
        checkLocationService()
        tableView.allowsSelection = false

    }
    
      //MARK: - Method
    
    //Удаление стадиона
    @IBAction func removeButton(_ sender: UIButton) {
        self.stadiumEditVM = StadiumEditViewModel()
        guard let stadium = stadium else { return }
        self.stadiumEditVM?.removeStadium(stadiumId: stadium.id)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    //Нажали на MapView
    @objc func didTappedMapp(sender:Any){
        let stadAddressEditOnMapVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StadAddressEditOnMapVC") as! StadAddressEditOnMapVC
        stadAddressEditOnMapVC.location = newLocation ?? stadium?.points
        stadAddressEditOnMapVC.stadTitle = nameStadField.text!
        self.navigationController?.pushViewController(stadAddressEditOnMapVC, animated: true)
    }
    
    //Нажали на кнопку сохранить
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        MMProgressHUD.show(withStatus: "Загрузка")
        if allImages.count == 0 {
            MMProgressHUD.dismissWithError("Добавьте фоторнафии")
            return
        }
        guard let name = self.nameStadField.text,!self.nameStadField.text!.isEmpty else {
            MMProgressHUD.dismissWithError("Введите имя")
            return
        }
        guard let description = self.descripTextView.text,!self.descripTextView.text!.isEmpty else {
            MMProgressHUD.dismissWithError("Введите описание")
            return
        }
        let location = newLocation ?? stadium?.points
        if self.nameStadField.text != self.stadium?.stadName || self.descripTextView.text != self.stadium?.description || newLocation != nil || allImages != oldimages {
            self.doneButton.isEnabled = false
            self.stadiumEditVM = StadiumEditViewModel()
            self.stadiumEditVM?.uploadImagesToFirestore(images: self.allImages, onCompletion: { (imageURL) in
                self.stadiumEditVM?.saveStadiumData(user: Auth.auth().currentUser, stadiumName: name, description: description, location: location, stadiumId: self.stadium?.id, imagesArray: imageURL, completion: { (error) in
                    if error != nil {
                        print(error?.localizedDescription as Any)
                    }else{
                        newLocation = nil
                        self.navigationController?.popViewController(animated: true)
                        self.doneButton.isEnabled = true
                        //                self.hud.dismiss()
                        MMProgressHUD.dismiss(withSuccess: "Выполнено")
                        print("Success")
                    }
                })
            })
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func imageDownload() {
//        MMProgressHUD.show()
        self.stadiumEditVM = StadiumEditViewModel()
        self.stadiumEditVM?.imageDownload(images: self.stadium!.images, onCompletion: { (allImages) in
            print(allImages)
            self.allImages = allImages
            self.oldimages = allImages
            MMProgressHUD.dismiss()
            self.collectionView.reloadData()
            
        })
        
    }
    
    //Location
    func setupLocationManager() {
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
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
            locManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            locManager.startUpdatingLocation()
            break
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations  locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let region = MKCoordinateRegion.init(center: location.coordinate,  latitudinalMeters: self.regionInMeters, longitudinalMeters: self.regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager,  didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error\(error.localizedDescription)")
    }
}

// extension UICollectionView
extension StadiumEditTVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath:IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width/3 - 4, height: collectionView.frame.height/2 - 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allImages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddImagesCVCell", for: indexPath) as! AddImagesCVCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StadiumEditCVCell", for: indexPath) as! StadiumEditCVCell
            cell.removeButtonOutlet.tag = indexPath.row
            cell.removeButtonOutlet.addTarget(self, action: #selector(buttonClicked(sender: ))
                , for: .touchUpInside)
            let image = self.allImages[indexPath.row - 1]
            print("image.originalUrl! \(image)")
            cell.stadiumEditImages.image = image
            return cell
        }
    }
    
    @objc func buttonClicked(sender:UIButton) {
        let buttonRow = sender.tag
        self.allImages.remove(at: buttonRow - 1)
        collectionView.reloadData()
    }
    
    // BSImagePickerViewController
    func maxImagesAlert(){
        let alert = UIAlertController(title: "Извините", message: "Максимальное количество фотографий", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if allImages.count == 7 {
        //max image item alert
                showAlert(title: "Извините", message: "Максимальное количество фотографий")
                
            } else {
                let vc = BSImagePickerViewController()
                vc.maxNumberOfSelections = 7 - allImages.count
                //display picture gallery
                self.bs_presentImagePickerController(vc, animated: true,
                                                     select: { (asset: PHAsset) -> Void in
                }, deselect: { (asset: PHAsset) -> Void in
                }, cancel: { (assets: [PHAsset]) -> Void in
                }, finish: { (assets: [PHAsset]) -> Void in
                    convertAssetToImages(assests: assets)
                }, completion: nil)
                
                func convertAssetToImages(assests: [PHAsset]) {
                    if assests.count > 0{
                        for asset in assests{
                            let manager = PHImageManager.default()
                            let option = PHImageRequestOptions()
                            option.isSynchronous = true
                            manager.requestImage(for: asset, targetSize: CGSize(width: 1000, height: 1000) , contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
                                self.allImages.append(result!)
                            })
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
            }
        } else {
            print("clicked image")
        }
    }
}
