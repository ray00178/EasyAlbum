//
//  EasyAlbumDemoCell.swift
//  EasyAlbumDemo
//
//  Created by Ray on 2019/4/10.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit

class EasyAlbumDemoCell: UITableViewCell {

    @IBOutlet weak var mImgView: UIImageView!
    @IBOutlet weak var mDescriptionLab: UILabel!
    
    var data: (image: UIImage, desc: String)! {
        didSet {
            mImgView.image = data.image
            mDescriptionLab.text = data.desc
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mImgView.layer.cornerRadius = 25.0
        mImgView.layer.masksToBounds = true
        
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
