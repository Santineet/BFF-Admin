//
//  LoginViewModel.swift
//  BffAdmin
//
//  Created by Mairambek on 18/07/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import Foundation
import Firebase

class LoginViewModel: NSObject{
    
    //    MARK:    Variables
    //    MARK:    Переменные
    var originImageUrl: String = ""
    var previewImageUrl: String = ""

    var reachability:Reachability?

    //    MARK:    Function to create an email account
    //    MARK:    Функция для созданя аккаунта email
    func accountCreateWithEmail(name:String, email: String, password: String, onCompletion: @escaping (AuthDataResult?) -> Void){
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if error == nil {
                if let result = result{
                    print(result.user.uid)
                    let ref = Database.database().reference().child("users")
                    ref.child(result.user.uid).updateChildValues(["name" : name,"email" : email])
//                    onCompletion(result)
                }
            }
            onCompletion(result)

        }
    }
    
    //    MARK:   Функция для входа в аккаунт email
    
    func siginWithEmail(email: String, password: String,completion: @escaping (Error?) -> ()){
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil{
                completion(error)
                return
            }else{
                completion(nil)
            } 
        }
    }
    
    //    MARK:    Function to authorization with PhoneNumber.
    //    MARK:    Функция для авторизации через PhoneNumber.
    func verifyPhoneNumber(verificationID:String, completion: @escaping (Data?, Error?) -> ()) {
        if self.isConnnected() == true {

            PhoneAuthProvider.provider().verifyPhoneNumber(verificationID, uiDelegate: nil) { (verificationID, error) in
                if error != nil {
                    completion(nil, error)
                }
                if verificationID != nil {
                    UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                    completion(Data.init(), nil)
                }
            }
        } else {
            completion(nil, NSError.init(message: "Not Connection"))
        }
    }
    
    //    MARK:    Internet check function.
    //    MARK:    Функция для проверки интернета.
    func isConnnected() -> Bool{
        do {
            try reachability = Reachability.init()
            
            if (self.reachability?.connection) == .wifi || (self.reachability?.connection) == .cellular {
                return true
            } else if self.reachability?.connection == .unavailable {
                return false
            } else if self.reachability?.connection == .none {
                return false
            } else {
                return false
            }
        }catch{
            return false
        }
    }
    
    
    //    MARK:    Function to log out.
    //    MARK:    Функция для выхода из системы.
    func logOut() -> String {
        do {
            UserDefaults.standard.removeObject(forKey: "isLoggedIn")
            try Auth.auth().signOut()
            LoginLogoutManager.instance.updateRootVC()
            return "Success"
        } catch let signOutError as NSError {
            return signOutError.localizedDescription
        }
    }
    
    
    //    MARK:    Function to authorization with phone number.
    //    MARK:    Функция для авторизации через номер телефона.
    func authWithPhoneNumber(credential:AuthCredential, completion: @escaping (AuthDataResult?, Data?, Error?) -> ()) {
        if self.isConnnected() == true {
            Auth.auth().signIn(with: credential) { (authDataResult, error) in
                if error != nil {
                    completion(nil, nil, error)
                    return
                }
                if authDataResult != nil {
                    completion(authDataResult, Data.init(), nil)
                }
            }
        } else {
            completion(nil, nil, NSError.init(message: "Not Connection"))
        }
    }
    
    //    MARK:    Reduce(compress) image size before upload and save data to Firestore.
    //    MARK:    Уменьшить (сжать) размер изображения и сохранить введенные данные в Firestore.
    func compressingImageWithSaveProfileInfo(imageToCompressing:UIImage?,data:[String:String],completion: @escaping (Data?, Error?) -> ()){
        
        let uid = Auth.auth().currentUser!.uid
        let originalImageStorRef = Storage.storage().reference().child("profileImages/"+"\(uid.lowercased())"+"Original"+".png")
        let previewImageStorRef = Storage.storage().reference().child("profileImages/"+"\(uid.lowercased())"+"Preview"+".png")
        if self.isConnnected() == true {
            if let originalImage = imageToCompressing!.jpeg(.original), let previewImage = imageToCompressing!.jpeg(.preview) {
                if self.isConnnected() == true {
                    originalImageStorRef.putData(originalImage, metadata: nil
                        , completion: { (_, error) in
                            if error != nil{
                                completion(nil, nil)
                                return
                            }
                            if self.isConnnected() == true {
                                originalImageStorRef.downloadURL(completion: { (url, error) in
                                    if error != nil{
                                        completion(nil, nil)
                                        return
                                    }
                                    self.originImageUrl = url!.absoluteString
                                    
                                    if self.isConnnected() == true {
                                        previewImageStorRef.putData(previewImage, metadata: nil, completion: { (_, error) in
                                            if error != nil{
                                                completion(nil, nil)
                                                return
                                            }
                                            if self.isConnnected() == true {
                                                previewImageStorRef.downloadURL(completion: { (url, error) in
                                                    if error != nil{
                                                        completion(nil, nil)
                                                        return
                                                    }
                                                    self.previewImageUrl = url!.absoluteString
                                                    let saveData = ["userNumber":data["userNumber"],"userName":data["userName"],"userStatus":data["userStatus"],"originalUrl":self.originImageUrl,"previewUrl":self.previewImageUrl] as! [String:String]
                                                    
                                                    if self.isConnnected() == true {
                                                        self.saveProfileData(user: Auth.auth().currentUser, data: saveData, completion: { ( error) in
                                                            if error != nil{
                                                                completion(nil, error)
                                                                return
                                                            } else {
                                                                completion(nil, nil)
                                                            }
                                                            
                                                        })
                                                    } else {
                                                        completion(nil, error)
                                                    }
                                                })
                                            } else {
                                                completion(nil, error)
                                            }
                                        })
                                    } else {
                                        completion(nil, error)
                                    }
                                })
                            } else {
                                completion(nil, error)
                            }
                    })
                } else {
                    completion(nil, NSError.init())
                }
            }
        } else {
            completion(nil, NSError.init())
        }
    }
    
    //    MARK:    Function to save changed profile information.
    //    MARK:    Функция для сохранения измененных информаций о профиле.
    func saveProfileData(user: User?,data:[String:String],completion: @escaping (Error?) -> ()){
        guard let user = user else {
            return
        }
        
        let uid = user.uid
        var params = [
            "phoneNumber":data["userNumber"]!,
            "name":data["userName"]!,
            "status":data["userStatus"]!
            ] as [String : Any]
        if let originUrl = data["originalUrl"], let prewUrl = data["previewUrl"] {
            params["imageUrl"] = ["original":originUrl, "preview":prewUrl]
        }
        
        FIRRefManager.instance.adminsRef.document(uid).setData(params, completion: { (error) in
            if error != nil{
                completion(error)
                return
            } else {
                completion(nil)
            }
        })
    }
    
    


}
