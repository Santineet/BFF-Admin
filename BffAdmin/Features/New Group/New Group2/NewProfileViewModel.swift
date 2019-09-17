//
//  NewProfileViewModel.swift
//  BffAdmin
//
//  Created by Mairambek on 03/09/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase
import FirebaseAuth


class NewProfileViewModel: NSObject {
    //    MARK:    Переменные
    let dispose = DisposeBag()
    let profileInfoBR = BehaviorRelay<ProfileInfo>(value: ProfileInfo())
    let errorBR = BehaviorRelay<Error>(value: NSError.init())
    let stadiumBR = BehaviorRelay<(EventType, Stadium)>(value: (EventType.Added, Stadium()))

    //    MARK:    ProfileRepistory object
    //    MARK:    Объект от ProfileRepistory
    let profileRepository = NewProfileRepistory()
    //    MARK:    ProfileRepistory object
    //    MARK:    Объект от ProfileRepistory
    
    //    MARK:    Function to retrieve profile information from ProfileRepistory.
    //    MARK:    Функция для получения информации о профиле из ProfileRepistory.
    func getProfileInfo() {
        profileRepository.getProfileInfo()
            .subscribe(onNext: { (profileInfo) in
                self.profileInfoBR.accept(profileInfo)
            }, onError: { (error) in
                self.errorBR.accept(error)
            }).disposed(by: self.dispose)
    }
    
    
    //    AMRK:    Function to log out.
    //    AMRK:    Функция для выхода из системы.
    func logOut() -> String {
        do {
            UserDefaults.standard.removeObject(forKey: "isLoggedIn")
            try Auth.auth().signOut()
            LoginLogoutManager.instance.updateRootVC()
            return "Success"
        } catch {
            print(error)
            let signOutError = error
            return signOutError.localizedDescription
            
        }
    }
    

    //    MARK:    Function to retrieve profile information from ProfileRepistory.
    //    MARK:    Функция для получения информации о профиле из ProfileRepistory.
    func getStadiums() {
        profileRepository.getStadiums()
            .subscribe(onNext: { (type, stadium) in
                self.stadiumBR.accept((type, stadium))
            }, onError: { (error) in
                self.errorBR.accept(error)
            }).disposed(by: self.dispose)
    }

 
    
}
