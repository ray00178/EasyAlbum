//
//  AlbumToast.swift
//  EasyAlbum
//
//  Created by Ray on 2019/4/24.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit

class AlbumToast: UIView {
    
    private var mMessageLab: UILabel!
    private weak var navigationVC: UINavigationController?
    private var barTintColor: UIColor?
    
    /// message font size，default = UIFont.systemFont(ofSize: 16.0, weight: .medium)
    var font: UIFont = UIFont.systemFont(ofSize: 16.0, weight: .medium) {
        didSet { mMessageLab.font = font }
    }
    
    /// message，default = nil
    var message: String? = nil {
        didSet { mMessageLab.text = message }
    }
    
    /// mesage color，default = .white
    var textColor: UIColor = .white {
        didSet { mMessageLab.textColor = textColor }
    }
    
    /// message background color，default = .black
    var toastBackgroundColor: UIColor = .black {
        didSet { backgroundColor = toastBackgroundColor }
    }
    
    /// message auto dismiss，default = true
    var autoCancel: Bool = true
    
    /// animate duration，default：0.25
    private var duration: TimeInterval = 0.25
    
    /// message show duration，default = 2s
    private var stayDuration: TimeInterval = 2
    
    private var timer: Timer?
    
    convenience init(navigationVC: UINavigationController?, barTintColor: UIColor?) {
        self.init(frame: .zero)
        self.navigationVC = navigationVC
        self.barTintColor = barTintColor
        setup()
    }
    
    private func setup() {
        mMessageLab = UILabel()
        mMessageLab.textColor = textColor
        mMessageLab.font = font
        mMessageLab.numberOfLines = 2
        mMessageLab.textAlignment = .center
        mMessageLab.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mMessageLab)
        
        mMessageLab.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        mMessageLab.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5.0).isActive = true
        mMessageLab.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5.0).isActive = true
        mMessageLab.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5.0).isActive = true

        backgroundColor = toastBackgroundColor
        isHidden = true
    }
    
    private func createTimer() {
        timer = Timer(timeInterval: stayDuration, target: self, selector: #selector(hide(_:)), userInfo: nil, repeats: false)
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func destroyTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func hide(_ timer: Timer) {
        hide()
    }
    
    public func show(with message: String = "", autoCancel: Bool = true) {
        self.autoCancel = autoCancel
        if !message.isEmpty { mMessageLab.text = message }
        
        // Restart
        if !isHidden {
            destroyTimer()
            if autoCancel {
                createTimer()
            }
            return
        }
        
        isHidden.toggle()
        navigationVC?.navigationBar.barTintColor = toastBackgroundColor
        frame = CGRect(origin: CGPoint(x: 0.0, y: -frame.height), size: frame.size)
        
        UIView.animate(withDuration: duration, animations: {
            self.frame = CGRect(origin: .zero, size: self.frame.size)
        }) { (finished) in
            if self.autoCancel {
                self.createTimer()
            }
        }
    }
    
    public func hide() {
        if isHidden { return }
        
        UIView.animate(withDuration: duration, animations: {
            self.frame = CGRect(origin: CGPoint(x: 0.0, y: -self.frame.height), size: self.frame.size)
        }) { (finished) in
            self.navigationVC?.navigationBar.barTintColor = self.barTintColor
            self.isHidden.toggle()
        }
    }
}
