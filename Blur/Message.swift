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
    var originalImageUrl: String
    var allowOrignal: Bool
    var isAcknowledged: Bool
    var isOriginalViewed: Bool
    var isDeleted: Bool
    var createdTime: Date
    
    init(dict: [String: Any], messageId: String) {
        self.messageId = messageId
        self.fromId = dict["fromId"] as! String
        self.editedImageUrl = dict["editedImageUrl"] as! String
        self.originalImageUrl = dict["originalImageUrl"] as! String
        self.allowOrignal = dict["allowOriginal"] as! Bool
        self.isAcknowledged = dict["isAcknowledged"] as! Bool
        self.isDeleted = dict["isDeleted"] as! Bool
        self.isOriginalViewed = dict["isOriginalViewed"] as! Bool
        self.createdTime = dict["createdTime"] as! Date
    }
}
