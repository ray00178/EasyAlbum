//
//  PhotoManager.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/4.
//  Copyright © 2019 Ray. All rights reserved.
//

import Photos

struct PhotoManager {
    
    /// 使用者允許讀取相簿 callback
    typealias DidAuthorized = () -> Swift.Void
    
    /// 使用者允許讀取相簿但僅顯示部分照片 callback，firstRequest：是否第一次詢問
    typealias DidLimited = (_ firstRequest: Bool) -> Swift.Void
    
    /// 使用者不允許讀取相簿 callback
    typealias DidDenied = () -> Swift.Void
    
    /// PHImageRequestOptions Setting
    ///
    /// - fast: Photos efficiently resizes the image to a size similar to, or slightly larger than, the target size.
    /// - exact: Photos resizes the image to match the target size exactly.
    enum Options {
        case fast
        
        case exact(isSync: Bool)
        
        var parameters: (resize: PHImageRequestOptionsResizeMode, delivery: PHImageRequestOptionsDeliveryMode, sync: Bool) {
            switch self {
            case .fast:
                let resize = PHImageRequestOptionsResizeMode.fast
                let delivery = PHImageRequestOptionsDeliveryMode.fastFormat
                return (resize, delivery, false)
            case .exact(let isSync):
                let resize = PHImageRequestOptionsResizeMode.exact
                let delivery = PHImageRequestOptionsDeliveryMode.highQualityFormat
                return (resize, delivery, isSync)
            }
        }
    }
    
    static let share = PhotoManager()
    
    /// Photo manager object
    private(set) var imageManager: PHCachingImageManager?
    private(set) var requestOptions: PHImageRequestOptions!
    
    /// Thumbnail photo size
    private(set) var photoThumbnailSize: CGSize = .zero
    
    /// Save animated album of id's
    private(set) var animatedIDs: Set<String> = Set()
    
    private init() {
        let density = UIScreen.density
        photoThumbnailSize = CGSize(width: 100 * density, height: 100 * density)
        
        // https://developer.apple.com/documentation/photos/phcachingimagemanager
        imageManager = PHCachingImageManager()
        imageManager?.allowsCachingHighQualityImages = false

        requestOptions = PHImageRequestOptions()
        requestOptions.isNetworkAccessAllowed = false
    }
    
    /// 請求相簿權限
    /// - Parameters:
    ///   - didAuthorized: 使用者允許讀取相簿 callback
    ///   - didLimited: 使用者允許讀取相簿但僅顯示部分照片 callback
    ///   - didDenied: 使用者不允許讀取相簿 callback
    public func requestPermission(didAuthorized: DidAuthorized?,
                                  didLimited: DidLimited?,
                                  didDenied: DidDenied?) {
        if #available(iOS 14.0, *) {
            switch PHPhotoLibrary.authorizationStatus() {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { (status) in
                    DispatchQueue.main.async {
                        switch status {
                        case .authorized:
                            didAuthorized?()
                        case .limited:
                            didLimited?(true)
                        case .denied, .restricted:
                            didDenied?()
                        case .notDetermined:
                            // do nothing...
                            break
                        @unknown default:
                            break
                        }
                    }
                }
            case .authorized:
                didAuthorized?()
            case .limited:
                didLimited?(false)
            case .denied, .restricted:
                didDenied?()
            default:
                break
            }
        } else {
            switch PHPhotoLibrary.authorizationStatus() {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { (status) in
                    DispatchQueue.main.async {
                        switch status {
                        case .authorized:
                            didAuthorized?()
                        case .denied, .restricted:
                            didDenied?()
                        default:
                            break
                        }
                    }
                }
            case .authorized:
                didAuthorized?()
            case .denied, .restricted:
                didDenied?()
            default:
                break
            }
        }
    }
    
    /// Fetch all photos
    ///
    /// - Parameters:
    ///   - datas: input datas
    ///   - pickColor: pick color
    public mutating func fetchPhotos(in folders: inout [AlbumFolder], pickColor: UIColor) {
        // PHAssetCollectionType
        // https://developer.apple.com/documentation/photos/phassetcollectiontype
        // PHAssetCollectionSubtype
        // https://developer.apple.com/documentation/photos/phassetcollectionsubtype
        // http://www.jianshu.com/p/8cf7593cc44d
        // PHFetchOptions
        // https://developer.apple.com/documentation/photos/phfetchoptions
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeAssetSourceTypes = .typeUserLibrary
        
        // Smart album
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                  subtype: .albumRegular,
                                                                  options: fetchOptions)
        
        // DropBox、Instagram ... else
        let albums = PHAssetCollection.fetchAssetCollections(with: .album,
                                                             subtype: .albumRegular,
                                                             options: fetchOptions)
        
        // 取出所有相片
        //let allPhotos = PHAsset.fetchAssets(with: fetchOptions)
        // 取出所有使用者建立的相簿列表(保留)
        //let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil) as! PHFetchResult<PHAssetCollection>

        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        var temps: [(collection: PHAssetCollection, assets: PHFetchResult<PHAsset>)] = []
        
        for i in 0 ..< albums.count {
            let c = smartAlbums[i]
            let assets = PHAsset.fetchAssets(in: c , options: options)
            
            // if album count = 0, not show
            guard assets.count > 0 else { continue }
            
            temps.append((c, assets))
        }
        
        for i in 0 ..< smartAlbums.count {
            let c = smartAlbums[i]
            let assets = PHAsset.fetchAssets(in: c , options: options)
            
            // if album is delete album, not show
            guard isDeleted(with: c.localizedTitle) == false else { continue }
            
            // if album count = 0, not show
            guard assets.count > 0 else { continue }
            
            // if album is animated, then save asset localIdentifier
            if isAnimated(with: c.localizedTitle) {
                for j in 0 ..< assets.count {
                    animatedIDs.insert(assets[j].localIdentifier)
                }
            }
            
            temps.append((c, assets))
        }
        
        // sort by the count from greatest to least
        temps.sort { $0.assets.count > $1.assets.count }
        
        temps.forEach {
            folders.append(AlbumFolder(title: $0.collection.localizedTitle,
                                       assets: $0.assets))
        }
    }
    
    /// Fetch thumbnail photo
    public func fetchThumbnail(form asset: PHAsset,
                               size: CGSize? = nil,
                               options: Options,
                               completion: @escaping (_ image: UIImage) -> Swift.Void) {
        requestOptions.resizeMode = options.parameters.resize
        requestOptions.deliveryMode = options.parameters.delivery
        requestOptions.isSynchronous = options.parameters.sync
        
        var thumbnailSize = photoThumbnailSize
        
        if let t = size { thumbnailSize = t }
        
        let _ = imageManager?.requestImage(for: asset,
                                            targetSize: thumbnailSize,
                                            contentMode: .aspectFill,
                                            options: requestOptions,
                                            resultHandler:
        { (result, info) -> Void in
            var thumbnail = UIImage()
            if let image = result { thumbnail = image }
            completion(thumbnail)
        })
    }
    
    /// Fetch photo
    public func fetchImage(form asset: PHAsset,
                           size: CGSize,
                           options: Options,
                           completion: @escaping (_ image: UIImage) -> Swift.Void) {
        requestOptions.resizeMode = options.parameters.resize
        requestOptions.deliveryMode = options.parameters.delivery
        requestOptions.isSynchronous = options.parameters.sync
        
        let _ = PHImageManager.default().requestImage(for: asset,
                                                      targetSize: size,
                                                      contentMode: .aspectFit,
                                                      options: requestOptions)
        { (result, info) in
            var thumbnail = UIImage()
            if let image = result { thumbnail = image }
            completion(thumbnail)
        }
    }
    
    /// Fetch image data
    public func fetchImageData(from asset: PHAsset,
                               options: Options,
                               completion: @escaping (_ data: Data?, _ utiKey: String?) -> Swift.Void) {
        requestOptions.resizeMode = options.parameters.resize
        requestOptions.deliveryMode = options.parameters.delivery
        requestOptions.isSynchronous = options.parameters.sync
        
        let imageManager = PHImageManager.default()
        if #available(iOS 13, *) {
            let _ = imageManager.requestImageDataAndOrientation(for: asset,
                                                                options: requestOptions)
            { (data, utiKey, orientation, info) in
                completion(data, utiKey)
            }
        } else {
            let _ = imageManager.requestImageData(for: asset, options: requestOptions)
            { (data, utiKey, orientation, info) in
                completion(data, utiKey)
            }
        }
    }
    
    public func startCacheImage(prefetchItemsAt assets: [PHAsset], options: Options) {
        // https://viblo.asia/p/create-a-simple-image-picker-just-like-the-camera-roll-6J3Zgk8AZmB
        requestOptions.resizeMode = options.parameters.resize
        requestOptions.deliveryMode = options.parameters.delivery
        requestOptions.isSynchronous = options.parameters.sync
        
        imageManager?.startCachingImages(for: assets,
                                          targetSize: photoThumbnailSize,
                                          contentMode: .aspectFill,
                                          options: requestOptions)
    }
    
    public func stopCacheImage(cancelPrefetchingForItemsAt assets: [PHAsset], options: Options) {
        requestOptions.resizeMode = options.parameters.resize
        requestOptions.deliveryMode = options.parameters.delivery
        requestOptions.isSynchronous = options.parameters.sync
        
        imageManager?.stopCachingImages(for: assets,
                                         targetSize: photoThumbnailSize,
                                         contentMode: .aspectFill,
                                         options: requestOptions)
    }
    
    public func stopAllCachingImages() {
        imageManager?.stopCachingImagesForAllAssets()
    }
    
    public func fetchImageName(from asset: PHAsset) -> String? {
        return PHAssetResource.assetResources(for: asset).first?.originalFilename
    }
    
    public func fetchImageUTI(from asset: PHAsset) -> String? {
        return PHAssetResource.assetResources(for: asset).first?.uniformTypeIdentifier
    }
    
    public func fetchImageURL(from asset: PHAsset,
                              completion: @escaping (_ url : URL?) -> Swift.Void) {
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = false
        asset.requestContentEditingInput(with: options) { (input, info) in
            completion(input?.fullSizeImageURL)
        }
    }
    
    /// PHAsset convert AlbumData task
    public func cenvertTask(from assets: [PHAsset],
                            factor: EasyAlbumSizeFactor,
                            completion: @escaping (_ datas: [AlbumData]) -> Swift.Void) {
        var datas: [AlbumData] = []
        let grp = DispatchGroup()
        let queue = DispatchQueue(label: EasyAlbumCore.EASYALBUM_BUNDLE_ID)
        
        for asset in assets {
            grp.enter()
            queue.async {
                let width = CGFloat(asset.pixelWidth)
                let height = CGFloat(asset.pixelHeight)
                let size = self.calcScaleFactor(from: CGSize(width: width, height: height), factor: factor)
                let mediaType = asset.mediaType.rawValue
                let createDate = asset.creationDate
                let modificationDate = asset.modificationDate
                let isFavorite = asset.isFavorite
                let isHidden = asset.isHidden
                let location = asset.location
                let fileName = self.fetchImageName(from: asset)
                var fileData: Data? = nil
                var fileSize = 0
                var fileUTI = ""
                
                self.fetchImageData(from: asset,
                                    options: .fast,
                                    completion:
                { (data, uti)  in
                    if let data = data {
                        fileData = data
                        fileSize = data.count
                    }
                    
                    if let uti = uti {
                        fileUTI = uti
                    }
                    
                    self.fetchImage(form: asset,
                                    size: size,
                                    options: .exact(isSync: false),
                                    completion:
                    { (image) in
                        datas.append(AlbumData(image,
                                               mediaType: mediaType,
                                               width: width,
                                               height: height,
                                               creationDate: createDate,
                                               modificationDate: modificationDate,
                                               isFavorite: isFavorite,
                                               isHidden: isHidden,
                                               location: location,
                                               fileName: fileName,
                                               fileData: fileData,
                                               fileSize: fileSize,
                                               fileUTI: fileUTI))
                        grp.leave()
                    })
                })
            }
        }
        
        grp.notify(queue: .main) { completion(datas) }
    }
    
    /// Calculator photo scale factor
    public func calcScaleFactor(from size: CGSize, factor: EasyAlbumSizeFactor = .auto) -> CGSize {
        let oriW = size.width
        let oriH = size.height
        
        switch factor {
        case .auto:
            let w = UIScreen.width * UIScreen.density
            let h = UIScreen.height * UIScreen.density
            
            let screenW = UIScreen.isPortrait ? w : h
            let screenH = UIScreen.isPortrait ? h : w

            var factor: CGFloat = 1.0
            if oriW > screenW || oriH > screenH {
                factor = min(screenW / oriW, screenH / oriH)
            }
            
            return CGSize(width: oriW * factor, height: oriH * factor)
        case .fit(let reqW, let reqH):
            var factor: CGFloat = 1.0
            if oriW > reqW || oriH > reqH {
                factor = min(reqW / oriW, reqH / oriH)
            }
            
            return CGSize(width: oriW * factor, height: oriH * factor)
        case .scale(let scaleW, let scaleH):
            return CGSize(width: oriW * scaleW, height: oriH * scaleH)
        case .original:
            return size
        }
    }
    
    /// 檢查該相片是否為動圖
    /// - Parameter asset: see more PHAsset
    /// - Returns: If true means is animated, otherwise false.
    public func isAnimatedImage(from asset: PHAsset) -> Bool {
        if #available(iOS 11.0, *) {
            return asset.playbackStyle == .imageAnimated
        } else {
            return animatedIDs.contains(asset.localIdentifier)
        }
    }
    
    /// Check album is `Animated`
    private func isAnimated(with title: String?) -> Bool {
        guard let title = title else { return false }
        
        switch title {
        case "動圖", "动图", "Animated", "アニメーション", "움직이는 항목": return true
        default: return false
        }
    }
    
    /// Check album is `Recently Deleted`
    private func isDeleted(with title: String?) -> Bool {
        guard let title = title else { return false }
        
        switch title {
        case "最近刪除", "最近删除", "Recently Deleted", "最近削除した項目", "최근 삭제된 항목": return true
        default: return false
        }
    }
    
    #if DEBUG
    private func printLog(with asset: PHAsset, title: String, isGif: Bool) {
        print("title               👉🏻 \(title)")
        print("isGif               👉🏻 \(isGif)")
        print("burstIdentifier     👉🏻 \(String(describing: asset.burstIdentifier))")
        print("burstSelectionTypes 👉🏻 \(String(describing: asset.burstSelectionTypes))")
        print("creationDate        👉🏻 \(String(describing: asset.creationDate))")
        print("modificationDate    👉🏻 \(String(describing: asset.modificationDate))")
        print("duration            👉🏻 \(String(describing: asset.duration))")
        print("isFavorite          👉🏻 \(String(describing: asset.isFavorite))")
        print("isHidden            👉🏻 \(String(describing: asset.isHidden))")
        print("location            👉🏻 \(String(describing: asset.location))")
        print("mediaType           👉🏻 \(String(describing: asset.mediaType.rawValue))")
        print("mediaSubtypes       👉🏻 \(String(describing: asset.mediaSubtypes.rawValue))")
        print("pixelWidth          👉🏻 \(String(describing: asset.pixelWidth))")
        print("pixelHeight         👉🏻 \(String(describing: asset.pixelHeight))")
        print("representsBurst     👉🏻 \(String(describing: asset.representsBurst))")
        print("sourceType          👉🏻 \(String(describing: asset.sourceType.rawValue))")
        print("------------------------------------------")
    }
    #endif
}
