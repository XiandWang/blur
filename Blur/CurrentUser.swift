//
//  CurrentUser.swift
//  Blur
//
//  Created by xiandong wang on 1/7/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import Firebase

class CurrentUser {
    static var user: User?
    static var hasShownInviteDialog = false
    static var hasShowNewUserInstructions = false
    static var numInvites = 5
    
    static func getUser(completion: @escaping ((User?, Error?) -> ())) {
        if let user = self.user {
            completion(user, nil)
            return
        } else {
            guard let uid = Auth.auth().currentUser?.uid  else {
                completion(nil, NSError(domain: "user uid error", code: 0, userInfo: nil))
                return
            }
            
            Database.getUser(uid: uid, completion: { (user, error) in
                if let user = user {
                    self.user = user
                    completion(user, nil)
                } else if let error = error {
                    completion(nil, error)
                }
            })
        }
    }
    
    
    static func getInvitesNum() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("invites").child(uid).observeSingleEvent(of: .value) { (snap) in
            if snap.exists() {
                guard let dict = snap.value as? [String: Any] else { return }
                guard let num = dict["num"] as? Int else { return }
                self.numInvites = num
            } else {
                self.numInvites = 0
            }
        }
    }
}
