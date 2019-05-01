//
//  EasyAlbum.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/3.
//  Copyright © 2019 Ray. All rights reserved.
//

import Foundation

public struct EasyAlbum {
    private var albumNVC: EasyAlbumNavigationController!
    
    private init(with appName: String) {
        albumNVC = EasyAlbumNavigationController()
        albumNVC.appName = appName
    }
    
    /// Your app project name，default：EasyAlbum
    public static func of(appName: String) -> EasyAlbum {
        return EasyAlbum(with: appName)
    }
    
    /// navigationBar tint color，default：#ffffff
    public func tintColor(_ color: UIColor) -> EasyAlbum {
        albumNVC.tintColor = color
        return self
    }
    
    /// navigationBar bar color，default：#673ab7
    public func barTintColor(_ color: UIColor) -> EasyAlbum {
        albumNVC.barTintColor = color
        return self
    }
    
    /// 狀態列是否為亮色系列，default：true
    public func lightStatusBarStyle(_ isLight: Bool) -> EasyAlbum {
        albumNVC.lightStatusBarStyle = isLight
        return self
    }
    
    /// 選取照片數量限制，default：30
    public func limit(_ count: Int) -> EasyAlbum {
        albumNVC.limit = count
        return self
    }
    
    /// 每一行幾欄，default：3
    public func span(_ count: Int) -> EasyAlbum {
        albumNVC.span = count
        return self
    }
    
    /// 標題文字的顏色，default：#ffffff
    public func titleColor(_ color: UIColor) -> EasyAlbum {
        albumNVC.titleColor = color
        return self
    }
    
    /// 選取照片時的顏色，default：#ffc107
    public func pickColor(_ color: UIColor) -> EasyAlbum {
        albumNVC.pickColor = color
        return self
    }
    
    /// 拍照時是否剪裁照片，僅用於拍照模式下，default：false
    public func crop(_ crop: Bool) -> EasyAlbum {
        albumNVC.crop = crop
        return self
    }
    
    /// 是否顯示照相功能圖示，default：true
    public func showCamera(_ show: Bool) -> EasyAlbum {
        albumNVC.showCamera = show
        return self
    }
    
    /// 是否顯示GIF圖，default：true
    public func showGIF(_ show: Bool) -> EasyAlbum {
        albumNVC.showGIF = show
        return self
    }
    
    /// 當選取數量超過上限時，顯示的提示訊息，default：""
    public func message(_ message: String) -> EasyAlbum {
        albumNVC.message = message
        return self
    }
    
    /// 挑選後相片的大小比例，default = .auto
    ///```
    /// auto : 自動縮放成目前手機的解析度大小
    /// fit  : 手動設定寬高的最大長度
    /// scale: 手動設定縮放倍率
    ///```
    public func sizeFactor(_ factor: EasyAlbumSizeFactor) -> EasyAlbum {
        albumNVC.sizeFactor = factor
        return self
    }
    
    public func start(_ viewController: UIViewController, delegate: EasyAlbumDelegate) {
        albumNVC.albumDelegate = delegate
        viewController.present(albumNVC, animated: true, completion: nil)
    }
    
    public func start(_ navigationController: UINavigationController, delegate: EasyAlbumDelegate) {
        albumNVC.albumDelegate = delegate
        navigationController.present(albumNVC, animated: true, completion: nil)
    }
}
