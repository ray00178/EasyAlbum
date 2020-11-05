//
//  EasyAlbumVC.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/3.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

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
    
    private var titleButton: UIButton!
    private var refreshCtrl: UIRefreshControl!
    private var collectionView: UICollectionView!
    private var doneView: AlbumDoneView?
    private var toast: AlbumToast?
    private var doneViewHeightConst: NSLayoutConstraint?
    
    private var photoManager: PhotoManager = PhotoManager.share
    
    /// Cache image object
    private var imageCache: NSCache<AnyObject, UIImage>?
    
    /// Put item size for portrait or landscape
    private var dynamicItemSizeDictionary: Dictionary<Bool, CGSize> = [:]
    
    /// Album folders
    private var albumFolders: [AlbumFolder] = []
    
    /// Album category type index
    private var categoryIndex: Int = 0
    
    private var currentResultAsset: PHFetchResult<PHAsset>?
    
    /// Selected photos，default = []
    private var selectedPhotos: [PhotoData] = []
        
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
        addAlbumObserver()
        requestPhotoPermission()
    }
    
    override func viewDidLayoutSubviews() {
        safeAreaBottom = view.layoutMargins.bottom
        
        if #available(iOS 11.0, *) {
            safeAreaBottom = view.safeAreaInsets.bottom
        }
        
        doneViewHeightConst?.constant = doneViewHeight + safeAreaBottom
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // When device rotate, trigger invalidateLayout
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    deinit {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            photoManager.stopAllCachingImages()
        }
        
        imageCache?.removeAllObjects()
        
        NotificationCenter.default.removeObserver(self)
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
        
        titleButton = UIButton(type: .custom)
        titleButton.setTitleColor(titleColor, for: .normal)
        titleButton.titleLabel?.font = font
        navigationItem.titleView = titleButton

        let barClose = UIBarButtonItem(image: UIImage.bundle(image: .close),
                                       style: .plain,
                                       target: self,
                                       action: #selector(close(_:)))
        let barCamera = UIBarButtonItem(image: UIImage.bundle(image: .camera),
                                        style: .plain,
                                        target: self,
                                        action: #selector(openCamera(_:)))
        navigationItem.leftBarButtonItem = barClose
        navigationItem.rightBarButtonItem = showCamera ? barCamera : nil
        
        refreshCtrl = UIRefreshControl()
        refreshCtrl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        refreshCtrl.tintColor = .gray
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = CGFloat(1)
        flowLayout.minimumLineSpacing = CGFloat(1)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.registerHeader(AlbumCategoryView.self, isNib: false)
        collectionView.registerCell(AlbumPhotoCell.self, isNib: false)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.refreshControl = refreshCtrl
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        // AutoLayout
        if #available(iOS 11.0, *) {
            collectionView.leadingAnchor
                          .constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
                          .isActive = true
            collectionView.trailingAnchor
                          .constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
                          .isActive = true
        } else {
            collectionView.leadingAnchor
                          .constraint(equalTo: view.leadingAnchor)
                          .isActive = true
            collectionView.trailingAnchor
                          .constraint(equalTo: view.trailingAnchor)
                          .isActive = true
        }
        
        collectionView.topAnchor
                      .constraint(equalTo: view.topAnchor)
                      .isActive = true
        collectionView.bottomAnchor
                      .constraint(equalTo: view.bottomAnchor)
                      .isActive = true
        
        refreshCtrl.beginRefreshing()
    }
    
    private func addAlbumObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(photoNumberDidChangeNotification(_:)),
                                               name: .EasyAlbumPhotoNumberDidChangeNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(previewPageDismissNotification(_:)),
                                               name: .EasyAlbumPreviewPageDismissNotification,
                                               object: nil)
        PHPhotoLibrary.shared().register(self)
    }
    
    private func requestPhotoPermission() {
        photoManager.requestPermission {
            self.loadAlbums(isLimit: false)
        } didLimited: { (isLimit) in
            self.loadAlbums(isLimit: isLimit)
            
            if #available(iOS 14, *), isLimit {
                let library = PHPhotoLibrary.shared()
                library.register(self)
                library.presentLimitedLibraryPicker(from: self)
            }
        } didDenied: {
            self.showDialog(with: .photo)
        }
    }
    
    private func addToastView() {
        guard let navigationVC = navigationController as? EasyAlbumNAC else { return }
        
        toast = AlbumToast(navigationVC: navigationVC, barTintColor: barTintColor)
        toast?.translatesAutoresizingMaskIntoConstraints = false
        navigationVC.navigationBar.addSubview(toast!)
        
        // AutoLayout
        toast?.topAnchor
              .constraint(equalTo: navigationVC.navigationBar.topAnchor)
              .isActive = true
        toast?.leadingAnchor
              .constraint(equalTo: navigationVC.navigationBar.leadingAnchor)
              .isActive = true
        toast?.trailingAnchor
              .constraint(equalTo: navigationVC.navigationBar.trailingAnchor)
              .isActive = true
        toast?.bottomAnchor
              .constraint(equalTo: navigationVC.navigationBar.bottomAnchor)
              .isActive = true
    }
    
    private func addDoneView() {
        doneView = AlbumDoneView()
        doneView?.delegate = self
        doneView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneView!)

        // AutoLayout
        doneViewHeightConst = doneView?.heightAnchor.constraint(equalToConstant: 0.0)
        doneViewHeightConst?.isActive = true
        
        doneView?.topAnchor
                 .constraint(equalTo: view.bottomAnchor)
                 .isActive = true
        
        if #available(iOS 11.0, *) {
            doneView?.leadingAnchor
                     .constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
                     .isActive = true
            doneView?.trailingAnchor
                     .constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
                     .isActive = true
        } else {
            doneView?.leadingAnchor
                     .constraint(equalTo: view.leadingAnchor)
                     .isActive = true
            doneView?.trailingAnchor
                     .constraint(equalTo: view.trailingAnchor)
                     .isActive = true
        }
    }
    
    private func loadAlbums(isLimit: Bool) {
        if imageCache == nil { imageCache = NSCache() }
        photoManager.fetchPhotos(in: &albumFolders, pickColor: pickColor)
        
        if isLimit == false {
            // Setup first is selected
            albumFolders[0].isCheck = true
            currentResultAsset = albumFolders[0].assets
            
            // Show first album name
            collectionView.reloadData()
            setNavigationTitle(with: albumFolders[0].title)

            // Stop refreshing and remove
            refreshCtrl.endRefreshing()
            collectionView.refreshControl = nil
            
            addToastView()
            addDoneView()
        }
    }
    
    private func showDialog(with permission: EasyAlbumPermission) {
        let witch = permission.description
        let msg = LString(.permissionMsg(appName: appName, witch: witch))
        let ac = UIAlertController(title: LString(.permissionTitle(witch: witch)),
                                   message: msg,
                                   preferredStyle: .alert)
        
        let setting = UIAlertAction(title: LString(.setting),
                                    style: .default)
        { (action) in
            let url = URL(string: UIApplication.openSettingsURLString)!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
                // Back to previous
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(320), execute: {
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
        
        ac.addAction(setting)
        present(ac, animated: true, completion: nil)
    }
    
    private func clickedNumberPhoto(on item: Int) {
        guard isProcessing == false else { return }
        guard let asset = currentResultAsset?[item] else { return }
        
        let isCheck = selectedPhotos.contains { $0.asset == asset }
        
        if isCheck {
            selectedPhotos.removeAll { $0.asset == asset }
        } else {
            guard selectedPhotos.count <= (limit - 1) else {
                toast?.show(with: message)
                return
            }
            
            selectedPhotos.append((asset, selectedPhotos.count + 1))
        }
        
        UIView.performWithoutAnimation {
            self.collectionView.reloadItems(at: [IndexPath(row: item, section: 0)])
        }
        
        changePhotoNumber()
        changeDoneViewData()
    }

    /// Change selected photo pick number
    private func changePhotoNumber() {
        var needReoloadItems: [Int] = []
        for (index, values) in selectedPhotos.enumerated() {
            selectedPhotos[index] = (values.asset, index + 1)
            
            if let i = currentResultAsset?.index(of: values.asset) {
                needReoloadItems.append(i)
            }
        }

        UIView.performWithoutAnimation {
            self.collectionView.reloadItems(at: needReoloadItems.map { IndexPath(item: $0, section: 0) })
        }
    }
    
    private func changeDoneViewData() {
        let isGreaterZero = selectedPhotos.count > 0
        let h = doneViewHeight + safeAreaBottom

        if isGreaterZero {
            let density = UIScreen.density
            let size = CGSize(width: AlbumDoneView.width * density, height: AlbumDoneView.height * density)
            photoManager.fetchThumbnail(form: selectedPhotos[0].asset,
                                        size: size,
                                        options: .exact(isSync: false))
            { [weak self] (image) in
                self?.doneView?.image = image
            }
                        
            doneView?.number = selectedPhotos.count
            UIView.animate(withDuration: animateDuration) {
                self.doneView?.transform = CGAffineTransform(translationX: 0.0, y: -h)
            }
        } else {
            UIView.animate(withDuration: animateDuration) {
                self.doneView?.transform = .identity
            }
        }
        
        // Setting collectionView content margin
        collectionView.contentInset = UIEdgeInsets(top: 0.0,
                                                   left: 0.0,
                                                   bottom: isGreaterZero ? h : 0.0,
                                                   right: 0.0)
    }
    
    private func setNavigationTitle(with text: String) {
        var width = text.height(with: 22.0, font: font)
        
        if let image = titleButton.imageView?.image {
           width += image.size.width
        }
        
        titleButton.frame.size = CGSize(width: width, height: 22.0)
        titleButton.setTitle(text, for: .normal)
    }
    
    private func convertTask() {
        guard isProcessing == false else { return }
        
        isProcessing = true
        
        toast?.show(with: LString(.photoProcess), autoCancel: false)
        photoManager.cenvertTask(from: selectedPhotos.compactMap({ $0.asset }), factor: sizeFactor)
        { [weak self] (datas) in
            self?.toast?.hide()
            self?.albumDelegate?.easyAlbumDidSelected(datas)
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func handlePhotoFromAppCamera(assets: [PHAsset]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(320)) {
            if isFromEasyAlbumCamera {
                isFromEasyAlbumCamera = false

                self.photoManager.cenvertTask(from: assets,
                                              factor: self.sizeFactor)
                { (datas) in
                    self.albumDelegate?.easyAlbumDidSelected(datas)
                    self.dismiss(animated: true, completion: nil)
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
            toast?.show(with: LString(.noCamera))
        }
    }
    
    // MARK: - Notification 通知
    
    @objc private func photoNumberDidChangeNotification(_ notification: Notification) {
        guard let albumNotification = notification.object as? AlbumNotification
        else { return }

        selectedPhotos = albumNotification.selectedPhotos
        collectionView.reloadItems(at: albumNotification.reloadItems)
        changeDoneViewData()
    }
    
    @objc private func previewPageDismissNotification(_ notification: Notification) {
        guard let albumNotification = notification.object as? AlbumNotification
        else { return }

        if albumNotification.isSend, selectedPhotos.isEmpty == false { convertTask() }
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension EasyAlbumVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentResultAsset?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(AlbumPhotoCell.self, indexPath: indexPath)
        
        let item = indexPath.item
        
        guard let asset = currentResultAsset?[item] else { return cell }
        
        cell.representedAssetIdentifier = asset.localIdentifier
        cell.delegate = self
        
        if let image = imageCache?.object(forKey: asset) {
            if cell.representedAssetIdentifier == asset.localIdentifier {
                let values = selectedPhotos.first { $0.asset == asset }
                cell.setData(from: asset,
                             image: image,
                             number: values?.number,
                             pickColor: pickColor,
                             item: item)
            }
        } else {
            let isPortrait = UIScreen.height >= UIScreen.width
            let size = dynamicItemSizeDictionary[isPortrait]?.scale(to: 1.8)
            
            photoManager.fetchThumbnail(form: asset, size: size, options: .exact(isSync: false))
            { [weak self] (image) in
                guard let self = self else { return }
                
                self.imageCache?.setObject(image, forKey: asset)
                if cell.representedAssetIdentifier == asset.localIdentifier {
                    let values = self.selectedPhotos.first { $0.asset == asset }
                    cell.setData(from: asset,
                                 image: image,
                                 number: values?.number,
                                 pickColor: self.pickColor,
                                 item: item)
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueHeader(AlbumCategoryView.self, indexPath: indexPath)
            headerView.datas = albumFolders
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
        
        let previewVC = EasyAlbumPreviewPageVC(transitionStyle: .scroll,
                                               navigationOrientation: .horizontal,
                                               options: nil)
        previewVC.limit = limit
        previewVC.pickColor = pickColor
        previewVC.message = message
        previewVC.orientation = orientation
        previewVC.currentItem = item
        previewVC.assets = currentResultAsset
        previewVC.selectedPhotos = selectedPhotos
        previewVC.cellFrame = cellFrame
        previewVC.modalPresentationStyle = .overCurrentContext

        present(previewVC, animated: false, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let assets = indexPaths.compactMap({ currentResultAsset?[$0.item] })
        
        DispatchQueue.main.async {
            self.photoManager.startCacheImage(prefetchItemsAt: assets, options: .fast)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        guard let count = currentResultAsset?.count, count < indexPaths.count
        else { return }
        
        var assets: [PHAsset?] = []
        for i in 0 ..< indexPaths.count {
            assets.append(i < count ? currentResultAsset?[i] : nil)
        }
        
        DispatchQueue.main.async {
            self.photoManager.startCacheImage(prefetchItemsAt: assets.compactMap { $0 }, options: .fast)
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
        
        if let size = dynamicItemSizeDictionary[isPortrait] {
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
        
        dynamicItemSizeDictionary[isPortrait] = size
        return size
    }
}

// MARK: - AlbumPhotoCellDelegate
extension EasyAlbumVC: AlbumPhotoCellDelegate {
    
    func albumPhotoCell(didNumberClickAt item: Int) {
        clickedNumberPhoto(on: item)
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
        for i in 0 ..< albumFolders.count { albumFolders[i].isCheck = false }
        
        categoryIndex = index
        albumFolders[index].isCheck = true
        currentResultAsset = albumFolders[index].assets
        
        setNavigationTitle(with: albumFolders[index].title)
        collectionView.reloadData()
    }
}

// MARK: - PHPhotoLibraryChangeObserver
extension EasyAlbumVC: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Update all folder assets
        for (index, folder) in albumFolders.enumerated() {
            if let changeDetails = changeInstance.changeDetails(for: folder.assets) {
                albumFolders[index].assets = changeDetails.fetchResultAfterChanges
            }
        }
        
        if let assets = currentResultAsset,
           let changeDetails = changeInstance.changeDetails(for: assets) {
            currentResultAsset = changeDetails.fetchResultAfterChanges
            
            DispatchQueue.main.async {
                if changeDetails.hasIncrementalChanges {
                    guard let collectionView = self.collectionView else { fatalError() }

                    // Handle removals, insertions, and moves in a batch update.
                    collectionView.performBatchUpdates {
                        if let removed = changeDetails.removedIndexes,
                           removed.isEmpty == false {
                            collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                        }
                        
                        if let inserted = changeDetails.insertedIndexes,
                           inserted.isEmpty == false {
                            collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                        }
                    } completion: { (finished) in
                        // We are reloading items after the batch update since
                        // `PHFetchResultChangeDetails.changedIndexes` refers to
                        // items in the *after* state and not the *before* state as expected by
                        // `performBatchUpdates(_:completion:)`.
                        if let changed = changeDetails.changedIndexes,
                           changed.isEmpty == false,
                           finished == true {
                            collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                        }
                        
                        for asset in changeDetails.removedObjects {
                            if let i = self.selectedPhotos.firstIndex(where: { $0.asset == asset }) {
                                self.selectedPhotos.remove(at: i)
                            }
                        }

                        self.changePhotoNumber()
                        self.changeDoneViewData()
                    }
                } else {
                    // Reload the collection view if incremental changes are not available.
                    self.collectionView.reloadData()
                }
                
                self.handlePhotoFromAppCamera(assets: changeDetails.insertedObjects)
            }
        }
    }
}
