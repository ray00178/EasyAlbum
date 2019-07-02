//
//  ExView.swift
//  EasyAlbum
//
//  Created by Ray on 2019/4/9.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit

extension UIView {
    
    /// Use `translatesAutoresizingMaskIntoConstraints`
    var useAutoLayout: Bool {
        get { return self.translatesAutoresizingMaskIntoConstraints }
        set { self.translatesAutoresizingMaskIntoConstraints = newValue }
    }
}
