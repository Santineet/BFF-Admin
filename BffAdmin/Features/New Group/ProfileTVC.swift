//
//  ProfileTVC.swift
//  BffAdmin
//
//  Created by Mairambek on 03/09/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import UIKit
import RxSwift
import PKHUD

class ProfileTVC: UITableViewController {

    
    var profileVM: NewProfileViewModel?
    var profileInfo = ProfileInfo()
    var stadiums = [Stadium]()
    let dispose = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Профиль"
        getProfileInfo()
    }

    func getProfileInfo() {
        HUD.show(.progress)
        self.profileVM = NewProfileViewModel()
        self.profileVM?.getProfileInfo()
        self.profileVM?.profileInfoBR.skip(1).subscribe(onNext: { (profileInfo) in
            self.profileInfo = profileInfo
            self.getStadiums()
        }, onError: { (error) in
            HUD.hide()
            print(error.localizedDescription)
        }).disposed(by: self.dispose)
        
    }
    
    func getStadiums(){
        
        self.profileVM = NewProfileViewModel()
        self.profileVM?.getStadiums()
        self.profileVM?.stadiumBR.skip(1).subscribe(onNext: { (type, stadium) in
            
            self.tableView.reloadData()
            HUD.hide()
            switch type {
            case .Added:
                if let index = self.stadiums.firstIndex(where: { (item) -> Bool in
                    return item.id == stadium.id
                }){
                    self.stadiums[index] = stadium
                    self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }else{
                    self.stadiums.append(stadium)
                    self.tableView.insertRows(at: [IndexPath(row: self.stadiums.count-1, section: 0)], with: .automatic)
                }
                break
            case .Changed:
                if let index = self.stadiums.firstIndex(where: { (item) -> Bool in
                    return item.id == stadium.id
                }){
                    self.stadiums[index] = stadium
                    self.tableView.insertRows(at: [IndexPath(row: self.stadiums.count-1, section: 0)], with: .automatic)
                }
                break
            case .Removed:
                if let index = self.stadiums.firstIndex(where: { (item) -> Bool in
                    return item.id == stadium.id
                }){
                    self.stadiums.remove(at: index)
                    self.tableView.insertRows(at: [IndexPath(row: self.stadiums.count-1, section: 0)], with: .left)
                }
                break
            }
        }).disposed(by: dispose)
    }
    

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.stadiums.count + 2
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTVCell", for: indexPath) as! ProfileTVCell

            cell.name.text = self.profileInfo.name
            cell.userNumber.text = profileInfo.numberPhone
            cell.status.text = self.profileInfo.status
            DispatchQueue.main.async {
                cell.profileImage.sd_setImage(with: URL(string:self.profileInfo.previewImageUrl), placeholderImage: UIImage(named: ""))
            }
            
            return cell
        } else if indexPath.row == 1 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")
            return cell!
        }
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "MyStadiumsTVCell", for: indexPath) as! MyStadiumsTVCell
        let stadium = self.stadiums[indexPath.row - 2]
        
        cell.name.text = stadium.stadName
        if let originalurl = stadium.images.first?.originalUrl {
            cell.stadiumImage.sd_setImage(with: URL(string: originalurl), placeholderImage: UIImage(named: ""))
        }
        
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 300
        } else if indexPath.row == 1 {
            return 55
        }
        return 134
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row > 1 {
        let stadium = self.stadiums[indexPath.row - 2]
        let stadiumDetailVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyStadiumInfoTVC") as! MyStadiumInfoTVC
        stadiumDetailVC.stadium = stadium
        self.navigationController?.pushViewController(stadiumDetailVC, animated: true)
    
        }
    }
   

}
