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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        UINavigationBar.appearance().barTintColor = UIColor.rgb(red: 255, green: 218, blue: 68, alpha: 1)
        UINavigationBar.appearance().tintColor = .black
        
        window = UIWindow()
        window?.rootViewController = MainTabBarController()
        window?.tintColor = .black
    
        registerNotifications(app: application)
        
        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("registered with fcm", fcmToken) 
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.notification)
        
        let userInfo = response.notification.request.content.userInfo
        
        if let type = userInfo["type"] as? String {
            print("type", type, "&&&&&&&&&&&&&&&&&&&")
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
        print("attempt to register")
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            if let error = error {
                print(error as Any)
            }
            
            if granted {
                print(")))))))))))))))) granted")
            } else {
                print("denied")
            }
        }
        app.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("device token", deviceToken)
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


}

