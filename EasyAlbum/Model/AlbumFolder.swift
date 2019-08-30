//
//  AlbumFolder.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/3.
//  Copyright © 2019 Ray. All rights reserved.
//

import Photos

struct AlbumFolder {
    
    var title: String = ""
    var photos: [AlbumPhoto]!
    var pickColor: UIColor = EasyAlbumCore.PICK_COLOR
    var isCheck: Bool = false
    
    init() {}
    
    init(_ title: String?, photos: [AlbumPhoto], pickColor: UIColor, isCheck: Bool) {
        self.title = title == nil ? "" : title!
        self.photos = photos
        self.pickColor = pickColor
        self.isCheck = isCheck
    }
}
