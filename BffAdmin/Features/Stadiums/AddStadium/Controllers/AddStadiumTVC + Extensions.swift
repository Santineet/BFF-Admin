//
//  AddStadiumTVC + Extentions.swift
//  BffAdmin
//
//  Created by Mairambek on 16/07/2019.
//  Copyright © 2019 Mairambek Abdrasulov. All rights reserved.
//

import UIKit
import Photos
import BSImagePicker

// extension UICollectionView

extension AddStadiumTVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath:IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width/3 - 4, height: collectionView.frame.height/2 - 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return images.count + 1
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddImagesCVCell", for: indexPath) as! AddImagesCVCell
            return cell
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddStadiumCVCell", for: indexPath) as! AddStadiumCVCell
            
            cell.removeImageButton.tag = indexPath.row
            cell.removeImageButton.addTarget(self, action: #selector(buttonClicked(sender: )), for: .touchUpInside)
            
            
            let image = self.images[indexPath.row - 1]
            print("image.originalUrl! \(image)")
            cell.addStadiumImageView.image = image
            print("cell.stadiumEditImages.image = image")
            return cell
        }
    }
    
    @objc func buttonClicked(sender:UIButton) {
        let buttonRow = sender.tag
        self.images.remove(at: buttonRow - 1)
        collectionView.reloadData()
    }
    
    // BSImagePickerViewController
    func maxImagesAlert(){
        let alert = UIAlertController(title: "Извините", message: "Максимальное количество фотографий", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if images.count >= 7 {
                maxImagesAlert()
            } else {
                let vc = BSImagePickerViewController()
                vc.maxNumberOfSelections = 7 - images.count
                //display picture gallery
                self.bs_presentImagePickerController(vc, animated: true,
                                                     select: { (asset: PHAsset) -> Void in
                }, deselect: { (asset: PHAsset) -> Void in
                }, cancel: { (assets: [PHAsset]) -> Void in
                }, finish: { (assets: [PHAsset]) -> Void in
                    convertAssetToImages(assests: assets)
                }, completion: nil)
                
                func convertAssetToImages(assests: [PHAsset]) {
                    if assests.count > 0{
                        for asset in assests{
                            let manager = PHImageManager.default()
                            let option = PHImageRequestOptions()
                            option.isSynchronous = true
                            manager.requestImage(for: asset, targetSize: CGSize(width: 1000, height: 1000) , contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
                                self.images.append(result!)
                            })
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
            }
        } else {
            print("clicked image")
        }
    }
}


