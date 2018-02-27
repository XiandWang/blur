//
//  User.swift
//  Blur
//
//  Created by xiandong wang on 2017/10/1.
//  Copyright © 2017年 xiandong wang. All rights reserved.
//

import Foundation

struct User {
    let uid: String
    let username: String
    var fullName: String
    var profileImgUrl: String?
    
    init(dictionary: [String: Any], uid: String) {
        self.uid = uid
        self.username = dictionary["username"] as? String ?? "(NO_USERNAME)"
        self.fullName = dictionary["fullName"] as? String ?? "(NO_FULL_NAME)"
        self.profileImgUrl =  dictionary["profileImgUrl"] as? String
    }
}
