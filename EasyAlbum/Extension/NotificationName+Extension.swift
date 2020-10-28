//
//  NotificationName+Extension.swift
//  EasyAlbum
//
//  Created by Ray on 2020/9/26.
//  Copyright © 2020 Ray. All rights reserved.
//

import Foundation

extension Notification.Name {

    /// 相片編號更改通知
    static let EasyAlbumPhotoNumberDidChangeNotification: Notification.Name = Notification.Name("EasyAlbumPhotoNumberDidChangeNotification")
    
    /// 相片預覽頁面，消失通知
    static let EasyAlbumPreviewPageDismissNotification: Notification.Name = Notification.Name("EasyAlbumPreviewPageDismissNotification")
    
}
