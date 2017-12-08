//
//  UserContactCell.swift
//  Blur
//
//  Created by xiandong wang on 2017/10/9.
//  Copyright © 2017年 xiandong wang. All rights reserved.
//

import UIKit

class UserContactCell : UITableViewCell {
    
    var user: User? {
        didSet {
            if let user = user {
                usernameLabel.text = user.username
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
        lb.font = UIFont.systemFont(ofSize: 16)
        lb.numberOfLines = 1
        lb.text = ""
        return lb
    }()
    
    let userImageView : UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 25
        iv.layer.masksToBounds = true
        iv.backgroundColor = .lightGray
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let sendButton : UIButton = {
        let bt = UIButton()
        bt.setImage(UIImage.fontAwesomeIcon(name: .sendO, textColor: PRIMARY_COLOR_LIGHT, size: CGSize(width: 24, height: 24)), for: .normal)
        return bt
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(userImageView)
        contentView.addSubview(sendButton)
        setupConstraints()
    }
    
    func setupConstraints() {
        userImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        usernameLabel.anchor(top: nil, left: userImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        usernameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
