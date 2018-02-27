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
    var messageId: String
    var user: User
    var type: String
    var text: String?
    var createdTime: Date
    var isRead: Bool
    
    init(dict: [String: Any], notificationId: String) {
        self.notificationId = notificationId
        self.messageId = dict["messageId"] as? String ?? ""
        self.type = dict["type"] as? String ?? ""
        self.createdTime = dict["createdTime"] as? Date ?? Date()
        self.isRead = dict["isRead"] as? Bool ?? true
        
        self.text = dict["text"] as? String
        
        let userDict = dict["user"] as? [String: Any] ?? [String: Any]()
        self.user = User(dictionary: userDict, uid: userDict["userId"] as? String ?? "")
    }
}
