//
//  NotificationController.swift
//  Blur
//
//  Created by xiandong wang on 1/5/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import UIKit
import Firebase
import AZDialogView

class NotificationController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    let maxString = "zzzzzzzzzzzzzzzz requests access to your photo. Mood: ♥️♥️♥️♥️♥️♥️♥️♥️♥️♥️. 13 mins."
    
    
    var notifications = [MessageNotification]()
    var notificationMessages = [String: Message]()
    var senderTypes = [NotificationType.likeMessage.rawValue, NotificationType.rejectMessage.rawValue, NotificationType.requestAccess.rawValue]
    var receiverTypes = [NotificationType.allowAccess.rawValue]
    
    let messageCellId = "messageNotifCellId"
    let otherCellId = "otherNotifCellId"

    var notificationsListener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Notifications"
        self.setupNavTitleAttr()
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        
        collectionView?.register(MessageNotificationCell.self, forCellWithReuseIdentifier: messageCellId)
        collectionView?.register(OtherNotificationCell.self, forCellWithReuseIdentifier: otherCellId)
        setupRightBarItem()
        listenForNotifications()

    }
    
    
    func setupRightBarItem() {
        let trashImg = UIImage.fontAwesomeIcon(name: .trash, textColor: .black, size: CGSize(width: 30, height: 44))
        let barItem = UIBarButtonItem(image: trashImg, style: .plain, target: self, action: #selector(deleteNotifications))
        if #available(iOS 11.0, *) {
           navigationItem.rightBarButtonItem = barItem
            navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -8)
        } else {
            navigationItem.rightBarButtonItems = [UIBarButtonItem.fixNavigationSpacer(),  barItem]
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.collectionView?.reloadData()
    }
    
    @objc fileprivate func deleteNotifications() {
        guard let curUserId = Auth.auth().currentUser?.uid else { return }
        AppHUD.progress(nil, isDarkTheme: true)
//        for notif in notifications {
//            FIRRef.getNotifications().document(curUserId)
//                    .collection("messageNotifications").document(notif.notificationId).delete(completion: { (error) in
//                        if let error = error  {
//                            AppHUD.error(error.localizedDescription, isDarkTheme: true)
//                            return
//                        }
//                    })
//        }
        
        let batch = Firestore.firestore().batch()
        for notif in notifications {
            batch.deleteDocument(FIRRef.getNotifications().document(curUserId)
                .collection("messageNotifications").document(notif.notificationId))
        }
        batch.commit { (error) in
            AppHUD.progressHidden()
            if let error = error {
                AppHUD.error(error.localizedDescription, isDarkTheme: true)
                return
            }
            AppHUD.success("Deleted", isDarkTheme: true)
        }
        
        if let app = UIApplication.shared.delegate as? AppDelegate {
            app.setBadge(tabBarIndex: 2, num: 0)
        }
    }
    
    fileprivate func listenForNotifications() {
        guard let curUserId = Auth.auth().currentUser?.uid else { return }
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else { return }
        self.notificationsListener =
            FIRRef.getNotifications()
                .document(curUserId)
                .collection("messageNotifications")
                .order(by: "createdTime", descending: false)
                .whereField("createdTime", isGreaterThan: yesterday)
                .addSnapshotListener { (snap, error) in
                if let error = error {
                    AppHUD.error("Notifications error: " + error.localizedDescription, isDarkTheme: true)
                    return
                }
                guard let docChanges = snap?.documentChanges else { return }
                for docChange in docChanges {
                    if docChange.type == .added {
                        let doc = docChange.document
                        let notification = MessageNotification(dict: doc.data(), notificationId: doc.documentID)
                        self.notifications.insert(notification, at: 0)
                    }
                    else if docChange.type  == .modified {
                        let id = docChange.document.documentID
                        if let index = self.notifications.index(where: { (notif) -> Bool in
                            return notif.notificationId == id
                        }) {
                            let notification = MessageNotification(dict: docChange.document.data(), notificationId: docChange.document.documentID)
                            self.notifications[index] = notification
                        }
                    }  else if docChange.type  == .removed {
                        let id = docChange.document.documentID
                        if let index = self.notifications.index(where: { (notif) -> Bool in
                            return notif.notificationId == id
                        }) {
                            self.notifications.remove(at: index)
                        }
                    }
                }
                self.collectionView?.reloadData()
                guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
                let unreadNum = self.notifications.filter({$0.isRead == false}).count
                app.setBadge(tabBarIndex: 2, num: unreadNum)
        }
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = notifications.count
        if count == 0 {
            let label = UILabel()
            label.font = UIFont(name: APP_FONT_BOLD, size: 24)
            label.textColor = TEXT_GRAY
            label.text = "No new notifications"
            label.textAlignment = .center
            collectionView.backgroundView = label
            label.center = collectionView.center
        } else {
            collectionView.backgroundView = nil
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let notif = self.notifications[indexPath.row]
        if notif.type == NotificationType.askForChat.rawValue ||  notif.type == NotificationType.compliment.rawValue {
            return CGSize(width: view.frame.width, height: 80.0)
        } else {
            let rect = NSString(string: notif.buildNotifString()).boundingRect(with: CGSize(width:view.width - 80.0 - 32.0, height: 999), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedStringKey.font: TEXT_FONT], context: nil).size

            let height = max(rect.height + 24.0, 80)
            return CGSize(width: view.frame.width, height: height)
        }
     }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let notif = self.notifications[indexPath.row]
        if notif.type == NotificationType.askForChat.rawValue || notif.type == NotificationType.compliment.rawValue {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: otherCellId, for: indexPath) as! OtherNotificationCell
            cell.notification = notif
            cell.userProfileImageView.tag = indexPath.row
            cell.userProfileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowUserProfile(sender:))))
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: messageCellId, for: indexPath) as! MessageNotificationCell
            cell.notification = notif
            cell.userProfileImageView.tag = indexPath.row
            cell.userProfileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowUserProfile(sender:))))
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        let notification = self.notifications[indexPath.row]
        if receiverTypes.contains(notification.type) {
            guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else { return }
            if notification.createdTime >= yesterday {
                let receiverController = ReceiverImageMessageController()
                receiverController.message = notification.message
                receiverController.senderUser = notification.user
                receiverController.hidesBottomBarWhenPushed = true
                present(receiverController, animated: true, completion: nil)
            } else {
                deleteNotification(notifId: notification.notificationId, row: indexPath.row)
                return
            }
        } else if senderTypes.contains(notification.type) {
            guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else { return }
            if notification.createdTime >= yesterday {
                let senderController = SenderImageMessageController()
                senderController.receiverUser = notification.user
                senderController.message = notification.message
                senderController.hidesBottomBarWhenPushed = true
                self.configureTransparentNav()
                self.navigationController?.pushViewController(senderController, animated: true)
            } else {
                deleteNotification(notifId: notification.notificationId, row: indexPath.row)
                return
            }
        } else if notification.type == NotificationType.askForChat.rawValue {
            let userProfile = UserProfileController()
            userProfile.user = notification.user
            let nav = UINavigationController(rootViewController: userProfile)
            userProfile.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: userProfile, action: #selector(userProfile.dismissNav))
            self.present(nav, animated: true)
        } else if notification.type == NotificationType.compliment.rawValue {
            guard let complimentText = notification.text else { return }
            showComplimentDialog(compliment: complimentText, user: notification.user.fullName)
        }
        
        if !notification.isRead {
            notification.isRead = true
            guard let curUserId = Auth.auth().currentUser?.uid else { return }
            FIRRef.getNotifications().document(curUserId)
                .collection("messageNotifications").document(notification.notificationId).updateData(["isRead": true])
        }
    }
    
    
    func deleteNotification(notifId: String, row: Int) {
        guard let curUserId = Auth.auth().currentUser?.uid else { return }
        AppHUD.progress("Message expired...", isDarkTheme: true)
        
        
        FIRRef.getNotifications().document(curUserId)
            .collection("messageNotifications").document(notifId).delete { (error) in
                if let e = error {
                    AppHUD.progressHidden()
                    AppHUD.error(e.localizedDescription, isDarkTheme: true)
                    return
                }
                AppHUD.progressHidden()
        }
        
    }
    
    func showComplimentDialog(compliment: String, user: String) {
        let blue = LIGHT_BLUE
        let dialog = AZDialogViewController(title: user, message: compliment, verticalSpacing: -1, buttonSpacing: 10, sideSpacing: 17, titleFontSize: 20, messageFontSize: 16, buttonsHeight: 44)
        dialog.dismissWithOutsideTouch = true
        dialog.blurBackground = true
        dialog.imageHandler = { (imageView) in
            imageView.image = UIImage.fontAwesomeIcon(name: .heart, textColor: UIColor.white, size: CGSize(width: 50, height: 50))
            imageView.backgroundColor = blue
            imageView.contentMode = .center
            return true //must return true, otherwise image won't show.
        }
        dialog.buttonStyle = { (button,height,position) in
            button.setTitleColor(blue, for: .normal)
            button.titleLabel?.font = TEXT_FONT
            button.layer.masksToBounds = true
            button.layer.borderColor = blue.cgColor
        }
        dialog.addAction(AZDialogAction(title: "close", handler: { (dialog) -> (Void) in
            dialog.dismiss()
        }))
        
        dialog.show(in: self)

    }
    
    @objc func handleShowUserProfile(sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag else { return }
        guard let user = self.notifications[safe: tag]?.user else { return }
        
        let userProfile = UserProfileController()
        userProfile.user = user
        let nav = UINavigationController(rootViewController: userProfile)
        userProfile.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: userProfile, action: #selector(userProfile.dismissNav))
        self.present(nav, animated: true)
    }
}

extension UIViewController {
     public func configureTransparentNav() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        let color = PURPLE_COLOR_LIGHT
        navigationController?.navigationBar.tintColor = color
        navigationItem.backBarButtonItem?.tintColor = color
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: color]
        
    }
    
    public func setupNavTitleAttr() {
        let font = UIFont(name: APP_FONT_BOLD, size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: font]
    }
    
    public func hideBackButton() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
