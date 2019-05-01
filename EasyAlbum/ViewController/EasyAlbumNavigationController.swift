//
//  EasyAlbumNavigationController.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/3.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit

class EasyAlbumNavigationController: UINavigationController {
    private let album = EasyAlbumViewController()
    
    var tintColor: UIColor = .white
    
    var barTintColor: UIColor = UIColor(hex: "673ab7")
    
    var appName: String! {
        didSet { album.appName = appName }
    }
    
    var limit: Int! {
        didSet { album.limit = limit }
    }
    
    var span: Int! {
        didSet { album.span = span }
    }
    
    var titleColor: UIColor! {
        didSet { album.titleColor = titleColor }
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
    
    var showGIF: Bool! {
        didSet { album.showGIF = showGIF }
    }
    
    var message: String! {
        didSet { album.message = message }
    }
    
    var sizeFactor: EasyAlbumSizeFactor! {
        didSet { album.sizeFactor = sizeFactor }
    }
    
    var lightStatusBarStyle: Bool = true
    
    weak var albumDelegate: EasyAlbumDelegate? {
        didSet { album.delegate = albumDelegate }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.tintColor = tintColor
        navigationBar.barTintColor = barTintColor
        viewControllers = [album]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return lightStatusBarStyle ? .lightContent : .default
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
}
