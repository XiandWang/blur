//
//  DatabaseHelper.swift
//  Blur
//
//  Created by xiandong wang on 1/3/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import Foundation
import Firebase

extension Database {
    static func getUser(uid: String, completion: @escaping (User?, Error?) -> ()) {
        Database.database().reference().child(USERS_NODE).child(uid).observeSingleEvent(of: .value, with: { (snap) in
            guard let userDict = snap.value as? [String: Any] else { return }
            completion(User(dictionary: userDict, uid: snap.key), nil)
        }) { (err) in
            completion(nil, err)
        }
    }
    
    static func isUsernameChosen(uid: String, completion: @escaping (Bool, Error?) -> ()) {
        Database.database().reference().child(USERS_NODE).child(uid).observeSingleEvent(of: .value, with: { (snap) in
            let dict = snap.value as? [String: Any]
            if dict == nil || dict?["username"] == nil {
                completion(false, nil)
            } else {
                completion(true, nil)
            }
        }) { (error) in
            completion(true, error)
        }
    }
}

struct AnimationHelper {
    static func yRotation(_ angle: Double) -> CATransform3D {
        return CATransform3DMakeRotation(CGFloat(angle), 0.0, 1.0, 0.0)
    }
    
    static func zRotation(_ angle: Double) -> CATransform3D {
        return CATransform3DMakeRotation(CGFloat(angle), 0.0, 0.0, 1.0)
    }
    
    static func perspectiveTransform(for containerView: UIView) {
        var transform = CATransform3DIdentity
        transform.m34 = -0.002
        containerView.layer.sublayerTransform = transform
    }
}

struct NotificationHelper {
    static func createMessageNotification(messageId: String, receiverUserId: String, type: NotificationType, senderUser sender: User, text: String?, shouldShowHUD: Bool, hudSuccessText: String?) {
        if shouldShowHUD {
            AppHUD.progress(nil,  isDarkTheme: false)
        }
        let userData = ["userId": sender.uid, "username": sender.username, "profileImgUrl": sender.profileImgUrl]
        var data = ["type": type.rawValue, "user": userData, "messageId": messageId, "isRead": false, "createdTime": Date()] as [String : Any]
        if let text = text {
            data["text"] = text
        }
        Firestore.firestore()
            .collection("notifications")
            .document(receiverUserId).collection("messageNotifications").addDocument(data: data) { (error) in
                if shouldShowHUD {
                    AppHUD.progressHidden()
                    AppHUD.success(hudSuccessText ?? "Success", isDarkTheme: false)
                }
                if let error = error {
                    print(error)
                    return
                }
        }
    }
}

