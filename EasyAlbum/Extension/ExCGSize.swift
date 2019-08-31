//
//  ExCGSize.swift
//  EasyAlbum
//
//  Created by Ray on 2019/4/20.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit

extension CGSize {
    
    /// Fit size with another size
    ///
    /// - Parameter another: another size
    /// - Returns: after calc size
    func fit(with another: CGSize) -> CGSize {
        let anotherW = another.width
        let anotherH = another.height
        let nowW = self.width
        let nowH = self.height
        
        var scale: CGFloat = 1.0
        if nowW > anotherW && nowH < anotherH {
            scale = anotherW / nowW
        } else if nowW < anotherW && nowH > anotherH {
            scale = anotherH / nowH
        } else {
            scale = min(anotherW / nowW, anotherH / nowH)
        }

        return CGSize(width: nowW * scale, height: nowH * scale)
    }
    
    /// Fit frame with another frame and center in another
    ///
    /// - Parameter another: another frame
    /// - Returns: after calculation frame
    func fit(with another: CGRect) -> CGRect {
        let anotherW = another.width
        let anotherH = another.height
        let nowW = self.width
        let nowH = self.height
        
        var scale: CGFloat = 1.0
        if nowW > anotherW && nowH < anotherH {
            scale = anotherW / nowW
        } else if nowW < anotherW && nowH > anotherH {
            scale = anotherH / nowH
        } else {
            scale = min(anotherW / nowW, anotherH / nowH)
        }
        
        let w = nowW * scale
        let h = nowH * scale
        let x = w == anotherW ? 0.0 : (anotherW - w) / 2
        let y = h == anotherH ? 0.0 : (anotherH - h) / 2
        
        return CGRect(x: x, y: y, width: w, height: h)
    }
}
