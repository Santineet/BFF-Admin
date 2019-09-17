//
//  StadiumInfoRepository.swift
//  BffAdmin
//
//  Created by Mairambek on 18/07/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import Foundation
import RxSwift

class StadiumInfoRepository: NSObject {
    
    //    MARK:    Function to retrieve stadiumInfo from databse.
    //    MARK:    Функция для получения информации о stadiumInfo из базы данных.
    func getStadiumInfo(stadiumID:String) -> Observable<Stadium>{
        return Observable.create({ (observer) -> Disposable in
            ApiService.sharedInstance.getStadiumInfo(stadiumID: stadiumID, onComplation: { (stadiumInfo) in
                observer.onNext(stadiumInfo)
                observer.onCompleted()
            }, onError: { (error) in
                observer.onError(NSError.init())
            })
            return Disposables.create()
        })
    }
}
