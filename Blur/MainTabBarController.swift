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
        if FIRAuth.auth()?.currentUser == nil {
            DispatchQueue.main.async {
                let navController = UINavigationController(rootViewController: LoginController())
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
        view.backgroundColor = .blue
        
        let navController = UINavigationController(rootViewController: UserProfileController(collectionViewLayout: UICollectionViewFlowLayout()))
        navController.tabBarItem.image = #imageLiteral(resourceName: "profile_unselected")
        navController.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")
        tabBar.tintColor = UIColor.rgb(red: 255, green: 153, blue: 0, alpha: 1)
        tabBar.isTranslucent = false
        viewControllers = [navController, UIViewController()]
    }
}
