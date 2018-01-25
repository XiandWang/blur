//
//  NewFriendsRequestController.swift
//  Blur
//
//  Created by xiandong wang on 10/20/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit
import Firebase

class NewFriendsRequestController: UITableViewController {
    private let cellId = "newFriendsRequestCellId"
    var newRequestUids = [String]()
    var newUsers = [User]()
    
    let dbRef = Database.database().reference()
    
    init(newRequestUids : [String]) {
        super.init(nibName: nil, bundle: nil)
        self.newRequestUids = newRequestUids
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "New Requests"
        tableView.register(NewRequestUserCell.self, forCellReuseIdentifier: cellId)
        //tableView.separatorStyle = .none
        tableView.allowsSelection = false
        
        getNewFriends()
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(navBack))
        swipe.direction = .right
        view.addGestureRecognizer(swipe)
    }
    
    @objc func navBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func getNewFriends() {
        for uid in newRequestUids {
            Database.getUser(uid: uid, completion: { (user, error) in
                if let user = user {
                    self.newUsers.append(user)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! NewRequestUserCell
        cell.user = newUsers[indexPath.row]
        cell.acceptButton.tag = indexPath.row
        cell.acceptButton.addTarget(self, action: #selector(handleAcceptRequest), for: .touchUpInside)
        return cell
    }
    
    @objc func handleAcceptRequest(sender: UIButton) {
        let user = newUsers[sender.tag]
        addFriend(for: user, fromRow: sender.tag)
    }
    
    func addFriend(for user: User, fromRow row: Int) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        AppHUD.progress(nil, isDarkTheme: true)
        let time = Date().timeIntervalSince1970
        let friendValue = ["status": FriendStatus.added.rawValue, "updatedTime": time] as [String : Any]
        let childUpdates = ["/\(FRIENDS_NODE)/\(user.uid)/\(currentUid)": friendValue,
                            "/\(FRIENDS_NODE)/\(currentUid)/\(user.uid)": friendValue,
                            "/\(RECEIVER_FRIEND_REQUESTS_NODE)/\(currentUid)/\(user.uid)": ["status": FriendStatus.added.rawValue, "updatedTime": time],
                            "/\(SENDER_FRIEND_REQUESTS_NODE)/\(user.uid)/\(currentUid)": ["status": FriendStatus.added.rawValue, "updatedTime": time],] as [String : Any]
        dbRef.updateChildValues(childUpdates) { (err, ref) in
            AppHUD.progressHidden()
            if let err =  err {
                AppHUD.error(err.localizedDescription,  isDarkTheme: true)
                return
            }
            AppHUD.success("Friend Added", isDarkTheme: true)
            self.newUsers.remove(at: row)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if newUsers.count == 0 {
            TableViewHelper.emptyMessage(message: "You have no new requests.", viewController: self)
            return 0
        } else {
            tableView.backgroundView = nil
            tableView.backgroundColor = .white
            return newUsers.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let user = newUsers[indexPath.row]
        let time = Date().timeIntervalSince1970
        let deleteUpdates = ["/\(RECEIVER_FRIEND_REQUESTS_NODE)/\(currentUid)/\(user.uid)":
                                    ["status": FriendStatus.deleted.rawValue, "updatedTime": time],
                             "/\(SENDER_FRIEND_REQUESTS_NODE)/\(user.uid)/\(currentUid)":
                                    ["status": FriendStatus.deleted.rawValue, "updatedTime": time]
                            ] as [String: Any]
        dbRef.updateChildValues(deleteUpdates) { (error, _) in
            if let error = error {
                AppHUD.error(error.localizedDescription, isDarkTheme: true)
                return
            }
            self.newUsers.remove(at: indexPath.row)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
