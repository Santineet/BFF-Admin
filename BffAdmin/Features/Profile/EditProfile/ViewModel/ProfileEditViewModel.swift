//
//  ProfileEditViewModel.swift
//  BffAdmin
//
//  Created by Mairambek on 17/07/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase

class ProfileEditViewModel: NSObject {
    
    //    MARK:    Variables
    //    MARK:    Переменные
    var originImageUrl: String = ""
    var previewImageUrl: String = ""
    
    var reachability: Reachability?
    
    
    //    MARK:    Internet check function.
    //    MARK:    Функция для проверки интернета.
    func isConnected() -> Bool{
        do {
            try reachability = Reachability.init()
            
            if (reachability?.connection) == .wifi || (self.reachability?.connection) == .cellular {
                return true
            } else if reachability?.connection == .unavailable {
                return false
            } else if reachability?.connection == .none {
                return false
            } else {
                return false
            }
        }catch{
            return false
        }
    }
    
    
    //    MARK:    Reduce(compress) image size before upload
    //    MARK:    Уменьшить (сжать) размер изображения перед загрузкой
    func compressingImageWithSaveProfileInfo(selectedImage:UIImage?,data:[String:String],completion: @escaping (Data?, Error?) -> ()){
        
        let uid = Auth.auth().currentUser!.uid
        let originalImageStorRef = Storage.storage().reference().child("profileImages/"+"\(uid.lowercased())"+"Original"+".png")
        let previewImageStorRef = Storage.storage().reference().child("profileImages/"+"\(uid.lowercased())"+"Preview"+".png")
        if self.isConnected() == true {
            if let originalImage = selectedImage!.jpeg(.original), let previewImage = selectedImage!.jpeg(.preview) {
                if self.isConnected() == true {
                    originalImageStorRef.putData(originalImage, metadata: nil
                        , completion: { (_, error) in
                            if error != nil{
                                completion(nil, nil)
                                return
                            }
                            if self.isConnected() == true {
                                originalImageStorRef.downloadURL(completion: { (url, error) in
                                    if error != nil{
                                        completion(nil, nil)
                                        return
                                    }
                                    self.originImageUrl = url!.absoluteString
                                    
                                    if self.isConnected() == true {
                                        previewImageStorRef.putData(previewImage, metadata: nil, completion: { (_, error) in
                                            if error != nil{
                                                completion(nil, nil)
                                                return
                                            }
                                            if self.isConnected() == true {
                                                previewImageStorRef.downloadURL(completion: { (url, error) in
                                                    if error != nil{
                                                        completion(nil, nil)
                                                        return
                                                    }
                                                    self.previewImageUrl = url!.absoluteString
                                                    let saveData = ["userNumber":data["userNumber"],"userName":data["userName"],"userStatus":data["userStatus"],"originalUrl":self.originImageUrl,"previewUrl":self.previewImageUrl] as! [String:String]
                                                    
                                                    if self.isConnected() == true {
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
        } else { completion(nil, NSError.init())}
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
    
}
