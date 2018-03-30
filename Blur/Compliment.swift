//
//  Compliment.swift
//  Blur
//
//  Created by xiandong wang on 3/15/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import Foundation

struct Compliment {
    let complimentId: String
    let sender: User?
    let complimentText: String
    let createdTime: Date
    
    init(dict: [String: Any], complimentId: String) {
        self.complimentId = complimentId
        
        if let userDict = dict["sender"] as? [String: Any], let uid = userDict["userId"] as? String {
            self.sender = User(dictionary: userDict, uid: uid)
        } else {
            self.sender = nil
        }
        self.complimentText = dict["compliment"] as? String ?? ""
        self.createdTime = dict["createdTime"] as? Date ?? Date()
    }
}
