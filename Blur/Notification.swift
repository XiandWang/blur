//
//  Notification.swift
//  Blur
//
//  Created by xiandong wang on 1/6/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import Foundation

class MessageNotification {
    var notificationId: String
    var messageId: String?
    var user: User
    var type: String
    var text: String?
    var createdTime: Date
    var isRead: Bool
    var message: Message?
    
    init(dict: [String: Any], notificationId: String) {
        self.notificationId = notificationId
        self.type = dict["type"] as? String ?? ""
        self.createdTime = dict["createdTime"] as? Date ?? Date()
        self.isRead = dict["isRead"] as? Bool ?? true
        
        self.text = dict["text"] as? String
        
        let userDict = dict["user"] as? [String: Any] ?? [String: Any]()
        self.user = User(dictionary: userDict, uid: userDict["userId"] as? String ?? "")
        
        self.messageId = dict["messageId"] as? String
        
        if let messageId = self.messageId, let messageDict = dict["message"] as? [String: Any]  {
            self.message = Message(dict: messageDict, messageId: messageId)
        }
    }
    
    func buildNotifString() -> String {
        let type = self.type
        var text = self.user.fullName
        if type == NotificationType.allowAccess.rawValue {
            text.append(" allows you to access the image")
        } else if type == NotificationType.rejectMessage.rawValue {
            text.append(" rejects your image. ")
            if let moodText = self.text, !moodText.isEmpty {
                text.append("Mood: \(moodText)")
            }
        } else if type == NotificationType.requestAccess.rawValue {
            text.append(" wants to access your image. ")
            if let moodText = self.text, !moodText.isEmpty {
                text.append("Mood: \(moodText)")
            }
        } else if type == NotificationType.likeMessage.rawValue {
            text.append(" likes your image")
        }
        text.append("  •  \(self.createdTime.timeAgoDisplay())")
        return text
    }
}
