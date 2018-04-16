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
                let navController = UINavigationController(rootViewController: ChooseLoginSignupController())
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
        CurrentUser.getInvitesNum()
        
        setupViewControllers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if let isGoogleSignIn = Auth.auth().currentUser?.providerData[safe: 0]?.providerID.starts(with: "google"), isGoogleSignIn {
            Database.hasAcceptedTerms(uid: uid) { (hasAccepted, error) in
                if let error = error {
                    AppHUD.error(error.localizedDescription, isDarkTheme: true)
                    return
                }
                if !hasAccepted {
                    let terms = EULAController()
                    terms.uid = uid
                    terms.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: terms, action: #selector(terms.handleReject))
                    terms.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Accept", style: .plain, target: terms, action: #selector(terms.handleAccept))
                    DispatchQueue.main.async {
                        let navController = UINavigationController(rootViewController: terms)
                        self.present(navController, animated: true, completion: {
                            AppHUD.success("Please accept the Terms of Service first", isDarkTheme: true)
                        })
                    }
                }
            }
        }
    }
    
     func setupViewControllers() {
        tabBar.tintColor = YELLOW_COLOR
        tabBar.barTintColor = UIColor.hexStringToUIColor(hex: "#141e33")
        tabBar.isTranslucent = false
        let myAccountController = MyAccountController(collectionViewLayout: UICollectionViewFlowLayout())
        let myAccountNavController = UINavigationController(rootViewController: myAccountController)
        myAccountNavController.tabBarItem.image = #imageLiteral(resourceName: "ic_person")
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
