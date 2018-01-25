//
//  constants.swift
//  Blur
//
//  Created by xiandong wang on 7/10/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit

let RED_COLOR = UIColor.rgb(red: 194, green: 12, blue: 12, alpha: 1)
let RED_COLOR_LIGHT = UIColor.rgb(red: 194, green: 12, blue: 12, alpha: 0.5)
let BACKGROUND_GRAY = UIColor.rgb(red: 233, green: 235, blue: 238, alpha: 1)
let GREEN_COLOR =  UIColor.rgb(red: 69, green: 182, blue: 73, alpha: 1)
let YELLOW_COLOR = UIColor.rgb(red: 255, green: 218, blue: 68, alpha: 1)
let TEXT_GRAY = UIColor.rgb(red: 84, green: 109, blue: 126, alpha: 1)

let USERS_NODE = "users"
let PROFILE_IMAGES_NODE = "profileImages"
let RECEIVER_FRIEND_REQUESTS_NODE = "receiverFriendRequests"
let SENDER_FRIEND_REQUESTS_NODE = "senderFriendRequests"
let FRIENDS_NODE = "friends"
let IMAGE_MESSAGES_NODE = "imageMessages"
let USER_NOTIFICATIONS_NODE = "userNotifications"
let NOTIFICATIONS_NODE = "notifications"

let NEW_MESSAGE_CREATED = NSNotification.Name(rawValue: "NEW_MESSAGE_CREATED")

enum FriendStatus: String {
    case pending
    case added
    case deleted
}

enum NotificationType: String {
    case rejectMessage
    case requestAccess
    case allowAccess
}

