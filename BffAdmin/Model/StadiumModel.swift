//
//  StadiumModel.swift
//  BffAdmin
//
//  Created by Mairambek on 03/07/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import Foundation
import ObjectMapper
import Firebase

var newLocation:GeoPoint? 

class Stadium: NSObject,Mappable {
    var id:String = ""
    var stadName: String = ""
    var stadStatus: String = ""
    var stadDescription: String = ""
    var userID: String = ""
    var points: GeoPoint?
    var images = [Image]()
    var startWorkTime: String = ""
    var endWorkTime: String = ""
    var price: String = ""
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    
    func mapping(map: Map) {
        userID <- map["userId"]
        stadName <- map["name"]
        stadStatus <- map["status"]
        stadDescription <- map["description"]
        points <- map["location"]
        startWorkTime <- map["workTime.Start"]
        endWorkTime <- map["workTime.End"]
        price <- map["price"]
        
        
        if let images = map.JSON["images"] as? [[String: String]] {
            self.images.removeAll()
            for img in images {
                let image = Image()
                image.originalUrl = img["original"]
                image.previewUrl = img["preview"]
                self.images.append(image)
            }
        }
        
    }
    
}


class Coordinate: NSObject {
    @objc dynamic var lat: Double = 0.0
    @objc dynamic var long: Double = 0.0
}

class Trip: NSObject, Mappable {
    @objc dynamic var fromCoor: Coordinate?
    @objc dynamic var whereCoor: Coordinate?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        if let fromGeopoint = map.JSON["from"] as? GeoPoint {
            let fromCoor = Coordinate()
            fromCoor.lat = fromGeopoint.latitude
            fromCoor.long = fromGeopoint.longitude
            self.fromCoor = fromCoor
        }
        if let whereGeopoint = map.JSON["where"] as? GeoPoint {
            let whereCoor = Coordinate()
            whereCoor.lat = whereGeopoint.latitude
            whereCoor.long = whereGeopoint.longitude
            self.whereCoor = whereCoor
        }
    }
}

class Image: NSObject, Mappable {
    
    var previewUrl: String?
    var originalUrl: String?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        self.previewUrl <- map["preview"]
        self.originalUrl <- map["original"]
    }
    
}

