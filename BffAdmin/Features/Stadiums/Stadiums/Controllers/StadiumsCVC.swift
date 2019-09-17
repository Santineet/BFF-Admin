//
//  StadiumsCVC.swift
//  BffAdmin
//
//  Created by Mairambek on 03/07/2019.
//  Copyright © 2019 Mairambek Abdrasulov. All rights reserved.
//

import UIKit
import RxSwift
import Firebase
import SDWebImage

enum StadiumInfoEvent{
    case Added
    case Removed
    case Changed
}

class StadiumsCVC: UICollectionViewController {
    
    @IBOutlet var collectionV: UICollectionView!
    
    //    MARK:    Variables
    //    MARK:    Переменные
    var images = [Image]()
    var stadiums = [Stadium]()
    var stadiumVM: StadiumViewModel?
    let dispose = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionV.alwaysBounceVertical = true
        registrXib()
        getStadiums()
        
    }
    
    func registrXib() {
        collectionView.register(StadiumCVCell.nib, forCellWithReuseIdentifier: StadiumCVCell.identifier)
    }
    

    //    MARK:    Retrieving Stadiums information from a database
    //    MARK:    Получение информации о Stadiums из базы данных
    func getStadiums(){
        
        self.stadiumVM = StadiumViewModel()
        self.stadiumVM?.getStadiums()
        self.stadiumVM?.stadiumBR.skip(1).subscribe(onNext: { (type, stadium) in
            switch type {
            case .Added:
                if let index = self.stadiums.firstIndex(where: { (item) -> Bool in
                    return item.id == stadium.id
                }){
                    self.stadiums[index] = stadium
                    self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
                }else{
                    self.stadiums.append(stadium)
                    self.collectionView.insertItems(at: [IndexPath(row: self.stadiums.count-1, section:0)])
                }
                break
            case .Changed:
                if let index = self.stadiums.firstIndex(where: { (item) -> Bool in
                    return item.id == stadium.id
                }){
                    self.stadiums[index] = stadium
                    self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
                }
                break
            case .Removed:
                if let index = self.stadiums.firstIndex(where: { (item) -> Bool in
                    return item.id == stadium.id
                }){
                    self.stadiums.remove(at: index)
                    self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
                }
                break
            }
        }).disposed(by: dispose)
    }
    
    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return self.stadiums.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StadiumCVCell.identifier, for: indexPath) as! StadiumCVCell
        let stadium = self.stadiums[indexPath.row]
        if let originalurl = stadium.images.first?.originalUrl {
            cell.image.sd_setImage(with: URL(string: originalurl), placeholderImage: UIImage(named: ""))

        }
        cell.name.text = stadium.stadName
        cell.status.text = stadium.stadStatus
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let stadium = self.stadiums[indexPath.row]
        let stadiumDetailVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyStadiumInfoTVC") as! MyStadiumInfoTVC
        stadiumDetailVC.stadium = stadium
        self.navigationController?.pushViewController(stadiumDetailVC, animated: true)
    }
}
