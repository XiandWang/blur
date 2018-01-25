//
//  MainTabBarController.swift
//  Blur
//
//  Created by xiandong wang on 7/10/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let navController = UINavigationController(rootViewController: LoginController())
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
        guard let uid = Auth.auth().currentUser?.uid else { return }
//        Database.database().reference().child(USERS_NODE).child(uid).observe(.value, with: { (snap) in
//            let dict = snap.value as? [String: Any]
//            if dict == nil || dict?["username"] == nil {
//                let chooseNameController = ChooseUserNameController()
//                chooseNameController.uid = uid
//                DispatchQueue.main.async {
//                    let navController = UINavigationController(rootViewController: chooseNameController)
//                    navController.isNavigationBarHidden = true
//                    self.present(navController, animated: true, completion: nil)
//                }
//            }
//        }, withCancel: nil)
        
//        Database.database().reference().child(USERS_NODE).child(uid).observeSingleEvent(of: DataEventType.value, with: { (snap) in
//            let dict = snap.value as? [String: Any]
//            if dict == nil || dict?["username"] == nil {
//                let chooseNameController = ChooseUserNameController()
//                chooseNameController.uid = uid
//                DispatchQueue.main.async {
//                    let navController = UINavigationController(rootViewController: chooseNameController)
//                    navController.isNavigationBarHidden = true
//                    self.present(navController, animated: true, completion: nil)
//                }
//            }
//        }, withCancel: nil)
        
        Database.isUsernameChosen(uid: uid) { (isEntered, error) in
            if let error = error {
                AppHUD.error(error.localizedDescription, isDarkTheme: true)
                return
            }
            if !isEntered {
                let chooseNameController = ChooseUserNameController()
                chooseNameController.uid = uid
                DispatchQueue.main.async {
                    let navController = UINavigationController(rootViewController: chooseNameController)
                    navController.isNavigationBarHidden = true
                    self.present(navController, animated: true, completion: nil)
                }
            }
        }
        
        setupViewControllers()
        
    }
    
     func setupViewControllers() {
        tabBar.tintColor = .black
        tabBar.isTranslucent = false
        let size = CGSize(width: 40, height: 40)
        let myAccountController = MyAccountController(collectionViewLayout: UICollectionViewFlowLayout())
        let myAccountNavController = UINavigationController(rootViewController: myAccountController)
        myAccountNavController.tabBarItem.image = UIImage.fontAwesomeIcon(name: .userCircle, textColor: .lightGray, size: size)
        myAccountNavController.tabBarItem.selectedImage = UIImage.fontAwesomeIcon(name: .userCircle, textColor: .black, size: size)
        //myAccountNavController.tabBarItem.title = "Me"
        
        
        let friendsNavController = UINavigationController(rootViewController: FriendsController())
        friendsNavController.tabBarItem.image = UIImage.fontAwesomeIcon(name: .addressBook, textColor: .lightGray, size: size)
        friendsNavController.tabBarItem.selectedImage = UIImage.fontAwesomeIcon(name: .addressBook, textColor: .black, size: size)
        //friendsNavController.tabBarItem.title = "Friends"
        
        let notificationController = NotificationController(collectionViewLayout: UICollectionViewFlowLayout())
        let notificationNavController = UINavigationController(rootViewController: notificationController)
        notificationNavController.tabBarItem.image = UIImage.fontAwesomeIcon(name: .bell, textColor: .lightGray, size: CGSize(width: 40, height: 30))
        notificationNavController.tabBarItem.selectedImage = UIImage.fontAwesomeIcon(name: .bell, textColor: .black, size: CGSize(width: 40, height: 30))
        
        let homeNavController = UINavigationController(rootViewController: HomeController())
        homeNavController.tabBarItem.image = UIImage.fontAwesomeIcon(name: .camera, textColor: .lightGray, size: size)
        homeNavController.tabBarItem.selectedImage = UIImage.fontAwesomeIcon(name: .camera, textColor: .black, size: size)
        //homeNavController.tabBarItem.title = "HidingChats"

        viewControllers = [homeNavController, friendsNavController, notificationNavController, myAccountNavController]
    }
}
