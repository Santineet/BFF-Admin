//
//  BookedTVC.swift
//  BffAdmin
//
//  Created by Mairambek on 08/08/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import UIKit
import RxSwift
import Firebase

class BookedTVC: UITableViewController {
    
    var bookeds = [BookedModel]()
    var bookedVM: BookedViewModel?
    let dispose = DisposeBag()
    var stadium: Stadium?

    override func viewDidLoad() {
        super.viewDidLoad()
 
        getBookeds()
        tableView.tableFooterView = UIView()

    }
    
 

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print(bookeds.count)
        return bookeds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookedTVCell", for: indexPath) as! BookedTVCell

        let stadiumBooked = bookeds[indexPath.row]
        var name = stadium?.stadName ?? "Name"

        if self.stadium == nil {
//            name = "Name"
        self.bookedVM = BookedViewModel()
            self.bookedVM?.getStadiumInfo(stadiumID: stadiumBooked.stadiumId)
            self.bookedVM?.stadiumInfoBR.skip(1).subscribe(onNext: {  (stadiumInfo) in
                self.stadium = stadiumInfo
                let stadium = self.stadium
                print("aasd " + self.stadium!.stadName)
                name = stadium?.stadName ?? "nil"
                tableView.reloadData()
            }, onError: { (error) in
                print(error.localizedDescription)
            }).disposed(by: self.dispose)
        }
        
        cell.requestText.text = "Пользователь " + stadiumBooked.userName + " хочет забронировать поле " + name + " нa время " + stadiumBooked.time
        
        cell.acceptButton.tag = indexPath.row
        cell.acceptButton.addTarget(self, action: #selector(acceptClicked(sender:)), for: .touchUpInside)
        return cell
    }
    
    @objc func acceptClicked(sender: UIButton){
        
        let buttonRow = sender.tag
        self.bookedVM = BookedViewModel()
 
        let bookedStadium = bookeds[buttonRow]
        
        self.bookedVM?.saveBookedRequestData(bookedTableId: bookedStadium.bookedTableId, requestId: bookedStadium.id, stadiumId: bookedStadium.stadiumId, time: bookedStadium.time, userId: bookedStadium.userId, userName: bookedStadium.userName, completion: { (error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            } else {
                print("Accept Button is work!")
            }
        })

        
        
    }
    
    func getBookeds(){
        
        self.bookedVM = BookedViewModel()
        self.bookedVM?.getBooked()
     
        self.bookedVM?.bookedBR.skip(1).subscribe(onNext: { (type, booking) in
            switch type {
            case .Added:
                if let index = self.bookeds.firstIndex(where: { (item) -> Bool in
                    return item.id == booking.id
                }){
                    self.bookeds[index] = booking

              self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }else{
                    self.bookeds.append(booking)

                self.tableView.insertRows(at: [IndexPath(row: self.bookeds.count-1, section: 0)], with: .automatic)
                }
                break
            case .Changed:
                if let index = self.bookeds.firstIndex(where: { (item) -> Bool in
                    return item.id == booking.id
                }){
                    self.bookeds[index] = booking

                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
                break
            case .Removed:
                if let index = self.bookeds.firstIndex(where: { (item) -> Bool in
                    return item.id == booking.id
                }){
                    self.bookeds.remove(at: index)

                    self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
                break
            }
        }).disposed(by: dispose)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    

}
