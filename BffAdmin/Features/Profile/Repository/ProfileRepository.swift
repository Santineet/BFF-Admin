//
//  ProfileRepository.swift
//  BffAdmin
//
//  Created by Mairambek on 17/07/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import Foundation
import RxSwift

class ProfileRepistory: NSObject {
    
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
}
