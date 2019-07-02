//
//  EasyAlbumPreviewViewController.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/3.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit
import Photos

protocol EasyAlbumPreviewViewControllerDelegate: AnyObject {
    func easyAlbumPreviewViewController(didSelectedWith markPhotos: [AlbumPhoto], removeItems: [Int],
                                        item: Int, send: Bool)
}

class EasyAlbumPreviewViewController: UIViewController {
    private enum Anchor {
        case top
        case leading
        case bottom
        case trailing
    }
    
    private var mCollectionView: UICollectionView!
    private var mBackBtn: UIButton!
    private var mNumberBtn: UIButton!
    private var mSmallNumberLab: UILabel!
    private var mSendBtn: UIButton!
    
    var limit: Int = 5
    var selectItem: Int = 0
    var pickColor: UIColor = UIColor(hex: "ffc107")
    var message: String = ""
    var mAlbumPhotos: [AlbumPhoto] = []
    var mMarkPhotos: [AlbumPhoto] = []
    
    /// 紀錄刪除的Item
    var mRemoveItems: [Int] = []
    
    /// 圖片管理對象
    private var photoManager: PhotoManager = PhotoManager.share
    /// 緩存圖片對象
    private var mImgCache: NSCache<AnyObject, UIImage>?
    /// 緩存圖片Data對象
    private var mImgDataCache: NSCache<AnyObject, NSData>?
    
    private let portraitLeadingForBack: CGFloat = 17.0
    private let portraitLeading: CGFloat = 20.0
    private let portraitTrailing: CGFloat = -20.0
    private let portraitTop: CGFloat = 54.0
    private let portraitBottom: CGFloat = -58.0
    
    private let landscapeLeadingForBack: CGFloat = 59.0
    private let landscapeLeading: CGFloat = 62.0
    private let landscapeTrailing: CGFloat = -62.0
    private let landscapeTop: CGFloat = 14.0
    private let landscapeBottom: CGFloat = -46.0
    
    /// 控制statusbar是否隱藏狀態，default：false
    private var hide: Bool = false
    
    weak var delegate: EasyAlbumPreviewViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mImgCache?.removeAllObjects()
        mImgDataCache?.removeAllObjects()
    }
    
    override var prefersStatusBarHidden: Bool {
        return hide
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    /*override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        autoDynamicConstant(in: UIScreen.orientation)
        mCollectionView.collectionViewLayout.invalidateLayout()
        
        let indexPath = IndexPath(row: selectIndex, section: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.mCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }*/
    
    private func setup() {
        mImgCache = NSCache()
        mImgDataCache = NSCache()
                
        let mFlowLayout = UICollectionViewFlowLayout()
        mFlowLayout.scrollDirection = .horizontal
        mFlowLayout.sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        mFlowLayout.minimumLineSpacing = CGFloat(0.0)
        
        mCollectionView = UICollectionView(frame: .zero, collectionViewLayout: mFlowLayout)
        mCollectionView.registerCell(AlbumPreviewCell.self, isNib: false)
        mCollectionView.registerCell(AlbumPreviewGIFCell.self, isNib: false)
        mCollectionView.backgroundColor = .black
        mCollectionView.isPagingEnabled = true
        mCollectionView.showsVerticalScrollIndicator = false
        mCollectionView.showsHorizontalScrollIndicator = false
        mCollectionView.delegate = self
        mCollectionView.dataSource = self
        mCollectionView.useAutoLayout = false
        view.addSubview(mCollectionView)
        mCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mCollectionView.isHidden = true
        
        var btnWH: CGFloat = 26.0
        mBackBtn = UIButton(type: .system)
        mNumberBtn = UIButton(type: .custom)
        view.addSubview(mBackBtn)
        view.addSubview(mNumberBtn)
        
        mBackBtn.setImage(UIImage.bundle(image: "album_back"), for: .normal)
        mBackBtn.tintColor = .white
        mBackBtn.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        mBackBtn.useAutoLayout = false
        mBackBtn.widthAnchor.constraint(equalToConstant: btnWH).isActive = true
        mBackBtn.heightAnchor.constraint(equalToConstant: btnWH).isActive = true
        mBackBtn.topAnchor.constraint(equalTo: view.topAnchor,
                                      constant: autoConstant(for: .top)).isActive = true
        mBackBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                          constant: autoConstant(for: .leading, isBack: true)).isActive = true
        //mBackBtn.centerXAnchor.constraint(equalTo: mNumberBtn.centerXAnchor).isActive = true

        btnWH = 30.0
        mNumberBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
        mNumberBtn.setTitleColor(UIColor.white, for: .normal)
        mNumberBtn.layer.cornerRadius = btnWH / 2
        mNumberBtn.layer.borderColor = UIColor.white.cgColor
        mNumberBtn.layer.borderWidth = 3.0
        mNumberBtn.addTarget(self, action: #selector(numberClicked(_:)), for: .touchUpInside)
        mNumberBtn.useAutoLayout = false
        mNumberBtn.widthAnchor.constraint(equalToConstant: btnWH).isActive = true
        mNumberBtn.heightAnchor.constraint(equalToConstant: btnWH).isActive = true
        mNumberBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                           constant: autoConstant(for: .bottom)).isActive = true
        mNumberBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                            constant: autoConstant(for: .leading)).isActive = true
        
        btnWH = 50.0
        let padding: CGFloat = 14.0
        mSendBtn = UIButton(type: .custom)
        mSendBtn.setImage(UIImage.bundle(image: "album_done"), for: .normal)
        mSendBtn.imageEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        mSendBtn.backgroundColor = .white
        mSendBtn.layer.cornerRadius = btnWH / 2
        mSendBtn.addTarget(self, action: #selector(done(_:)), for: .touchUpInside)
        mSendBtn.useAutoLayout = false
        view.addSubview(mSendBtn)
        mSendBtn.widthAnchor.constraint(equalToConstant: btnWH).isActive = true
        mSendBtn.heightAnchor.constraint(equalToConstant: btnWH).isActive = true
        mSendBtn.centerYAnchor.constraint(equalTo: mNumberBtn.centerYAnchor).isActive = true
        mSendBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                           constant: autoConstant(for: .trailing)).isActive = true
        
        btnWH = 22.0
        mSmallNumberLab = UILabel(frame: .zero)
        mSmallNumberLab.text = "\(mMarkPhotos.count)"
        mSmallNumberLab.textColor = .white
        mSmallNumberLab.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        mSmallNumberLab.textAlignment = .center
        mSmallNumberLab.backgroundColor = pickColor
        mSmallNumberLab.layer.cornerRadius = btnWH / 2
        mSmallNumberLab.layer.masksToBounds = true
        mSmallNumberLab.isHidden = mMarkPhotos.count == 0
        mSmallNumberLab.useAutoLayout = false
        view.addSubview(mSmallNumberLab)
        mSmallNumberLab.widthAnchor.constraint(equalToConstant: btnWH).isActive = true
        mSmallNumberLab.heightAnchor.constraint(equalToConstant: btnWH).isActive = true
        mSmallNumberLab.topAnchor.constraint(equalTo: mSendBtn.topAnchor, constant: -5.0).isActive = true
        mSmallNumberLab.trailingAnchor.constraint(equalTo: mSendBtn.trailingAnchor, constant: 5.0).isActive = true
        
        if #available(iOS 11.0, *) {
            mCollectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.mCollectionView.isHidden = false
            self.mCollectionView.scrollToItem(at: IndexPath(item: self.selectItem, section: 0),
                                              at: .centeredHorizontally, animated: false)
            self.changeButtonNumber()
        }
    }
    
    private func changeButtonNumber() {
        let photo = mAlbumPhotos[selectItem]
        let pickNumber = photo.pickNumber
        mNumberBtn.layer.borderColor = pickNumber > 0 ?
            photo.pickColor.cgColor : UIColor(white: 1.0, alpha: 0.78).cgColor
        mNumberBtn.backgroundColor = pickNumber > 0 ?
            photo.pickColor : UIColor(hex: "000000", alpha: 0.1)
        mNumberBtn.setTitle(pickNumber > 0 ? "\(pickNumber)" : "", for: .normal)
    }
    
    private func changePhotoNumber() {
        for i in 0 ..< mMarkPhotos.count {
            mMarkPhotos[i].pickNumber = i + 1
            let asset = mMarkPhotos[i].asset
            if let index = mAlbumPhotos.firstIndex(where: { return $0.asset == asset }) {
                mAlbumPhotos[index].pickNumber = i + 1
            }
        }
        mSmallNumberLab.text = "\(mMarkPhotos.count)"
        mSmallNumberLab.isHidden = mMarkPhotos.count == 0
    }
    
    private func autoConstant(for anchor: Anchor, isBack: Bool = false) -> CGFloat {
        switch anchor {
        case .top: return UIScreen.isLandscape ? landscapeTop : portraitTop
        case .leading:
            if isBack { return UIScreen.isLandscape ? landscapeLeadingForBack : portraitLeadingForBack }
            return UIScreen.isLandscape ? landscapeLeading : portraitLeading
        case .bottom: return UIScreen.isLandscape ? landscapeBottom : portraitBottom
        case .trailing: return UIScreen.isLandscape ? landscapeTrailing : portraitTrailing
        }
    }
    
    private func autoDynamicConstant(in orientation: UIDeviceOrientation) {
        switch orientation {
        case .portrait:
            for c in view.constraints {
                if let btn = c.firstItem as? UIButton, btn == mBackBtn {
                    switch c.firstAttribute {
                    case .top: c.constant = portraitTop
                    //case .leading: c.constant = portraitLeading
                    default:break
                    }
                }
                if let btn = c.firstItem as? UIButton, btn == mNumberBtn {
                    switch c.firstAttribute {
                    case .bottom: c.constant = portraitBottom
                    case .leading: c.constant = portraitLeading
                    default:break
                    }
                }
                if let btn = c.firstItem as? UIButton, btn == mSendBtn {
                    switch c.firstAttribute {
                    case .trailing: c.constant = portraitTrailing
                    default:break
                    }
                }
            }
        case .landscapeLeft, .landscapeRight:
            for c in view.constraints {
                if let btn = c.firstItem as? UIButton, btn == mBackBtn {
                    switch c.firstAttribute {
                    case .top: c.constant = landscapeTop
                    //case .leading: c.constant = landscapeLeading
                    default:break
                    }
                }
                if let btn = c.firstItem as? UIButton, btn == mNumberBtn {
                    switch c.firstAttribute {
                    case .bottom: c.constant = landscapeBottom
                    case .leading: c.constant = landscapeLeading
                    default:break
                    }
                }
                if let btn = c.firstItem as? UIButton, btn == mSendBtn {
                    switch c.firstAttribute {
                    case .trailing: c.constant = landscapeTrailing
                    default:break
                    }
                }
            }
        default:break
        }
    }
    
    @objc private func done(_ btn: UIButton) {
        delegate?.easyAlbumPreviewViewController(didSelectedWith: mMarkPhotos, removeItems: mRemoveItems,
                                                 item: selectItem, send: true)
        dismiss(animated: false, completion: nil)
    }
    
    @objc private func back(_ btn: UIButton) {
        delegate?.easyAlbumPreviewViewController(didSelectedWith: mMarkPhotos, removeItems: mRemoveItems,
                                                 item: selectItem, send: false)
        dismiss(animated: false, completion: nil)
    }
    
    @objc private func numberClicked(_ btn: UIButton) {
        let photo = mAlbumPhotos[selectItem]
        let asset = photo.asset!
        let isCheck = photo.isCheck

        if isCheck {
            if let i = mMarkPhotos.firstIndex(where: { return $0.asset == asset }) {
                mMarkPhotos.remove(at: i)
            }
            photo.pickNumber = 0
            mRemoveItems.append(selectItem)
        } else {
            guard mMarkPhotos.count <= (limit - 1) else {
                AlbumToast.share.show(with: message)
                return
            }
            
            photo.pickNumber = mMarkPhotos.count + 1
            mMarkPhotos.append(photo)
        }
        
        mAlbumPhotos[selectItem].isCheck = !isCheck
        changeButtonNumber()
        changePhotoNumber()
    }
}

extension EasyAlbumPreviewViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mAlbumPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = indexPath.item
        let photo = mAlbumPhotos[item]
        let asset = photo.asset!
        let cell = collectionView.dequeueCell(photo.isGIF ? AlbumPreviewGIFCell.self : AlbumPreviewCell.self,
                                              indexPath: indexPath)
        
        if photo.isGIF, let cell = cell as? AlbumPreviewGIFCell {
            cell.representedAssetIdentifier = asset.localIdentifier
            cell.delegate = self
        } else if let cell = cell as? AlbumPreviewCell {
            cell.representedAssetIdentifier = asset.localIdentifier
            cell.delegate = self
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let item = indexPath.item
        let photo = mAlbumPhotos[item]
        let asset = photo.asset!
        
        if photo.isGIF, let cell = cell as? AlbumPreviewGIFCell {
            if let data = mImgDataCache?.object(forKey: asset) {
                if cell.representedAssetIdentifier == asset.localIdentifier {
                    cell.data = Data(referencing: data)
                }
            } else {
                photoManager.fetchImageData(from: asset, isSynchronous: false) { [weak self] (data, _) in
                    guard let data = data else { return }
                    self?.mImgDataCache?.setObject(NSData(data: data), forKey: asset)
                    if cell.representedAssetIdentifier == asset.localIdentifier {
                        cell.data = data
                    }
                }
            }
        } else if let cell = cell as? AlbumPreviewCell {
            if let img = mImgCache?.object(forKey: asset) {
                if cell.representedAssetIdentifier == asset.localIdentifier {
                    cell.setData(from: img)
                }
            } else {
                let width = asset.pixelWidth
                let height = asset.pixelHeight
                let size = photoManager.calcScaleFactor(from: CGSize(width: width, height: height))
                photoManager.fetchThumbnail(form: asset, size: size, isSynchronous: false) { (image) in
                    self.mImgCache?.setObject(image, forKey: asset)
                    if cell.representedAssetIdentifier == asset.localIdentifier {
                        cell.setData(from: image)
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        photoManager.startCacheImage(prefetchItemsAt: indexPaths, photos: mAlbumPhotos)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        photoManager.stopCacheImage(cancelPrefetchingForItemsAt: indexPaths, photos: mAlbumPhotos)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        /*let offSetX = scrollView.contentOffset.x
        let width = scrollView.bounds.width
        let _ = Int(offSetX / width)*/
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 顯示目前index
        let offSetX = scrollView.contentOffset.x
        let width = scrollView.bounds.width
        let index = Int(offSetX / width)
        selectItem = index
        changeButtonNumber()
    }
}

extension EasyAlbumPreviewViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.width, height: UIScreen.height)
    }
}

extension EasyAlbumPreviewViewController: AlbumCellDelegate {
    func albumCellSingleTap(_ cell: UICollectionViewCell) {
        hide.toggle()
        setNeedsStatusBarAppearanceUpdate()
        let views: [UIView] = [mBackBtn, mSendBtn, mSmallNumberLab]
        UIView.animate(withDuration: 0.2) {
            views.forEach({ $0.alpha = self.hide ? 0.0 : 1.0 })
        }
    }
}
