//
//  NewProfileRepository.swift
//  BffAdmin
//
//  Created by Mairambek on 03/09/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import Foundation
import RxSwift

class NewProfileRepistory: NSObject {
    
    //    MARK:    Function to retrieve profile information from databse.
    //    MARK:    Функция для получения информации о профиле из базы данных.
    func getProfileInfo() -> Observable<ProfileInfo>{
        return Observable.create({ (observer) -> Disposable in
            ApiService.sharedInstance.getProfileInfo(onComplation: { (profileInfo) in
                observer.onNext(profileInfo)
                observer.onCompleted()
            }, onError: { (error) in
                observer.onError(NSError.init())
            })
            return Disposables.create()
        })
    }
    
    //    MARK:    Function to retrieve stadiums from databse.
    //    MARK:    Функция для получения информации о stadiums из базы данных.
    func getStadiums() -> Observable<(EventType, Stadium)>{
        return Observable.create({ (observer) -> Disposable in
            ApiService.sharedInstance.getStadiums(onComplation: { (type, stadium)  in
                observer.onNext((type, stadium))
            }, onError: { (error) in
                observer.onError(NSError.init())
            })
            return Disposables.create()
        })
    }
    
    
}
