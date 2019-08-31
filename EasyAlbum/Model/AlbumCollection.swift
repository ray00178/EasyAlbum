//
//  AlbumCollection.swift
//  EasyAlbum
//
//  Created by Ray on 2019/4/13.
//  Copyright © 2019 Ray. All rights reserved.
//

import Photos

struct AlbumCollection {
    
    var collection: PHAssetCollection
    var assets: PHFetchResult<PHAsset>
    var count: Int
}
