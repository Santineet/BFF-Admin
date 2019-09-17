//
//  StadiumCVCell.swift
//  BffAdmin
//
//  Created by Mairambek on 03/07/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import UIKit

class StadiumCVCell: UICollectionViewCell {
    
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var status: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    class var identifier:String {
        return String(describing: self)
    }
    
    class var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
}
