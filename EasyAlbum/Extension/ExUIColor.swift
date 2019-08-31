//
//  ExUIColor.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/3.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit

extension UIColor {
    
    /// let color = UIColor(hex: "ff0000")
    /// - Parameter hex: 色碼
    convenience init(hex: String) {
        self.init(hex: hex, alpha: 1.0)
    }
    
    /// let color = UIColor(hex: "ff0000", alpha: 1.0)
    /// - Parameter
    ///     hex: 色碼
    ///     alpha: 透明度
    convenience init(hex: String, alpha: CGFloat) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: alpha)
    }
}
