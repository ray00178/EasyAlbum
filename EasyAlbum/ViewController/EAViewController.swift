//
//  EasyAlbumVC.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/3.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit
import Photos

class EasyAlbumVC: UIViewController {
        
    var appName: String = EasyAlbumCore.APP_NAME
    var barTintColor: UIColor = EasyAlbumCore.BAR_TINT_COLOR
    var limit: Int = EasyAlbumCore.LIMIT
    var span: Int = EasyAlbumCore.SPAN
    var titleColor: UIColor = EasyAlbumCore.TINT_COLOR
    var pickColor: UIColor = EasyAlbumCore.PICK_COLOR
    var crop: Bool = EasyAlbumCore.CROP
    var showCamera: Bool = EasyAlbumCore.SHOW_CAMERA
    var message: String = EasyAlbumCore.MESSAGE
    var sizeFactor: EasyAlbumSizeFactor = EasyAlbumCore.SIZE_FACTOR
    var orientation: UIInterfaceOrientationMask = EasyAlbumCore.ORIENTATION
    
    weak var albumDelegate: EasyAlbumDelegate?
    
    private var mTitleBtn: UIButton!
    private var mRefreshCtrl: UIRefreshControl!
    private var mCollectionView: UICollectionView!
    private var mDoneView: AlbumDoneView?
    private var mToast: AlbumToast?
    
    private var photoManager: PhotoManager = PhotoManager.share
    
    /// Cache image object
    private var mImgCache: NSCache<AnyObject, UIImage>?
    
    /// Put item size for portrait or landscape
    private var mDynamicItemSize: Dictionary<Bool, CGSize> = [:]
    
    /// Album folders
    private var mAlbumFolders: [AlbumFolder] = []
    
    /// Photos(PHAsset)
    private var mAlbumPhotos: [AlbumPhoto] = []
    
    /// Save selected photo
    private var mSelectedPhotos: [AlbumPhoto] = []
    
    /// Is first loading，default = false
    private var isLoaded: Bool = false
    
    /// Album category type index
    private var categoryIndex: Int = 0
    
    private var isPortrait: Bool = UIScreen.isPortrait
    
    /// Is processing photo，default = false
    private var isProcessing: Bool = false
    
    private let font = UIFont.systemFont(ofSize: 18.0, weight: .medium)
    private let doneViewHeight: CGFloat = 54.0
    private var safeAreaBottom: CGFloat = 0.0
    private let animateDuration: TimeInterval = 0.25
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        safeAreaBottom = view.layoutMargins.bottom
        if #available(iOS 11.0, *) {
            safeAreaBottom = view.safeAreaInsets.bottom
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAlbumPermission()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // When device rotate, trigger invalidateLayout
        mCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    deinit {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            photoManager.stopAllCachingImages()
        }
        
        mImgCache?.removeAllObjects()
        
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        
        #if targetEnvironment(simulator)
        print("EasyAlbumVC deinit 👍🏻")
        #endif
    }
    
    private func setup() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        view.backgroundColor = .white
        
        if message.isEmpty { message = LString(.overLimit(count: limit)) }
        
        mTitleBtn = UIButton(type: .custom)
        mTitleBtn.setTitleColor(titleColor, for: .normal)
        mTitleBtn.titleLabel?.font = font
        navigationItem.titleView = mTitleBtn

        let close = UIBarButtonItem(image: UIImage.bundle(image: .close),
                                    style: .plain, target: self, action: #selector(close(_:)))
        let camera = UIBarButtonItem(image: UIImage.bundle(image: .camera),
                                     style: .plain, target: self, action: #selector(openCamera(_:)))
        navigationItem.leftBarButtonItem = close
        navigationItem.rightBarButtonItem = showCamera ? camera : nil
        
        mRefreshCtrl = UIRefreshControl()
        mRefreshCtrl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        mRefreshCtrl.tintColor = .gray
        
        let mFlowLayout = UICollectionViewFlowLayout()
        mFlowLayout.minimumInteritemSpacing = CGFloat(1)
        mFlowLayout.minimumLineSpacing = CGFloat(1)
        
        mCollectionView = UICollectionView(frame: .zero, collectionViewLayout: mFlowLayout)
        mCollectionView.registerHeader(AlbumCategoryView.self, isNib: false)
        mCollectionView.registerCell(AlbumPhotoCell.self)
        mCollectionView.showsVerticalScrollIndicator = false
        mCollectionView.backgroundColor = .white
        mCollectionView.delegate = self
        mCollectionView.dataSource = self
        mCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mCollectionView)
    
        if #available(iOS 10.0, *) {
            mCollectionView.prefetchDataSource = self
            mCollectionView.refreshControl = mRefreshCtrl
        } else {
            mCollectionView.addSubview(mRefreshCtrl)
        }
        
        if #available(iOS 11.0, *) {
            mCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            mCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        } else {
            mCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            mCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        }
        mCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        mRefreshCtrl.beginRefreshing()
        PHPhotoLibrary.shared().register(self)
    }
    
    private func addToastView() {
        guard let navigationVC = navigationController else { return }
        
        mToast = AlbumToast(navigationVC: navigationVC, barTintColor: barTintColor)
        mToast?.translatesAutoresizingMaskIntoConstraints = false
        navigationVC.navigationBar.addSubview(mToast!)
        
        mToast?.topAnchor.constraint(equalTo: navigationVC.navigationBar.topAnchor).isActive = true
        mToast?.leadingAnchor.constraint(equalTo: navigationVC.navigationBar.leadingAnchor).isActive = true
        mToast?.trailingAnchor.constraint(equalTo: navigationVC.navigationBar.trailingAnchor).isActive = true
        mToast?.bottomAnchor.constraint(equalTo: navigationVC.navigationBar.bottomAnchor).isActive = true
    }
    
    private func addDoneView() {
        mDoneView = AlbumDoneView()
        mDoneView?.delegate = self
        mDoneView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mDoneView!)
        
        mDoneView?.heightAnchor.constraint(equalToConstant: doneViewHeight + safeAreaBottom).isActive = true
        mDoneView?.topAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            mDoneView?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            mDoneView?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        } else {
            mDoneView?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            mDoneView?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        }
    }
    
    private func loadAlbums() {
        if isLoaded { return }
        
        mImgCache = NSCache()
        photoManager.fetchPhotos(in: &mAlbumFolders, pickColor: pickColor)
        
        // Setup first is selected
        mAlbumFolders[0].isCheck = true
        mAlbumPhotos = mAlbumFolders[0].photos
        
        isLoaded = true
        
        // Show first album name
        mCollectionView.reloadData()
        setNavigationTitle(with: mAlbumFolders[0].title)
        
        // Stop refreshing and remove
        mRefreshCtrl.endRefreshing()
        if #available(iOS 10.0, *) {
            mCollectionView.refreshControl = nil
        } else {
            mRefreshCtrl.removeFromSuperview()
        }
        
        addToastView()
        addDoneView()
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
                
                // Back to previous
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
        
        ac.addAction(setting)
        present(ac, animated: true, completion: nil)
    }
    
    private func clickedPhoto(on item: Int) {
        guard !isProcessing else { return }
        
        let photo = mAlbumPhotos[item]
        let asset = photo.asset
        let isCheck = photo.isCheck
        
        if isCheck {
            if let i = mSelectedPhotos.firstIndex(where: { return $0.asset == asset }) {
                mSelectedPhotos.remove(at: i)
            }
            photo.pickNumber = 0
        } else {
            // Check selected count = limit count
            guard mSelectedPhotos.count <= (limit - 1) else {
                mToast?.show(with: message)
                return
            }
            
            photo.pickNumber = mSelectedPhotos.count + 1
            mSelectedPhotos.append(photo)
        }
        
        mAlbumPhotos[item].isCheck = !isCheck
        mCollectionView.reloadItems(at: [IndexPath(row: item, section: 0)])
        changePhotoNumber()
        showDoneView()
    }
    
    private func showDoneView() {
        let isGreaterZero = mSelectedPhotos.count > 0
        let h = doneViewHeight + safeAreaBottom

        if isGreaterZero {
            let density = UIScreen.density
            let size = CGSize(width: AlbumDoneView.width * density, height: AlbumDoneView.height * density)
            photoManager.fetchThumbnail(form: mSelectedPhotos[0].asset, size: size, options: .exact(isSync: false)) {
                [weak self] (image) in
                self?.mDoneView?.image = image
            }
            mDoneView?.number = mSelectedPhotos.count
            UIView.animate(withDuration: animateDuration) {
                self.mDoneView?.transform = CGAffineTransform(translationX: 0.0, y: -h)
            }
        } else {
            UIView.animate(withDuration: animateDuration) {
                self.mDoneView?.transform = .identity
            }
        }
        
        // Setting collectionView content margin
        mCollectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0,
                                                    bottom: isGreaterZero ? doneViewHeight : 0.0, right: 0.0)
    }
    
    /// Change selected photo pick number
    private func changePhotoNumber() {
        for i in 0 ..< mSelectedPhotos.count {
            mSelectedPhotos[i].pickNumber = i + 1
            let asset = mSelectedPhotos[i].asset
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
        guard !isProcessing else { return }
        
        isProcessing = true
        
        mToast?.show(with: LString(.photoProcess), autoCancel: false)
        photoManager.cenvertTask(from: mSelectedPhotos, factor: sizeFactor) { (datas) in
            self.mToast?.hide()
            self.albumDelegate?.easyAlbumDidSelected(datas)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - CheckAlbumPermission
    @objc private func checkAlbumPermission() {
        PHPhotoLibrary.requestAuthorization { (status) in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .notDetermined:
                    self.loadAlbums()
                case .denied, .restricted:
                    self.showDialog(with: .photo)
                default: break
                }
            }
        }
    }
    
    @objc private func close(_ btn: UIButton) {
        albumDelegate?.easyAlbumDidCanceled()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func openCamera(_ btn: UIButton) {
        let hasCamera = UIImagePickerController.isSourceTypeAvailable(.camera)
        if hasCamera {
            let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
            switch authStatus {
            case .authorized, .notDetermined:
                let camera = EasyAlbumCameraVC()
                camera.isEdit = crop
                present(camera, animated: true, completion: nil)
            case .denied, .restricted:
                showDialog(with: .camera)
            default: break
            }
        } else {
            mToast?.show(with: LString(.noCamera))
        }
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension EasyAlbumVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
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
        let asset = photo.asset
        cell.representedAssetIdentifier = asset.localIdentifier
        
        if let img = mImgCache?.object(forKey: asset) {
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.setData(from: photo, image: img, item: item)
            }
        } else {
            let isPortrait = UIScreen.height >= UIScreen.width
            let size = mDynamicItemSize[isPortrait]?.scale(to: 1.8)
            
            photoManager.fetchThumbnail(form: asset, size: size, options: .exact(isSync: false)) { [weak self] (image) in
                self?.mImgCache?.setObject(image, forKey: asset)
                if cell.representedAssetIdentifier == asset.localIdentifier {
                    cell.setData(from: photo, image: image, item: item)
                }
            }
        }
        
        cell.delegate = self
        return cell
    }
    
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
        guard !isProcessing else { return }
        
        // Get cell position relative `collectionView.contentOffset = .zero`
        var cellFrame: CGRect = .zero
        if let cell = collectionView.cellForItem(at: indexPath) as? AlbumPhotoCell {
            let originX = cell.frame.minX
            let relativeY = cell.center.y - collectionView.contentOffset.y
            cellFrame = CGRect(origin: CGPoint(x: originX, y: relativeY), size: cell.frame.size)
        }
        
        let item = indexPath.item
        
        let previewVC = EasyAlbumPreviewPageVC(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        previewVC.limit = limit
        previewVC.pickColor = pickColor
        previewVC.message = message
        previewVC.orientation = orientation
        previewVC.selectedItem = item
        previewVC.mAlbumPhotos = mAlbumPhotos
        previewVC.mSelectedPhotos = mSelectedPhotos
        previewVC.cellFrame = cellFrame
        previewVC.pageDelegate = self
        previewVC.modalPresentationStyle = .overCurrentContext
        
        present(previewVC, animated: false, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let assets = indexPaths.map({ mAlbumPhotos[$0.row].asset })
        DispatchQueue.main.async {
            self.photoManager.startCacheImage(prefetchItemsAt: assets, options: .fast)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        guard mAlbumPhotos.count >= indexPaths.count else { return }
        
        let assets = indexPaths.map({ mAlbumPhotos[$0.row].asset })
        DispatchQueue.main.async {
            self.photoManager.stopCacheImage(cancelPrefetchingForItemsAt: assets, options: .fast)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension EasyAlbumVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return section == 0 ? CGSize(width: UIScreen.width, height: AlbumCategoryView.height) : .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let isPortrait = UIScreen.height >= UIScreen.width
        
        if let size = mDynamicItemSize[isPortrait] {
            return size
        }
        
        // Get margin of left and right
        var left = CGFloat(0.0)
        var right = CGFloat(0.0)

        if #available(iOS 11.0, *) {
            left = view.safeAreaInsets.left
            right = view.safeAreaInsets.right
        }

        // Calc span count, if orientation = landscape, then span count + 2
        let spanCount = isPortrait ? span : span + 2
        
        let divider = CGFloat(spanCount - 1) + left + right
        let itemW = (UIScreen.width - divider) / CGFloat(spanCount)
        let itemH = itemW
        let size = CGSize(width: itemW, height: itemH)
        
        mDynamicItemSize[isPortrait] = size
        return size
    }
}

// MARK: - AlbumPhotoCellDelegate
extension EasyAlbumVC: AlbumPhotoCellDelegate {
    func albumPhotoCell(didNumberClickAt item: Int) {
        clickedPhoto(on: item)
    }
}

// MARK: - AlbumDoneViewDelegate
extension EasyAlbumVC: AlbumDoneViewDelegate {
    func albumDoneViewDidClicked(_ albumDoneView: AlbumDoneView) {
        convertTask()
    }
}

// MARK: - AlbumCategoryViewDelegate
extension EasyAlbumVC: AlbumCategoryViewDelegate {
    func albumCategoryView(_ albumCategoryView: AlbumCategoryView, didSelectedAt index: Int) {
        for i in 0 ..< mAlbumFolders.count { mAlbumFolders[i].isCheck = false }
        categoryIndex = index
        mAlbumFolders[index].isCheck = true
        mAlbumPhotos = mAlbumFolders[index].photos
        setNavigationTitle(with: mAlbumFolders[index].title)
        mCollectionView.reloadData()
    }
}

// MARK: - EasyAlbumPreviewPageVCDelegate
extension EasyAlbumVC: EasyAlbumPreviewPageVCDelegate {
    func easyAlbumPreviewPageVC(didSelectedWith markPhotos: [AlbumPhoto], removeItems: [Int], item: Int, send: Bool) {
        mSelectedPhotos = markPhotos
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
        
        showDoneView()
        
        if send { convertTask() }
    }
}

// MARK: - PHPhotoLibraryChangeObserver
extension EasyAlbumVC: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard photoManager.assetsArray.count > 0 else { return }
        guard let changes = changeInstance.changeDetails(for: photoManager.assetsArray[categoryIndex]) else { return }

        let assets = changes.insertedObjects
        if assets.count > 0 && isFromEasyAlbumCamera {
            isFromEasyAlbumCamera = false
            photoManager.cenvertTask(from: assets, factor: sizeFactor) { (datas) in
                self.albumDelegate?.easyAlbumDidSelected(datas)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
