//
//  BlockedController.swift
//  Blur
//
//  Created by xiandong wang on 2/22/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import UIKit
import Firebase

class BlockedController: UITableViewController {
    private let cellId = "blockCellId"
    var blockedFriends = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .singleLine
        tableView.register(SimpleUserCell.self, forCellReuseIdentifier: cellId)
        navigationItem.title = "Blocked"
        getBlockedFriends()
    }
    
    func getBlockedFriends() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child(FRIENDS_NODE).child(currentUid).queryOrdered(byChild: "status").queryEqual(toValue: FriendStatus.blocked.rawValue).observe(.childAdded, with: { (snap) in
            let uid = snap.key
            Database.database().reference().child(USERS_NODE).child(uid).observeSingleEvent(of: .value, with: { (usersnap) in
                guard let userDict = usersnap.value as? [String: Any] else { return }
                let user = User(dictionary: userDict, uid: uid)
                self.blockedFriends.append(user)
                self.tableView.reloadData()
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = blockedFriends.count
        if count == 0 {
            TableViewHelper.emptyMessage(message: "No blocked yet", viewController: self)
        } else {
            tableView.backgroundView = nil
        }
        return count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! SimpleUserCell
        cell.user = blockedFriends[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let curUid = Auth.auth().currentUser?.uid else { return }
        let user = blockedFriends[indexPath.row]
        let alert = UIAlertController(title: "Confirm Unblock?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Unblock", style: .default, handler: { (action) in
            let updates = ["/\(FRIENDS_NODE)/\(curUid)/\(user.uid)/status": FriendStatus.added.rawValue,
                           "/\(FRIENDS_NODE)/\(user.uid)/\(curUid)/status": FriendStatus.added.rawValue]
            Database.database().reference().updateChildValues(updates) { (error, ref) in
                if let error = error {
                    AppHUD.error(error.localizedDescription, isDarkTheme: false)
                    return
                }
                AppHUD.success("Unblocked", isDarkTheme: true)
                self.blockedFriends.remove(at: indexPath.row)
                self.tableView.reloadData()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

