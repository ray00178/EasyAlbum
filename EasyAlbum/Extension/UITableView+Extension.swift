//
//  UITableView+Extension.swift
//  EasyAlbum
//
//  Created by Ray on 2020/9/26.
//  Copyright © 2020 Ray. All rights reserved.
//

import Foundation

import UIKit

extension UITableView {
    
    func registerCell<T: UITableViewCell>(_ t: T.Type, isNib: Bool = true) {
        let identifier = String(describing: t)
        if isNib {
            self.register(UINib(nibName: identifier, bundle: Bundle(for: t)),
                          forCellReuseIdentifier: identifier)
        } else {
            self.register(t, forCellReuseIdentifier: identifier)
        }
    }
    
    func dequeueCell<T: UITableViewCell>(_ t: T.Type, indexPath: IndexPath) -> T {
        let identifier = String(describing: t)
        guard let cell = self.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T
        else { fatalError("Can not found \(t.description()) type!") }
        
        return cell
    }
}
