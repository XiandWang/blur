//
//  DBNode.swift
//  Blur
//
//  Created by xiandong wang on 2/25/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import Firebase

class FIRRef {
    static let fireStore = Firestore.firestore()
    
    static func getMessages() -> CollectionReference {
        #if DEBUG
            return fireStore.collection("test_messages")
        #else
            return fireStore.collection("messages")
        #endif
    }
    
    static func getLikes() -> CollectionReference {
        #if DEBUG
            return fireStore.collection("test_messageLikes")
        #else
            return fireStore.collection("messageLikes")
        #endif
    }
    
    static func getNotifications() -> CollectionReference {
        #if DEBUG
            return fireStore.collection("test_notifications")
        #else
            return fireStore.collection("notifications")
        #endif
    }
    
    static func getHasAllowedAccess() -> CollectionReference {
        #if DEBUG
            return fireStore.collection("test_hasAllowedAccess")
        #else
            return fireStore.collection("hasAllowedAccess")
        #endif
    }
    
    static func getHasSentRequest() -> CollectionReference {
        #if DEBUG
            return fireStore.collection("test_hasSentRequest")
        #else
            return fireStore.collection("hasSentRequest")
        #endif
    } 
}
