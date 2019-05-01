//
//  AlbumBorderView.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/3.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit

@IBDesignable
class AlbumBorderView: UIView {
    
    @IBInspectable var borderColor: UIColor = UIColor(hex: "6600ff") {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var strokeWidth: CGFloat = 8.0 {
        didSet { setNeedsDisplay() }
    }
    
    private var path: UIBezierPath!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        // 繪製半透明背景
        ctx.setFillColor(UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.35).cgColor)
        ctx.addRect(rect)
        ctx.fillPath()
        
        // 繪製邊框
        ctx.setLineCap(.square)
        ctx.setLineJoin(.miter)
        ctx.setLineWidth(strokeWidth)
        ctx.setStrokeColor(borderColor.cgColor)
        
        let oriSX = rect.minX
        let oriSY = rect.minY
        let oriEX = rect.maxX
        let oriEY = rect.maxY
        
        // left
        ctx.move(to: CGPoint(x: oriSX, y: oriSY))
        ctx.addLine(to: CGPoint(x: oriSX, y: oriEY))
        // bottom
        ctx.move(to: CGPoint(x: oriSX, y: oriEY))
        ctx.addLine(to: CGPoint(x: oriEX, y: oriEY))
        // right
        ctx.move(to: CGPoint(x: oriEX, y: oriEY))
        ctx.addLine(to: CGPoint(x: oriEX, y: oriSY))
        // top
        ctx.move(to: CGPoint(x: oriEX, y: oriSY))
        ctx.addLine(to: CGPoint(x: oriSX, y: oriSY))
        
        ctx.strokePath()
    }
}
