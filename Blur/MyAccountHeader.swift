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
        backgroundColor = BACKGROUND_GRAY
        [userNameLabel, userProfileImageView, editProfileImageButton].forEach { (view) in
            addSubview(view)
        }
       
        userProfileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        userNameLabel.anchor(top: nil, left: userProfileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 100, height: 0)
        userNameLabel.centerYAnchor.constraint(equalTo: userProfileImageView.centerYAnchor, constant: -10).isActive = true
        editProfileImageButton.anchor(top: nil, left: userProfileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        editProfileImageButton.centerYAnchor.constraint(equalTo: userProfileImageView.centerYAnchor, constant: 20).isActive = true
        
        let topDivider = UIView()
        topDivider.backgroundColor = .lightGray
        let bottomDivider = UIView()
        bottomDivider.backgroundColor = .lightGray
        addSubview(topDivider)
        addSubview(bottomDivider)
        topDivider.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
        bottomDivider.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
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
}
