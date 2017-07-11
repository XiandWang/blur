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
        setupLogoutButton()
    }
    
    fileprivate func setupLogoutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear"), style: .plain, target: self, action:#selector(handleLogout))
        navigationItem.rightBarButtonItem?.tintColor = PRIMARY_COLOR
    }
    
    func handleLogout() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            print("perform")
            do {
                try FIRAuth.auth()?.signOut()
                let navController = UINavigationController(rootViewController: LoginController())
                self.present(navController, animated: true, completion: nil)
            } catch let signOutError {
                AppHUD.error(signOutError.localizedDescription)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func fetchUser() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            AppHUD.error("Cannot retrieve the current user")
            return
        }
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userDict = snapshot.value as? [String: Any] else { return }
            let user = User(dictionary: userDict)
            self.navigationItem.title = user.username
        }) { (error) in
            AppHUD.error(error.localizedDescription)
            return
        }
    }
}

struct User {
    let username: String
    let profileImageUrl: String
    
    init(dictionary: [String: Any]) {
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl =  dictionary["profileImageUrl"] as? String ?? ""
    }
}

