//
//  MyStadiumsTVCell.swift
//  BffAdmin
//
//  Created by Mairambek on 03/09/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import UIKit

class MyStadiumsTVCell: UITableViewCell {


    @IBOutlet weak var stadiumImage: UIImageView!
    
    @IBOutlet weak var name: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        setupProfileImageViewStyle()
        
    }

    func setupProfileImageViewStyle(){
        stadiumImage.frame = CGRect(x:0, y: 0, width: 100, height: 100)
        let imageBounds:CGFloat = stadiumImage.bounds.size.width
        stadiumImage.layer.masksToBounds = true
        stadiumImage.layer.cornerRadius = 0.5 * imageBounds
        stadiumImage.layer.borderWidth = 2
        stadiumImage.layer.borderColor = UIColor.white.cgColor
        stadiumImage.translatesAutoresizingMaskIntoConstraints = false
        stadiumImage.contentMode = .scaleAspectFill
        stadiumImage.isUserInteractionEnabled = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
