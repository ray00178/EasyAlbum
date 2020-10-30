//
//  AlbumPhotoCell.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/3.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit
import Photos

protocol AlbumPhotoCellDelegate: class {
    func albumPhotoCell(didNumberClickAt item: Int)
}

class AlbumPhotoCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var borderView: AlbumBorderView!
    @IBOutlet weak var gifLabel: UILabel!
    @IBOutlet weak var numberButton: UIButton!
        
    var representedAssetIdentifier: String?
        
    weak var delegate: AlbumPhotoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        borderView.isHidden = true
        
        gifLabel.alpha = 0.75
        gifLabel.layer.cornerRadius = gifLabel.frame.height / 2
        gifLabel.layer.masksToBounds = true
        gifLabel.isHidden = true
        
        numberButton.layer.cornerRadius = numberButton.frame.height / 2
        numberButton.layer.borderWidth = 1.5
        numberButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        numberButton.setTitleColor(UIColor.white, for: .normal)
        numberButton.addTarget(self,
                               action: #selector(didNumberClicked(_:)),
                               for: .touchUpInside)
        numberButton.isHidden = true
    }
    
    override func prepareForReuse() {
        imageView.image = nil
        super.prepareForReuse()
    }
    
    func setData(from asset: PHAsset, image: UIImage, number: Int?, pickColor: UIColor, item: Int) {
        let hasNumber = number ?? 0 > 0
        borderView.isHidden = !hasNumber
        
        if borderView.isHidden == false {
            borderView.borderColor = pickColor
        }
        
        gifLabel.isHidden = PhotoManager.share.isAnimatedImage(from: asset) == false
        
        numberButton.layer.borderColor = borderView.isHidden ?
                                         UIColor(white: 1.0, alpha: 0.78).cgColor :
                                         pickColor.cgColor
        numberButton.backgroundColor = borderView.isHidden ?
                                       UIColor(hex: "000000", alpha: 0.1) :
                                       pickColor
        numberButton.setTitle(hasNumber ? "\(number ?? 0)" : "", for: .normal)
        numberButton.tag = item
        numberButton.isHidden = false
        
        imageView.image = image
    }
    
    @objc private func didNumberClicked(_ btn: UIButton) {
        delegate?.albumPhotoCell(didNumberClickAt: btn.tag)
    }
}
