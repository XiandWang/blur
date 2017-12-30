//
//  constants.swift
//  Blur
//
//  Created by xiandong wang on 7/10/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit

let PRIMARY_COLOR = UIColor.rgb(red: 194, green: 12, blue: 12, alpha: 1)
let PRIMARY_COLOR_LIGHT = UIColor.rgb(red: 194, green: 12, blue: 12, alpha: 0.5)
let BACKGROUND_GRAY = UIColor.rgb(red: 233, green: 235, blue: 238, alpha: 1)
let GREEN_COLOR =  UIColor.rgb(red: 69, green: 182, blue: 73, alpha: 1)

let USERS_NODE = "users"
let PROFILE_IMAGES_NODE = "profileImages"
let RECEIVER_FRIEND_REQUESTS_NODE = "receiverFriendRequests"
let SENDER_FRIEND_REQUESTS_NODE = "senderFriendRequests"
let FRIENDS_NODE = "friends"
let IMAGE_MESSAGES_NODE = "imageMessages"
let USER_NOTIFICATIONS_NODE = "userNotifications"
let NOTIFICATIONS_NODE = "notifications"

enum FriendStatus: String {
    case PENDING
    case ADDED
}

enum NotificationType: String {
    case REJECT_MESSAGE
    case REQUEST_ACCESS
}

