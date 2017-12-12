//
//  NewContactHeader.swift
//  Blur
//
//  Created by xiandong wang on 11/1/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit

class NewContactHeader : UITableViewCell {
    let newContactImageView : UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        
        let size = CGSize(width: 50, height: 50)
        iv.image = UIImage.fontAwesomeIcon(name: .users, textColor: .black, size: size)
        return iv
    }()
    
    let badgeImageView : UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    let newContactLabel : UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16)
        lb.numberOfLines = 1
        lb.text = "New Friends"
        return lb
    }()
    
    var newFriendsNum : String? {
        didSet {
            if let num = newFriendsNum {
                let badgeImage = BadgeHelper.createBadge(string: num, fontSize: 11, backgroundColor: PRIMARY_COLOR)
                badgeImageView.frame.size = CGSize(width: badgeImage.size.width, height: badgeImage.size.height)
                badgeImageView.image = badgeImage
            }
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        super.frame = CGRect(origin: .zero, size: CGSize(width: contentView.frame.width, height: 66))
        contentView.addSubview(newContactImageView)
        contentView.addSubview(newContactLabel)
        contentView.addSubview(badgeImageView)
        setupConstraints()
    }
    
    func setupConstraints() {
        newContactImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width:0, height: 0)
        newContactLabel.anchor(top: nil, left: newContactImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        newContactLabel.centerYAnchor.constraint(equalTo: newContactImageView.centerYAnchor).isActive = true
        badgeImageView.anchor(top: nil, left: nil, bottom: nil, right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 0, height: 0)
        badgeImageView.centerYAnchor.constraint(equalTo: newContactImageView.centerYAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

