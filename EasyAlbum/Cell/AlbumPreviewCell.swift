//
//  AlbumPreviewCell.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/18.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit

class AlbumPreviewCell: UICollectionViewCell {
    private var imgScaleForDoubleTap: CGFloat = 2.5
    
    private let mScrollView = UIScrollView()
    private let mImgView: UIImageView = UIImageView()
    private var mNumberBut: UIButton!
    
    private var fitScreenBounds: CGRect = .zero
    
    private var centerOfContentSize: CGPoint {
        let deltaWidth = fitScreenBounds.width - mScrollView.contentSize.width
        let offsetX = deltaWidth > 0 ? deltaWidth * 0.5 : 0
        let deltaHeight = fitScreenBounds.height - mScrollView.contentSize.height
        let offsetY = deltaHeight > 0 ? deltaHeight * 0.5 : 0
        
        return CGPoint(x: mScrollView.contentSize.width * 0.5 + offsetX,
                       y: mScrollView.contentSize.height * 0.5 + offsetY)
    }
    
    private var fitSize: CGSize {
        guard let image = mImgView.image else { return CGSize.zero }
        return image.size.fit(with: mScrollView.bounds.size)
    }
    
    private var fitFrame: CGRect {
        let width = mScrollView.bounds.width
        let height = mScrollView.bounds.height
        let imgW = fitSize.width
        let imgH = fitSize.height

        let x = width - imgW > 0 ? (width - imgW) * 0.5 : 0.0
        let y = height - imgH > 0 ? (height - imgH) * 0.5 : 0.0

        return CGRect(x: x, y: y, width: fitSize.width, height: fitSize.height)
    }
    
    var imgScale: CGFloat = 3.0 {
        didSet { mScrollView.maximumZoomScale = imgScale }
    }
    
    var representedAssetIdentifier: String!
    
    weak var delegate: AlbumCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        fitScreenBounds = CGRect(x: 0.0, y: 0.0, width: UIScreen.width, height: UIScreen.height)
        
        contentView.addSubview(mScrollView)
        mScrollView.showsHorizontalScrollIndicator = false
        mScrollView.showsVerticalScrollIndicator = false
        mScrollView.delegate = self
        mScrollView.minimumZoomScale = 1.0
        mScrollView.maximumZoomScale = imgScale
        
        mScrollView.addSubview(mImgView)
        mImgView.clipsToBounds = true
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(onSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        contentView.addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(onDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        contentView.addGestureRecognizer(doubleTap)
        
        // Single tap ＆ Double tap
        singleTap.require(toFail: doubleTap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(from image: UIImage) {
        mImgView.image = image
        doLayout()
    }
    
    private func doLayout() {
        fitScreenBounds = CGRect(origin: .zero, size: CGSize(width: UIScreen.width, height: UIScreen.height))
        mScrollView.frame = fitScreenBounds
        //mScrollView.frame = contentView.bounds
        mScrollView.setZoomScale(1.0, animated: false)
        mImgView.frame = fitFrame
        mScrollView.setZoomScale(1.0, animated: false)
    }
    
    @objc private func onSingleTap(_ tap: UITapGestureRecognizer) {
        delegate?.albumCellSingleTap(self)
    }
    
    @objc private func onDoubleTap(_ tap: UITapGestureRecognizer) {
        if mScrollView.zoomScale == 1.0 {
            // 以點擊的位置為中心，放大
            let pointInView = tap.location(in: mImgView)
            let w = mScrollView.bounds.size.width / imgScaleForDoubleTap
            let h = mScrollView.bounds.size.height / imgScaleForDoubleTap
            let x = pointInView.x - (w / 2.0)
            let y = pointInView.y - (h / 2.0)
            mScrollView.zoom(to: CGRect(x: x, y: y, width: w, height: h), animated: true)
        } else {
            mScrollView.setZoomScale(1.0, animated: true)
        }
    }
}

extension AlbumPreviewCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mImgView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        mImgView.center = centerOfContentSize
    }
}
