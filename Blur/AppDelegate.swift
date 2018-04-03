//
//  AppDelegate.swift
//  Blur
//
//  Created by xiandong wang on 7/5/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate, GIDSignInDelegate {
    

    var window: UIWindow?

    fileprivate func getEnvFile() -> String? {
        #if DEBUG
            return Bundle.main.path(forResource: "GoogleService-Info-dev", ofType: "plist")
        #else
            return Bundle.main.path(forResource: "GoogleService-Info-prod", ofType: "plist")
        #endif
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let filePath = getEnvFile()
        guard let fileopts = FirebaseOptions(contentsOfFile: filePath!)
            else { exit(0) }

        FirebaseApp.configure(options: fileopts)
        
       // FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
                
        UINavigationBar.appearance().barTintColor = YELLOW_COLOR
        UINavigationBar.appearance().tintColor = .black
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: APP_FONT, size: 17) ?? UIFont.systemFont(ofSize: 17)], for: UIControlState.normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.lightGray], for: .disabled)
        

        window = UIWindow()
        window?.rootViewController = MainTabBarController()
        window?.tintColor = TINT_COLOR

        registerNotifications(app: application)
        
        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        //print("registered with fcm", fcmToken)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if let type = userInfo["type"] as? String {
            guard let tabBarController = window?.rootViewController as? MainTabBarController else { return }
            if type == "newFriendRequest" {
                tabBarController.selectedIndex = 1
            } else if type == "newImageMessage" {
                tabBarController.selectedIndex = 0
            } else if type == "newMessageNotification" {
                tabBarController.selectedIndex = 2
            }
        }
    }
    
    
    fileprivate func registerNotifications(app: UIApplication) {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            if let _ = error {
               // print(error as Any)
            }
        }
        app.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let _ = deviceToken
        //print("device token", deviceToken)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            AppHUD.progressHidden()
            AppHUD.error(error.localizedDescription, isDarkTheme: true)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                AppHUD.progressHidden()
                AppHUD.error(error.localizedDescription, isDarkTheme: true)
                return
            }
            guard let uid = user?.uid else { return }
            Database.database().reference().child(USERS_NODE).child(uid).observeSingleEvent(of: .value, with: { (snap) in
                if !snap.exists() {
                    let fcmToken = Messaging.messaging().fcmToken
                    let time = Date().timeIntervalSince1970
                    let childUpdates = ["/\(FRIENDS_NODE)/\(uid)/\(uid)": ["status": FriendStatus.added.rawValue, "updatedTime": time],
                                        "/\(USERS_NODE)/\(uid)": ["createdTime": time, "fcmToken": fcmToken ?? ""]] as [String : Any]
                    Database.database().reference().updateChildValues(childUpdates, withCompletionBlock: { (error, ref) in
                        if let error = error  {
                            AppHUD.progressHidden()
                            AppHUD.error(error.localizedDescription, isDarkTheme: true)
                            return
                        }
                        NotificationCenter.default.post(name: NEW_GOOGLE_SIGN_UP_SUCCESS, object: nil, userInfo: ["userId": uid])
                    })
                } else {
                    NotificationCenter.default.post(name: GOOGLE_LOGIN_SUCCESS, object: nil, userInfo: ["userId": uid])
                }
            })
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            AppHUD.progressHidden()
            AppHUD.error(error.localizedDescription, isDarkTheme: true)
        }
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            let googleHandled = GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:])
            return googleHandled
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func setBadge(tabBarIndex:Int, num: Int) {
        guard let mainTabBarController = window?.rootViewController as? MainTabBarController else { return }
        guard let tabBarItems = mainTabBarController.tabBar.items else { return }
        if tabBarIndex >= tabBarItems.count { return }
        if num > 0 {
            tabBarItems[tabBarIndex].badgeValue = "\(num)"
        } else {
            tabBarItems[tabBarIndex].badgeValue = nil
        }
        
        var appBadge = 0
        for item in tabBarItems {
            if let curBadgeStr = item.badgeValue, let curBadgeNum = Int(curBadgeStr), curBadgeNum >= 0 {
                appBadge += curBadgeNum
            }
        }
        UIApplication.shared.applicationIconBadgeNumber = appBadge > 0 ? appBadge : 0
    }
}

