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
        
        Database.isUsernameChosen(uid: uid) { (isChosen, error) in
            if let error = error {
                AppHUD.error(error.localizedDescription, isDarkTheme: true)
                return
            }
            if !isChosen {
                let chooseNameController = ChooseUserNameController()
                chooseNameController.uid = uid
                DispatchQueue.main.async {
                    let navController = UINavigationController(rootViewController: chooseNameController)
                    navController.isNavigationBarHidden = true
                    self.present(navController, animated: true, completion: nil)
                }
            }
        }
        
        CurrentUser.getUser { (_, _) in
        }
        
        setupViewControllers()
    }
    
     func setupViewControllers() {
        tabBar.tintColor = YELLOW_COLOR
        tabBar.barTintColor = UIColor.hexStringToUIColor(hex: "#141e33")
        tabBar.isTranslucent = false
        let myAccountController = MyAccountController(collectionViewLayout: UICollectionViewFlowLayout())
        let myAccountNavController = UINavigationController(rootViewController: myAccountController)
        myAccountNavController.tabBarItem.image = #imageLiteral(resourceName: "ic_person").imageWithColor(.white)
        myAccountNavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "ic_person")
        

        let friendsNavController = UINavigationController(rootViewController: FriendsController())
        friendsNavController.tabBarItem.image = #imageLiteral(resourceName: "ic_people")
        friendsNavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "ic_people")
        
        let notificationController = NotificationController(collectionViewLayout: UICollectionViewFlowLayout())
        let notificationNavController = UINavigationController(rootViewController: notificationController)
        notificationNavController.tabBarItem.image = #imageLiteral(resourceName: "bell")
        notificationNavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "bell")    
        
        let homeNavController = UINavigationController(rootViewController: HomeController())
        homeNavController.tabBarItem.image = #imageLiteral(resourceName: "speech_buble")
        homeNavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "speech_buble")
        viewControllers = [homeNavController, friendsNavController, notificationNavController, myAccountNavController]
    }
}
