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
    
    init(newRequestUids : [String]) {
        super.init(nibName: nil, bundle: nil)
        self.newRequestUids = newRequestUids
        self.newRequestUids.forEach { (str) in
            print(str)
        }
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
        
        getUsers()
    }
    
    func getUsers() {
        for uid in newRequestUids {
            Database.database().reference().child(USERS_NODE).child(uid).observeSingleEvent(of: .value, with: { (snap: DataSnapshot) in
                guard let dict = snap.value as? [String: Any] else { return }
                let user = User(dictionary: dict, uid: snap.key)
                self.newUsers.append(user)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
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
    
    func handleAcceptRequest(sender: UIButton) {
        print(sender.tag)
        let user = newUsers[sender.tag]
        addFriends(for: user, fromRow: sender.tag)
    }
    
    func addFriends(for user: User, fromRow row: Int) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let time = Date().timeIntervalSince1970
        let friendValue = ["status": FriendStatus.Added.rawValue, "updatedTime": time] as [String : Any]
        let childUpdates = ["/\(FRIENDS_NODE)/\(user.uid)/\(currentUid)": friendValue,
                            "/\(FRIENDS_NODE)/\(currentUid)/\(user.uid)": friendValue,
                            "/\(RECEIVER_FRIEND_REQUESTS_NODE)/\(currentUid)/\(user.uid)": ["status": FriendStatus.Added.rawValue, "updatedTime": time],
                            "/\(SENDER_FRIEND_REQUESTS_NODE)/\(user.uid)/\(currentUid)": ["status": FriendStatus.Added.rawValue, "updatedTime": time],] as [String : Any]
        Database.database().reference().updateChildValues(childUpdates) { (err, ref) in
            if let err =  err {
                AppHUD.error(err.localizedDescription)
                return
            }
            AppHUD.success("Friend Added")
            self.newUsers.remove(at: row)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newUsers.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
}