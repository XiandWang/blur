//
//  NotifCell.swift
//  Blur
//
//  Created by xiandong wang on 3/14/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Kingfisher

class OtherNotificationCell: UICollectionViewCell {
    
    var notification: MessageNotification? {
        didSet {
            if let notification = notification {
                if let profileImgUrl = notification.user.profileImgUrl {
                    userProfileImageView.kf.setImage(with: URL(string: profileImgUrl))
                }
                
                notifLabel.attributedText = buildText(notification: notification)
                
                if !notification.isRead  {
                    backgroundColor = UIColor.rgb(red: 237, green: 231, blue: 246, alpha: 1)
                } else {
                    backgroundColor = .white
                }
            } else {
                userProfileImageView.kf.setImage(with: nil)
            }
        }
    }
    
    let userProfileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = BACKGROUND_GRAY
        iv.layer.cornerRadius = 20
        iv.layer.masksToBounds = true
        iv.isUserInteractionEnabled = true

        return iv
    }()
    
    let notifLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .left
        lb.numberOfLines = 0
        return lb
    }()
    
    let divider: UIView = {
        let v = UIView()
        v.backgroundColor = .lightGray
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(notifLabel)
        addSubview(userProfileImageView)
        addSubview(divider)
        
        userProfileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
       
        notifLabel.anchor(top: nil, left: userProfileImageView.rightAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 2, width: 0, height: 66)
        notifLabel.centerYAnchor.constraint(equalTo: userProfileImageView.centerYAnchor).isActive = true
        
        divider.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func buildText(notification: MessageNotification) -> NSMutableAttributedString {
        let type = notification.type
        let attributedText = NSMutableAttributedString(string: notification.user.fullName, attributes: [NSAttributedStringKey.font: BOLD_FONT, NSAttributedStringKey.foregroundColor: UIColor.black])
        var text = ""
        if type == NotificationType.compliment.rawValue {
            text = " compliments you 💙"
        } else if type == NotificationType.askForChat.rawValue {
            text = " asks you for a chat 🙈💬"
        }
        attributedText.append(NSAttributedString(string: text, attributes: [NSAttributedStringKey.font: TEXT_FONT, NSAttributedStringKey.foregroundColor: UIColor.black]))
        attributedText.append(NSAttributedString(string: "  •  " + notification.createdTime.timeAgoDisplay(), attributes: [NSAttributedStringKey.font: UIFont(name: APP_FONT, size: 14) as Any
, NSAttributedStringKey.foregroundColor: UIColor.lightGray]))
        return attributedText
    }
}
