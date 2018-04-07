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
    private let cellId = "userFriendCellId"
    let ref = Database.database().reference()
    
    var friendRequestsRef: DatabaseQuery?
    var friendsRef: DatabaseQuery?

    var newRequestUids = [User]()
    var users = [User]()
    var titleUserDict = [String: [User]]()
    var userTitles = [String]()
    var isIntialLoading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Friends"
        setupNavTitleAttr()
        view?.backgroundColor = .white
        tableView.register(UserFriendCell.self, forCellReuseIdentifier: cellId)
        tableView.sectionIndexColor = TEXT_GRAY
        observeFriends()
        observeFriendRequests()

        setupBarItems()
    }
    
    
    func setupBarItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Invite", style: .plain, target: self, action: #selector(handleInvite))
        
        let userPlus = UIImage.fontAwesomeIcon(name: .userPlus, textColor: .black, size: CGSize(width: 30, height: 44))
        let barItem = UIBarButtonItem(image: userPlus, style: .plain, target: self, action: #selector(handleAddFriends))
        if #available(iOS 11.0, *) {
            navigationItem.rightBarButtonItem = barItem
            navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -8)
        } else {
            navigationItem.rightBarButtonItems = [UIBarButtonItem.fixNavigationSpacer(),  barItem]
        }
    }
    
    @objc func handleInvite() {
        let contacts = ContactsController(style: .plain)
        self.navigationController?.pushViewController(contacts, animated: true)  
    }
    
    func setupHeaderView() {
        let rect = CGRect(x: 0, y: 0, width: view.frame.width, height: 66)
        let cell = NewFriendsHeader(frame: rect)
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
            } else {
                TableViewHelper.emptyMessage(message: "You have no contacts yet.", viewController: self)
            }
            return userTitles.count
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserFriendCell
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
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.tintColor = BACKGROUND_GRAY
            headerView.textLabel?.font = SMALL_TEXT_FONT
            headerView.textLabel?.textColor = TEXT_GRAY
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let blockAction  = UITableViewRowAction(style: .destructive, title: "Block") { (action, indexPath) in
            let user = self.getUser(from: indexPath)
            guard let curUid = Auth.auth().currentUser?.uid else { return }
            if curUid == user.uid {
                AppHUD.error("You can't block your self...", isDarkTheme: true)
                return
            }
            let alert = UIAlertController(title: "Confirm Block?", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Block", style: .default, handler: { (_) in
                let updates = ["/\(FRIENDS_NODE)/\(curUid)/\(user.uid)/status": FriendStatus.blocked.rawValue,
                               "/\(FRIENDS_NODE)/\(user.uid)/\(curUid)/status": FriendStatus.blocked.rawValue]
                Database.database().reference().updateChildValues(updates) { (error, ref) in
                    if let error = error {
                        AppHUD.error(error.localizedDescription, isDarkTheme: false)
                        return
                    }
                    AppHUD.success("Blocked", isDarkTheme: true)
                    self.removeUser(for: indexPath)
                    self.tableView.reloadData()
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        return [blockAction]
    }
    
    fileprivate func getUser(from indexPath: IndexPath) -> User {
        let title = userTitles[indexPath.section]
        let users = titleUserDict[title]!
        let user = users[indexPath.row]

        return user
    }
    
    fileprivate func removeUser(for indexPath: IndexPath) {
        let title = userTitles[indexPath.section]

        titleUserDict[title]?.remove(at: indexPath.row)
        if titleUserDict[title]?.count == 0 {
            titleUserDict.removeValue(forKey: title)
        }
        self.userTitles = self.titleUserDict.keys.sorted()
    }
}

// Database
extension FriendsController {
    fileprivate func observeFriends() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        friendsRef = self.ref.child(FRIENDS_NODE).child(currentUid).queryOrdered(byChild: "status").queryEqual(toValue: FriendStatus.added.rawValue)
        friendsRef?.observe(.childAdded, with: { (snap) in
            let uid = snap.key
            self.ref.child(USERS_NODE).child(uid).observeSingleEvent(of: .value, with: { (usersnap) in
                guard let userDict = usersnap.value as? [String: Any] else { return }
                let user = User(dictionary: userDict, uid: uid)
                self.users.append(user)
                
                guard let letterChar = user.fullName.first else { return }
                let letter = "\(letterChar)".uppercased()
                
                if let _ = self.titleUserDict[letter] {
                    self.titleUserDict[letter]?.append(user)
                } else {
                    self.titleUserDict[letter] = [user]
                }
                
                self.userTitles = self.titleUserDict.keys.sorted()
                self.isIntialLoading = false
                self.tableView.reloadData()
            
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    fileprivate func observeFriendRequests() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        self.friendRequestsRef = self.ref.child(RECEIVER_FRIEND_REQUESTS_NODE)
            .child(currentUid).queryOrdered(byChild: "status").queryEqual(toValue: FriendStatus.pending.rawValue)
        self.friendRequestsRef?.observe(.value) { (snap : DataSnapshot) in
            self.newRequestUids = []
            for c in snap.children {
                guard let child = c as? DataSnapshot else { return }
                Database.getUser(uid: child.key, completion: { (user, error) in
                    if let user = user {
                        self.newRequestUids.append(user)
                    }
                })
            }
            
            DispatchQueue.main.async {
                self.setupHeaderView()
                let cell = self.tableView.tableHeaderView as? NewFriendsHeader
                if snap.childrenCount > 0 {
                    cell?.newFriendsNum = "\(snap.childrenCount)"
                    if let app = UIApplication.shared.delegate as? AppDelegate {
                        app.setBadge(tabBarIndex: 1, num: Int(snap.childrenCount))
                    }
                } else {
                    if let app = UIApplication.shared.delegate as? AppDelegate {
                        app.setBadge(tabBarIndex: 1, num: 0)
                    }
                }
            }
        }
    }
}

// Gestures
extension FriendsController {
    @objc func handleFriendsRequests() {
        let newFriendsRequestController = NewFriendsRequestController(newRequestUsers: self.newRequestUids)
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
