//
//  NewRequestUserCell.swift
//  Blur
//
//  Created by xiandong wang on 11/1/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit
import Kingfisher

class NewRequestUserCell : UITableViewCell {
    var user: User? {
        didSet {
            if let user = user {
                usernameLabel.text = "@" + user.username
                fullNameLabel.text = user.fullName
                if let imgUrl = user.profileImgUrl {
                    userImageView.kf.setImage(with: URL(string: imgUrl))
                } else {
                    userImageView.kf.setImage(with: nil)
                }
            } else {
                userImageView.kf.setImage(with: nil)
            }
        }
    }
    
    let usernameLabel : UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 1
        lb.font = TEXT_FONT
        lb.textColor = .lightGray
        lb.text = ""
        return lb
    }()
    
    let fullNameLabel : UILabel = {
        let lb = UILabel()
        lb.font = BOLD_FONT
        lb.numberOfLines = 0
        lb.text = ""
        return lb
    }()
    
    let userImageView : UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 25
        iv.layer.masksToBounds = true
        iv.backgroundColor = BACKGROUND_GRAY
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let acceptButton : UIButton = {
        let bt = UIButton()
        bt.setTitle("Add", for: .normal)
        bt.backgroundColor = .white
        bt.setTitleColor(UIColor.rgb(red: 69, green: 182, blue: 73, alpha: 1), for: .normal)
        bt.layer.cornerRadius = 19
        bt.layer.masksToBounds = true
        bt.layer.borderWidth = 1
        bt.layer.borderColor = UIColor.rgb(red: 69, green: 182, blue: 73, alpha: 1).cgColor
        return bt
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(fullNameLabel)
        contentView.addSubview(userImageView)
        contentView.addSubview(acceptButton)
        setupConstraints()
    }
    
    func setupConstraints() {
        userImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        fullNameLabel.anchor(top: nil, left: userImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        fullNameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor, constant: -10).isActive = true
        usernameLabel.anchor(top: fullNameLabel.bottomAnchor, left: userImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        acceptButton.anchor(top: nil, left: nil, bottom: nil, right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 90, height: 38)
        acceptButton.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

