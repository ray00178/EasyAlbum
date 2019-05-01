//
//  EasyAlbumViewController.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/3.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit
import Photos

public protocol EasyAlbumDelegate: AnyObject {
    func easyAlbumDidSelected(_ photos: [AlbumData])
    
    func easyAlbumDidCanceled()
}

class EasyAlbumViewController: UIViewController {
    var appName: String = "EasyAlbum"
    var limit: Int = 30
    var span: Int = 3
    var titleColor: UIColor = .white
    var pickColor: UIColor = UIColor(hex: "ffc107")
    var crop: Bool = false
    var showCamera: Bool = true
    var showGIF: Bool = true
    var message: String = ""
    var sizeFactor: EasyAlbumSizeFactor = .auto
    
    weak var delegate: EasyAlbumDelegate?
    
    /// 圖片管理對象
    private var photoManager: PhotoManager = PhotoManager.share
    /// 緩存圖片對象
    private var mImgCache: NSCache<AnyObject, UIImage>?
    //private var mImgCache: NSCache<NSIndexPath, UIImage>?
    
    /// 相簿資料夾
    private var mAlbumFolders: [AlbumFolder] = []
    /// 照片(PHAsset)
    private var mAlbumPhotos: [AlbumPhoto] = []
    /// 紀錄已點選的照片
    private var mMarkPhotos: [AlbumPhoto] = []
    
    /// 是否第一次載入讀取，default：true
    private var isFirstLoad: Bool = true
    
    /// 相簿分類的index
    private var categoryIndex: Int = 0
    
    private let font = UIFont.systemFont(ofSize: 18.0, weight: .medium)
    private let doneViewHeight: CGFloat = 40.0
    private var safeAreaBottom: CGFloat = 0.0
    private let animateDuration: TimeInterval = 0.25
    
    private var mTitleBtn: UIButton!
    private var mLoadingView: UIActivityIndicatorView!
    private var mCollectionView: UICollectionView!
    private var mDoneView: AlbumDoneView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFirstLoad {
            checkAlbumPermission()
            if #available(iOS 11.0, *) {
                // UIEdgeInsets(top: 88.0, left: 0.0, bottom: 34.0, right: 0.0)
                safeAreaBottom = view.safeAreaInsets.bottom
            } else {
                safeAreaBottom = view.layoutMargins.bottom
            }
            addDoneView()
            isFirstLoad = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        photoManager.clear()
        mImgCache?.removeAllObjects()
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    private func setup() {
        view.backgroundColor = .white
        
        if message.isEmpty { message = LString(.overLimit(count: limit)) }
        
        mTitleBtn = UIButton(type: .custom)
        mTitleBtn.titleLabel?.font = font
        navigationItem.titleView = mTitleBtn

        let close = UIBarButtonItem(image: UIImage.image(named: "album_close"),
                                    style: .plain, target: self, action: #selector(close(_:)))
        let camera = UIBarButtonItem(image: UIImage.image(named: "album_camera"),
                                     style: .plain, target: self, action: #selector(openCamera(_:)))
        navigationItem.leftBarButtonItem = close
        navigationItem.rightBarButtonItem = showCamera ? camera : nil
        
        let mFlowLayout = UICollectionViewFlowLayout()
        let divider = CGFloat(span - 1)
        let itemW = (UIScreen.width - divider) / CGFloat(span)
        let itemH = itemW
        let itemSize = CGSize(width: itemW, height: itemH)
        mFlowLayout.minimumInteritemSpacing = CGFloat(1)
        mFlowLayout.minimumLineSpacing = CGFloat(1)
        mFlowLayout.itemSize = itemSize
        
        mCollectionView = UICollectionView(frame: .zero, collectionViewLayout: mFlowLayout)
        mCollectionView.registerHeader(AlbumCategoryView.self, isNib: false)
        mCollectionView.registerCell(AlbumPhotoCell.self)
        mCollectionView.showsVerticalScrollIndicator = false
        mCollectionView.backgroundColor = .white
        mCollectionView.alpha = 0
        mCollectionView.delegate = self
        mCollectionView.dataSource = self
        mCollectionView.useAutoLayout = false
        view.addSubview(mCollectionView)
        mCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        mLoadingView = UIActivityIndicatorView(style: .gray)
        mLoadingView.useAutoLayout = false
        view.addSubview(mLoadingView)
        mLoadingView.topAnchor.constraint(equalTo: mCollectionView.topAnchor, constant: 120.0).isActive = true
        mLoadingView.centerXAnchor.constraint(equalTo: mCollectionView.centerXAnchor).isActive = true
        
        PHPhotoLibrary.shared().register(self)
    }
    
    private func addDoneView() {
        mDoneView = AlbumDoneView()
        mDoneView.delegate = self
        mDoneView.useAutoLayout = false
        view.addSubview(mDoneView)
        mDoneView.widthAnchor.constraint(equalToConstant: UIScreen.width).isActive = true
        mDoneView.heightAnchor.constraint(equalToConstant: doneViewHeight + safeAreaBottom).isActive = true
        mDoneView.topAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mDoneView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func checkAlbumPermission() {
        mLoadingView.startAnimating()
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized, .notDetermined:
                self.loadAlbums()
            case .denied:
                self.showDialog(with: .photo)
            default: break // restricted
            }
        }
    }
    
    private func loadAlbums() {
        mImgCache = NSCache()        
        photoManager.fetchPhotos(in: &mAlbumFolders, filterGIF: !showGIF, pickColor: pickColor)
        // 預設第一個為點選狀態
        mAlbumFolders[0].isCheck = true
        mAlbumPhotos = mAlbumFolders[0].photos
        DispatchQueue.main.async {
            // 顯示第一本相簿的名稱
            self.mCollectionView.reloadData()
            self.mCollectionView.alpha = 1.0
            self.setNavigationTitle(with: self.mAlbumFolders[0].title)
            self.mLoadingView.stopAnimating()
        }
    }
    
    private func showDialog(with permission: EasyAlbumPermission) {
        let witch = permission.description
        let msg = LString(.permissionMsg(appName: appName, witch: witch))
        let ac = UIAlertController(title: LString(.permissionTitle(witch: witch)), message: msg, preferredStyle: .alert)
        let setting = UIAlertAction(title: LString(.setting), style: .default) { (action) in
            let url = URL(string: UIApplication.openSettingsURLString)!
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        ac.addAction(setting)
        present(ac, animated: true, completion: nil)
        
        DispatchQueue.main.async { self.mLoadingView.stopAnimating() }
    }
    
    private func clickedPhoto(on item: Int) {
        let photo = mAlbumPhotos[item]
        let asset = photo.asset!
        let isCheck = photo.isCheck
        
        if isCheck {
            if let i = mMarkPhotos.firstIndex(where: { return $0.asset == asset }) {
                mMarkPhotos.remove(at: i)
            }
            photo.pickNumber = 0
        } else {
            // 檢查目前挑選數量是否達到紹上限
            guard mMarkPhotos.count <= (limit - 1) else {
                AlbumToast.share.show(with: message)
                return
            }
            
            photo.pickNumber = mMarkPhotos.count + 1
            mMarkPhotos.append(photo)
        }
        
        mAlbumPhotos[item].isCheck = !isCheck
        mCollectionView.reloadItems(at: [IndexPath(row: item, section: 0)])
        changePhotoNumber()
        showDoneView()
    }
    
    private func showDoneView() {
        let isGreaterZero = mMarkPhotos.count > 0
        let h = doneViewHeight + safeAreaBottom
        if isGreaterZero {
            let density = UIScreen.density
            let size = CGSize(width: AlbumDoneView.width * density, height: AlbumDoneView.height * density)
            photoManager.fetchThumbnail(form: mMarkPhotos[0].asset, size: size, isSynchronous: false) {
                [weak self] (image) in
                self?.mDoneView.image = image
            }
            mDoneView.number = mMarkPhotos.count
            UIView.animate(withDuration: animateDuration) {
                self.mDoneView.transform = CGAffineTransform(translationX: 0.0, y: -h)
            }
        } else {
            UIView.animate(withDuration: animateDuration) {
                self.mDoneView.transform = .identity
            }
        }
        // 調整collectionView content間距
        mCollectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0,
                                                    bottom: isGreaterZero ? doneViewHeight : 0.0, right: 0.0)
    }
    
    /// 改變目前點選照片的索引
    private func changePhotoNumber() {
        for i in 0 ..< mMarkPhotos.count {
            mMarkPhotos[i].pickNumber = i + 1
            let asset = mMarkPhotos[i].asset
            if let index = mAlbumPhotos.firstIndex(where: { return $0.asset == asset }) {
                mCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        }
    }
    
    private func setNavigationTitle(with text: String) {
        var width = text.height(with: 22.0, font: font)
        if let image = mTitleBtn.imageView?.image {
           width += image.size.width
        }
        mTitleBtn.frame.size = CGSize(width: width, height: 22.0)
        mTitleBtn.setTitle(text, for: .normal)
    }
    
    private func convertTask() {
        AlbumToast.share.show(with: LString(.photoProcess), autoCancel: false)
        photoManager.cenvertTask(from: mMarkPhotos, factor: sizeFactor) { (datas) in
            self.delegate?.easyAlbumDidSelected(datas)
            self.dismiss(animated: true, completion: nil)
            AlbumToast.share.hide()
        }
    }
    
    @objc private func close(_ btn: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func openCamera(_ btn: UIButton) {
        let hasCamera = UIImagePickerController.isSourceTypeAvailable(.camera)
        if hasCamera {
            // 檢查相機是否授權
            let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
            switch authStatus {
            case .authorized, .notDetermined:
                let camera = EasyAlbumCameraViewController()
                camera.isEdit = crop
                present(camera, animated: true, completion: nil)
            case .denied:
                showDialog(with: .camera)
            default: break // restricted
            }
        } else {
            AlbumToast.share.show(with: LString(.noCamera))
        }
    }
}

extension EasyAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mAlbumPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(AlbumPhotoCell.self, indexPath: indexPath)
        
        let item = indexPath.item
        let photo = mAlbumPhotos[item]
        let asset = photo.asset!
        cell.representedAssetIdentifier = asset.localIdentifier
        
        if let img = mImgCache?.object(forKey: asset) {
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.setData(from: photo, image: img, item: item)
            }
        } else {
            photoManager.fetchThumbnail(form: asset, size: nil, isSynchronous: false) { [weak self] (image) in
                self?.mImgCache?.setObject(image, forKey: asset)
                //print("cellForItemAt from fetchThumbnail 👉🏻 \(item) \(image)")
                if cell.representedAssetIdentifier == asset.localIdentifier {
                    cell.setData(from: photo, image: image, item: item)
                }
            }
        }
        
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {}
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let section = indexPath.section
        if section == 0 {
            let headerView = collectionView.dequeueHeader(AlbumCategoryView.self, indexPath: indexPath)
            headerView.datas = mAlbumFolders
            headerView.delegate = self
            return headerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = indexPath.item
        
        let previewVC = EasyAlbumPreviewViewController()
        previewVC.limit = limit
        previewVC.pickColor = pickColor
        // 檢查目前的相片，所對應全部相片的第幾張(保留 2019.04.13 Sat)
        //previewVC.selectIndex = mAlbumFolders[0].photos.firstIndex(of: mAlbumPhotos[item]) ?? item
        //previewVC.mAlbumPhotos = mAlbumFolders[0].photos
        previewVC.selectItem = item
        previewVC.message = message
        previewVC.mAlbumPhotos = mAlbumPhotos
        previewVC.mMarkPhotos = mMarkPhotos
        previewVC.delegate = self
        present(previewVC, animated: false, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        photoManager.startCacheImage(prefetchItemsAt: indexPaths, photos: mAlbumPhotos)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        photoManager.stopCacheImage(cancelPrefetchingForItemsAt: indexPaths, photos: mAlbumPhotos)
    }
}

extension EasyAlbumViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return section == 0 ? CGSize(width: UIScreen.width, height: AlbumCategoryView.height) : .zero
    }
}

extension EasyAlbumViewController: AlbumPhotoCellDelegate {
    func albumPhotoCell(didNumberClickAt item: Int) {
        clickedPhoto(on: item)
    }
}

extension EasyAlbumViewController: AlbumDoneViewDelegate {
    func albumDoneViewDidClicked(_ albumDoneView: AlbumDoneView) {
        convertTask()
    }
}

extension EasyAlbumViewController: AlbumCategoryViewDelegate {
    func albumCategoryView(_ albumCategoryView: AlbumCategoryView, didSelectedAt index: Int) {
        for i in 0 ..< mAlbumFolders.count { mAlbumFolders[i].isCheck = false }
        categoryIndex = index
        mAlbumFolders[index].isCheck = true
        mAlbumPhotos = mAlbumFolders[index].photos
        setNavigationTitle(with: mAlbumFolders[index].title)
        mCollectionView.reloadData()
    }
}

extension EasyAlbumViewController: EasyAlbumPreviewViewControllerDelegate {
    func easyAlbumPreviewViewController(didSelectedWith markPhotos: [AlbumPhoto], removeItems: [Int],
                                        item: Int, send: Bool) {
        mMarkPhotos = markPhotos
        for i in 0 ..< markPhotos.count {
            if let index = mAlbumPhotos.firstIndex(of: markPhotos[i]) {
                mAlbumPhotos[index].isCheck = true
                mAlbumPhotos[index].pickNumber = markPhotos[i].pickNumber
                mCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        }
        
        for item in removeItems {
            mAlbumPhotos[item].isCheck = false
            mAlbumPhotos[item].pickNumber = 0
            mCollectionView.reloadItems(at: [IndexPath(item: item, section: 0)])
        }
        
        mCollectionView.scrollToItem(at: IndexPath(item: item, section: 0), at: .centeredVertically, animated: false)
        showDoneView()
        
        if send { convertTask() }
    }
}

extension EasyAlbumViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard photoManager.assetsArray.count > 0 else { return }
        guard let changes = changeInstance.changeDetails(for: photoManager.assetsArray[categoryIndex]) else { return }
        /*
         [
         PHPhotoLibraryChangeObserver insertedObjects
         <PHAsset: 0x1048e1f50> 73AC25BD-AEE7-43F9-AA9F-B53C28E4B779/L0/001
         mediaType=1/0,
         sourceType=1, (3024x4032),
         creationDate=2019-04-27 14:07:21 +0000,
         location=0,
         hidden=0,
         favorite=0
         ]
         */
        let assets = changes.insertedObjects
        if assets.count > 0 && isFromEasyAlbumCamera {
            isFromEasyAlbumCamera = false
            photoManager.cenvertTask(from: assets, factor: sizeFactor) { (datas) in
                self.delegate?.easyAlbumDidSelected(datas)
                self.dismiss(animated: true, completion: nil)
            }
        }

        /*DispatchQueue.main.async {
            if changes.hasIncrementalChanges {
                self.mCollectionView.performBatchUpdates({
                    if let removed = changes.removedIndexes, !removed.isEmpty {
                        for asset in changes.removedObjects {
                            self.mMarkPhotos.removeAll(where: { $0.asset == asset })
                        }
                        self.mCollectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    
                    if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                        for asset in changes.insertedObjects {
                            
                        }
                        
                       self.mCollectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    
                    changes.enumerateMoves { fromIndex, toIndex in
                        self.mCollectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                      to: IndexPath(item: toIndex, section: 0))
                    }
                }, completion: { (finished) in
                    self.showDoneView()
                })
            }
            self.photoManager.stopAllCachingImages()
        }*/
    }
}
