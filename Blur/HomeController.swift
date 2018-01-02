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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.separatorColor = UIColor.lightGray
        tableView.register(HomeChatCell.self, forCellReuseIdentifier: cellId)
        setupNavigationItems()
        listenForMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //
        ImageCache.default.clearMemoryCache()
        // Reload data to refresh timestamps
        tableView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupNavigationItems() {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationItem.title = "Inbox Chats"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageMessages.keys.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! HomeChatCell
        let fromId = userIdsSorted[indexPath.row]
        if let user = self.usersDict[fromId] {
            cell.user = user
        }
        let messages = imageMessages[fromId]
        cell.messages = messages
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fromId = userIdsSorted[indexPath.row]
        if let user = self.usersDict[fromId] {
            print(user.username)
        }
        if let messages = imageMessages[fromId], let user = self.usersDict[fromId] {
            let messagesPageViewController = MessagesPageViewController(messages: messages, fromUser: user)
            messagesPageViewController.hidesBottomBarWhenPushed = true
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            //navigationController?.isNavigationBarHidden = true
            navigationController?.pushViewController(messagesPageViewController, animated: true)
        }
    }
    
    func listenForMessages() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("imageMessages").whereField("toId", isEqualTo: currentUserId)
            .whereField("isDeleted", isEqualTo: false)
            .addSnapshotListener { (messagesSnap, error) in
                messagesSnap?.documentChanges.forEach({ (docChange: DocumentChange) in
                    if docChange.type == .added {
                        print("added not modified...")
                        print(docChange.document.documentID)

                        let fromId = docChange.document.data()["fromId"] as! String
                        self.addMessage(doc: docChange.document)
                        self.sortUserIdsByMessageCreatedTime()
                        if self.usersDict[fromId] == nil {
                            self.getUserData(uid: fromId) // async
                        } else {
                            DispatchQueue.main.async {
                                self.tableView?.reloadData()
                            }
                        }
                    } else if docChange.type == DocumentChangeType.removed {
                        self.removeMessage(doc: docChange.document)
                    } else if docChange.type == DocumentChangeType.modified {
                        print("modified....")
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
        let fromId = doc.data()["fromId"] as! String
        let message = Message(dict: doc.data(), messageId: doc.documentID)
        if let _ = self.imageMessages[fromId] {
            self.imageMessages[fromId]?.append(message)
            // sort by date
            self.imageMessages[fromId] = self.imageMessages[fromId]?.sorted(by: { (msg1, msg2) -> Bool in
                return msg1.createdTime > msg2.createdTime
            })
        } else {
            self.imageMessages[fromId] = [message]
        }
    }
    
    fileprivate func removeMessage(doc: DocumentSnapshot) {
        guard let fromId = doc.data()["fromId"] as? String else { return }
        let messageIdToRemove = doc.documentID
        guard let messages = self.imageMessages[fromId] else { return }
        guard let index = messages.index(where: { (message) -> Bool in
            return message.messageId == messageIdToRemove
        }) else { return }
        self.imageMessages[fromId]?.remove(at: index)
        if let count = self.imageMessages[fromId]?.count, count == 0 {
            self.imageMessages.removeValue(forKey: fromId)
        }
        //print("********************removing done")
        //print(self.imageMessages)
        sortUserIdsByMessageCreatedTime()
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }
    
    fileprivate func modifyMessage(doc: DocumentSnapshot) {
        guard let fromId = doc.data()["fromId"] as? String else { return }
        let messageIdToModify = doc.documentID
        guard let messages = self.imageMessages[fromId] else { return }
        guard let index = messages.index(where: { (message) -> Bool in
            return message.messageId == messageIdToModify
        }) else { return }
        self.imageMessages[fromId]?[index] = Message(dict: doc.data(), messageId: messageIdToModify)
        self.sortUserIdsByMessageCreatedTime()
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }
    
    func getUserData(uid fromId: String) {
        Database.database().reference().child(USERS_NODE).child(fromId).observeSingleEvent(of: .value, with: { (userSnap) in
            if let userDict = userSnap.value as? [String: Any] {
                let user = User(dictionary: userDict, uid: userSnap.key)
                self.usersDict[fromId] = user
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                }
            }
        })
    }
}
