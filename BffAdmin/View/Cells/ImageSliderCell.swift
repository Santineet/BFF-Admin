//
//  ImageSliderCell.swift
//  BffAdmin
//
//  Created by Mairambek on 03/07/2019.
//  Copyright © 2019 Azamat Kushmanov. All rights reserved.
//

import UIKit

class ImageSliderCell: UICollectionViewCell {
  
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage! {
        didSet {
            imageView.image = image
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        // Initialization code
    }
}
