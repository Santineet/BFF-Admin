//
//  BookedViewModel.swift
//  BffAdmin
//
//  Created by Mairambek on 08/08/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import UIKit
import RxSwift
import Firebase
import RxCocoa

class BookedViewModel: NSObject {
    //    MARK:    Variables
    //    MARK:    Переменные
    let dispose = DisposeBag()
    
    let bookedBR = BehaviorRelay<(EventType, BookedModel)>(value: (EventType.Added, BookedModel()))
    let stadiumInfoBR = BehaviorRelay<Stadium>(value: Stadium())

    let errorBR = BehaviorRelay<Error>(value: NSError.init())

    //    MARK:    ProfileRepistory object
    //    MARK:    Объект от ProfileRepistory
    let bookedRepository = BookedRepository()
    
    //    MARK:    Function to retrieve profile information from ProfileRepistory.
    //    MARK:    Функция для получения информации о профиле из ProfileRepistory.
    func getBooked() {
        bookedRepository.getBookedModel()
            .subscribe(onNext: { (type, booked) in
                self.bookedBR.accept((type, booked))
            }, onError: { (error) in
                self.errorBR.accept(error)
            }).disposed(by: self.dispose)
    }
    
    //    MARK:    Function to retrieve profile information from StadiumRepository.
    //    MARK:    Функция для получения информации о профиле из StadiumRepository.
    func getStadiumInfo(stadiumID:String?) {
        bookedRepository.getStadiumInfo(stadiumID: stadiumID!)
            .subscribe(onNext: { (stadiumInfo) in
                self.stadiumInfoBR.accept(stadiumInfo)
            }, onError: { (error) in
                self.errorBR.accept(error)
            }).disposed(by: self.dispose)
    }
    
    //   MARK:    Функция для сохранения измененных информаций о Request.
    func saveBookedRequestData(bookedTableId: String?, requestId: String?, stadiumId: String?, time: String?, userId: String?, userName: String?,completion: @escaping (Error?) -> ()) {
        let adminId = Auth.auth().currentUser?.uid
        let params = [
            "adminId":adminId!,
            "bookedTableId":bookedTableId!,
            "userId": userId!,
            "requestId": requestId!,
            "stadiumId": stadiumId!,
            "isActive": true,
            "time": time!,
            "userName": userName!
            ] as [String : Any]
        
        FIRRefManager.instance.bookingRequestRef.document(requestId!).setData(params, completion: { (error) in
            if error != nil{
                completion(error)
                return
            }else{
                completion(nil)
            }
        })
        
    }

    
    
    
}
