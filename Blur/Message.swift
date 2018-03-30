//
//  Message.swift
//  Blur
//
//  Created by xiandong wang on 2017/10/9.
//  Copyright © 2017年 xiandong wang. All rights reserved.
//

import Foundation

class Message {
    var messageId: String
    var senderId: String
    var receiverId: String
    var editedImageUrl: String
    var originalImageUrl: String
    var allowOriginal: Bool
    var isAcknowledged: Bool
    var acknowledgeType: String
    var isOriginalViewed: Bool
    var isDeleted: Bool
    var createdTime: Date
    var isLiked: Bool
    var caption: String
    
    var countDown: Int
    var allowOriginalTime: Date?
    
    init(dict: [String: Any], messageId: String) {
        self.messageId = messageId
        self.senderId = dict[MessageSchema.SENDER_ID] as? String ?? ""
        self.receiverId = dict[MessageSchema.RECEIVER_ID] as? String ?? ""
        
        self.editedImageUrl = dict[MessageSchema.EDITED_IMAGE_URL] as? String ?? ""
        self.originalImageUrl = dict[MessageSchema.ORIGINAL_IMAGE_URL] as? String ?? ""
        self.allowOriginal = dict[MessageSchema.ALLOW_ORIGINAL] as? Bool ?? false
        self.isAcknowledged = dict[MessageSchema.IS_ACKNOWLEDGED] as? Bool ?? false
        self.acknowledgeType = dict[MessageSchema.ACKNOWLEDGE_TYPE] as? String ?? "NotAck"
        self.isDeleted = dict[MessageSchema.IS_DELETED] as? Bool ?? true 
        self.isOriginalViewed = dict[MessageSchema.IS_ORIGINAL_VIEWED] as? Bool ?? false
        self.isLiked = dict[MessageSchema.IS_LIKED] as? Bool ?? false
        self.caption = dict[MessageSchema.CAPTION] as? String ?? ""
        self.createdTime = dict[MessageSchema.CREATED_TIME] as? Date ?? Date()
        self.countDown = dict[MessageSchema.COUNT_DOWN] as? Int ?? 0
        
        self.allowOriginalTime = dict[MessageSchema.ALLOW_ORIGINAL_TIME] as? Date
    }
    
    func toDict() -> [String: Any] {
        var dict = [MessageSchema.SENDER_ID: senderId, MessageSchema.RECEIVER_ID: receiverId,
                    MessageSchema.EDITED_IMAGE_URL: editedImageUrl, MessageSchema.ORIGINAL_IMAGE_URL: originalImageUrl,
                    MessageSchema.ALLOW_ORIGINAL: allowOriginal, MessageSchema.IS_ACKNOWLEDGED: isAcknowledged,
                    MessageSchema.ACKNOWLEDGE_TYPE: acknowledgeType, MessageSchema.IS_DELETED: isDeleted,
                    MessageSchema.IS_ORIGINAL_VIEWED: isOriginalViewed, MessageSchema.IS_LIKED: isLiked,
                    MessageSchema.CAPTION: caption, MessageSchema.CREATED_TIME: createdTime,
                    MessageSchema.COUNT_DOWN: countDown] as [String : Any]
        if let allowOriginalTime = self.allowOriginalTime {
            dict[MessageSchema.ALLOW_ORIGINAL_TIME] = allowOriginalTime
        }
        return dict
    }
}

struct MessageSchema {
    static let MESSAGE_ID = "messageId"
    static let SENDER_ID = "senderId"
    static let SENDER_USER = "senderUser"
    static let RECEIVER_ID = "receiverId"
    static let EDITED_IMAGE_URL = "editedImageUrl"
    static let ORIGINAL_IMAGE_URL = "originalImageUrl"
    static let ALLOW_ORIGINAL = "allowOriginal"
    static let ALLOW_ORIGINAL_TIME = "allowOriginalTime"
    static let IS_ACKNOWLEDGED = "isAcknowledged"
    static let ACKNOWLEDGE_TYPE = "acknowledgeType"
    static let IS_ORIGINAL_VIEWED = "isOriginalViewed"
    static let IS_DELETED = "isDeleted"
    static let CREATED_TIME = "createdTime"
    static let IS_LIKED = "isLiked"
    static let CAPTION = "caption"
    static let COUNT_DOWN = "countDown"
}
