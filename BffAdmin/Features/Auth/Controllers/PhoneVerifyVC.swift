//
//  PhoneVerifyVC.swift
//  BffAdmin
//
//  Created by Mairambek on 12/06/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import UIKit
import Firebase
import MMProgressHUD

class PhoneVerifyVC: UIViewController, UITextFieldDelegate {

    //    MARK:    Outlets
    //    MARK:    Выходные точки
    @IBOutlet weak var numberField: UITextField!
    @IBOutlet weak var sendCodeButton: UIButton!
    @IBOutlet weak var countryCode: UILabel!
    
    var loginVM: LoginViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        self.numberField.delegate = self
        self.view.backgroundColor = UIColor(white: 0.95, alpha: 1)
 
    }
    
    //MARK: - Method
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        numberField.resignFirstResponder()
        return true
    }
    
    @IBAction func sendButton(_ sender: Any) {
        
        let alert = UIAlertController(title: "Номер телефона", message: "Это ваш номер телефона? \n \(countryCode.text! + numberField.text!)", preferredStyle: .alert)
        let action = UIAlertAction(title: "Да", style: UIAlertAction.Style.default) { (UIAlertAction) in
            self.sendCodeButton.isUserInteractionEnabled = false
            self.sendCodeButton.alpha = 0.5
            
            let verificationID: String = self.countryCode.text! + self.numberField.text!
            
            self.loginVM = LoginViewModel()
            self.loginVM?.verifyPhoneNumber(verificationID: verificationID, completion: { (data, error) in
                
                guard error == nil else{
                    self.sendCodeButton.alpha = 1
                    self.sendCodeButton.isUserInteractionEnabled = true
                    self.sendCodeButton.isEnabled = true
                    
                    MMProgressHUD.dismissWithError(error?.localizedDescription)
                    if self.loginVM?.logOut() == "Success" {
                        LoginLogoutManager.instance.updateRootVC()
                    } else {
                        MMProgressHUD.show()
                        
                        MMProgressHUD.dismissWithError(self.loginVM?.logOut())
                        LoginLogoutManager.instance.updateRootVC()
                    }
                    return
                }
                
                if data != nil {
                    self.sendCodeButton.alpha = 1
                    self.sendCodeButton.isUserInteractionEnabled = true
                    self.sendCodeButton.isEnabled = true
                    let enterCodeVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EnterCodeVC") as! EnterCodeVC
                    self.numberField.text = ""
                    MMProgressHUD.dismiss(withSuccess: "Number confirmed")
                    print("pushViewController")
                    self.navigationController?.pushViewController(enterCodeVC, animated: true)
                } else {
                    self.sendCodeButton.alpha = 1
                    self.sendCodeButton.isUserInteractionEnabled = true
                    self.sendCodeButton.isEnabled = true
                    
                    if self.loginVM?.logOut() == "Success" {
                        MMProgressHUD.dismissWithError("Data is nil")
                        LoginLogoutManager.instance.updateRootVC()
                    } else {
                        MMProgressHUD.dismissWithError(self.loginVM?.logOut())
                        LoginLogoutManager.instance.updateRootVC()
                    }
                }
            })
        }
        let cancel = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
}


