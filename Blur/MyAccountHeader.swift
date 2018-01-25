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

class MyAccountHeader: UICollectionViewCell {
    
    var user : User? {
        didSet {
            guard let name = user?.username else { return }
            userNameLabel.text = name
            guard let userProfileImgUrl = user?.profileImgUrl, userProfileImgUrl != "" else {
                return
            }
            
            userProfileImageView.kf.setImage(with: URL(string: userProfileImgUrl))
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white

        [userNameLabel, userProfileImageView, editProfileImageButton, bannerLabel].forEach { (view) in
            addSubview(view)
        }
        
        bannerLabel.layer.addBorder(edge: .bottom, color: YELLOW_COLOR, thickness: 10.0)
       
        userProfileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        userNameLabel.anchor(top: nil, left: userProfileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 100, height: 0)
        userNameLabel.centerYAnchor.constraint(equalTo: userProfileImageView.centerYAnchor, constant: -10).isActive = true
        editProfileImageButton.anchor(top: nil, left: userProfileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        editProfileImageButton.centerYAnchor.constraint(equalTo: userProfileImageView.centerYAnchor, constant: 20).isActive = true
        
       bannerLabel.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 56)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.numberOfLines = 0
        label.text = ""
        return label
    }()
    
    let userProfileImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .lightGray
        iv.layer.cornerRadius = 40
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
    
    let editProfileImageButton: UIButton = {
        let bt = UIButton(type: .system)
        bt.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        bt.setTitle("Edit profile image", for: .normal)
        bt.setTitleColor(.purple, for: .normal)
        return bt
    }()
    
    let bannerLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Sent by me in 24 hrs"
        lb.textAlignment = .center
        lb.textColor = UIColor.rgb(red: 84, green: 109, blue: 126, alpha: 1)
        lb.backgroundColor = BACKGROUND_GRAY
        lb.font = UIFont.boldSystemFont(ofSize: 22)
        return lb
    }()
}
