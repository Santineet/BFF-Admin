//
//  StadiumInfo.swift
//  BffAdmin
//
//  Created by Mairambek on 18/07/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

//import Foundation
//import ObjectMapper
//import Firebase
//
//class StadiumInfo: NSObject,Mappable {
//    
//    var id:String = ""
//    var stadName: String = ""
//    var stadStatus: String = ""
//    var stadDescription: String = ""
//    var userID: String = ""
//    var points: GeoPoint?
//    var images = [Image]()
//    
//    required convenience init?(map: Map) {
//        self.init()
//    }
//    
//    func mapping(map: Map) {
//        userID <- map["userId"]
//        stadName <- map["name"]
//        stadStatus <- map["status"]
//        stadDescription <- map["description"]
//        points <- map["location"]
//        
//        if let images = map.JSON["images"] as? [[String: String]] {
//            self.images.removeAll()
//            for img in images {
//                let image = Image()
//                image.originalUrl = img["original"]
//                image.previewUrl = img["preview"]
//                self.images.append(image)
//            }
//        }
//    }
//    
//    override func isEqual(_ object: Any?) -> Bool {
//        if let profileInfo = object as? ProfileInfo {
//            return self.id == profileInfo.id
//        } else {
//            return false
//        }
//    }
//}
