//
//  constants.swift
//  Blur
//
//  Created by xiandong wang on 7/10/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit

//let RED_COLOR = UIColor.rgb(red: 194, green: 12, blue: 12, alpha: 1)
//let RED_COLOR_LIGHT = UIColor.rgb(red: 194, green: 12, blue: 12, alpha: 0.5)
let BACKGROUND_GRAY = UIColor.rgb(red: 233, green: 235, blue: 238, alpha: 1)
let GREEN_COLOR =  UIColor.rgb(red: 69, green: 182, blue: 73, alpha: 1)
let YELLOW_COLOR = UIColor.rgb(red: 255, green: 218, blue: 68, alpha: 1)
let TEXT_GRAY = UIColor.rgb(red: 84, green: 109, blue: 126, alpha: 1)

let RED_COLOR = UIColor.rgb(red: 211, green: 47, blue: 47, alpha: 1)
let RED_COLOR_LIGHT = UIColor.rgb(red: 239, green: 154, blue: 154, alpha: 1)
let PURPLE_COLOR = UIColor.rgb(red: 81, green: 45, blue: 168, alpha: 1)
let PURPLE_COLOR_LIGHT = UIColor.rgb(red: 179, green: 157, blue: 219, alpha: 1)
let BLUE_COLOR = UIColor.rgb(red: 25, green: 118, blue: 210, alpha: 1)
let BLUE_COLOR_LIGHT = UIColor.rgb(red: 144, green: 202, blue: 249, alpha: 1)
let PINK_COLOR = UIColor.rgb(red: 194, green: 24, blue: 91, alpha: 1)
let PINK_COLOR_LIGHT = UIColor.rgb(red: 244, green: 143, blue: 177, alpha: 0.9)



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
    case likeMessage
}

