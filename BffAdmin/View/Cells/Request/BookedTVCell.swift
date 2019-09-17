//
//  BookedTVCell.swift
//  BffAdmin
//
//  Created by Mairambek on 08/08/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import UIKit

class BookedTVCell: UITableViewCell {

    @IBOutlet weak var requestText: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
   
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


