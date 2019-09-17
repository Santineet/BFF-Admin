
//
//  Stadium.swift
//  BffAdmin
//
//  Created by Mairambek on 18/07/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import FirebaseFirestore
import MMProgressHUD
import SDWebImage

class StadiumEditViewModel: NSObject {
    
    let dispose = DisposeBag()
    
    //    MARK:    Function to remove stadium
    //    MARK:    Функция для удаления стадиона в StadiumEdit
    func removeStadium(stadiumId: String){
        FIRRefManager.instance.stadiumsRef.whereField("stadiumId", isEqualTo: stadiumId).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    document.reference.delete()
                }
            }
        }
    }
    
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
                        if error != nil{
                            print(error?.localizedDescription as Any)
                            return
                        }
                        originalImageStorRef.downloadURL(completion: { (url, error) in
                            if error != nil{
                                print(error?.localizedDescription as Any)
                                return
                            }
                            original = url!.absoluteString
                            previewImageStorRef.putData(previewImageData, metadata: nil, completion: { (_, error) in
                                if error != nil{
                                    print(error?.localizedDescription as Any)
                                    return
                                }
                                previewImageStorRef.downloadURL(completion: { (url, error) in
                                    if error != nil{
                                        print(error?.localizedDescription as Any)
                                        return
                                    }
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
    func saveStadiumData(user: User?,stadiumName:String?,description:String?,location:GeoPoint?,stadiumId:String?,imagesArray:[[String:String?]],completion: @escaping (Error?) -> ()) {
        let uid = Auth.auth().currentUser?.uid
        let params = [
            "name":stadiumName!,
            "description":description!,
            "userId": uid!,
            "location": location!,
            "stadiumId": stadiumId!,
            "images": imagesArray
            ] as [String : Any]
        
        FIRRefManager.instance.stadiumsRef.document(stadiumId!).setData(params, completion: { (error) in
            if error != nil{
                completion(error)
                return
            }else{
                completion(nil)
            }
        })
        
    }
    
    func imageDownload(images:[Image], onCompletion: @escaping ([UIImage]) -> Void){
        var allImages = [UIImage]()
        
        for image in images {
            print(image)
            SDWebImageManager.shared.loadImage(with: URL(string: image.originalUrl!), options: .continueInBackground, progress: { (recieved, expected, nil) in
                print(recieved,expected)
            }, completed: { (downloadedImage, data, error, SDImageCacheType, true, imageUrlString) in
                if downloadedImage != nil{
                     allImages.append(downloadedImage!)
                    if allImages.count == images.count {
                        onCompletion(allImages)
                    }
                }
            }
        )}
    }
}


