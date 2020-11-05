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
    
    private var imageView: UIImageView!
    private var borderView: AlbumBorderView!
    private var gifLabel: UILabel!
    private var numberButton: UIButton!
    
    var representedAssetIdentifier: String?
        
    weak var delegate: AlbumPhotoCellDelegate?
    
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
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        borderView = AlbumBorderView()
        borderView.isHidden = true
        borderView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(borderView)
        
        gifLabel = UILabel()
        gifLabel.text = "GIF"
        gifLabel.textColor = UIColor(hex: "828282")
        gifLabel.textAlignment = .center
        gifLabel.font = .systemFont(ofSize: 13.0, weight: .medium)
        gifLabel.backgroundColor = .white
        gifLabel.alpha = 0.75
        gifLabel.layer.cornerRadius = 10.0
        gifLabel.layer.masksToBounds = true
        gifLabel.isHidden = true
        gifLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(gifLabel)
        
        numberButton = UIButton(type: .system)
        numberButton.titleLabel?.font = .systemFont(ofSize: 13.0, weight: .bold)
        numberButton.setTitleColor(UIColor.white, for: .normal)
        numberButton.layer.cornerRadius = 14.0
        numberButton.layer.borderWidth = 1.5
        numberButton.addTarget(self,
                               action: #selector(didNumberClicked(_:)),
                               for: .touchUpInside)
        numberButton.isHidden = true
        numberButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(numberButton)
        
        // AutoLayout
        imageView.topAnchor
                 .constraint(equalTo: contentView.topAnchor)
                 .isActive = true
        imageView.leadingAnchor
                 .constraint(equalTo: contentView.leadingAnchor)
                 .isActive = true
        imageView.trailingAnchor
                 .constraint(equalTo: contentView.trailingAnchor)
                 .isActive = true
        imageView.bottomAnchor
                 .constraint(equalTo: contentView.bottomAnchor)
                 .isActive = true
        
        borderView.topAnchor
                  .constraint(equalTo: contentView.topAnchor)
                  .isActive = true
        borderView.leadingAnchor
                  .constraint(equalTo: contentView.leadingAnchor)
                  .isActive = true
        borderView.trailingAnchor
                  .constraint(equalTo: contentView.trailingAnchor)
                  .isActive = true
        borderView.bottomAnchor
                  .constraint(equalTo: contentView.bottomAnchor)
                  .isActive = true
        
        gifLabel.widthAnchor
                .constraint(equalToConstant: 30.0)
                .isActive = true
        gifLabel.heightAnchor
                .constraint(equalToConstant: 20.0)
                .isActive = true
        gifLabel.leadingAnchor
                .constraint(equalTo: contentView.leadingAnchor, constant: 10.0)
                .isActive = true
        gifLabel.bottomAnchor
                .constraint(equalTo: contentView.bottomAnchor, constant: -10.0)
                .isActive = true
        
        numberButton.widthAnchor
                    .constraint(equalToConstant: 28.0)
                    .isActive = true
        numberButton.heightAnchor
                    .constraint(equalToConstant: 28.0)
                    .isActive = true
        numberButton.topAnchor
                    .constraint(equalTo: contentView.topAnchor, constant: 10.0)
                    .isActive = true
        numberButton.trailingAnchor
                    .constraint(equalTo: contentView.trailingAnchor, constant: -10.0)
                    .isActive = true
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
