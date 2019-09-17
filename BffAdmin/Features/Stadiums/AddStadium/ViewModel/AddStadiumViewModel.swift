//
//  AddStadiumViewModel.swift
//  BffAdmin
//
//  Created by Mairambek on 16/07/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import RxSwift
import RxCocoa
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import SwiftLocation
import FirebaseFirestore
import MMProgressHUD

class AddStadiumViewModel: NSObject {
    //    MARK:    Variables
    //    MARK:    Переменные
    
    var reachability: Reachability?

    //    MARK:    Reduce(compress) image size before upload
    //    MARK:    Уменьшить (сжать) размер изображения перед загрузкой
    func uploadImagesToFirestore (images:[UIImage], onCompletion: @escaping ([[String:String]]) -> Void) {
        var imagesURL = [[String:String]]()
        for image in images {
            var original: String = ""
            var preview: String = ""
            let originalImageStorRef = Storage.storage().reference().child("stadiumImages/"+"\(String(describing:image.description.lowercased()))"+"Original"+".png")
            let previewImageStorRef = Storage.storage().reference().child("stadiumImages/"+"\(String(describing:   image.description.lowercased()))"+"Preview"+".png")
            if let originalImageData = image.jpeg(.original), let previewImageData = image.jpeg(.preview) {
                originalImageStorRef.putData(originalImageData, metadata: nil
                    , completion: { (_, error) in
                        print("originalImageStorRef")
                        if error != nil{
                            print(error?.localizedDescription as Any)
                            return
                        }
                        originalImageStorRef.downloadURL(completion: { (url, error) in
                            if error != nil{
                                print(error?.localizedDescription as Any)
                                return
                            }
                            print("originalImageStorRef", url!)
                            original = url!.absoluteString
                            previewImageStorRef.putData(previewImageData, metadata: nil, completion: { (_, error) in
                                if error != nil{
                                    print(error?.localizedDescription as Any)
                                    return
                                }
                                print("previewImageStorRef")
                                previewImageStorRef.downloadURL(completion: { (url, error) in
                                    if error != nil{
                                        print(error?.localizedDescription as Any)
                                        return
                                    }
                                    print("previewImageStorRef")
                                    preview = url!.absoluteString
                                    
                                    imagesURL.append(["original" :  original,"preview":preview])
                                    print(">>>>>>>", imagesURL.count)
                                    if imagesURL.count == images.count{
                                        onCompletion(imagesURL)
                                    }
                                })
                            })
                        })
                })
            }
        }
        
    }
    
    //   MARK:    Function to save changed stadium information.
    //   MARK:    Функция для сохранения измененных информаций о стадионе.
    func saveStadiumData(user: User?,stadiumName:String?,description:String?,location:GeoPoint?,workTime:[String:String?],price:String?,interval:Int?,startTime:Date?,imagesArray:[[String:String?]],completion: @escaping (Error?) -> ()) {
        let uid = Auth.auth().currentUser?.uid
        let stadiumId = FIRRefManager.instance.stadiumsRef.document().documentID
        let params = [
            "name":stadiumName!,
            "description":description!,
            "userId": uid!,
            "location": location!,
            "stadiumId": stadiumId,
            "images": imagesArray,
            "workTime": workTime,
            "price": price!
            ] as [String : Any]
        
        FIRRefManager.instance.stadiumsRef.document(stadiumId).setData(params, completion: { (error) in
            if error != nil{
               completion(error)
                return
            }else{
                completion(nil)
            }
        })
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d"
        var hours = [[String: Any]]()
        for i in 0...interval! {
            
            let bookedTime =  Calendar.current.date(byAdding: .hour, value: i, to: startTime!)
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "H:mm"
            
            let bookedTimeFormat = timeFormatter.string(from: bookedTime!)
            let hoursMap = [ "booked": false,"hour": bookedTimeFormat ] as [String : Any]
            hours.append(hoursMap)
        }
        
        let bookingId = FIRRefManager.instance.bookingTableRef.document().documentID
        var days = [[String : Any]]()
        for i in 0...7 {
            let day = formatter.string(from: Calendar.current.date(byAdding: .day, value: i, to: date)!)
            let timeMap = ["date": day, "hours": hours] as [String : Any]
            days.append(timeMap)
        }

        let bookingParams = [
            "days": days,
            "stadiumId": stadiumId,
            "bookingId": bookingId
            ] as [String : Any]
        
        FIRRefManager.instance.bookingTableRef.document(bookingId).setData(bookingParams)
        
    }
    
    //    MARK:    Internet check function.
    //    MARK:    Функция для проверки интернета.
    func isConnnected() -> Bool{
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
    
    
}



