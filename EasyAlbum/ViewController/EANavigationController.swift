//
//  EANavigationController.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/3.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit

class EANavigationController: UINavigationController {
    
    private let album = EAViewController()
    
    var appName: String! {
        didSet { album.appName = appName }
    }
    
    var tintColor: UIColor = EasyAlbumCore.TINT_COLOR {
        didSet { album.titleColor = tintColor }
    }
    
    var barTintColor: UIColor = EasyAlbumCore.BAR_TINT_COLOR {
        didSet { album.barTintColor = barTintColor }
    }
    
    var limit: Int! {
        didSet { album.limit = limit }
    }
    
    var span: Int! {
        didSet { album.span = span }
    }
    
    var pickColor: UIColor! {
        didSet { album.pickColor = pickColor }
    }
    
    var crop: Bool! {
        didSet { album.crop = crop }
    }
    
    var showCamera: Bool! {
        didSet { album.showCamera = showCamera }
    }
    
    var message: String! {
        didSet { album.message = message }
    }
    
    var sizeFactor: EasyAlbumSizeFactor! {
        didSet { album.sizeFactor = sizeFactor }
    }
    
    var lightStatusBarStyle: Bool = EasyAlbumCore.LIGHT_STATUS_BAR_STYLE
    
    var orientation: UIInterfaceOrientationMask = EasyAlbumCore.ORIENTATION {
        didSet { album.orientation = orientation }
    }
    
    weak var albumDelegate: EasyAlbumDelegate? {
        didSet { album.delegate = albumDelegate }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.tintColor = tintColor
        navigationBar.barTintColor = barTintColor
        navigationBar.isTranslucent = false
        viewControllers = [album]
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
}
