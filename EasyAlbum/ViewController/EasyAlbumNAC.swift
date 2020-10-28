//
//  EasyAlbumNAC.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/3.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit

class EasyAlbumNAC: UINavigationController {
        
    var appName: String?
    var tintColor: UIColor?
    var barTintColor: UIColor?
    var limit: Int?
    var span: Int?
    var pickColor: UIColor?
    var crop: Bool?
    var showCamera: Bool?
    var message: String?
    var sizeFactor: EasyAlbumSizeFactor?
    var lightStatusBarStyle: Bool?
    var orientation: UIInterfaceOrientationMask?
    
    weak var albumDelegate: EasyAlbumDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return lightStatusBarStyle ?? EasyAlbumCore.LIGHT_STATUS_BAR_STYLE ? .lightContent : .default
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return orientation ?? EasyAlbumCore.ORIENTATION
    }
    
    deinit {
        #if targetEnvironment(simulator)
        print("EasyAlbumNAC deinit 👍🏻")
        #endif
    }
    
    private func setup() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        navigationBar.tintColor = tintColor ?? EasyAlbumCore.TINT_COLOR
        navigationBar.barTintColor = barTintColor ?? EasyAlbumCore.BAR_TINT_COLOR
        navigationBar.isTranslucent = false
        
        let albumVC = EasyAlbumVC()
        
        if let value = appName      { albumVC.appName = value }
        if let value = barTintColor { albumVC.barTintColor = value }
        if let value = limit        { albumVC.limit = value }
        if let value = span         { albumVC.span = value }
        if let value = tintColor    { albumVC.titleColor = value }
        if let value = pickColor    { albumVC.pickColor = value }
        if let value = crop         { albumVC.crop = value }
        if let value = showCamera   { albumVC.showCamera = value }
        if let value = message      { albumVC.message = value }
        if let value = sizeFactor   { albumVC.sizeFactor = value }
        if let value = orientation  { albumVC.orientation = value }

        albumVC.albumDelegate = albumDelegate
        
        viewControllers = [albumVC]
    }
}
