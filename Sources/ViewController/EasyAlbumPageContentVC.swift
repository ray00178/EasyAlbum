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

    private let scrollView = UIScrollView()
    private let imageView: UIImageView = UIImageView()
    
    //private var mPohtoLiveView: PHLivePhotoView?

    /// Device screen frame
    private var screenFrame: CGRect = .zero
    
    /// Initialize ImageView center
    private var oriImageCenter: CGPoint = .zero
    
    private var centerOfContentSize: CGPoint {
        let deltaWidth = screenFrame.width - scrollView.contentSize.width
        let offsetX = deltaWidth > 0 ? deltaWidth / 2 : 0
        let deltaHeight = screenFrame.height - scrollView.contentSize.height
        let offsetY = deltaHeight > 0 ? deltaHeight / 2 : 0
        
        return CGPoint(x: scrollView.contentSize.width / 2 + offsetX,
                       y: scrollView.contentSize.height / 2 + offsetY)
    }
    
    private var imageScaleForDoubleTap: CGFloat = 3.0
    private var imageScale: CGFloat = 4.0 {
        didSet { scrollView.maximumZoomScale = imageScale }
    }
    
    private var photoManager: PhotoManager = PhotoManager.share
    
    var asset: PHAsset?
    
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
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = true
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = imageScale
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        scrollView.addSubview(imageView)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(onSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(onDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        pan.maximumNumberOfTouches = 1
        pan.delegate = self
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(pan)
        
        imageView.frame = cellFrame
        
        // Single tap ＆ Double tap
        singleTap.require(toFail: doubleTap)
        
        screenFrame = CGRect(origin: .zero, size: CGSize(width: UIScreen.width, height: UIScreen.height))
        
        guard let asset = asset else { return }
        
        let width = asset.pixelWidth
        let height = asset.pixelHeight
        let size = photoManager.calcScaleFactor(from: CGSize(width: width, height: height))
        
        if photoManager.isAnimatedImage(from: asset) {
            photoManager.fetchImageData(from: asset,
                                        options: .exact(isSync: false))
            { (data, _) in
                guard let data = data else { return }
                
                self.imageView.loadGif(data: data)
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(320)) { self.doLayout() }
            }
        } else {
            photoManager.fetchImage(form: asset,
                                    size: size,
                                    options: .exact(isSync: false))
            { (image) in
                self.imageView.image = image
                self.doLayout()
            }
        }
    }
    
    private func doLayout() {
        // If has zoom, we need to scale to original
        if scrollView.zoomScale != 1.0 {
            scrollView.setZoomScale(1.0, animated: false)
        }
        
        // Setting scrollView frame, because when rotate the frame can't be changed
        scrollView.frame = screenFrame

        // Origin image size
        guard let imageSize = imageView.image?.size else { return }
        
        // Calculation screen frame
        let fitFrame = imageSize.fit(with: screenFrame)
        
        if cellFrame != .zero {
            UIView.animate(withDuration: 0.32, animations: {
                self.imageView.frame = fitFrame
                self.oriImageCenter = self.imageView.center
            }) { (finished) in
                self.scrollView.setZoomScale(1.0, animated: false)
            }
        } else {
            imageView.frame = fitFrame
            oriImageCenter = imageView.center
            scrollView.setZoomScale(1.0, animated: false)
        }
    }
    
    @objc private func onSingleTap(_ tap: UITapGestureRecognizer) {
        delegate?.singleTap(self)
    }
    
    @objc private func onDoubleTap(_ tap: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1.0 {
            let pointInView = tap.location(in: imageView)
            let w = scrollView.frame.size.width / imageScaleForDoubleTap
            let h = scrollView.frame.size.height / imageScaleForDoubleTap
            let x = pointInView.x - (w / 2.0)
            let y = pointInView.y - (h / 2.0)
            scrollView.zoom(to: CGRect(x: x, y: y, width: w, height: h), animated: true)
        } else {
            scrollView.setZoomScale(1.0, animated: true)
        }
    }

    @objc private func onPan(_ pan: UIPanGestureRecognizer) {
        guard scrollView.zoomScale == 1.0 else { return }
        
        let height = UIScreen.height
        let halfHeight = height / 2
        var alpha = CGFloat(1.0)
        
        switch pan.state {
        case .began: break
        case .changed:
            let translation = pan.translation(in: imageView.superview)
            
            // if x > y, means scroll to left or right
            let tx = abs(translation.x)
            let ty = abs(translation.y)
            if tx > ty { return }
            
            let y = pan.view!.center.y + translation.y
            
            // Calculator alpha
            alpha = y < halfHeight ? y / halfHeight : (height - y) / halfHeight
            
            // add 0.15 because don't want fast to transparent
            alpha += 0.15
            delegate?.panDidChanged(self, in: imageView, alpha: alpha)
            
            imageView.center = CGPoint(x: imageView.center.x, y: y)
            pan.setTranslation(.zero, in: imageView.superview)
        case .ended, .cancelled:
            let translation = pan.translation(in: imageView.superview)
            
            // if x > y, means scroll to left or right
            let tx = abs(translation.x)
            let ty = abs(translation.y)
            
            if tx > ty {
                // if x > y but y has move a little then image center to origin
                if imageView.center != oriImageCenter {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.imageView.center = self.oriImageCenter
                    }) { (finished) in
                        self.delegate?.panDidChanged(self, in: self.imageView, alpha: 1.0)
                    }
                }
                
                return
            }
            
            delegate?.panDidEnded(self, in: imageView)
        default: break
        }
    }
}

// MARK: - UIScrollViewDelegate
extension EasyAlbumPageContentVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageView.center = centerOfContentSize
    }
}

// MARK: - UIGestureRecognizerDelegate
extension EasyAlbumPageContentVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        // allow scroll can to left or right
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = pan.translation(in: imageView)
            return abs(translation.x) >= abs(translation.y)
        }
        
        // if true means both(UIPanGestureRecognizer & UICollectionView) otherwise UIPanGestureRecognizer
        return true
    }
}
