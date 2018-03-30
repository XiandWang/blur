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



