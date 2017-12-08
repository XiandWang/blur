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
        contentView.addSubview(userImageView)
        contentView.addSubview(acceptButton)
        setupConstraints()
    }
    
    func setupConstraints() {
        userImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        usernameLabel.anchor(top: nil, left: userImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        usernameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor).isActive = true
        
        acceptButton.anchor(top: nil, left: nil, bottom: nil, right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 90, height: 38)
        acceptButton.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

