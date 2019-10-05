//
//  EasyAlbumPageContentVC.swift
//  EasyAlbum
//
//  Created by Ray on 2019/8/26.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit
import Photos
//import PhotosUI

class EasyAlbumPageContentVC: UIViewController {

    private let mScrollView = UIScrollView()
    private let mImgView: UIImageView = UIImageView()
    
    //private var mPohtoLiveView: PHLivePhotoView?

    /// Device screen frame
    private var screenFrame: CGRect = .zero
    
    /// Initialize ImageView center
    private var oriImageCenter: CGPoint = .zero
    
    private var centerOfContentSize: CGPoint {
        let deltaWidth = screenFrame.width - mScrollView.contentSize.width
        let offsetX = deltaWidth > 0 ? deltaWidth / 2 : 0
        let deltaHeight = screenFrame.height - mScrollView.contentSize.height
        let offsetY = deltaHeight > 0 ? deltaHeight / 2 : 0
        
        return CGPoint(x: mScrollView.contentSize.width / 2 + offsetX,
                       y: mScrollView.contentSize.height / 2 + offsetY)
    }
    
    private var imageScaleForDoubleTap: CGFloat = 3.0
    private var imageScale: CGFloat = 4.0 {
        didSet { mScrollView.maximumZoomScale = imageScale }
    }
    
    private var photoManager: PhotoManager = PhotoManager.share
    
    var albumPhoto: AlbumPhoto?
    
    /// The cell frame，default = .zero
    var cellFrame: CGRect = .zero
    
    weak var delegate: EasyAlbumPageContentVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        screenFrame = CGRect(origin: .zero, size: size)
        doLayout()
    }

    private func setup() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        mScrollView.showsHorizontalScrollIndicator = false
        mScrollView.showsVerticalScrollIndicator = false
        mScrollView.alwaysBounceHorizontal = true
        mScrollView.alwaysBounceVertical = true
        mScrollView.minimumZoomScale = 1.0
        mScrollView.maximumZoomScale = imageScale
        mScrollView.delegate = self
        view.addSubview(mScrollView)
        
        if #available(iOS 11.0, *) {
            mScrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        mScrollView.addSubview(mImgView)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(onSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(onDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        pan.maximumNumberOfTouches = 1
        pan.delegate = self
        mImgView.isUserInteractionEnabled = true
        mImgView.addGestureRecognizer(pan)
        
        mImgView.frame = cellFrame
        
        // Single tap ＆ Double tap
        singleTap.require(toFail: doubleTap)
        
        screenFrame = CGRect(origin: .zero, size: CGSize(width: UIScreen.width, height: UIScreen.height))
        
        guard let albumPhoto = albumPhoto else { return }
        let width = albumPhoto.asset.pixelWidth
        let height = albumPhoto.asset.pixelHeight
        let size = photoManager.calcScaleFactor(from: CGSize(width: width, height: height))
        
        if albumPhoto.isGIF {
            photoManager.fetchImageData(from: albumPhoto.asset, options: .exact(isSync: false)) { (data, _) in
                guard let data = data else { return }
                
                self.mImgView.loadGif(data: data)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { self.doLayout() }
            }
        } else {
            photoManager.fetchImage(form: albumPhoto.asset, size: size, options: .exact(isSync: false)) { (image) in
                self.mImgView.image = image
                self.doLayout()
            }
        }
    }
    
    private func doLayout() {
        // If has zoom, we need to scale to original
        if mScrollView.zoomScale != 1.0 {
            mScrollView.setZoomScale(1.0, animated: false)
        }
        
        // Setting scrollView frame, because when rotate the frame can't be changed
        mScrollView.frame = screenFrame

        // Origin image size
        guard let imageSize = mImgView.image?.size else { return }
        
        // Calculation screen frame
        let fitFrame = imageSize.fit(with: screenFrame)
        
        if cellFrame != .zero {
            UIView.animate(withDuration: 0.25, animations: {
                self.mImgView.frame = fitFrame
                self.oriImageCenter = self.mImgView.center
            }) { (finished) in
                self.mScrollView.setZoomScale(1.0, animated: false)
            }
        } else {
            mImgView.frame = fitFrame
            oriImageCenter = mImgView.center
            mScrollView.setZoomScale(1.0, animated: false)
        }
    }
    
    @objc private func onSingleTap(_ tap: UITapGestureRecognizer) {
        delegate?.singleTap(self)
    }
    
    @objc private func onDoubleTap(_ tap: UITapGestureRecognizer) {
        if mScrollView.zoomScale == 1.0 {
            let pointInView = tap.location(in: mImgView)
            let w = mScrollView.frame.size.width / imageScaleForDoubleTap
            let h = mScrollView.frame.size.height / imageScaleForDoubleTap
            let x = pointInView.x - (w / 2.0)
            let y = pointInView.y - (h / 2.0)
            mScrollView.zoom(to: CGRect(x: x, y: y, width: w, height: h), animated: true)
        } else {
            mScrollView.setZoomScale(1.0, animated: true)
        }
    }

    @objc private func onPan(_ pan: UIPanGestureRecognizer) {
        guard mScrollView.zoomScale == 1.0 else { return }
        
        let height = UIScreen.height
        let halfHeight = height / 2
        var alpha = CGFloat(1.0)
        
        switch pan.state {
        case .began: break
        case .changed:
            let translation = pan.translation(in: mImgView.superview)
            
            // if x > y, means scroll to left or right
            let tx = abs(translation.x)
            let ty = abs(translation.y)
            if tx > ty { return }
            
            let y = pan.view!.center.y + translation.y
            
            // Calculator alpha
            alpha = y < halfHeight ? y / halfHeight : (height - y) / halfHeight
            
            // add 0.15 because don't want fast to transparent
            alpha += 0.15
            delegate?.panDidChanged(self, in: mImgView, alpha: alpha)
            
            mImgView.center = CGPoint(x: mImgView.center.x, y: y)
            pan.setTranslation(.zero, in: mImgView.superview)
        case .ended, .cancelled:
            let translation = pan.translation(in: mImgView.superview)
            
            // if x > y, means scroll to left or right
            let tx = abs(translation.x)
            let ty = abs(translation.y)
            
            if tx > ty {
                // if x > y but y has move a little then image center to origin
                if mImgView.center != oriImageCenter {
                    UIView.animate(withDuration: 0.15, animations: {
                        self.mImgView.center = self.oriImageCenter
                    }) { (finished) in
                        self.delegate?.panDidChanged(self, in: self.mImgView, alpha: 1.0)
                    }
                }
                return
            }
            
            delegate?.panDidEnded(self, in: mImgView)
        default: break
        }
    }
}

// MARK: - UIScrollViewDelegate
extension EasyAlbumPageContentVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mImgView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        mImgView.center = centerOfContentSize
    }
}

// MARK: - UIGestureRecognizerDelegate
extension EasyAlbumPageContentVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        // allow scroll can to left or right
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = pan.translation(in: mImgView)
            return abs(translation.x) >= abs(translation.y)
        }
        
        // if true means both(UIPanGestureRecognizer & UICollectionView) otherwise UIPanGestureRecognizer
        return true
    }
}
