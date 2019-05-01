//
//  AlbumFolder.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/3.
//  Copyright © 2019 Ray. All rights reserved.
//

import Photos

struct AlbumFolder {
    /// 相簿資料夾名稱
    var title: String = ""
    
    /// 相簿內的照片
    var photos: [AlbumPhoto]!
    
    /// 選到時顏色
    var pickColor: UIColor = UIColor(hex: "ffc107")
    
    /// 是否點選到
    var isCheck: Bool = false
    
    init() {}
    
    init(_ title: String?, photos: [AlbumPhoto], pickColor: UIColor, isCheck: Bool) {
        self.title = title == nil ? "" : title!
        self.photos = photos
        self.pickColor = pickColor
        self.isCheck = isCheck
    }
}
