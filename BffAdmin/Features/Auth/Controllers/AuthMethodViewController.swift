//
//  AuthMethodViewController.swift
//  BffAdmin
//
//  Created by Mairambek on 12/06/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import UIKit

class AuthMethodViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

         self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "bffAdminImage")!))
       
    }
    
    @IBAction func signInEmailButton(_ sender: Any) {
  
        let emailVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
        self.navigationController?.pushViewController(emailVC, animated: true)
    
    }
    
    @IBAction func signInPhoneButton(_ sender: Any) {
        let phoneVerifyVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhoneVerifyVC") as! PhoneVerifyVC
        self.navigationController?.pushViewController(phoneVerifyVC, animated: true)
    }
    
}



