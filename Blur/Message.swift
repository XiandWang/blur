//
//  Message.swift
//  Blur
//
//  Created by xiandong wang on 2017/10/9.
//  Copyright © 2017年 xiandong wang. All rights reserved.
//

import Foundation

struct Message {
    var messageId: String
    var fromId: String
    var editedImageUrl: String
    var uneditedImageUrl: String
    var allowUnedited: Bool
    var isRead: Bool
    var isUneditedViewed: Bool
    var createdTime: Date
    
    init(dict: [String: Any], messageId: String) {
        self.messageId = messageId
        self.fromId = dict["fromId"] as! String
        self.editedImageUrl = dict["editedImageUrl"] as! String
        self.uneditedImageUrl = dict["uneditedImageUrl"] as! String
        self.allowUnedited = dict["allowUnedited"] as! Bool
        self.isRead = dict["isRead"] as! Bool
        self.isUneditedViewed = dict["isUneditedViewed"] as! Bool
        self.createdTime = dict["createdTime"] as! Date
    }
}
