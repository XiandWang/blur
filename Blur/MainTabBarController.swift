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
        
        setupViewControllers()
    }
    
     func setupViewControllers() {
        let myAccountController = MyAccountController(collectionViewLayout: UICollectionViewFlowLayout())
        let myAccountNavController = UINavigationController(rootViewController: myAccountController)
        myAccountNavController.tabBarItem.image = #imageLiteral(resourceName: "profile_unselected")
        myAccountNavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")
        tabBar.tintColor = .black
        tabBar.isTranslucent = false
        
        let friendsNavController = UINavigationController(rootViewController: FriendsController())
        friendsNavController.tabBarItem.image = #imageLiteral(resourceName: "search_unselected")
        friendsNavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "search_selected")
        
        
        let homeNavController = UINavigationController(rootViewController: HomeController())
        homeNavController.tabBarItem.image = #imageLiteral(resourceName: "home_unselected")
        homeNavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "home_selected")

        viewControllers = [homeNavController, friendsNavController, myAccountNavController]
    }
}
