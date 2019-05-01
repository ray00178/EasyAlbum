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
    static let width: CGFloat = 34.0
    static let height: CGFloat = 34.0
    
    private var mDoneBtn: UIButton?
    private var mImgView: UIImageView?
    private var mNumberLab: UILabel?
    
    private let textColor: UIColor = UIColor(hex: "1a1a1a")
    
    /// 背景色，default：#ffffff
    var bgColor: UIColor = .white {
        didSet { backgroundColor = bgColor}
    }
    
    /// 第一張選取的照片，default：nil
    var image: UIImage? {
        didSet { mImgView?.image = image }
    }
    
    /// 已選取照片數量，default：0
    var number: Int = 0 {
        didSet { mNumberLab?.text = "( \(number) )"}
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
        mImgView = UIImageView(frame: .zero)
        mImgView?.contentMode = .scaleAspectFit
        mImgView?.layer.cornerRadius = 5.0
        mImgView?.layer.masksToBounds = true
        mImgView?.useAutoLayout = false
        addSubview(mImgView!)
        mImgView?.widthAnchor.constraint(equalToConstant: AlbumDoneView.width).isActive = true
        mImgView?.heightAnchor.constraint(equalToConstant: AlbumDoneView.height).isActive = true
        mImgView?.topAnchor.constraint(equalTo: topAnchor, constant: 10.0).isActive = true
        mImgView?.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin).isActive = true
        
        mNumberLab = UILabel(frame: .zero)
        mNumberLab?.textColor = textColor
        mNumberLab?.font = UIFont.systemFont(ofSize: 15.0, weight: .medium)
        mNumberLab?.useAutoLayout = false
        addSubview(mNumberLab!)
        mNumberLab?.centerYAnchor.constraint(equalTo: mImgView!.centerYAnchor).isActive = true
        mNumberLab?.leadingAnchor.constraint(equalTo: mImgView!.trailingAnchor, constant: 10.0).isActive = true
        
        let padding: CGFloat = 3.0
        mDoneBtn = UIButton(type: .system)
        mDoneBtn?.setImage(UIImage.image(named: "album_done"), for: .normal)
        mDoneBtn?.imageEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        mDoneBtn?.tintColor = textColor
        mDoneBtn?.addTarget(self, action: #selector(done(_:)), for: .touchUpInside)
        mDoneBtn?.useAutoLayout = false
        addSubview(mDoneBtn!)
        mDoneBtn?.centerYAnchor.constraint(equalTo: mImgView!.centerYAnchor).isActive = true
        mDoneBtn?.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin).isActive = true
    }
    
    @objc private func done(_ btn: UIButton) {
        delegate?.albumDoneViewDidClicked(self)
    }
}
