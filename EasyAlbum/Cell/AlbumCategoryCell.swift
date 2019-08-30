//
//  AlbumCategoryCell.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/10.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit

class AlbumCategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var mImgView: UIImageView!
    @IBOutlet weak var mCategoryLab: UILabel!
    @IBOutlet weak var mSelectedBtn: UIButton!
    
    var data: AlbumFolder! {
        didSet { setData() }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mImgView.layer.cornerRadius = 5.0
        mImgView.layer.masksToBounds = true
    }

    private func setData() {
        let size = CGSize(width: 60.0 * UIScreen.density, height: 60.0 * UIScreen.density)
        PhotoManager.share.fetchThumbnail(form: data.photos[0].asset, size: size, options: .exact(isSync: true)) {
            [weak self] (image) in
            self?.mImgView.image = image
        }
        mCategoryLab.text = data.title
        mSelectedBtn.alpha = data.isCheck ? 1.0 : 0.0
    }
}
