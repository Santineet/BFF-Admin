//
//  ProfileEditVC.swift
//  BffAdmin
//
//  Created by Mairambek on 19/06/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import UIKit
import FirebaseAuth
import MMProgressHUD

class ProfileEditVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    //    MARK:    Outlets
    //    MARK:    Выходные точки
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var numberField: UITextField!
    @IBOutlet weak var statusField: UITextField!
    @IBOutlet weak var logoutButon: UIButton!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    //    MARK:    Variables
    //    MARK:    Переменные
    var profileImage: UIImage?
    var username: String = ""
    var numberPhone: String = ""
    var status: String = ""
    var originImageUrl: String = ""
    var previewImageUrl: String = ""
    
    var profileEditVM: ProfileEditViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProfileImageViewStyle()
        if Auth.auth().currentUser != nil{
            transferProfileInfoToRetailOutletsForEditing()
        }
        
    }
    
    //    MARK:    Transfer profile data to retail outlets for editing
    //    MARK:    Перенос данных профиля в выходные точки для редактирования
    fileprivate func transferProfileInfoToRetailOutletsForEditing() {
        profileImageView.image = profileImage
        nameField.text = username
        numberField.text = numberPhone
        statusField.text = status
        doneButton.isEnabled = true
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTappedProfileImageView)))
    }
    
    
    //    MARK:    Assigns a style to a profile photo.
    //    MARK:    Присвоит стиль для фотографии профиля.
    func setupProfileImageViewStyle(){
        profileImageView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        let imageBounds:CGFloat = profileImageView.bounds.size.width
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = 0.5 * imageBounds
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.isUserInteractionEnabled = false
        self.view.backgroundColor = UIColor(white: 0.95, alpha: 1)
    }
    
    //    MARK:    Did tapped logOutButton to log out.
    //    MARK:    Сделал прикосновение к кнопке logOutButton, чтобы выйти из системы.
    @IBAction func logoutButtonAction(_ sender: Any) {
        MMProgressHUD.show()
        
        self.profileEditVM = ProfileEditViewModel()
        guard let lougOutResult = self.profileEditVM?.logOut() else {return}
        
        if lougOutResult == "Success" {
            MMProgressHUD.dismiss(withSuccess: "Вы вышли")
        } else {
            MMProgressHUD.dismissWithError(lougOutResult)
        }
    }
    
    //    MARK:    Did tapped doneButtonAction to save changed data.
    //    MARK:    Сделал прикосновение к кнопке doneButtonAction, чтобы сохранить изменённые данные.
    @IBAction func doneButtonAction(_ sender: UIBarButtonItem) {
        
        MMProgressHUD.show(withStatus: "Загрузка")
        
        self.profileEditVM = ProfileEditViewModel()
        
        guard let name = self.nameField.text,!self.nameField.text!.isEmpty else {
            MMProgressHUD.dismissWithError("Name is Empty")
            return
        }
        guard let number = self.numberField.text,!self.numberField.text!.isEmpty else {
            MMProgressHUD.dismissWithError("Number is Empty")
            return
        }
        guard let status = self.statusField.text,!self.statusField.text!.isEmpty else {
            MMProgressHUD.dismissWithError("Status is Empty")
            return
        }
        guard let _ = self.profileImageView.image,self.profileImageView != nil else {
            MMProgressHUD.dismissWithError("Image is Empty")
            return
        }
        
        if self.nameField.text != self.username ||
            self.numberField.text != self.numberPhone ||
            self.statusField.text != self.status ||
            self.profileImageView.image != self.profileImage{
            
            if self.profileImageView.image != self.profileImage{
                
                if self.profileEditVM?.isConnected() == true {
                    
                    self.profileEditVM = ProfileEditViewModel()
                    let data = ["userName":name,"userNumber":number,"userStatus":status] as [String:String]
                    
                    profileEditVM?.compressingImageWithSaveProfileInfo(selectedImage: self.profileImageView.image, data: data, completion: { (data, error) in
                        if error != nil {
                            self.doneButton.isEnabled = true
                            MMProgressHUD.dismissWithError("Не завершен")
                            self.navigationController?.popViewController(animated: true)
                            self.dismiss(animated: true, completion: nil)
                        }
                        if data == data {
                            MMProgressHUD.dismiss(withSuccess: "Выполнено")
                            self.navigationController?.popViewController(animated: true)
                            self.dismiss(animated: true, completion: nil)
                            self.doneButton.isEnabled = true
                        }else{
                            self.doneButton.isEnabled = true
                            MMProgressHUD.dismissWithError("Не завершен")
                            self.navigationController?.popViewController(animated: true)
                            self.dismiss(animated: true, completion: nil)
                            
                        }
                    })
                } else {
                    MMProgressHUD.dismissWithError("Нет соединения")
                }
                
            }else{
                self.profileEditVM = ProfileEditViewModel()
                let saveData = ["userNumber":number,"userName":name,"userStatus":status,"originalUrl":self.originImageUrl,"previewUrl":self.previewImageUrl]
                profileEditVM?.saveProfileData(user: Auth.auth().currentUser, data: saveData, completion: { (error) in
                    if error != nil {
                        self.doneButton.isEnabled = true
                        MMProgressHUD.dismissWithError("Не завершен")
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    }else{
                        self.doneButton.isEnabled = true
                        MMProgressHUD.dismiss(withSuccess: "Выполнено")
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }else{
            MMProgressHUD.dismissWithError("Не завершено")
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    //    MARK:    Сlicked the profile Image to select a photo for the profile.
    //    MARK:    Нажатие на изображение профиля, чтобы выбрать фотографию для профиля.
    @objc func didTappedProfileImageView(paramsender: Any){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.isEditing = true
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    // Select a photo in the gallery.
    // Выбрать фотографию в галерее.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedFromImageFromPicker:UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            selectedFromImageFromPicker = editedImage
        }else if let originalImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            selectedFromImageFromPicker = originalImage
        }
        if let selectedImage = selectedFromImageFromPicker{
            self.profileImageView.image = selectedImage
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}







