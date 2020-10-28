//
//  AlbumDoneView.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/10.
//  Copyright © 2019 Ray. All rights reserved.
//

import Foundation

protocol AlbumDoneViewDelegate: class {
    func albumDoneViewDidClicked(_ albumDoneView: AlbumDoneView)
}

class AlbumDoneView: UIView {
    
    /// width，value = 34.0
    static let width: CGFloat = 34.0
    
    /// height，value = 34.0
    static let height: CGFloat = 34.0
    
    private var doneButton: UIButton?
    private var imageView: UIImageView?
    private var numberLabel: UILabel?
    
    private let textColor: UIColor = UIColor(hex: "1a1a1a")
    
    /// Background color，default = #ffffff
    var bgColor: UIColor = .white {
        didSet { backgroundColor = bgColor}
    }
    
    /// Selected photo of first，default = nil
    var image: UIImage? {
        didSet { imageView?.image = image }
    }
    
    /// Selected count，default = 0
    var number: Int = 0 {
        didSet { numberLabel?.text = "( \(number) )"}
    }
    
    weak var delegate: AlbumDoneViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = bgColor
        
        let margin: CGFloat = 20.0
        imageView = UIImageView(frame: .zero)
        imageView?.contentMode = .scaleAspectFit
        imageView?.layer.cornerRadius = 5.0
        imageView?.layer.masksToBounds = true
        imageView?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView!)
        
        numberLabel = UILabel(frame: .zero)
        numberLabel?.textColor = textColor
        numberLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .medium)
        numberLabel?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(numberLabel!)
        
        let padding: CGFloat = 3.0
        doneButton = UIButton(type: .system)
        doneButton?.setImage(UIImage.bundle(image: .done), for: .normal)
        doneButton?.imageEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        doneButton?.tintColor = textColor
        doneButton?.addTarget(self, action: #selector(done(_:)), for: .touchUpInside)
        doneButton?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(doneButton!)
    
        // AutoLayout
        imageView?.widthAnchor
                  .constraint(equalToConstant: AlbumDoneView.width)
                  .isActive = true
        imageView?.heightAnchor
                  .constraint(equalToConstant: AlbumDoneView.height)
                  .isActive = true
        imageView?.topAnchor
                  .constraint(equalTo: topAnchor, constant: 10.0)
                  .isActive = true
        imageView?.leadingAnchor
                  .constraint(equalTo: leadingAnchor, constant: margin)
                  .isActive = true
        
        numberLabel?.centerYAnchor
                    .constraint(equalTo: imageView!.centerYAnchor)
                    .isActive = true
        numberLabel?.leadingAnchor
                    .constraint(equalTo: imageView!.trailingAnchor, constant: 10.0)
                    .isActive = true
        
        doneButton?.centerYAnchor
                   .constraint(equalTo: imageView!.centerYAnchor)
                   .isActive = true
        doneButton?.trailingAnchor
                   .constraint(equalTo: trailingAnchor, constant: -margin)
                   .isActive = true
    }
    
    @objc private func done(_ btn: UIButton) {
        delegate?.albumDoneViewDidClicked(self)
    }
}
