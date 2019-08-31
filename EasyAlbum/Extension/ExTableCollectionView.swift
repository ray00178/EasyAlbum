//
//  ExTableCollectionView.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/3.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit

extension UITableView {
    
    func registerCell<T: UITableViewCell>(_ t: T.Type, isNib: Bool = true) {
        let identifier = String(describing: t)
        if isNib {
            self.register(UINib(nibName: identifier, bundle: Bundle(for: t)), forCellReuseIdentifier: identifier)
        } else {
            self.register(t, forCellReuseIdentifier: identifier)
        }
    }
    
    func dequeueCell<T: UITableViewCell>(_ t: T.Type, indexPath: IndexPath) -> T {
        let identifier = String(describing: t)
        guard let cell = self.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Can not found \(t.description()) type!")
        }
        
        return cell
    }
}

extension UICollectionView {
    
    func registerCell<T: UICollectionViewCell>(_ t: T.Type, isNib: Bool = true) {
        let identifier = String(describing: t)
        if isNib {
            self.register(UINib(nibName: identifier, bundle: Bundle(for: t)), forCellWithReuseIdentifier: identifier)
        } else {
            self.register(t, forCellWithReuseIdentifier: identifier)
        }
    }
    
    func registerHeader<T: UICollectionReusableView>(_ t: T.Type, isNib: Bool = true) {
        let identifier = String(describing: t)
        if isNib {
            self.register(UINib(nibName: identifier, bundle: Bundle(for: t)), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier)
        } else {
            self.register(t, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier)
        }
    }
    
    func registerFooter<T: UICollectionReusableView>(_ t: T.Type, isNib: Bool = true) {
        let identifier = String(describing: t)
        if isNib {
            self.register(UINib(nibName: identifier, bundle: Bundle(for: t)), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: identifier)
        } else {
            self.register(t, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: identifier)
        }
    }
    
    func dequeueCell<T: UICollectionViewCell>(_ t: T.Type, indexPath: IndexPath) -> T {
        let identifier = String(describing: t)
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Can not found \(t.description()) type!")
        }
        
        return cell
    }
    
    func dequeueHeader<T: UICollectionReusableView>(_ t: T.Type, indexPath: IndexPath) -> T {
        let identifier = String(describing: t)
        guard let header = self.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Can not found \(t.description()) type!")
        }
        
        return header
    }
    
    func dequeueFooter<T: UICollectionReusableView>(_ t: T.Type, indexPath: IndexPath) -> T {
        let identifier = String(describing: t)
        guard let footer = self.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Can not found \(t.description()) type!")
        }
        
        return footer
    }
}
