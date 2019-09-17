//
//  BookedModel.swift
//  BffAdmin
//
//  Created by Mairambek on 08/08/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import Foundation
import ObjectMapper
import Firebase

class BookedModel: NSObject,Mappable {
 
    var isActive: String = ""
    var stadiumId: String = ""
    var time: String = ""
    var userId: String = ""
    var userName: String = ""
    var id: String = ""
    var bookedTableId: String = ""
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {

        isActive <- map["isActive"]
        stadiumId <- map["stadiumId"]
        time <- map["time"]
        userId <- map["userId"]
        userName <- map["userName"]
        bookedTableId <- map["bookedTableId"]
        id <- map["id"]
        
    }
    
}
