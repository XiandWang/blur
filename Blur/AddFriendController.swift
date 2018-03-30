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
        tableView?.register(SimpleUserCell.self, forCellReuseIdentifier: cellId)
        setupSearchController()
        tableView.keyboardDismissMode = .none
        tableView.separatorStyle = .none
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(navback))
        swipe.direction = .right
        view.addGestureRecognizer(swipe)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }

    @objc func navback() {
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setupSearchController() {
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
        
        if let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField {
            textFieldInsideSearchBar.font = TEXT_FONT
        }
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
            self.ref.child(RECEIVER_FRIEND_REQUESTS_NODE).child(user.uid).updateChildValues(receiverValues, withCompletionBlock: { (err, _) in
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
            tableView.backgroundView = nil
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! SimpleUserCell
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
            Database.database().reference().child(USERS_NODE).queryOrdered(byChild: "usernameLowercased").queryEqual(toValue: term.lowercased()).observeSingleEvent(of: .value, with: { (snap) in
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
                }
                
                Database.database().reference().child(USERS_NODE).queryOrdered(byChild: "username").queryEqual(toValue: term).observeSingleEvent(of: .value, with: { (usernap) in
                    AppHUD.progressHidden()
                    if usernap.exists() {
                        for c in usernap.children {
                            let child = c as? DataSnapshot
                            guard let userDict = child?.value as? [String: Any] else { return }
                            guard let uid = child?.key else { return }
                            let user = User(dictionary: userDict, uid: uid)
                            self.users.append(user)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
                    
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }, withCancel: { (error) in
                self.hasSearched = true
                AppHUD.progressHidden()
                AppHUD.error("Error finding users. Please try again.", isDarkTheme: true)
            })
        }
    }
}

class SimpleUserCell: UITableViewCell {
    
    var user: User? {
        didSet {
            if let user = user {
                usernameLabel.text = "@" + user.username
                fullNameLabel.text = user.fullName
                if let profileImageUrl = user.profileImgUrl {
                    profileImageView.kf.setImage(with: URL(string: profileImageUrl))
                } else {
                    profileImageView.kf.setImage(with: nil)
                }
            } else {
                usernameLabel.text = ""
                fullNameLabel.text = ""
                profileImageView.kf.setImage(with: nil)
            }
            
        }
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = BACKGROUND_GRAY
        iv.layer.cornerRadius = 25
        iv.clipsToBounds = true
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: APP_FONT_BOLD, size: 16)
        label.textColor = .lightGray
        return label
    }()
    
    let fullNameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = BOLD_FONT
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(fullNameLabel)

        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        fullNameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: -10).isActive = true
        fullNameLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        usernameLabel.anchor(top: fullNameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: contentView.rightAnchor, paddingTop: 2, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        
//        usernameLabel.backgroundColor = .red
//        fullNameLabel.backgroundColor = .purple
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
