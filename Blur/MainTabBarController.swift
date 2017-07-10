//
//  MainTabBarController.swift
//  Blur
//
//  Created by xiandong wang on 7/10/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .blue
        
        let navController = UINavigationController(rootViewController: UserProfileController(collectionViewLayout: UICollectionViewFlowLayout()))
        navController.tabBarItem.image = #imageLiteral(resourceName: "profile_unselected")
        navController.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")
        tabBar.tintColor = UIColor.rgb(red: 255, green: 153, blue: 0, alpha: 1)
        viewControllers = [navController, UIViewController()]
    }
}
