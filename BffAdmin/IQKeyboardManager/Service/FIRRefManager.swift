//
//  FIRRefManager.swift
//  BffClient
//
//  Created by Avazbek Kodiraliev on 6/12/19.
//  Copyright © 2019 Avazbek Kodiraliev. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

enum Route:String{
    case admins
    case stadiums
    case bookingTable
    case bookingRequest
}


class FIRRefManager: NSObject {

    static let instance = FIRRefManager()
    let adminsRef = Firestore.firestore().collection(Route.admins.rawValue)
    let stadiumsRef = Firestore.firestore().collection(Route.stadiums.rawValue)
    let bookingTableRef = Firestore.firestore().collection(Route.bookingTable.rawValue)
    let bookingRequestRef = Firestore.firestore().collection(Route.bookingRequest.rawValue)
}
