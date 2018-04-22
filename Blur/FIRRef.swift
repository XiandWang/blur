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
    static let PROD_HIDINGCHAT_TEAM_UID = "VcaU4cIuoNV9I2JViQRIsNvxp9K2"
    static let  DEV_HIDINGCHAT_TEAM_UID = "E6ciOBTwRXfYEnogy04F3xldfng1"
    
    static func getMessages() -> CollectionReference {
            return fireStore.collection("messages")
    }
    
    static func getMessageLikes() -> CollectionReference {
            return fireStore.collection("messageLikes")
    }
    
    static func getNotifications() -> CollectionReference {
       // #if DEBUG
            return fireStore.collection("notifications")
//        #else
//            return fireStore.collection("prod_notifications")
//        #endif
    }
    
    static func getHasAllowedAccess() -> CollectionReference {
        //#if DEBUG
            return fireStore.collection("hasAllowedAccess")
//        #else
//            return fireStore.collection("prod_hasAllowedAccess")
//        #endif
    }
    
    static func getHasSentRequest() -> CollectionReference {
        //#if DEBUG
            return fireStore.collection("hasSentRequest")
//        #else
//            return fireStore.collection("prod_hasSentRequest")
//        #endif
    }
    
    static func getCompliments() -> CollectionReference {
        //#if DEBUG
            return fireStore.collection("compliments")
//        #else
//            return fireStore.collection("prod_compliments")
//        #endif
    }
    
    static func getActivities() -> CollectionReference {
        //#if DEBUG
            return fireStore.collection("userActivities")
//        #else
//            return fireStore.collection("prod_userActivities")
//        #endif
    }
    
    static func getImageMessages() -> StorageReference {
        //#if DEBUG
            return Storage.storage().reference().child("imageMessages")
        //#else
            //return Storage.storage().reference().child("prod_imageMessages")
        //#endif
    }
    
    static func getTeamUid() -> String {
        #if DEBUG
            return DEV_HIDINGCHAT_TEAM_UID
        #else
            return PROD_HIDINGCHAT_TEAM_UID
        #endif
    }
}
