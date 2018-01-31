//
//  NotificationController.swift
//  Blur
//
//  Created by xiandong wang on 1/5/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import UIKit
import Firebase

class NotificationController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var notifications = [MessageNotification]()
    
    let cellId = "notificationCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Notifications"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: PURPLE_COLOR]
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        
        collectionView?.register(NotificationCell.self, forCellWithReuseIdentifier: cellId)
        let trashImg = UIImage.fontAwesomeIcon(name: .trash, textColor: .black, size: CGSize(width: 30, height: 44))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: trashImg, style: .plain, target: self, action: #selector(deleteNotifications))
        navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -8)
        listenForNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let curUserId = Auth.auth().currentUser?.uid else { return }
        for notif in notifications {
            notif.isRead = true
            Firestore.firestore().collection("notifications").document(curUserId)
                .collection("messageNotifications").document(notif.notificationId).updateData(["isRead": true])
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView?.reloadData()
    }
    
    @objc fileprivate func deleteNotifications() {
        guard let curUserId = Auth.auth().currentUser?.uid else { return }
        AppHUD.progress(nil, isDarkTheme: true)
        for notif in notifications {
            Firestore.firestore().collection("notifications").document(curUserId)
                    .collection("messageNotifications").document(notif.notificationId).delete(completion: { (error) in
                        if let error = error  {
                            AppHUD.error(error.localizedDescription, isDarkTheme: true)
                            return
                        }
                    })
        }
        self.notifications = []
        collectionView?.reloadData()
        AppHUD.progressHidden()
    }
    
    fileprivate func listenForNotifications() {
        guard let curUserId = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("notifications")
            .document(curUserId).collection("messageNotifications").order(by: "createdTime", descending: false).addSnapshotListener { (snap, error) in
                if let error = error {
                    print(error.localizedDescription)
                    AppHUD.error(error.localizedDescription, isDarkTheme: true)
                    return
                }
                guard let docChanges = snap?.documentChanges else { return }
                print(docChanges.count)
                for docChange in docChanges {
                    if docChange.type == .added {
                        let doc = docChange.document
                        let notification = MessageNotification(dict: doc.data(), notificationId: doc.documentID)
                        self.notifications.insert(notification, at: 0)
                        print(notification)
                        //DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        //}
                    }
                }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return notifications.count
//        if notifications.count == 0 {
//            let l = UILabel(frame: view.bounds)
//            l.text = "sdsf"
//            collectionView.backgroundView = l
//            return 0
//        }
        return notifications.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 72.0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NotificationCell
        cell.notification = self.notifications[indexPath.row]
        
        return cell
    }
    
    
    
}

extension UIBarButtonItem {
    
    /// 生成一个窄的 UIBarButtonItem
    ///
    /// - parameter image:
    /// - parameter target:
    /// - parameter action:
    ///
    /// - returns: UIBarButtonItem
    static func narrowButtonItem(image: UIImage?, target: AnyObject?, action: Selector) -> UIBarButtonItem {
        let (item, _) = narrowButtonItem2(image: image, target: target, action: action)
        return item
    }
    
    /// 生成一个窄的 UIBarButtonItem(同时返回 UIBarButtonItem 和里面的 UIButton)
    ///
    /// - parameter image:
    /// - parameter target:
    /// - parameter action:
    ///
    /// - returns: (UIBarButtonItem, UIButton)
    static func narrowButtonItem2(image: UIImage?, target: AnyObject?, action: Selector) -> (UIBarButtonItem, UIButton) {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 44))
        button.setImage(image, for: UIControlState())
        button.addTarget(target, action: action, for: .touchUpInside)
        return (UIBarButtonItem(customView: button), button)
    }
    
    /// 返回一个负宽度的 FixedSpace，使得 leftBarButtonItem 和 rightBarButtonItem 距离屏幕边框不那么远。
    ///
    /// - returns: 负宽度的 FixedSpace
    static func fixNavigationSpacer() -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil);
        item.width = -20;
        return item
    }
    
}
