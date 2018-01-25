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
import TDBadgedCell

class HomeController: UITableViewController {
    private let cellId = "chatCellId"
    
    var imageMessages = [String: [Message]]()
    var usersDict = [String: User]()
    var userIdsSorted = [String]()
    var isIntialLoading = true

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.register(HomeChatCell.self, forCellReuseIdentifier: cellId)
        setupNavigationItems()
        listenForMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //ImageCache.default.clearMemoryCache()
        // Reload data to refresh timestamps
        tableView.reloadData()
    }
    
    func setupNavigationItems() {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        self.navigationItem.title = "Chats"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isIntialLoading {
            TableViewHelper.loadingView(viewController: self)
            return 0
        } else {
            let count = imageMessages.keys.count
            if count == 0 {
                TableViewHelper.emptyMessage(message: "You have no recent chats", viewController: self)
                return 0
            } else {
                tableView.backgroundView = nil
                return count
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! HomeChatCell
        print(indexPath.row, "******************indexPath")
        print(self.userIdsSorted.count, "******************count")
        
        let senderId = userIdsSorted[indexPath.row]
        if let user = self.usersDict[senderId] {
            cell.user = user
        }
        let messages = imageMessages[senderId]
        cell.messages = messages
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72.0
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let userId = self.userIdsSorted[row]
        guard let messages = self.imageMessages[userId] else { return }
        print(messages)
        AppHUD.progress("Deleting...", isDarkTheme: true)
        for message in messages {
            Firestore.firestore()
                .collection("imageMessages").document(message.messageId).updateData([MessageSchema.IS_DELETED: true])
        }
        AppHUD.progressHidden()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let senderId = userIdsSorted[indexPath.row]
        if let user = self.usersDict[senderId] {
            print(user.username)
        }
        if let messages = imageMessages[senderId], let user = self.usersDict[senderId] {
            let messagesPageViewController = MessagesPageViewController(messages: messages, senderUser: user)
            messagesPageViewController.hidesBottomBarWhenPushed = true
            configureTransparentNav()
            navigationController?.pushViewController(messagesPageViewController, animated: true)
        }
    }
    
    fileprivate func configureTransparentNav() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
        
        navigationItem.backBarButtonItem?.tintColor = YELLOW_COLOR
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: YELLOW_COLOR]
    }
    
    func listenForMessages() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("imageMessages").whereField(MessageSchema.RECEIVER_ID, isEqualTo: currentUserId)
            .whereField(MessageSchema.IS_DELETED, isEqualTo: false)
            .addSnapshotListener { (messagesSnap, error) in
                self.isIntialLoading = false
                messagesSnap?.documentChanges.forEach({ (docChange: DocumentChange) in
                    if docChange.type == .added {
                        print("added not modified...")
                        print(docChange.document.documentID)

                        let senderId = docChange.document.data()[MessageSchema.SENDER_ID] as! String
                        self.addMessage(doc: docChange.document)
                        self.sortUserIdsByMessageCreatedTime()
                        if self.usersDict[senderId] == nil {
                            self.getUser(uid: senderId) // async
                        } else {
                            DispatchQueue.main.async {
                                self.tableView?.reloadData()
                            }
                        }
                    } else if docChange.type == .removed {
                        self.removeMessage(doc: docChange.document)
                    } else if docChange.type == .modified {
                        self.modifyMessage(doc: docChange.document)
                    }
                })
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
        
        let senderId = doc.data()[MessageSchema.SENDER_ID] as! String
        let message = Message(dict: doc.data(), messageId: doc.documentID)
        let urls = [doc.data()[MessageSchema.EDITED_IMAGE_URL] as! String, doc.data()[MessageSchema.ORIGINAL_IMAGE_URL] as! String].map { URL(string: $0 )! }
        let prefetcher = ImagePrefetcher(urls: urls)
        prefetcher.start()
        if let _ = self.imageMessages[senderId] {
            self.imageMessages[senderId]?.append(message)
            // sort by date
            self.imageMessages[senderId] = self.imageMessages[senderId]?.sorted(by: { (msg1, msg2) -> Bool in
                return msg1.createdTime > msg2.createdTime
            })
        } else {
            self.imageMessages[senderId] = [message]
        }
    }
    
    fileprivate func removeMessage(doc: DocumentSnapshot) {
        print("************************debugging", "removing")
        guard let senderId = doc.data()[MessageSchema.SENDER_ID] as? String else { return }
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
        print("************************debugging", "removingDone")

        //DispatchQueue.main.async {
            self.tableView?.reloadData()
        //}
    }
    
    fileprivate func modifyMessage(doc: DocumentSnapshot) {
        guard let senderId = doc.data()[MessageSchema.SENDER_ID] as? String else { return }
        let messageIdToModify = doc.documentID
        guard let messages = self.imageMessages[senderId] else { return }
        guard let index = messages.index(where: { (message) -> Bool in
            return message.messageId == messageIdToModify
        }) else { return }
        self.imageMessages[senderId]?[index] = Message(dict: doc.data(), messageId: messageIdToModify)
        self.sortUserIdsByMessageCreatedTime()
        //DispatchQueue.main.async {
            self.tableView?.reloadData()
        //}
    }
    
    func getUser(uid senderId: String) {
        Database.getUser(uid: senderId) { (user, error) in
            if let error = error {
                AppHUD.error(error.localizedDescription, isDarkTheme: true)
                return
            } else if let user = user {
                self.usersDict[senderId] = user
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                }
            }
        }
    }
}
