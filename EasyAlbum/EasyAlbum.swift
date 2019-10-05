//
//  EasyAlbum.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/3.
//  Copyright © 2019 Ray. All rights reserved.
//

import Foundation

public struct EasyAlbum {
        
    private var albumNVC: EasyAlbumNAC?
    
    private init(appName: String) {
        albumNVC = EasyAlbumNAC()
        albumNVC?.appName = appName
    }
    
    public static func of(appName: String) -> EasyAlbum {
        return EasyAlbum(appName: appName)
    }
    
    /// NavigationBar tint color
    ///
    /// - Parameter color: default = #ffffff
    /// - Returns: EasyAlbum
    public func tintColor(_ color: UIColor) -> EasyAlbum {
        albumNVC?.tintColor = color
        return self
    }

    /// NavigationBar bar color
    ///
    /// - Parameter color: default = #673ab7
    /// - Returns: EasyAlbum
    public func barTintColor(_ color: UIColor) -> EasyAlbum {
        albumNVC?.barTintColor = color
        return self
    }
    
    /// Setting statusBar style
    ///
    /// - Parameter isLight: default = true
    /// - Returns: EasyAlbum
    public func lightStatusBarStyle(_ isLight: Bool) -> EasyAlbum {
        albumNVC?.lightStatusBarStyle = isLight
        return self
    }
    
    /// Selected photo count of max
    ///
    /// - Parameter count: default = 30
    /// - Returns: EasyAlbum
    public func limit(_ count: Int) -> EasyAlbum {
        albumNVC?.limit = count
        return self
    }

    /// Span count per line
    ///
    /// - Parameter count: default = 3
    /// - Returns: EasyAlbum
    public func span(_ count: Int) -> EasyAlbum {
        albumNVC?.span = count
        return self
    }
    
    /// Selected color
    ///
    /// - Parameter color: default = #ffc107
    /// - Returns: EasyAlbum
    public func pickColor(_ color: UIColor) -> EasyAlbum {
        albumNVC?.pickColor = color
        return self
    }
    
    /// Is need crop photo, only for camera mod
    ///
    /// - Parameter crop: default = false
    /// - Returns: EasyAlbum
    public func crop(_ crop: Bool) -> EasyAlbum {
        albumNVC?.crop = crop
        return self
    }

    /// Show camera function
    ///
    /// - Parameter show: default = true
    /// - Returns: EasyAlbum
    public func showCamera(_ show: Bool) -> EasyAlbum {
        albumNVC?.showCamera = show
        return self
    }

    /// UIDevice orientation (🆕 Create function after version 2.1.0)
    ///
    /// - Parameter orientation: default = .all，See more UIInterfaceOrientationMask
    /// - Returns: EasyAlbum
    public func orientation(_ orientation: UIInterfaceOrientationMask) -> EasyAlbum {
        albumNVC?.orientation = orientation
        return self
    }

    /// Show message when selected count over limit
    ///
    /// - Parameter message: default = ""
    /// - Returns: EasyAlbum
    public func message(_ message: String) -> EasyAlbum {
        albumNVC?.message = message
        return self
    }

    /// After selected photo scale
    /// ```
    /// auto     : scale to device's width and height. unit:px
    /// fit      : manual setting width and height. unit:px
    /// scale    : manual setting scale ratio.
    /// original : Use original size.
    /// ```
    /// - Parameter factor: default = .auto
    /// - Returns: EasyAlbum
    public func sizeFactor(_ factor: EasyAlbumSizeFactor) -> EasyAlbum {
        albumNVC?.sizeFactor = factor
        return self
    }
    
    /// Show photo picker
    ///
    /// - Parameters:
    ///   - viewController: viewController
    ///   - delegate: See more EasyAlbumDelegate
    public func start(_ viewController: UIViewController, delegate: EasyAlbumDelegate) {
        albumNVC?.albumDelegate = delegate
        
        if #available(iOS 13.0, *) {
            albumNVC?.modalPresentationStyle = .fullScreen
        }
        
        viewController.present(albumNVC!, animated: true, completion: nil)
    }
    
    /// Show photo picker
    ///
    /// - Parameters:
    ///   - viewController: navigationController
    ///   - delegate: See more EasyAlbumDelegate
    public func start(_ navigationController: UINavigationController, delegate: EasyAlbumDelegate) {
        albumNVC?.albumDelegate = delegate
        
        if #available(iOS 13.0, *) {
            albumNVC?.modalPresentationStyle = .fullScreen
        }
        
        navigationController.present(albumNVC!, animated: true, completion: nil)
    }
    
    /*
    ⚠️ Deprecated on verson 2.1.0
    
    /// Show gif photo
    ///
    /// - Parameter color: default = true
    /// - Returns: EasyAlbum
    public func showGIF(_ show: Bool) -> EasyAlbum {
        albumNVC.showGIF = show
        return self
    }
     
    /// Title color
    ///
    /// - Parameter color: default = #ffffff
    /// - Returns: EasyAlbum
    public func titleColor(_ color: UIColor) -> EasyAlbum {
        albumNVC.titleColor = color
    return self
    }
    */
}
