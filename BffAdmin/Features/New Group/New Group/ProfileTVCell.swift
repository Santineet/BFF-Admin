//
//  ProfileTVCell.swift
//  BffAdmin
//
//  Created by Mairambek on 03/09/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import UIKit

class ProfileTVCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var userNumber: UILabel!
    @IBOutlet weak var status: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupProfileImageViewStyle()
    }
    
    
    func setupProfileImageViewStyle(){
        profileImage.frame = CGRect(x:0, y: 0, width: 150, height: 150)
        let imageBounds:CGFloat = profileImage.bounds.size.width
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = 0.5 * imageBounds
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor.white.cgColor
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.contentMode = .scaleAspectFill
        profileImage.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
