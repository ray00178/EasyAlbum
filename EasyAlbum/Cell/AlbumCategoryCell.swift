//
//  AlbumCategoryCell.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/10.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit

class AlbumCategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var selectedButton: UIButton!
    
    var data: AlbumFolder! {
        didSet { setData() }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.cornerRadius = 5.0
        imageView.layer.masksToBounds = true
    }

    private func setData() {
        let wh = 60.0 * UIScreen.density
        let size = CGSize(width: wh, height: wh)
        PhotoManager.share.fetchThumbnail(form: data.assets[0],
                                          size: size,
                                          options: .exact(isSync: true))
        { [weak self] (image) in
            self?.imageView.image = image
        }
        
        categoryLabel.text = data.title
        selectedButton.alpha = data.isCheck ? 1.0 : 0.0
    }
}
