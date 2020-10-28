//
//  ExUIScreen.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/3.
//  Copyright © 2019 Ray. All rights reserved.
//

import Foundation

extension UIScreen {
    
    /// Return the width of a rectangle.
    static var width: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    /// Return the height of a rectangle.
    static var height: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    /// Return the statusBar height of a rectangle.
    static var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    /// The natural scale factor associated with the screen.
    static var density: CGFloat {
        return UIScreen.main.scale
    }
    
    /// Return the orientation of now.
    static var orientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    
    /// Return the device is landscape.
    static var isLandscape: Bool {
        return UIDevice.current.orientation.isLandscape
    }
    
    /// Return the device is portrait.
    static var isPortrait: Bool {
        return UIDevice.current.orientation.isPortrait
    }

}
