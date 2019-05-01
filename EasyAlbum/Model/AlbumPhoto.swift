//
//  AlbumPhoto.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/3.
//  Copyright © 2019 Ray. All rights reserved.
//

import Photos

class AlbumPhoto: Equatable, Hashable, CustomStringConvertible {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(asset.hashValue)
    }
    
    /// 照片索引
    var index: Int = 0
    
    /// 照片資訊
    var asset: PHAsset!
    
    /// 選取時的索引
    var pickNumber: Int = 0
    
    /// 選取時的顏色
    var pickColor: UIColor = UIColor(hex: "ffc107")
    
    /// 是否點選到
    var isCheck: Bool = false
    
    /// 是否為Gif圖檔
    var isGIF: Bool = false
    
    var description: String {
        get { return "asset 👉🏻 \(String(describing: asset))" }
    }
    
    init() {}
    
    init(_ index: Int, asset: PHAsset, pickNumber: Int, pickColor: UIColor, isCheck: Bool, isGIF: Bool) {
        self.index = index
        self.asset = asset
        self.pickNumber = pickNumber
        self.pickColor = pickColor
        self.isCheck = isCheck
        self.isGIF = isGIF
    }
    
    static func ==(lhs: AlbumPhoto, rhs: AlbumPhoto) -> Bool {
        return lhs.asset == rhs.asset
    }
}
