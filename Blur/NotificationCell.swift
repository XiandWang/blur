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
                
                
                if notification.type == NotificationType.askForChat.rawValue || notification.type == NotificationType.compliment.rawValue {
                    messageEditedImageView.isHidden = true
                } else {
                    if let url = notification.message?.editedImageUrl  {
                        messageEditedImageView.kf.setImage(with: URL(string: url))
                    }
                }

                
                messageLabel.attributedText = buildText(notification: notification)
                
                if !notification.isRead  {
                    backgroundColor = UIColor.rgb(red: 237, green: 231, blue: 246, alpha: 1)
                } else {
                    backgroundColor = .white
                }
                timestampLabel.text = notification.createdTime.timeAgoDisplay()
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
    
    let timestampLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .left
        lb.textColor = .lightGray
        lb.numberOfLines = 0
        lb.font = SMALL_TEXT_FONT
        return lb
    }()
    
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
        addSubview(timestampLabel)
        addSubview(divider)
        
        userProfileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        messageEditedImageView.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 40, height: 40)
        messageLabel.anchor(top: nil, left: userProfileImageView.rightAnchor, bottom: nil, right: messageEditedImageView.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 2, width: 0, height: 66)
        messageLabel.centerYAnchor.constraint(equalTo: userProfileImageView.centerYAnchor).isActive = true
        
        divider.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        timestampLabel.anchor(top: nil, left: userProfileImageView.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 1, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func buildText(notification: MessageNotification) -> NSMutableAttributedString {
        let type = notification.type
        let attributedText = NSMutableAttributedString(string: notification.user.username, attributes: [NSAttributedStringKey.font: BOLD_FONT, NSAttributedStringKey.foregroundColor: UIColor.black])
        var text = " "
        if type == NotificationType.allowAccess.rawValue {
            text = " allows you to access the image. "
        } else if type == NotificationType.rejectMessage.rawValue {
            text = " rejects your image. "
            if let moodText = notification.text, !moodText.isEmpty {
                text.append("Mood: \(moodText) . ")
            }
        } else if type == NotificationType.requestAccess.rawValue {
            text = " wants to access your image. "
            if let moodText = notification.text, !moodText.isEmpty {
                text.append("Mood: \(moodText) . ")
            }
        } else if type == NotificationType.likeMessage.rawValue {
            text = " likes your image. "
        } else if type == NotificationType.compliment.rawValue {
            text = " compliments you. "
        } else if type == NotificationType.askForChat.rawValue {
            text = " asks you for a chat. "
        }
        attributedText.append(NSAttributedString(string: text, attributes: [NSAttributedStringKey.font: TEXT_FONT, NSAttributedStringKey.foregroundColor: UIColor.black]))
        return attributedText
    }
}
