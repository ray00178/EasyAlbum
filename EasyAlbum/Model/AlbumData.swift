//
//  AlbumData.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/3.
//  Copyright © 2019 Ray. All rights reserved.
//

import CoreLocation

public struct AlbumData {
    
    public var image: UIImage!
    public var mediaType: String = ""
    public var width: CGFloat = 0.0
    public var height: CGFloat = 0.0
    public var creationDate: Date?
    public var modificationDate: Date?
    public var isFavorite: Bool = false
    public var isHidden: Bool = false
    public var location: CLLocation?
    public var fileName: String?
    public var fileData: Data?
    public var fileSize: Int = 0
    public var fileUTI: String?
    
    init() {}
    
    init(_ image: UIImage, mediaType: Int, width: CGFloat, height: CGFloat,
         creationDate: Date?, modificationDate: Date?,
         isFavorite: Bool, isHidden: Bool, location: CLLocation?,
         fileName: String?, fileData: Data?, fileSize: Int, fileUTI: String?) {
        self.image = image
        self.mediaType = mediaType == 0 ? EasyAlbumCore.MEDIAT_UNKNOW :
                         mediaType == 1 ? EasyAlbumCore.MEDIAT_IMAGE  :
                         mediaType == 2 ? EasyAlbumCore.MEDIAT_VIDEO  : EasyAlbumCore.MEDIAT_AUDIO
        self.width = width
        self.height = height
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.isFavorite = isFavorite
        self.isHidden = isHidden
        self.location = location
        self.fileName = fileName
        self.fileData = fileData
        self.fileSize = fileSize
        self.fileUTI = fileUTI
    }
}
