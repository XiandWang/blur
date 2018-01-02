//
//  MyAccountImageCell.swift
//  Blur
//
//  Created by xiandong wang on 12/30/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit
import Kingfisher

class MyAccountImageCell: UICollectionViewCell {
    var message: Message? {
        didSet {
            if let message = message {
                messageImageView.kf.indicatorType = .activity
                messageImageView.kf.setImage(with: URL(string: message.editedImageUrl))
            }
        }
    }
    
    let messageImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(messageImageView)
        messageImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
