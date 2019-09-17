//
//  AuthViewController.swift
//  BffAdmin
//
//  Created by Mairambek on 06/06/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore
import MMProgressHUD

class AuthViewController: UIViewController, UITextFieldDelegate {
    
    var loginVM: LoginViewModel?
    
    var signup: Bool = true {
        willSet{
            if newValue{
                titleLabel.text = "Регистрация"
                userNameField.isHidden = false
                enterButton.setTitle("Войти через электронную почту", for: .normal)
                accountLabel.text = "У вас уже есть аккаунт?"
            } else {
                titleLabel.text = "Войти"
                userNameField.isHidden = true
                enterButton.setTitle("Регистрация через электронную почту", for: .normal)
                accountLabel.text = "У вас еще нету аккаунта?"
            }
        }
    }
    
    //    MARK:    Outlets
    //    MARK:    Выходные точки
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var accountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Football"
        self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "bffAdminImage")!))
        self.userNameField.delegate = self
        self.emailField.delegate = self
        self.passwordField.delegate = self
        self.hideKeyboard()
    }
    
    //MARK: - Method
    
    @IBAction func switchLogin(_ sender: UIButton) {
        signup = !signup
    }
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == passwordField {
            textField.resignFirstResponder()
        }
        
        let name = userNameField.text!
        let email = emailField.text!
        let pasword = passwordField.text!
        if(signup){
            if(!name.isEmpty && !email.isEmpty && !pasword.isEmpty){
                
                MMProgressHUD.show(withStatus: "Загрузка")
                self.loginVM = LoginViewModel()
                if self.loginVM?.isConnnected() == true {
                    self.loginVM?.accountCreateWithEmail(name: name, email: email, password: pasword, onCompletion: { (result) in
                        if result != nil{
                            let fillingVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FillingVC") as! FillingVC
                            fillingVC.authDataResult = result!.user
                            
                            self.appDelegate.window?.rootViewController = UINavigationController(rootViewController: fillingVC)
                            self.appDelegate.window?.makeKeyAndVisible()
                        }else{
                            self.errorAlert(title: "Ошибка", message: "Пользователь с таким email уже зарегистрирован")
                        }
                    })
                }else{
                    MMProgressHUD.dismissWithError("Нет соединения")
                }
            } else {
                errorAlert(title: "Ошибка", message: "Заполните все поля")
            }
        } else {
            if(!email.isEmpty && !pasword.isEmpty){
                MMProgressHUD.show(withStatus: "Загрузка")
                self.loginVM = LoginViewModel()
                if self.loginVM?.isConnnected() == true{
                    self.loginVM?.siginWithEmail(email: email, password: pasword, completion: { (error) in
                        if error == nil {
                            let tabBarC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarCont") as! TabBarCont
                            self.appDelegate.window?.rootViewController = UINavigationController(rootViewController: tabBarC)
                            MMProgressHUD.dismiss(withSuccess: "Выполнено")
                        } else if error != nil {
                            self.errorAlert(title: "Ошибка", message: "Не правильный адрес электронной почты или пароль")
                        }})
                }else{
                    MMProgressHUD.dismissWithError("Нет соединения")
                }
            } else {
                errorAlert(title: "Ошибка", message: "Заполните все поля")
            }
        }
        return true
    }
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
}

//MARK: - Extensions
extension UIViewController {
    func hideKeyboard(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}






