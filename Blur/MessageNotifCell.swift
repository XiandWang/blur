//
//  NotificationCell.swift
//  Blur
//
//  Created by xiandong wang on 1/6/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class MessageNotificationCell: UICollectionViewCell {
    
    var notification: MessageNotification? {
        didSet {
            if let notification = notification {
                if let profileImgUrl = notification.user.profileImgUrl {
                    userProfileImageView.kf.setImage(with: URL(string: profileImgUrl))
                }
 
                if let url = notification.message?.editedImageUrl  {
                    messageEditedImageView.kf.setImage(with: URL(string: url))
                }
                
                messageLabel.attributedText = buildText(notification: notification)
                
                if !notification.isRead  {
                    backgroundColor = UIColor.rgb(red: 237, green: 231, blue: 246, alpha: 1)
                } else {
                    backgroundColor = .white
                }
                //timestampLabel.text = notification.createdTime.timeAgoDisplay()
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
    
    let messageEditedImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .lightGray
        iv.layer.cornerRadius = 5
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let messageLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .left
        lb.numberOfLines = 0
        return lb
    }()
    
//    let timestampLabel: UILabel = {
//        let lb = UILabel()
//        lb.textAlignment = .left
//        lb.textColor = .lightGray
//        lb.numberOfLines = 0
//        lb.font = SMALL_TEXT_FONT
//        return lb
//    }()
    
    let divider: UIView = {
        let v = UIView()
        v.backgroundColor = .lightGray
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(messageEditedImageView)
        addSubview(messageLabel)
        addSubview(userProfileImageView)
        addSubview(divider)
        
        userProfileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        userProfileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        messageEditedImageView.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 40, height: 40)
        messageEditedImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        messageLabel.anchor(top: topAnchor, left: userProfileImageView.rightAnchor, bottom: bottomAnchor, right: messageEditedImageView.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        messageLabel.centerYAnchor.constraint(equalTo: userProfileImageView.centerYAnchor).isActive = true

        divider.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func buildText(notification: MessageNotification) -> NSMutableAttributedString {
        let type = notification.type
        let attributedText = NSMutableAttributedString(string: notification.user.fullName, attributes: [NSAttributedStringKey.font: BOLD_FONT, NSAttributedStringKey.foregroundColor: UIColor.black])
        var text = " "
        if type == NotificationType.allowAccess.rawValue {
            text = " allows you to access the image"
        } else if type == NotificationType.rejectMessage.rawValue {
            text = " rejects your image. "
            if let moodText = notification.text, !moodText.isEmpty {
                text.append("Mood: \(moodText)")
            }
        } else if type == NotificationType.requestAccess.rawValue {
            text = " wants to access your image. "
            if let moodText = notification.text, !moodText.isEmpty {
                text.append("Mood: \(moodText)")
            }
        } else if type == NotificationType.likeMessage.rawValue {
            text = " likes your image"
        }
        attributedText.append(NSAttributedString(string: text, attributes: [NSAttributedStringKey.font: TEXT_FONT, NSAttributedStringKey.foregroundColor: UIColor.black]))
        let timeFont = UIFont(name: APP_FONT, size: 14)
        attributedText.append(NSAttributedString(string: "  •  " + notification.createdTime.timeAgoDisplay(), attributes: [NSAttributedStringKey.font: timeFont ?? UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.lightGray]))
        return attributedText
    }
}
