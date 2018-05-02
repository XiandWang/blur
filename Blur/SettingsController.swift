//
//  SettingsController.swift
//  Blur
//
//  Created by xiandong wang on 2/20/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import UIKit
import Static
import Firebase
import FBSDKLoginKit

class SettingsController: TableViewController {

    let userImageView: UIImageView = {
        let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        iv.backgroundColor = BACKGROUND_GRAY
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 22
        iv.layer.masksToBounds = true
        return iv
    }()
    
    var user: User?

    convenience init(user: User) {
        self.init(style: .grouped)
        self.user = user
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Settings"
        tableView.rowHeight = 54
        tableView.estimatedSectionHeaderHeight = 13.5
        tableView.estimatedSectionFooterHeight = 13.5
        guard let user = user else { return }
        self.dataSource = DataSource(tableViewDelegate: self)
        dataSource.sections = [
            Section(header: "User Info", rows: [
                Row(text: "Profile Photo", selection: { [unowned self] in
                    self.updateProfileImage()
                    }, accessory: .view(self.userImageView)),
                Row(text: "Username", detailText: "@" + user.username,
                    cellClass: Value1Cell.self),
                Row(text: "Full Name", detailText: user.fullName, selection: { [unowned self] in
                    let editFullnameController = EditFullNameController()
                    editFullnameController.user = self.user
                    self.navigationController?.pushViewController(editFullnameController, animated: true)
                    }, accessory: .disclosureIndicator, cellClass: Value1Cell.self),
                Row(text: "My Compliments", selection: { [unowned self] in
                        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                        self.navigationController?.pushViewController(ComplimentsController(), animated: true)
                    }, accessory: .disclosureIndicator)
                ],  footer: nil),
            Section(header: "Privacy", rows:[
                Row(text: "Blocked", selection: { [unowned self] in
                    self.navigationController?.pushViewController(BlockedController(), animated: true)
                }, accessory:.disclosureIndicator)
            ], footer: nil),
            Section(header: "Contact", rows:[
                Row(text: "Contact", selection: { [unowned self] in
                    self.navigationController?.pushViewController(AppContactController(), animated: true)
                    }, accessory:.disclosureIndicator)
                ], footer: nil)
        ]
        if let url = user.profileImgUrl {
            userImageView.kf.setImage(with: URL(string: url))
        }
        
        setupNavigationItem()
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(navback))
        swipe.direction = .right
        view.addGestureRecognizer(swipe)
    }
    
    @objc func navback() {
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setupNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    }
    
    func updateProfileImage() {
        let alert = UIAlertController(title: "Update Profile Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (_) in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
            self.present(imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func handleLogout() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do {
                CurrentUser.user = nil
                self.stopListeners()
                FBSDKLoginManager().logOut()
                try Auth.auth().signOut()
                let navController = UINavigationController(rootViewController: ChooseLoginSignupController())
                self.present(navController, animated: true, completion: nil)
            } catch let signOutError {
                AppHUD.error("Signout error: " + signOutError.localizedDescription, isDarkTheme: true)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

extension UIViewController {
    func stopListeners() {
        guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else {
            return
        }
        
        guard let controllers = mainTabBarController.viewControllers else { return }
        guard let homeNavController = controllers[0] as? UINavigationController else { return }
        guard let homeController = homeNavController.viewControllers[0] as? HomeController else { return }
        guard let notiNavController = controllers[2] as? UINavigationController else { return }
        guard let notiController = notiNavController.viewControllers[0] as? NotificationController else { return }
        
        notiController.notificationsListener?.remove()
        homeController.messageListener?.remove()
        
        guard let friendsNavController = controllers[1] as? UINavigationController else { return }
        guard let friendsController = friendsNavController.viewControllers[0] as? FriendsController else { return }
        friendsController.friendRequestsRef?.removeAllObservers()
        friendsController.friendsRef?.removeAllObservers()
    }

}



extension TableViewController: UITableViewDelegate {
    // MARK: - UITableViewDelegate example functions
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // You can get UITableViewDelegate celfunctions forwarded, even though the `DataSource` instance is the true delegate
        // ..
        cell.textLabel?.font = UIFont(name: APP_FONT, size: 16)
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.font = TEXT_FONT
    }
}

extension SettingsController: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage
        let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
        if let image = editedImage {
            uploadProfileImage(image: image)
        } else if let image = originalImage {
            uploadProfileImage(image: image)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func uploadProfileImage(image: UIImage) {
        guard let data = UIImageJPEGRepresentation(image, 0.5) else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        AppHUD.progress(nil, isDarkTheme: true)
        Storage.storage().reference().child(PROFILE_IMAGES_NODE).child(uid).putData(data, metadata: metaData, completion: { (metaData, error) in
            if let error = error {
                AppHUD.progressHidden()
                AppHUD.error(error.localizedDescription + "\nPlease try again.",  isDarkTheme: false)
                return
            }
            
            guard let profileImgUrl = metaData?.downloadURL()?.absoluteString else { return }
            let update = ["/\(USERS_NODE)/\(uid)/profileImgUrl": profileImgUrl]
            Database.database().reference().updateChildValues(update, withCompletionBlock: { (error, ref) in
                if let error = error {
                    AppHUD.progressHidden()
                    AppHUD.error(error.localizedDescription + "\nPlease try again.",  isDarkTheme: false)
                    return
                }
                AppHUD.progressHidden()
                AppHUD.success("Changed", isDarkTheme: true)
                if var user = self.user {
                    user.profileImgUrl = profileImgUrl
                    NotificationCenter.default.post(name: USER_CHANGED, object: nil, userInfo: ["user": user])
                }
                self.navigationController?.popToRootViewController(animated: true)
            })
        })
    }
}

