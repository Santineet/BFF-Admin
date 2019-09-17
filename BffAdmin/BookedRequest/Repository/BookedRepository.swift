//
//  BookedRepository.swift
//  BffAdmin
//
//  Created by Mairambek on 08/08/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import Foundation
import RxSwift

class BookedRepository: NSObject {
    
    //    MARK:    Function to retrieve Notification information from databse.
    //    MARK:    Функция для получения информации о бронированиях из базы данных.
    func getBookedModel() ->  Observable<(EventType, BookedModel)>{
        return Observable.create({ (observer) -> Disposable in
            ApiService.sharedInstance.getBookedRequest(onComplation: { (type, booked)  in
                observer.onNext((type, booked)) 
            }, onError: { (error) in
                observer.onError(NSError.init())
            })
            return Disposables.create()
        })
    }
    
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




