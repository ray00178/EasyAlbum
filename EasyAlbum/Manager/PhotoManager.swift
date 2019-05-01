//
//  PhotoManager.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/4.
//  Copyright © 2019 Ray. All rights reserved.
//

import Photos

struct PhotoManager {
    static let share = PhotoManager()
    
    /// 圖片管理對象
    private(set) var mImageManager: PHCachingImageManager?
    private(set) var requestOptions: PHImageRequestOptions!
    private(set) var fetchOptions: PHFetchOptions!
    
    /// 儲存各相簿列表`PHFetchResult<PHAsset>`
    private(set) var assetsArray: [PHFetchResult<PHAsset>] = []
    
    /// 略縮圖大小
    private(set) var photoThumbnailSize: CGSize = .zero
    
    private init() {
        let density = UIScreen.density
        photoThumbnailSize = CGSize(width: 120 * density, height: 120 * density)
        
        // https://developer.apple.com/documentation/photos/phcachingimagemanager
        mImageManager = PHCachingImageManager()
        mImageManager?.allowsCachingHighQualityImages = false

        requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.resizeMode = .exact
        
        fetchOptions = PHFetchOptions()
        fetchOptions.includeAssetSourceTypes = .typeUserLibrary
        
        //PHPhotoLibrary.shared().register(self)
    }
    
    /// 取出所有相簿
    ///
    /// - Parameters:
    ///   - datas: 放置的資料
    ///   - filterGIF: 排除.gif
    ///   - pickColor: 點擊顏色
    public mutating func fetchPhotos(in datas: inout [AlbumFolder], filterGIF: Bool = false, pickColor: UIColor) {
        // 取出所有相簿列表
        // PHAssetCollectionType
        // https://developer.apple.com/documentation/photos/phassetcollectiontype
        // PHAssetCollectionSubtype
        // https://developer.apple.com/documentation/photos/phassetcollectionsubtype
        // http://www.jianshu.com/p/8cf7593cc44d
        // PHFetchOptions
        // https://developer.apple.com/documentation/photos/phfetchoptions
        
        // 智慧相簿
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular,
                                                                  options: fetchOptions)
        // DropBox、Instagram ... else
        let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular,
                                                             options: fetchOptions)
        // 取出所有相簿列表
        //let allPhotos = PHAsset.fetchAssets(with: fetchOptions)
        // 取出所有使用者建立的相簿列表(保留)
        //let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil) as! PHFetchResult<PHAssetCollection>
        
        // https://developer.apple.com/documentation/photos/phfetchoptions/1624709-predicate
        // predicate：篩選要的種類image video audio
        // sortDescriptors：排序方式
        // NSPredicate(format: "mediaType = %d || mediaType = %d", PHAssetMediaType.image.rawValue,    PHAssetMediaType.video.rawValue)
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        var tempCollections: [AlbumCollection] = []
        fetchAlbumsInfo(from: smartAlbums, output: &tempCollections, options: options)
        fetchAlbumsInfo(from: albums, output: &tempCollections, options: options)
        // 將相簿做排序依照數量大小
        var sortedCollections = tempCollections.sorted { (now, next) in return now.count > next.count }

        var animatedIDs: [String] = []
        // 取得Animated Collections
        let animatedCollections = sortedCollections.filter({ return isAnimated(with: $0.collection.localizedTitle) })
        // 取得Animated內的photo localIdentifier
        for ac in animatedCollections {
            let assets = ac.assets
            for i in 0 ..< assets.count {
                animatedIDs.append(assets[i].localIdentifier)
            }
        }
        
        if filterGIF {
            sortedCollections.removeAll{ element in isAnimated(with: element.collection.localizedTitle) }
        }
        
        // 剔除「最近刪除」相簿
        sortedCollections.removeAll{ element in isDeleted(with: element.collection.localizedTitle) }

        for ac in sortedCollections {
            let c = ac.collection
            // 取得該相簿的所有照片
            let assets = ac.assets
            var title: String = "Unknow"
            if let t = c.localizedTitle { title = t }
            
            assetsArray.append(assets)
            
            var photos: [AlbumPhoto] = []
            for j in 0 ..< assets.count {
                let asset = assets[j]
                
                var isGIF = false
                if animatedIDs.contains(asset.localIdentifier) {
                    if let uti = fetchImageUTI(from: asset) {
                        isGIF = uti == EasyAlbumCore.UTI_IMAGE_GIF
                    }
                }
                
                // 是否顯示GIF圖
                if isGIF && filterGIF { continue }
                                
                let albumPhoto = AlbumPhoto(0, asset: asset, pickNumber: 0, pickColor: pickColor,
                                            isCheck: false, isGIF: isGIF)
                
                if datas.count > 0 {
                     if let index = datas[0].photos.firstIndex(of: albumPhoto) {
                        //printLog(with: datas[0].photos[index].asset, title: title, isGif: isGIF)
                        photos.append(datas[0].photos[index])
                     }
                 } else {
                    photos.append(albumPhoto)
                 }
            }

            if photos.count > 0 {
                datas.append(AlbumFolder(title, photos: photos, pickColor: pickColor, isCheck: false))
            }
        }
    }
    
    /// 取得略縮圖
    public func fetchThumbnail(form asset: PHAsset, size: CGSize?, isSynchronous: Bool,
                               completion: @escaping (_ image: UIImage) -> Swift.Void) {
        // https://developer.apple.com/documentation/photos/phimagerequestoptions
        // http://stackoverflow.com/questions/30812057/phasset-to-uiimage
        requestOptions.isSynchronous = isSynchronous
        var thumbnailSize = photoThumbnailSize
        if let t = size { thumbnailSize = t }
        let _ = mImageManager?.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: requestOptions, resultHandler: {(result, info) -> Void in
            var thumbnail = UIImage()
            if let image = result { thumbnail = image }
            completion(thumbnail)
            self.requestOptions.isSynchronous = false
        })
    }
    
    /// 取得相片Data
    public func fetchImageData(from asset: PHAsset, isSynchronous: Bool,
                               completion: @escaping (_ data: Data?, _ utiKey: String?) -> Swift.Void) {
        requestOptions.isSynchronous = isSynchronous
        mImageManager?.requestImageData(for: asset, options: requestOptions, resultHandler: { (data, utiKey,
            orientation, info) in
            completion(data, utiKey)
            self.requestOptions.isSynchronous = false
        })
    }
    
    public func startCacheImage(prefetchItemsAt indexPaths: [IndexPath], photos:  [AlbumPhoto]) {
        // https://viblo.asia/p/create-a-simple-image-picker-just-like-the-camera-roll-6J3Zgk8AZmB
        DispatchQueue.main.async {
            let assets = indexPaths.map({ photos[$0.row].asset! })
            self.mImageManager?.startCachingImages(for: assets, targetSize: self.photoThumbnailSize, contentMode: .aspectFill, options: self.requestOptions)
        }
    }
    
    public func stopCacheImage(cancelPrefetchingForItemsAt indexPaths: [IndexPath], photos:  [AlbumPhoto]) {
        DispatchQueue.main.async {
            let assets = indexPaths.map({ photos[$0.row].asset! })
            self.mImageManager?.stopCachingImages(for: assets, targetSize: self.photoThumbnailSize, contentMode: .aspectFill, options: self.requestOptions)
        }
    }
    
    public func stopAllCachingImages() {
        self.mImageManager?.stopCachingImagesForAllAssets()
    }
    
    /// 取得相片檔名
    public func fetchImageName(from asset: PHAsset) -> String? {
        return PHAssetResource.assetResources(for: asset).first?.originalFilename
    }
    
    /// 取得相片UTI
    public func fetchImageUTI(from asset: PHAsset) -> String? {
        return PHAssetResource.assetResources(for: asset).first?.uniformTypeIdentifier
    }
    
    /// 取得相片URL
    public func fetchImageURL(from asset: PHAsset, completion: @escaping (_ url : URL?) -> Swift.Void) {
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = false
        asset.requestContentEditingInput(with: options) { (input, info) in
            completion(input?.fullSizeImageURL)
        }
    }
    
    /// AlbumPhoto convert AlbumData task
    public func cenvertTask(from photos: [AlbumPhoto], factor: EasyAlbumSizeFactor,
                            completion: @escaping (_ datas: [AlbumData]) -> Swift.Void) {
        var datas: [AlbumData] = []
        let grp = DispatchGroup()
        let queue = DispatchQueue(label: EasyAlbumCore.EASYALBUM_BUNDLE_ID)
        
        for photo in photos {
            grp.enter()
            queue.async {
                let width = CGFloat(photo.asset.pixelWidth)
                let height = CGFloat(photo.asset.pixelHeight)
                let size = self.calcScaleFactor(from: CGSize(width: width, height: height), factor: factor)
                let mediaType = photo.asset.mediaType.rawValue
                let createDate = photo.asset.creationDate
                let modificationDate = photo.asset.modificationDate
                let isFavorite = photo.asset.isFavorite
                let isHidden = photo.asset.isHidden
                let location = photo.asset.location
                let fileName = self.fetchImageName(from: photo.asset)
                var fileData: Data? = nil
                var fileSize = 0
                var fileUTI = EasyAlbumCore.IMAGE_JPEG
                self.fetchImageData(from: photo.asset, isSynchronous: true, completion: { (data, uti)  in
                    if let data = data, let uti = uti {
                        fileData = data
                        fileSize = Data(data).count
                        fileUTI = uti
                    }
                })
                self.fetchThumbnail(form: photo.asset, size: size, isSynchronous: false, completion: { (image) in
                    datas.append(AlbumData(image, mediaType: mediaType, width: width, height: height, creationDate: createDate, modificationDate: modificationDate, isFavorite: isFavorite, isHidden: isHidden, location: location, fileName: fileName, fileData: fileData, fileSize: fileSize, fileUTI: fileUTI))
                    grp.leave()
                })
            }
        }
        
        grp.notify(queue: .main) { completion(datas) }
    }
    
    /// AlbumPhoto convert AlbumData task
    public func cenvertTask(from assets: [PHAsset], factor: EasyAlbumSizeFactor,
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
                var fileUTI = EasyAlbumCore.UTI_IMAGE_JPEG
                self.fetchImageData(from: asset, isSynchronous: true, completion: { (data, uti)  in
                    if let data = data, let uti = uti {
                        fileData = data
                        fileSize = Data(data).count
                        fileUTI = uti
                    }
                })
                self.fetchThumbnail(form: asset, size: size, isSynchronous: false, completion: { (image) in
                    datas.append(AlbumData(image, mediaType: mediaType, width: width, height: height, creationDate: createDate, modificationDate: modificationDate, isFavorite: isFavorite, isHidden: isHidden, location: location, fileName: fileName, fileData: fileData, fileSize: fileSize, fileUTI: fileUTI))
                    grp.leave()
                })
            }
        }
        
        grp.notify(queue: .main) { completion(datas) }
    }
    
    /// 計算照片縮放倍率
    public func calcScaleFactor(from size: CGSize, factor: EasyAlbumSizeFactor = .auto) -> CGSize {
        let oriW = size.width
        let oriH = size.height
        
        switch factor {
        case .fit(let reqW, let reqH):
            var factor: CGFloat = 1.0
            if oriW > reqW || oriH > reqH {
                factor = min(reqW / oriW, reqH / oriH)
            }
            return CGSize(width: oriW * factor, height: oriH * factor)
        case .scale(let scaleW, let scaleH):
            return CGSize(width: oriW * scaleW, height: oriH * scaleH)
        default:
            let w = UIScreen.width * UIScreen.density
            let h = UIScreen.height * UIScreen.density
            
            var factor: CGFloat = 1.0
            if oriW > w || oriH > h {
                factor = min(w / oriW, h / oriH)
            }
            return CGSize(width: oriW * factor, height: oriH * factor)
        }
    }
    
    /// 清除緩存圖片
    public func clear() {
        mImageManager?.stopCachingImagesForAllAssets()
    }
    
    private func fetchAlbumsInfo(from collections: PHFetchResult<PHAssetCollection>,
                                 output: inout [AlbumCollection], options: PHFetchOptions) {
        for i in 0 ..< collections.count {
            let c = collections[i]
            // 取得該相簿的所有照片
            let assets = PHAsset.fetchAssets(in: c , options: options)
            // 沒有照片的相簿不顯示
            guard assets.count > 0 else { continue }
            output.append(AlbumCollection(collection: c, assets: assets, count: assets.count))
        }
    }
    
    /// 檢查是否為`動圖`相簿
    private func isAnimated(with title: String?) -> Bool {
        guard let title = title else { return false }
        
        switch title {
        case "動圖", "动图", "Animated", "アニメーション", "움직이는 항목": return true
        default: return false
        }
    }
    
    /// 檢查是否為`最近刪除`相簿
    private func isDeleted(with title: String?) -> Bool {
        guard let title = title else { return false }
        
        switch title {
        case "最近刪除", "最近删除", "Recently Deleted", "最近削除した項目", "최근 삭제된 항목": return true
        default: return false
        }
    }
    
    private func printLog(with asset: PHAsset, title: String, isGif: Bool) {
        print("title               --> \(title)")
        print("isGif               --> \(isGif)")
        print("burstIdentifier     --> \(String(describing: asset.burstIdentifier))")
        print("burstSelectionTypes --> \(String(describing: asset.burstSelectionTypes))")
        print("creationDate        --> \(String(describing: asset.creationDate))")
        print("modificationDate    --> \(String(describing: asset.modificationDate))")
        print("duration            --> \(String(describing: asset.duration))")
        print("isFavorite          --> \(String(describing: asset.isFavorite))")
        print("isHidden            --> \(String(describing: asset.isHidden))")
        print("location            --> \(String(describing: asset.location))")
        print("mediaType           --> \(String(describing: asset.mediaType.rawValue))")
        print("mediaSubtypes       --> \(String(describing: asset.mediaSubtypes.rawValue))")
        print("pixelWidth          --> \(String(describing: asset.pixelWidth))")
        print("pixelHeight         --> \(String(describing: asset.pixelHeight))")
        print("representsBurst     --> \(String(describing: asset.representsBurst))")
        print("sourceType          --> \(String(describing: asset.sourceType.rawValue))")
        print("------------------------------------------")
    }
}
