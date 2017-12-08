//
//  PreviePhotoContainerView.swift
//  Blur
//
//  Created by xiandong wang on 9/21/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit
import LCMosaicImageView

class PreviewPhotoContainerView: UIView {
    var previewImageView : LCMosaicImageView = {
        let iv = LCMosaicImageView()
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .yellow
        
        addSubview(previewImageView)
        previewImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
