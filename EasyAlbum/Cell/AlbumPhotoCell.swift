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

    @IBOutlet weak var mImgView: UIImageView!
    @IBOutlet weak var mBorderView: AlbumBorderView!
    @IBOutlet weak var mGIFLab: UILabel!
    @IBOutlet weak var mNumberBtn: UIButton!
        
    var representedAssetIdentifier: String?
        
    weak var delegate: AlbumPhotoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mBorderView.isHidden = true
        
        mGIFLab.alpha = 0.75
        mGIFLab.layer.cornerRadius = mGIFLab.frame.height / 2
        mGIFLab.layer.masksToBounds = true
        mGIFLab.isHidden = true
        
        mNumberBtn.layer.cornerRadius = mNumberBtn.frame.height / 2
        mNumberBtn.layer.borderWidth = 1.5
        mNumberBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        mNumberBtn.setTitleColor(UIColor.white, for: .normal)
        mNumberBtn.addTarget(self, action: #selector(didNumberClicked(_:)), for: .touchUpInside)
        mNumberBtn.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        representedAssetIdentifier = nil
        mImgView.image = nil
        mGIFLab.isHidden = true
        mBorderView.isHidden = true
        mNumberBtn.layer.borderColor = UIColor(white: 1.0, alpha: 0.78).cgColor
        mNumberBtn.backgroundColor = UIColor(hex: "000000", alpha: 0.1)
        mNumberBtn.setTitle("", for: .normal)
    }

    func setData(from photo: AlbumPhoto, image: UIImage, item: Int) {
        let pickNumber = photo.pickNumber
        mBorderView.isHidden = !(pickNumber > 0)
        
        if !mBorderView.isHidden {
            mBorderView.borderColor = photo.pickColor
        }
        
        mGIFLab.isHidden = !photo.isGIF
        
        mNumberBtn.layer.borderColor = mBorderView.isHidden ? UIColor(white: 1.0, alpha: 0.78).cgColor : photo.pickColor.cgColor
        mNumberBtn.backgroundColor = mBorderView.isHidden ? UIColor(hex: "000000", alpha: 0.1) : photo.pickColor
        mNumberBtn.setTitle(pickNumber > 0 ? "\(pickNumber)" : "", for: .normal)
        mNumberBtn.tag = item
        mNumberBtn.isHidden = false
        
        mImgView.image = image
    }
    
    @objc private func didNumberClicked(_ btn: UIButton) {
        delegate?.albumPhotoCell(didNumberClickAt: btn.tag)
    }
}
