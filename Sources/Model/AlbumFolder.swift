//
//  AlbumFolder.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/3.
//  Copyright © 2019 Ray. All rights reserved.
//

import Photos

struct AlbumFolder {
    
    private(set) var title: String
    
    var assets: PHFetchResult<PHAsset>
    var isCheck: Bool = false
    
    init(title: String?, assets: PHFetchResult<PHAsset>) {
        self.title = title ?? ""
        self.assets = assets
    }
}
