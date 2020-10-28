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
    
    public static let height: CGFloat = 95.0
    private let width: CGFloat = 95.0
    
    private var collectionView: UICollectionView?
    
    weak var delegate: AlbumCategoryViewDelegate?
    
    var datas: [AlbumFolder] = [] {
        didSet { collectionView?.reloadData() }
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
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: width, height: AlbumCategoryView.height)
        flowLayout.minimumLineSpacing = 0.0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView?.registerCell(AlbumCategoryCell.self)
        collectionView?.backgroundColor = .white
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView!)
        
        // AutoLayout
        collectionView?.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
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
