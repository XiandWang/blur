//
//  HomeController.swift
//  Blur
//
//  Created by xiandong wang on 9/12/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import AudioToolbox

class HomeController: UITableViewController {
    private let cellId = "chatCellId"
    
    var imageMessages = [String: [Message]]()
    var usersDict = [String: User]()
    var userIdsSorted = [String]()
    var isIntialLoading = true
    var messageListener: ListenerRegistration?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Inbox"
        self.setupNavTitleAttr()
        view.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.register(HomeChatCell.self, forCellReuseIdentifier: cellId)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(handleShowFriends))
        listenForMessages()
    }
    
    @objc func handleShowFriends() {
        guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else {
            return
        }
        
        mainTabBarController.selectedIndex = 1
        AppHUD.success("Please choose a friend and send", isDarkTheme: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Reload data to refresh timestamps
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isIntialLoading {
            TableViewHelper.loadingView(viewController: self)
            return 0
        } else {
            let count = imageMessages.keys.count
            if count == 0 {
                TableViewHelper.emptyMessage(message: "No chats yet~", detail: "New to HidingChat? You can send a photo to yourself or HidingChat Monkey to see how it works.", viewController: self)
            } else {
                tableView.backgroundView = nil
            }
            return count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! HomeChatCell
        
        let senderId = userIdsSorted[indexPath.row]
        if let user = self.usersDict[senderId] {
            cell.user = user
        }
        let messages = imageMessages[senderId]
        cell.messages = messages
        
        cell.userAvatarView.tag = indexPath.row
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleShowUserProfile))
        cell.userAvatarView.addGestureRecognizer(tap)
        return cell
    }
    
    @objc func handleShowUserProfile(sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag else { return }
        guard let userId = userIdsSorted[safe: tag], let user = usersDict[userId] else { return }
        let userProfile = UserProfileController()
        userProfile.user = user
        let nav = UINavigationController(rootViewController: userProfile)
        userProfile.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: userProfile, action: #selector(userProfile.dismissNav))
        self.present(nav, animated: true) 
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72.0
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let row = indexPath.row
            let userId = self.userIdsSorted[row]
            guard let messages = self.imageMessages[userId] else { return }
            AppHUD.progress("Deleting...", isDarkTheme: true)
            for message in messages {
                FIRRef.getMessages().document(message.messageId).updateData([MessageSchema.IS_DELETED: true])
            }
            AppHUD.progressHidden()
        }
        
        
        
        return [delete]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let senderId = userIdsSorted[indexPath.row]
        
        if let messages = imageMessages[senderId], let user = self.usersDict[senderId] {
            let messagesPageViewController = MessagesPageViewController(messages: messages, senderUser: user)
            messagesPageViewController.hidesBottomBarWhenPushed = true
            self.configureTransparentNav()
            
            self.navigationController?.pushViewController(messagesPageViewController, animated: true)
            
        }
    }
    
    fileprivate func setBadge() {
        var num = 0
        for (_, messages) in self.imageMessages {
            for m in messages {
                if !m.isAcknowledged {
                    num += 1
                }
            }
        }
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        app.setBadge(tabBarIndex: 0, num: num)
    }
}

// MARK: database
extension HomeController {
    func listenForMessages() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        self.messageListener = FIRRef.getMessages()
            .whereField(MessageSchema.RECEIVER_ID, isEqualTo: currentUserId)
            .whereField(MessageSchema.IS_DELETED, isEqualTo: false)
            .addSnapshotListener { (messagesSnap, error) in
                self.isIntialLoading = false
                messagesSnap?.documentChanges.forEach({ (docChange: DocumentChange) in
                    if docChange.type == .added {
                        guard let senderId = docChange.document.data()[MessageSchema.SENDER_ID] as? String else { return }
                        guard let senderUser = docChange.document.data()[MessageSchema.SENDER_USER] as? [String: Any] else { return }
                        self.addMessage(doc: docChange.document)
                        self.usersDict[senderId] = User(dictionary: senderUser, uid: senderId)
                    } else if docChange.type == .removed {
                        self.removeMessage(doc: docChange.document)
                    } else if docChange.type == .modified {
                        self.modifyMessage(doc: docChange.document)
                    }
                })
                self.setBadge()
                self.tableView.reloadData()
        }
    }
    
    fileprivate func sortUserIdsByMessageCreatedTime() {
        self.userIdsSorted = Array(self.imageMessages.keys).sorted(by: { (userId1, userId2) -> Bool in
            if let msg1 = self.imageMessages[userId1]?.first, let msg2 = self.imageMessages[userId2]?.first {
                return msg1.createdTime > msg2.createdTime
            }
            return userId1 < userId2
        })
    }
    
    fileprivate func addMessage(doc : DocumentSnapshot) {
        guard let docData = doc.data() else { return }
        guard let senderId = docData[MessageSchema.SENDER_ID] as? String else { return }
        let message = Message(dict: docData, messageId: doc.documentID)
        prefetchImages(message: message)
        if let _ = self.imageMessages[senderId] {
            self.imageMessages[senderId]?.append(message)
            // sort by date
            self.imageMessages[senderId] = self.imageMessages[senderId]?.sorted(by: { (msg1, msg2) -> Bool in
                return msg1.createdTime > msg2.createdTime
            })
        } else {
            self.imageMessages[senderId] = [message]
        }
        self.sortUserIdsByMessageCreatedTime()
        
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    fileprivate func prefetchImages(message: Message) {
        let urls = [message.editedImageUrl, message.originalImageUrl].map { URL(string: $0 )! }
        ImagePrefetcher(urls: urls).start()
    }
    
    fileprivate func removeMessage(doc: DocumentSnapshot) {
        guard let docData = doc.data() else { return }
        guard let senderId = docData[MessageSchema.SENDER_ID] as? String else { return }
        let messageIdToRemove = doc.documentID
        guard let messages = self.imageMessages[senderId] else { return }
        guard let index = messages.index(where: { (message) -> Bool in
            return message.messageId == messageIdToRemove
        }) else { return }
        self.imageMessages[senderId]?.remove(at: index)
        if let count = self.imageMessages[senderId]?.count, count == 0 {
            self.imageMessages.removeValue(forKey: senderId)
        }
        
        sortUserIdsByMessageCreatedTime()
    }
    
    fileprivate func modifyMessage(doc: DocumentSnapshot) {
        guard let docData = doc.data() else { return }
        guard let senderId = docData[MessageSchema.SENDER_ID] as? String else { return }
        let messageIdToModify = doc.documentID
        guard let messages = self.imageMessages[senderId] else { return }
        guard let index = messages.index(where: { (message) -> Bool in
            return message.messageId == messageIdToModify
        }) else { return }
        self.imageMessages[senderId]?[index] = Message(dict: docData, messageId: messageIdToModify)
        
        self.sortUserIdsByMessageCreatedTime()
    }
}


