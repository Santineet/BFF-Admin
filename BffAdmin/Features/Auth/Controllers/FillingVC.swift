//
//  ProfileVC.swift
//  BffAdmin
//
//  Created by Mairambek on 13/06/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import MMProgressHUD

class FillingVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    //    MARK:    Outlets
    //    MARK:    Выходные точки
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var number: UITextField!
    @IBOutlet weak var status: UITextField!
    
    //    MARK:    Variables
    //    MARK:    Переменные
    var authDataResult:User?
    var originalImageUrl:URL?
    
    var loginVM: LoginViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFillingsOutlets()
        createBurButton()
        
    }
    
    func setupFillingsOutlets(){
        self.setupProfileImageViewStyle()
        self.view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        self.name.text = authDataResult?.displayName
        self.number.text = authDataResult?.phoneNumber
        self.status.text = "Hello World!"
        
        if originalImageUrl != nil{
            self.profileImage.sd_setImage(with: originalImageUrl, placeholderImage: UIImage(named: ""))
            self.profileImage.isUserInteractionEnabled = false
        }else{
            DispatchQueue.main.async {
                self.profileImage.isUserInteractionEnabled = true
                print("elseerror")
            }
            self.profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTappedProfileImageView)))
        }
    }
    
    func setupProfileImageViewStyle(){
        profileImage.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        let imageBounds:CGFloat = profileImage.bounds.size.width
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = 0.5 * imageBounds
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor.white.cgColor
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.contentMode = .scaleAspectFill
        profileImage.isUserInteractionEnabled = false
    }
    
    func createBurButton(){
        let navigationItem = UINavigationItem()
        navigationItem.title = "Авторизация"
        let didappedDoneButton = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(doneButtonSelector(paramsender:)))
        self.navigationItem.rightBarButtonItem = didappedDoneButton
        
    }
    
    @objc func doneButtonSelector(paramsender: Any){
        
        MMProgressHUD.show()
        guard let name = self.name.text,!self.name.text!.isEmpty else {
            print("Name is empty")
            MMProgressHUD.dismissWithError("Name is empty")
            return
        }
        guard let number = self.number.text,!self.number.text!.isEmpty else {
            print("number is empty")
            MMProgressHUD.dismissWithError("Number is empty")
            return
        }
        print(number)
        print(self.number.text as Any)
        guard let status = self.status.text,!self.status.text!.isEmpty else {
            print("Status is empty")
            MMProgressHUD.dismissWithError("Status is empty")
            return
        }
        guard let _ = self.profileImage.image,self.profileImage != nil else {
            print("Image is nil")
            MMProgressHUD.dismissWithError("Image is empty")
            return
        }
        
        self.doneButton.isEnabled = false
        let data = ["userName": name,"userNumber":number,"userStatus": status]
        self.loginVM = LoginViewModel()
        if self.loginVM?.isConnnected() == true{
            self.loginVM?.compressingImageWithSaveProfileInfo(imageToCompressing: self.profileImage.image, data: data, completion: { (data, error) in
                if error != nil{
                    self.doneButton.isEnabled = true
                    MMProgressHUD.dismissWithError(error?.localizedDescription)
                } else if data == data{
                    MMProgressHUD.dismiss(withSuccess: "")
                    self.doneButton.isEnabled = true
                    UserDefaults.standard.setValue(1, forKey: "isLoggedIn")
                    LoginLogoutManager.instance.updateRootVC()
                } else {
                    self.doneButton.isEnabled = true
                    guard let lougOutResult = self.loginVM?.logOut() else {return}
                    if lougOutResult == "Success" {
                        MMProgressHUD.dismissWithError("Data is nil")
                        LoginLogoutManager.instance.updateRootVC()
                    } else {
                        MMProgressHUD.dismissWithError(lougOutResult)
                        LoginLogoutManager.instance.updateRootVC()
                    }
                    
                }
            })
        }else{
            MMProgressHUD.dismissWithError("Нет соединения")
        }
    }
    
    //    MARK:    Сlicked the profile Image to select a photo for the profile.
    //    MARK:    Нажатие на изображение профиля, чтобы выбрать фотографию для профиля.
    @objc func didTappedProfileImageView(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.isEditing = true
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
  
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedFromImageFromPicker:UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            selectedFromImageFromPicker = editedImage
        }else if let originalImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            selectedFromImageFromPicker = originalImage
        }
        if let selectedImage = selectedFromImageFromPicker{
            self.profileImage.image = selectedImage
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //    MARK:    After selecting a photo, go to the current page.
    //    MARK:    После выбора фото переходит на текущую страницу.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
