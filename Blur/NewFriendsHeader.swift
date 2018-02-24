//
//  NewContactHeader.swift
//  Blur
//
//  Created by xiandong wang on 11/1/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit

class NewFriendsHeader : UITableViewCell {
    let newFriendImageView : UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .center
        let size = CGSize(width: 40, height: 44)
        iv.image = UIImage.fontAwesomeIcon(name: .user, textColor: .white, size: size)
        
        iv.backgroundColor = UIColor.rgb(red: 3, green: 169, blue: 244, alpha: 1)
        iv.layer.cornerRadius = 25
        iv.clipsToBounds = true
        return iv
    }()
    
    let badgeImageView : UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    let newFriendsLabel : UILabel = {
        let lb = UILabel()
        lb.font = UIFont(name: APP_FONT_BOLD, size: 16)
        lb.numberOfLines = 1
        lb.text = "New Friends"
        return lb
    }()
    
    var newFriendsNum : String? {
        didSet {
            if let num = newFriendsNum {
                let badgeImage = BadgeHelper.createBadge(string: num, fontSize: 11, backgroundColor: RED_COLOR)
                badgeImageView.frame.size = CGSize(width: badgeImage.size.width, height: badgeImage.size.height)
                badgeImageView.image = badgeImage
            }
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        super.frame = CGRect(origin: .zero, size: CGSize(width: contentView.frame.width, height: 66))
        contentView.addSubview(newFriendImageView)
        contentView.addSubview(newFriendsLabel)
        contentView.addSubview(badgeImageView)
        setupConstraints()
    }
    
    func setupConstraints() {
        newFriendImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width:50, height: 50)
        newFriendsLabel.anchor(top: nil, left: newFriendImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        newFriendsLabel.centerYAnchor.constraint(equalTo: newFriendImageView.centerYAnchor).isActive = true
        badgeImageView.anchor(top: nil, left: nil, bottom: nil, right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 0, height: 0)
        badgeImageView.centerYAnchor.constraint(equalTo: newFriendImageView.centerYAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

