//
//  ExString.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/10.
//  Copyright © 2019 Ray. All rights reserved.
//

import Foundation

extension String {
    
    /// 計算文字的高度
    ///
    /// - Parameters:
    ///   - width: 限制寬度的大小
    ///   - font: 字型的樣式
    /// - Returns: 計算後的高度
    func height(with width: CGFloat, font: UIFont) -> CGFloat {
        let attrString = NSMutableAttributedString(string: self)
        attrString.addAttribute(.font, value: font, range: NSRange(location: 0, length: self.utf16.count))
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = attrString.boundingRect(with: constraintRect,
                                                  options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                  context: nil)
        return ceil(boundingBox.height)
    }
    
    /// 計算文字的寬度
    ///
    /// - Parameters:
    ///   - height: 限制高度的大小
    ///   - font: 字型的樣式
    /// - Returns: 計算後的寬度
    func width(with height: CGFloat, font: UIFont) -> CGFloat {
        let attrString = NSMutableAttributedString(string: self)
        attrString.addAttribute(.font, value: font, range: NSRange(location: 0, length: self.utf16.count))
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = attrString.boundingRect(with: constraintRect,
                                                  options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                  context: nil)
        return ceil(boundingBox.width)
    }
}
