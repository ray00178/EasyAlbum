//
//  AlbumCategoryView.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/10.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit

protocol AlbumCategoryViewDelegate: class {
    func albumCategoryView(_ albumCategoryView: AlbumCategoryView, didSelectedAt index: Int)
}

class AlbumCategoryView: UICollectionReusableView {
    
    let width: CGFloat = 95.0
    public static let height: CGFloat = 95.0
    
    private var mCollectionView: UICollectionView?
    
    weak var delegate: AlbumCategoryViewDelegate?
    
    var datas: [AlbumFolder] = [] {
        didSet { mCollectionView?.reloadData() }
    }
    
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
        let mFlowLayout = UICollectionViewFlowLayout()
        mFlowLayout.scrollDirection = .horizontal
        mFlowLayout.itemSize = CGSize(width: width, height: AlbumCategoryView.height)
        mFlowLayout.minimumLineSpacing = 0.0
        
        mCollectionView = UICollectionView(frame: .zero, collectionViewLayout: mFlowLayout)
        mCollectionView?.registerCell(AlbumCategoryCell.self)
        mCollectionView?.backgroundColor = .white
        mCollectionView?.showsVerticalScrollIndicator = false
        mCollectionView?.showsHorizontalScrollIndicator = false
        mCollectionView?.delegate = self
        mCollectionView?.dataSource = self
        mCollectionView?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mCollectionView!)
        mCollectionView?.topAnchor.constraint(equalTo: topAnchor).isActive = true
        mCollectionView?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        mCollectionView?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        mCollectionView?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}

extension AlbumCategoryView: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.item
        let cell = collectionView.dequeueCell(AlbumCategoryCell.self, indexPath: indexPath)
        cell.data = datas[index]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.albumCategoryView(self, didSelectedAt: indexPath.item)
    }
}
