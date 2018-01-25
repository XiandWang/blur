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
    
    static func getUser(completion: @escaping ((User?, Error?) -> ())) {
        if let user = self.user {
            print("user is cached")
            completion(user, nil)
            return
        } else {
            guard let uid = Auth.auth().currentUser?.uid  else {
                completion(nil, NSError())
                return
            }
            Database.getUser(uid: uid, completion: { (user, error) in
                if let user = user {
                    print("user is not cached")
                    self.user = user
                    completion(user, nil)
                } else if let error = error {
                    completion(nil, error)
                }
            })
        }
    }
}
