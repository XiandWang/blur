//
//  ContactsController.swift
//  Blur
//
//  Created by xiandong wang on 9/7/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import Foundation

class FriendsController: UITableViewController {
    private let cellId = "userContactCellId"
    let ref = Database.database().reference()
    
    var newRequestUids = [String]()
    var users : [User] = []
    var titleUserDict = [String: [User]]()
    var userTitles : [String] = []
    var isIntialLoading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Contacts"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddFriends))
        view?.backgroundColor = .white
        tableView.register(UserContactCell.self, forCellReuseIdentifier: cellId)
        tableView.sectionIndexColor = PRIMARY_COLOR
        observeFriends()
        observeFriendRequests()
    }
    
    func setupHeaderView() {
        let rect = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        let cell = NewContactHeader(frame: rect)
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleFriendsRequests)))

        tableView.tableHeaderView = cell
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return userTitles
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isIntialLoading {
            TableViewHelper.loadingView(viewController: self)
            return 0
        } else {
            if userTitles.count > 0 {
                tableView.backgroundView = nil
                return userTitles.count
            } else {
                TableViewHelper.emptyMessage(message: "You have no contacts yet.", viewController: self)
                return 0
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitle = userTitles[section]
        guard let users = titleUserDict[sectionTitle] else { return 0 }
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return userTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserContactCell
        let user = getUser(from: indexPath)
        cell.user = user

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = getUser(from: indexPath)
        let controller = UserProfileController()
        controller.user = user
        navigationController?.pushViewController(controller, animated: true)
    }
    
    fileprivate func getUser(from indexPath: IndexPath) -> User {
        let title = userTitles[indexPath.section]
        let users = titleUserDict[title]!
        let user = users[indexPath.row]
    
        return user
    }
}

// Database
extension FriendsController {
    fileprivate func observeFriends() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        self.ref.child(FRIENDS_NODE).child(currentUid).observe(.childAdded, with: { (snap) in
            let uid = snap.key
            self.ref.child(USERS_NODE).child(uid).observeSingleEvent(of: .value, with: { (usersnap) in
                guard let userDict = usersnap.value as? [String: Any] else { return }
                let user = User(dictionary: userDict, uid: uid)
                self.users.append(user)
                
                guard let letterChar = user.username.first else { return }
                let letter = "\(letterChar)".uppercased()
                if let _ = self.titleUserDict[letter] {
                    self.titleUserDict[letter]?.append(user)
                } else {
                    self.titleUserDict[letter] = [user]
                }
                
                self.userTitles = self.titleUserDict.keys.sorted()
                self.isIntialLoading = false
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    fileprivate func observeFriendRequests() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        self.ref.child(RECEIVER_FRIEND_REQUESTS_NODE)
            .child(currentUid).queryOrdered(byChild: "status").queryEqual(toValue: FriendStatus.PENDING.rawValue).observe(.value) { (snap : DataSnapshot) in
            self.newRequestUids = []
            for c in snap.children {
                guard let child = c as? DataSnapshot else { return }
                self.newRequestUids.append(child.key)
            }
            DispatchQueue.main.async {
                self.setupHeaderView()
                let cell = self.tableView.tableHeaderView as? NewContactHeader
                if snap.childrenCount > 0 {
                    cell?.newFriendsNum = "\(snap.childrenCount)"
                }
            }
        }
    }
}

// Gestures
extension FriendsController {
    @objc func handleFriendsRequests() {
        let newFriendsRequestController = NewFriendsRequestController(newRequestUids : self.newRequestUids)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.pushViewController(newFriendsRequestController, animated: true)
    }
    
    @objc func handleAddFriends() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        let addFriendController = AddFriendController()
        addFriendController.existingFriendIds = self.users.map({ (user) -> String in
            return user.uid
        })
        self.navigationController?.pushViewController(addFriendController, animated: true)
    }
}
