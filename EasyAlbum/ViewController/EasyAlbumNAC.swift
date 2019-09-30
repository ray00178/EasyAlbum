//
//  EasyAlbumNAC.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/3.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit

class EasyAlbumNAC: UINavigationController {
    
    //private var albumVC: EasyAlbumVC?
    
    var appName: String = EasyAlbumCore.APP_NAME
    var tintColor: UIColor = EasyAlbumCore.TINT_COLOR
    var barTintColor: UIColor = EasyAlbumCore.BAR_TINT_COLOR
    var limit: Int = EasyAlbumCore.LIMIT
    var span: Int = EasyAlbumCore.SPAN
    var pickColor: UIColor = EasyAlbumCore.PICK_COLOR
    var crop: Bool = EasyAlbumCore.CROP
    var showCamera: Bool = EasyAlbumCore.SHOW_CAMERA
    var message: String = EasyAlbumCore.MESSAGE
    var sizeFactor: EasyAlbumSizeFactor = EasyAlbumCore.SIZE_FACTOR
    var lightStatusBarStyle: Bool = EasyAlbumCore.LIGHT_STATUS_BAR_STYLE
    var orientation: UIInterfaceOrientationMask = EasyAlbumCore.ORIENTATION
    
    weak var albumDelegate: EasyAlbumDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBar.tintColor = tintColor
        navigationBar.barTintColor = barTintColor
        navigationBar.isTranslucent = false
        
        let albumVC = EasyAlbumVC()
        albumVC.appName = appName
        albumVC.barTintColor = barTintColor
        albumVC.limit = limit
        albumVC.span = span
        albumVC.titleColor = tintColor
        albumVC.pickColor = pickColor
        albumVC.crop = crop
        albumVC.showCamera = showCamera
        albumVC.message = message
        albumVC.sizeFactor = sizeFactor
        albumVC.orientation = orientation
        albumVC.albumDelegate = albumDelegate
                
        viewControllers = [albumVC]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return lightStatusBarStyle ? .lightContent : .default
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return orientation
    }
    
    private func setup() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }
    
    deinit {
        //print("EasyAlbumNAC deinit")
    }
}
