//
//  MyAccountHeader.swift
//  Blur
//
//  Created by xiandong wang on 12/30/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import Hero

class MyAccountHeader: UICollectionViewCell {
    
    var user : User? {
        didSet {
            if let user = user {
                usernameLabel.text = "@" + user.username
                fullNameLabel.text = user.fullName

                guard let userProfileImgUrl = user.profileImgUrl, userProfileImgUrl != "" else {
                    return
                }
                
                userProfileImageView.kf.setImage(with: URL(string: userProfileImgUrl))
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        

        [usernameLabel, fullNameLabel, userProfileImageView, bannerLabel].forEach { (view) in
            addSubview(view)
        }
        userProfileImageView.hero.id = "imageViewHeroId"
        
        userProfileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 64, height: 64)
        fullNameLabel.anchor(top: nil, left: userProfileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        fullNameLabel.centerYAnchor.constraint(equalTo: userProfileImageView.centerYAnchor, constant: -10).isActive = true
        usernameLabel.anchor(top: fullNameLabel.bottomAnchor, left: userProfileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 2, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        
        bannerLabel.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 56)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: APP_FONT_BOLD, size: 17)
        label.numberOfLines = 0
        label.text = ""
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: APP_FONT_BOLD, size: 17)
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.text = ""
        return label
    }()
    
    let userProfileImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = BACKGROUND_GRAY
        iv.layer.cornerRadius = 32
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill

        return iv
    }()
    
    let bannerLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Sent by me in 24 hrs"
        lb.textAlignment = .center
        lb.textColor = UIColor.rgb(red: 84, green: 109, blue: 126, alpha: 1)
        lb.backgroundColor = BACKGROUND_GRAY
        lb.font = UIFont(name: APP_FONT_BOLD, size: 24)
        return lb
    }()
}
