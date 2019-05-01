//
//  AlbumPreviewGIFCell.swift
//  EasyAlbum
//
//  Created by Ray on 2019/4/2.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit
import Photos

class AlbumPreviewGIFCell: UICollectionViewCell {
    private let mImgView: UIImageView = UIImageView()
    
    var representedAssetIdentifier: String!
    
    var data: Data! {
        didSet { setData() }
    }
    
    weak var delegate: AlbumCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        contentView.addSubview(mImgView)
        mImgView.translatesAutoresizingMaskIntoConstraints = false
        
        mImgView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        mImgView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        mImgView.widthAnchor.constraint(equalToConstant: 0.0).isActive = true
        mImgView.heightAnchor.constraint(equalToConstant: 0.0).isActive = true
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(onSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        contentView.addGestureRecognizer(singleTap)
    }
    
    private func setData() {
        mImgView.loadGif(data: data)
        
        guard let image = UIImage(data: data) else { return }
        
        let fitSize = image.size.fit(with: CGSize(width: UIScreen.width, height: UIScreen.height))
        //print("fitSize 👉🏻 \(fitSize)")
        for c in mImgView.constraints {
            if let _ = c.firstItem as? UIImageView {
                switch c.firstAttribute {
                case .width: c.constant = fitSize.width
                case .height: c.constant = fitSize.height
                default: break
                }
            }
        }
    }
    
    @objc private func onSingleTap(_ tap: UITapGestureRecognizer) {
        delegate?.albumCellSingleTap(self)
    }
}
