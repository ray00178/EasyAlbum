//
//  AlbumCategoryCell.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/10.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit

class AlbumCategoryCell: UICollectionViewCell {
    
    private var imageView: UIImageView!
    private var categoryLabel: UILabel!
    private var selectedButton: AlbumSelectedButton!
    
    var data: AlbumFolder! {
        didSet { setData() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5.0
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        categoryLabel = UILabel()
        categoryLabel.textColor = UIColor(hex: "1A1A1A")
        categoryLabel.textAlignment = .center
        categoryLabel.font = .systemFont(ofSize: 12.0, weight: .medium)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(categoryLabel)
        
        selectedButton = AlbumSelectedButton()
        selectedButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(selectedButton)
        
        // AutoLayout
        imageView.widthAnchor
                 .constraint(equalToConstant: 50.0)
                 .isActive = true
        imageView.heightAnchor
                 .constraint(equalToConstant: 50.0)
                 .isActive = true
        imageView.topAnchor
                 .constraint(equalTo: contentView.topAnchor, constant: 10.0)
                 .isActive = true
        imageView.centerXAnchor
                 .constraint(equalTo: contentView.centerXAnchor)
                 .isActive = true
        
        categoryLabel.heightAnchor
                     .constraint(equalToConstant: 20.0)
                     .isActive = true
        categoryLabel.leadingAnchor
                     .constraint(equalTo: contentView.leadingAnchor, constant: 10.0)
                     .isActive = true
        categoryLabel.trailingAnchor
                     .constraint(equalTo: contentView.trailingAnchor, constant: -10.0)
                     .isActive = true
        categoryLabel.topAnchor
                     .constraint(equalTo: imageView.bottomAnchor, constant: 5.0)
                     .isActive = true
        
        selectedButton.topAnchor
                      .constraint(equalTo: imageView.topAnchor)
                      .isActive = true
        selectedButton.leadingAnchor
                      .constraint(equalTo: imageView.leadingAnchor)
                      .isActive = true
        selectedButton.trailingAnchor
                      .constraint(equalTo: imageView.trailingAnchor)
                      .isActive = true
        selectedButton.bottomAnchor
                      .constraint(equalTo: imageView.bottomAnchor)
                      .isActive = true
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
