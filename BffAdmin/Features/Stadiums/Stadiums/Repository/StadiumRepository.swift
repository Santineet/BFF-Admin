//
//  StadiumRepository.swift
//  BffAdmin
//
//  Created by Mairambek on 16/07/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import Foundation
import RxSwift

class StadiumRepository: NSObject {
    
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


