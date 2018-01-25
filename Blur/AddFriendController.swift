//
//  AddFriendController.swift
//  Blur
//
//  Created by xiandong wang on 10/14/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit
import Firebase

class AddFriendController: UITableViewController, UISearchResultsUpdating {
    private let cellId = "addFriendCellId"
    
    var existingFriendIds = [String]()
    var searchController: UISearchController!
    var users = [User]()
    var hasSearched = false
    var ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = UIColor.black
        navigationItem.title = "Search"
        tableView?.register(UserSearchCell.self, forCellReuseIdentifier: cellId)
        setupSearchController()
        tableView.keyboardDismissMode = .none
        tableView.separatorStyle = .none
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(navback))
        swipe.direction = .right
        view.addGestureRecognizer(swipe)
    }

    @objc func navback() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        let searchBar = searchController.searchBar
        searchBar.sizeToFit()
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        searchBar.placeholder = "Enter username"
        searchBar.delegate = self
        definesPresentationContext = true
        
        searchBar.isTranslucent = true
        searchBar.barTintColor = YELLOW_COLOR
        searchBar.layer.borderColor = YELLOW_COLOR.cgColor
        tableView.tableHeaderView = searchBar
        //searchBar.becomeFirstResponder()
        //navigationItem.titleView = searchController.searchBar
        
        
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        /*
         `updateSearchResultsForSearchController(_:)` is called when the controller is
         being dismissed to allow those who are using the controller they are search
         as the results controller a chance to reset their state. No need to update
         anything if we're being dismissed.
         */
        guard searchController.isActive else { return }
    }
    
    func handleCancel() {
        navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        if (existingFriendIds.contains(user.uid)) {
            let userController = UserProfileController()
            userController.user = user
            navigationController?.pushViewController(userController, animated: true)
            return
        }
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let sendAction = UIAlertAction(title: "Send Friend Request", style: .default) { (action) in
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            AppHUD.progress(nil, isDarkTheme: true)
            let receiverValues = [currentUid : ["status": FriendStatus.pending.rawValue, "createdTime":                 Date().timeIntervalSince1970]]
            self.ref.child(RECEIVER_FRIEND_REQUESTS_NODE).child(user.uid).updateChildValues(receiverValues, withCompletionBlock: { (err : Error?, _) in
                AppHUD.progressHidden()
                if let err = err {
                    AppHUD.error(err.localizedDescription, isDarkTheme: true)
                    return
                }
                AppHUD.success("Request Sent", isDarkTheme: true)
                let senderValues = [user.uid: ["status" : FriendStatus.pending.rawValue, "createdTime": Date().timeIntervalSince1970]]
                self.ref.child(SENDER_FRIEND_REQUESTS_NODE).child(currentUid).updateChildValues(senderValues)
                self.navigationController?.popToRootViewController(animated: true)
                return
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(sendAction)
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hasSearched {
            if users.count > 0 {
                tableView.backgroundView = nil
                return users.count
            } else {
                TableViewHelper.emptyMessage(message: "No users found", viewController: self)
                return 0
            }
        } else {
            TableViewHelper.emptyMessage(message: "", viewController: self)
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! UserSearchCell
        cell.selectionStyle = .none
        cell.user = users[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
}

extension AddFriendController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let term = searchController.searchBar.text?.trimmingCharacters(in: .whitespaces), term != "" {
            AppHUD.progress(nil, isDarkTheme: true)
            Database.database().reference().child(USERS_NODE).queryOrdered(byChild: "username").queryEqual(toValue: term).observeSingleEvent(of: .value, with: { (snap) in
                self.hasSearched = true
                AppHUD.progressHidden()
                self.users = []
                if snap.exists() {
                    for c in snap.children {
                        let child = c as? DataSnapshot
                        guard let userDict = child?.value as? [String: Any] else { return }
                        guard let uid = child?.key else { return }
                        let user = User(dictionary: userDict, uid: uid)
                        self.users.append(user)
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
}

class UserSearchCell: UITableViewCell {
    
    var user: User? {
        didSet {
            usernameLabel.text = user?.username
            
            guard let profileImageUrl = user?.profileImgUrl else { return }
            
            profileImageView.kf.setImage(with: URL(string: profileImageUrl))
        }
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .lightGray
        iv.layer.cornerRadius = 25
        iv.clipsToBounds = true
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(usernameLabel)
        
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        usernameLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
