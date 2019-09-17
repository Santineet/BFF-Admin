//
//  ProfileInfo.swift
//  BffAdmin
//
//  Created by Mairambek on 19/06/2019.
//

import Foundation
import ObjectMapper

class ProfileInfo:NSObject,Mappable {
    
    var id:String = ""
    var name:String = ""
    var numberPhone:String = ""
    var originalImageUrl:String = ""
    var previewImageUrl:String = ""
    var status:String = ""
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        numberPhone <- map["phoneNumber"]
        originalImageUrl <- map["imageUrl.original"]
        previewImageUrl <- map["imageUrl.preview"]
        status <- map["status"]
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let profileInfo = object as? ProfileInfo {
            return self.id == profileInfo.id
        } else {
            return false
        }
    }
    
}
