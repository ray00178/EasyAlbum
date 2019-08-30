//
//  AlbumSelectedButton.swift
//  EasyAlbum
//
//  Created by Ray on 2019/4/23.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit

@IBDesignable
class AlbumSelectedButton: UIButton {
    
    @IBInspectable var borderColor: UIColor = .white {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var strokeWidth: CGFloat = 8.0 {
        didSet { setNeedsDisplay() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = UIColor.clear
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        // draw translucent background
        ctx.setFillColor(UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.35).cgColor)
        ctx.addRect(rect)
        ctx.fillPath()
        
        // draw ☑️
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        ctx.setLineWidth(strokeWidth)
        ctx.setStrokeColor(borderColor.cgColor)
        
        let perW = rect.width / 10
        let perH = rect.height / 10
        
        ctx.move(to: CGPoint(x: perW * 4, y: perH * 5))
        ctx.addLine(to: CGPoint(x: perW * 5, y: perH * 7))
        
        ctx.move(to: CGPoint(x: perW * 5, y: perH * 7))
        ctx.addLine(to: CGPoint(x: perW * 7, y: perH * 4))
        
        ctx.strokePath()
    }
}
