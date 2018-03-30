//
//  HomeChatCell.swift
//  Blur
//
//  Created by xiandong wang on 10/12/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit

class HomeChatCell: UITableViewCell {
    
    var user: User? {
        didSet {
            if let user = user {
                usernameLabel.text = user.fullName
                if let imgUrl = user.profileImgUrl {
                    userAvatarView.kf.setImage(with: URL(string: imgUrl))
                } else {
                    userAvatarView.kf.setImage(with: nil)
                }
            } else {
                userAvatarView.kf.setImage(with: nil)
            }
        }
    }
    
    var messages : [Message]? {
        didSet {
            if let unreadNum = self.messages?.filter({ (message) -> Bool in
                return !message.isAcknowledged
            }).count, unreadNum > 0 {
                let badgeImage = BadgeHelper.createBadge(string: "\(unreadNum)", fontSize: 11, backgroundColor: RED_COLOR)
                badgeImageView.image = badgeImage
            } else {
                badgeImageView.image = nil
            }
            
            if let message = messages?.first {
                timestampLabel.text = message.createdTime.timeAgoDisplay()
            } else {
                timestampLabel.text = nil
            }
            if let totalCount = messages?.count, totalCount > 0 {
                if let hiddenNum = self.messages?.filter({ (message) -> Bool in
                    return !message.allowOriginal && message.isAcknowledged
                }).count, hiddenNum > 0 {
                    hiddenNumberLabel.textColor = .gray
                    hiddenNumberLabel.text = "\(hiddenNum) hiding, \(totalCount) total"
                } else {
                    hiddenNumberLabel.textColor = .gray
                    hiddenNumberLabel.text = "0 hiding, \(totalCount) total"
                }
            } else {
                hiddenNumberLabel.text = nil
            }
        }
    }
    
    let hiddenNumberLabel : UILabel = {
        let lb = UILabel()
        lb.font = TEXT_FONT
        lb.numberOfLines = 1
        lb.text = ""
        return lb
    }()
    
    let timestampLabel : UILabel = {
        let lb = UILabel()
        lb.font = TEXT_FONT
        lb.textColor = .lightGray
        lb.numberOfLines = 1
        lb.text = ""
        return lb
    }()
    
    let badgeImageView : UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    let usernameLabel : UILabel = {
        let lb = UILabel()
        lb.font = BOLD_FONT
        lb.numberOfLines = 1
        lb.text = ""
        return lb
    }()
    
    let userAvatarView : UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 28
        iv.layer.masksToBounds = true
        iv.backgroundColor = BACKGROUND_GRAY
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(userAvatarView)
        contentView.addSubview(timestampLabel)
        contentView.addSubview(hiddenNumberLabel)
        contentView.addSubview(badgeImageView)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        userAvatarView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 56, height: 56)
        usernameLabel.anchor(top: contentView.topAnchor, left: userAvatarView.rightAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        timestampLabel.anchor(top: contentView.topAnchor, left: nil, bottom: nil, right: contentView.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        hiddenNumberLabel.anchor(top: usernameLabel.bottomAnchor, left: userAvatarView.rightAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        badgeImageView.anchor(top: timestampLabel.bottomAnchor, left: nil, bottom: nil, right: contentView.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    }
}
