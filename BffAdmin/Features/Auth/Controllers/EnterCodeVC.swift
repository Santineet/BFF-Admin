//
//  EnterCodeVC.swift
//  BffAdmin
//
//  Created by Mairambek on 12/06/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import MMProgressHUD

class EnterCodeVC: UIViewController, UITextFieldDelegate {
    
    //    MARK:    Outlets
    //    MARK:    Выходные точки
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var codeSendButton: UIButton!
    
    var loginVM: LoginViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.codeSendButton.layer.cornerRadius = 5
        self.codeTextField.delegate = self
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)   
        
    }
    
    @IBAction func codeSendButton(_ sender: Any) {
        guard let code = codeTextField.text, codeTextField.text?.count == 6  else {
            return
        }
        
        if code.isValidNumber(testStr: code) == false {
            MMProgressHUD.show()
            MMProgressHUD.dismissWithError("This is not number")
        } else {
            MMProgressHUD.show()
            let verificationID: String = UserDefaults.standard.string(forKey: "authVerificationID")!
            let credential: PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: codeTextField.text!)
            
            self.loginVM = LoginViewModel()
            self.loginVM?.authWithPhoneNumber(credential: credential, completion: { (authDataResult, data, error) in
                MMProgressHUD.show()
                guard error == nil else{
                    MMProgressHUD.dismissWithError(error?.localizedDescription)
                    print(error?.localizedDescription as Any)
                    return
                }
                if data != nil {
                    let fillingVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FillingVC") as! FillingVC
                    fillingVC.authDataResult = authDataResult?.user
                    MMProgressHUD.dismiss(withSuccess: "VerificationID valid")
                    print("pushViewController")
                    self.navigationController?.pushViewController(fillingVC, animated: true)
                    
                } else {
                    
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
        
    }
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
}
