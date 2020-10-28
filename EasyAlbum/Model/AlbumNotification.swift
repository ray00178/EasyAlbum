//
//  AlbumNotification.swift
//  EasyAlbum
//
//  Created by Ray on 2020/9/28.
//  Copyright © 2020 Ray. All rights reserved.
//

struct AlbumNotification {
    
    /// Need reload items, Use for EasyAlbumPhotoNumberDidChangeNotification
    private(set) var reloadItems: [IndexPath] = []
    
    /// Current selected items, Use for EasyAlbumPhotoNumberDidChangeNotification
    private(set) var selectedPhotos: [PhotoData] = []
    
    /// Need send photo, Use for EasyAlbumPreviewPageDismissNotification
    private(set) var isSend: Bool = false
    
    init(reloadItems: [IndexPath], selectedPhotos: [PhotoData]) {
        self.reloadItems = reloadItems
        self.selectedPhotos = selectedPhotos
    }
    
    init(isSend: Bool) {
        self.isSend = isSend
    }
}
