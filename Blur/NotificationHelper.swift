//
//  NotificationHelper.swift
//  Blur
//
//  Created by xiandong wang on 2/28/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import Firebase

struct NotificationHelper {
    static func createMessageNotification(messageId: String?, message:Message?, receiverUserId: String, type: NotificationType, senderUser sender: User, text: String?, completion: @escaping (Error?) -> ()) {
        let userData = ["userId": sender.uid, "username": sender.username, "profileImgUrl": sender.profileImgUrl, "fullName": sender.fullName]
        var data = ["type": type.rawValue, "user": userData, "isRead": false, "createdTime": Date()] as [String : Any]
        if let text = text {
            data["text"] = text
        }
        if let messageId = messageId, let message = message {
            data["message"] = message.toDict()
            data["messageId"] = messageId
        }

        FIRRef.getNotifications()
            .document(receiverUserId).collection("messageNotifications").addDocument(data: data) { (error) in
                if let error = error {
                    completion(error)
                    return
                } else {
                    completion(nil)
                    return
                }
        }
    }
}


func logError(errMsg: String, errFrom: String) {
    Analytics.logEvent(APP_ERROR, parameters: ["errorMessage": errMsg, "errorFrom": errFrom])
}

extension Analytics {
    static func logAppError(errMsg: String, errFrom: String) {
        Analytics.logEvent(APP_ERROR, parameters: ["errorMessage": errMsg, "errorFrom": errFrom])
    } 
}

