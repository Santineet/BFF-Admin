//
//  StadiumViewModel.swift
//  BffAdmin
//
//  Created by Mairambek on 16/07/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class StadiumViewModel: NSObject {
    //    MARK:    Variables
    //    MARK:    Переменные
    let dispose = DisposeBag()
    
    let stadiumBR = BehaviorRelay<(EventType, Stadium)>(value: (EventType.Added, Stadium()))
    let errorBR = BehaviorRelay<Error>(value: NSError.init())
    
    //    MARK:    ProfileRepistory object
    //    MARK:    Объект от ProfileRepistory
    let stadiumRepository = StadiumRepository()
    
    //    MARK:    Function to retrieve profile information from ProfileRepistory.
    //    MARK:    Функция для получения информации о профиле из ProfileRepistory.
    func getStadiums() {
        stadiumRepository.getStadiums()
            .subscribe(onNext: { (type, stadium) in
                self.stadiumBR.accept((type, stadium))
            }, onError: { (error) in
                self.errorBR.accept(error)
            }).disposed(by: self.dispose)
    }
    
    
}
