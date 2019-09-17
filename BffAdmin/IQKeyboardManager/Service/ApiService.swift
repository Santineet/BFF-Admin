//
//  ApiService.swift
//  BffAdmin
//
//  Created by Mairambek on 16/07/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import Foundation
import Firebase
import ObjectMapper
import FirebaseAuth
import FirebaseDatabase


enum EventType {
    case Added
    case Changed
    case Removed
}

class ApiService: NSObject {
    
    //    MARK:    Singlton
    //    MARK:    Одиночка
    static let sharedInstance = ApiService()
    
    //    MARK:    Function to retrieve(query) stadiums from databse.
    //    MARK:    Функция для получения(запрос) информации о stadiums из базы данных.
    func getStadiums(onComplation:@escaping((EventType, Stadium) -> Void),onError:@escaping((String?) -> Void)) {

        FIRRefManager.instance.stadiumsRef.whereField("userId", isEqualTo: (Auth.auth().currentUser?.uid) as Any).addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else{return}
            if error != nil{
                print(error?.localizedDescription as Any)
                return
            } else {
                snapshot.documentChanges.forEach({ (documentChange) in
                    let value = documentChange.document.data()
                    if documentChange.type == .added {
                        if let stadium = Mapper<Stadium>().map(JSON: value){
                            stadium.id = documentChange.document.documentID
                            onComplation(.Added ,stadium)
                        }
                    } else if documentChange.type == .modified {
                        if let stadium = Mapper<Stadium>().map(JSON: value){
                            stadium.id = documentChange.document.documentID
                            onComplation(.Changed ,stadium)
                        }
                    } else if documentChange.type == .removed {
                        if let stadium = Mapper<Stadium>().map(JSON: value){
                            stadium.id = documentChange.document.documentID
                            onComplation(.Removed ,stadium)
                        }
                    }
                })
            }
        }
    }
    
    //    MARK:    Function to retrieve(query) profile information from databse.
    //    MARK:    Функция для получения(запрос) информации о профиле из базы данных.
    func getProfileInfo(onComplation:@escaping((ProfileInfo) -> Void),onError:@escaping((String?) -> Void)) {
        FIRRefManager.instance.adminsRef.document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            guard let snapshot = document else{return}
            if let value = snapshot.data(), let profileInfo = Mapper<ProfileInfo>().map(JSON: value){
                profileInfo.id = snapshot.documentID
                if error != nil{
                    print(error?.localizedDescription as Any)
                    return
                } else {
                    onComplation(profileInfo)
                }
            }
        }
    }
    
    
    //    MARK:    Function to retrieve(query) stadium information from databse.
    //    MARK:    Функция для получения(запрос) информации о stadium из базы данных.
    func getStadiumInfo(stadiumID:String?,onComplation:@escaping((Stadium) -> Void),onError:@escaping((String?) -> Void)) {
        FIRRefManager.instance.stadiumsRef.document(stadiumID!).getDocument { (document, error) in
            guard let snapshot = document else{return}
            if let value = snapshot.data(), let stadiumInfo = Mapper<Stadium>().map(JSON: value){
                stadiumInfo.id = snapshot.documentID
                if error != nil{
                    print(error?.localizedDescription as Any)
                    return
                } else {
                    onComplation(stadiumInfo)
                }
            }
        }
    }
    
    //    MARK:    Function to retrieve(query) notification information from databse.
    //    MARK:    Функция для получения(запрос) информации о бронированиях из базы данных.

    func getBookedRequest(onComplation:@escaping((EventType, BookedModel) -> Void),onError:@escaping((String?) -> Void)) {
        
        FIRRefManager.instance.bookingRequestRef.whereField("userId", isEqualTo: (Auth.auth().currentUser?.uid) as Any).whereField("isActive", isEqualTo: false).addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else{return}
            if error != nil{
                print(error?.localizedDescription as Any)
                return
            } else {
                snapshot.documentChanges.forEach({ (documentChange) in
                    let value = documentChange.document.data()
                    if documentChange.type == .added {
                        if let bookedInfo = Mapper<BookedModel>().map(JSON: value){
                            bookedInfo.id = documentChange.document.documentID
                            onComplation(.Added ,bookedInfo)
                        }
                    } else if documentChange.type == .modified {
                        if let bookedInfo = Mapper<BookedModel>().map(JSON: value){
                            bookedInfo.id = documentChange.document.documentID
                            onComplation(.Changed ,bookedInfo)
                        }
                    } else if documentChange.type == .removed {
                        if let bookedInfo = Mapper<BookedModel>().map(JSON: value){
                            bookedInfo.id = documentChange.document.documentID
                            onComplation(.Removed ,bookedInfo)
                        }
                    }
                })
            }
        }
    }
    
    
}


