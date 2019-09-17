//
//  StadiumInfoViewModel.swift
//  BffAdmin
//
//  Created by Mairambek on 18/07/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class StadiumInfoViewModel: NSObject {
    
    let dispose = DisposeBag()

    let stadiumInfoBR = BehaviorRelay<Stadium>(value: Stadium())
    let errorBR = BehaviorRelay<Error>(value: NSError.init())
    
    //    MARK:    ProfileRepistory object
    //    MARK:    Объект от ProfileRepistory
    let stadiumInfoRepository = StadiumInfoRepository()
    
    //    MARK:    Function to retrieve profile information from StadiumRepository.
    //    MARK:    Функция для получения информации о профиле из StadiumRepository.
    func getStadiumInfo(stadiumID:String?) {
        stadiumInfoRepository.getStadiumInfo(stadiumID: stadiumID!)
            .subscribe(onNext: { (stadiumInfo) in
                self.stadiumInfoBR.accept(stadiumInfo)
            }, onError: { (error) in
                self.errorBR.accept(error)
            }).disposed(by: self.dispose)
    }
    
}
