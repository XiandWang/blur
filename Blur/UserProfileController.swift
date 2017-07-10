//
//  UserProfileController.swift
//  Blur
//
//  Created by xiandong wang on 7/10/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: UICollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        fetchUser()
    }
    
    fileprivate func fetchUser() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            print("************************debugging")
            return
        }
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            print("************************debugging")
            print(snapshot.value ?? "")
            guard let userDict = snapshot.value as? [String: Any],
                  let username = userDict["username"] as? String else { return }
            self.navigationItem.title = username
        }) { (error) in
            AppHUD.error(error.localizedDescription)
            return
        }
    }
}

