//
//  AlbumToast.swift
//  EasyAlbum
//
//  Created by Ray on 2019/4/24.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit

class AlbumToast: UIWindow {
    static let share = AlbumToast(frame: .zero)
    
    private var rootView: UIView!
    private var mMessageLab: UILabel!
    
    /// 訊息字體大小，default = UIFont.systemFont(ofSize: 16.0, weight: .medium)
    var font: UIFont = UIFont.systemFont(ofSize: 16.0, weight: .medium) {
        didSet { mMessageLab.font = font }
    }
    
    /// 訊息文字，default：nil
    var message: String? = nil {
        didSet { mMessageLab.text = message }
    }
    
    /// 訊息顏色，default = .white
    var textColor: UIColor = .white {
        didSet { mMessageLab.textColor = textColor }
    }
    
    /// 訊息背景色，default：.black
    var toastBackgroundColor: UIColor = .black {
        didSet { rootView.backgroundColor = toastBackgroundColor }
    }
    
    /// 是否自動消失訊息，default：true
    var autoCancel: Bool = true
    
    /// 動畫時間，default：0.25
    private var duration: TimeInterval = 0.25
    
    /// 訊息顯示時間，default = 2s
    private var stayDuration: TimeInterval = 2
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let statusBarHeight = UIScreen.statusBarHeight
        let size = CGSize(width: UIScreen.width, height: UIScreen.isLandscape ? statusBarHeight : statusBarHeight + 44.0)
        frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
        
        rootView = UIView(frame: .zero)
        rootView.backgroundColor = toastBackgroundColor
        rootView.useAutoLayout = false
        addSubview(rootView)
        
        mMessageLab = UILabel(frame: .zero)
        mMessageLab.textColor = textColor
        mMessageLab.font = font
        mMessageLab.numberOfLines = 2
        mMessageLab.textAlignment = .center
        mMessageLab.useAutoLayout = false
        rootView.addSubview(mMessageLab)
        
        rootView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        rootView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        rootView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        rootView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        mMessageLab.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        mMessageLab.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 5.0).isActive = true
        mMessageLab.bottomAnchor.constraint(equalTo: rootView.bottomAnchor, constant: -10.0).isActive = true
        mMessageLab.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -5.0).isActive = true
        
        windowLevel = .alert
        isHidden = true
    }
    
    public func show(with message: String = "", autoCancel: Bool = true) {
        self.autoCancel = autoCancel
        if !message.isEmpty { mMessageLab.text = message }
        if !isHidden { return }
        
        isHidden.toggle()
        frame = CGRect(origin: CGPoint(x: 0.0, y: -frame.height), size: frame.size)
        UIView.animate(withDuration: duration, animations: {
            self.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: self.frame.size)
        }) { (finished) in
            DispatchQueue.main.asyncAfter(deadline: .now() + self.stayDuration, execute: {
                if self.autoCancel { self.hide() }
            })
        }
    }
    
    public func hide() {
        if isHidden { return }
        
        UIView.animate(withDuration: duration, animations: {
            self.frame = CGRect(origin: CGPoint(x: 0.0, y: -self.frame.height), size: self.frame.size)
        }) { (finished) in
            self.isHidden.toggle()
        }
    }
}
