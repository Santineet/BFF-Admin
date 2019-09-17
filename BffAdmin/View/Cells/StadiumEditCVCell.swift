//
//  StadiumEditCVCell.swift
//  BffAdmin
//
//  Created by Mairambek on 05/07/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import UIKit

class StadiumEditCVCell: UICollectionViewCell {
    @IBOutlet weak var stadiumEditImages: UIImageView!
    
    @IBOutlet weak var removeButtonOutlet: UIButton!
    @IBAction func removeButton(_ sender: Any)-> Void {
        print("remove")
        
    }
    
}
