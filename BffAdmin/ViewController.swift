//
//  ViewController.swift
//  BffAdmin
//
//  Created by Azamat Kushmanov on 6/6/19.
//

import UIKit
import RxSwift
import MMProgressHUD

class ViewController: UIViewController, UITextFieldDelegate,UINavigationControllerDelegate {
    
    //    MARK:    Outlets
    //    MARK:    Выходные точки
    @IBOutlet weak var activityOutlet: UIActivityIndicatorView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var status: UILabel!
    
    //    MARK:    Variables
    //    MARK:    Переменные
    var profileVM: ProfileViewModel?
    var profileInfo: ProfileInfo?
    let dispose = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoutbarButtonItem()
        getProfileInfo()
        setupProfileImageViewStyle()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.getProfileInfo()
    }
    
    fileprivate func logoutbarButtonItem() {
        let navigationItem = UINavigationItem()
        navigationItem.title = "Профиль"
        let logoutbarbutton = UIBarButtonItem(title: "Выйти", style: .plain, target: self, action: #selector(outselector(paramsender:)))
        let editItem = UIBarButtonItem(title: "Изменить", style: .plain, target: self, action: #selector(editItemSelector(sender:)))
        self.navigationItem.leftBarButtonItem = logoutbarbutton
        self.navigationItem.rightBarButtonItem = editItem
    }
    
    //    MARK:    Did tapped logoutbarButtonItem to log out.
    @objc func outselector(paramsender: Any){
        MMProgressHUD.show()
        
        self.profileVM = ProfileViewModel()
        guard let lougOutResult = self.profileVM?.logOut() else {return}
        
        if lougOutResult == "Success" {
            MMProgressHUD.dismiss(withSuccess: "Вы вышли")
        } else {
            MMProgressHUD.dismissWithError(lougOutResult)
        }
    }
    
    //    MAARK:    Did tapped editItemButton to open the page for editing.
    //    MAARK:    Сделал нажатие на кнопку редактирования, чтобы открыть страницу для редактирования.
    @objc func editItemSelector(sender: Any){
        if self.profileInfo != nil{
            let editeProfileInfoVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileEditVC") as! ProfileEditVC
            editeProfileInfoVC.profileImage = self.profileImage.image
            editeProfileInfoVC.username = self.profileInfo!.name
            editeProfileInfoVC.numberPhone =  self.profileInfo!.numberPhone
            editeProfileInfoVC.status = self.profileInfo!.status
            editeProfileInfoVC.originImageUrl =  self.profileInfo!.originalImageUrl
            editeProfileInfoVC.previewImageUrl = self.profileInfo!.previewImageUrl
            self.navigationController?.pushViewController(editeProfileInfoVC, animated: true)
        }else{
            MMProgressHUD.show()
            MMProgressHUD.dismissWithError("Ошибка")
        }
    }
    
    //    MARK:    Retrieving profile information from a database
    //    MARK:    Получение информации о профиле из базы данных
    func getProfileInfo() {
        self.profileVM = ProfileViewModel()
        self.profileVM?.getProfileInfo()
        self.profileVM?.profileInfoBR.skip(1).subscribe(onNext: { (profileInfo) in
            self.profileInfo = profileInfo
            self.transferProfileInfoToRetailOutlets()
        }, onError: { (error) in
            print(error.localizedDescription)
        }).disposed(by: self.dispose)
        
    }
    
    func setupProfileImageViewStyle(){
        profileImage.frame = CGRect(x:0, y: 0, width: 150, height: 150)
        let imageBounds:CGFloat = profileImage.bounds.size.width
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = 0.5 * imageBounds
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor.white.cgColor
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.contentMode = .scaleAspectFill
        profileImage.isUserInteractionEnabled = false
    }
    
    
    
    //    MARK:    Transfer profile data to retail outlets
    //    MARK:    Перенос данных профиля в выходные точки
    func transferProfileInfoToRetailOutlets() {
        guard let profile = self.profileInfo else { return }
        self.userName.text = profile.name
        self.phoneNumber.text = profile.numberPhone
        self.status.text = profile.status
        DispatchQueue.main.async {
            self.profileImage.sd_setImage(with: URL(string:profile.previewImageUrl), placeholderImage: UIImage(named: ""))
        }
        self.editButtonItem.isEnabled = true
        self.activityOutlet.stopAnimating()
        self.activityOutlet.isHidden = true
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}


