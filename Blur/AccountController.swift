//
//  UserProfileController.swift
//  Blur
//
//  Created by xiandong wang on 7/10/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class AccountController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var user : User? {
        didSet {
            guard let name = user?.username else { return }
            userNameLabel.text = "@" + name
            guard let userProfileImgUrl = user?.profileImgUrl, userProfileImgUrl != "" else {
                return
            }
            
            userProfileImageView.kf.setImage(with: URL(string: userProfileImgUrl))
        }
    }
    
    let userNameLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 0
        label.text = ""
        return label
    }()
    
    let userProfileImageView : UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .lightGray
        iv.layer.cornerRadius = 50
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
    
    let changeImageButton : UIButton = {
        let bt = UIButton(type: .system)
        bt.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        bt.setTitle("Change profile image", for: .normal)
        bt.layer.shadowOpacity = 0.7
        bt.layer.shadowRadius = 10.0
        bt.addTarget(self, action: #selector(handleChangeProfileImage), for: .touchUpInside)
        return bt
    }()
    
    func handleChangeProfileImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage
        let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
        if let image = editedImage {
           uploadProfileImage(image: image)
           userProfileImageView.image = image
        } else if let image = originalImage {
           uploadProfileImage(image: image)
           userProfileImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func uploadProfileImage(image: UIImage) {
        guard let data = UIImageJPEGRepresentation(image, 0.3) else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        Storage.storage().reference().child(PROFILE_IMAGES_NODE).child(uid).putData(data, metadata: metaData, completion: { (metaData, error) in
            if let error = error {
                AppHUD.error(error.localizedDescription + "\nPlease try again.")
                return
            }
            
            guard let profileImgUrl = metaData?.downloadURL()?.absoluteString else { return }
            Database.database().reference().child(USERS_NODE).child(uid).updateChildValues(["profileImgUrl": profileImgUrl], withCompletionBlock: { (error, ref) in
                if let error = error {
                    AppHUD.error(error.localizedDescription + "\nPlease try again.")
                    return
                }
            })
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Account"
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        view?.backgroundColor = .white
        fetchUser()
        setupViews()
        setupLogoutButton()
    }
    
    fileprivate func setupViews() {
        view.addSubview(userProfileImageView)
        userProfileImageView.translatesAutoresizingMaskIntoConstraints = false
        userProfileImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
        userProfileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        userProfileImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        userProfileImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        view.addSubview(userNameLabel)
        userNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        userNameLabel.anchor(top: userProfileImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(changeImageButton)
        changeImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        changeImageButton.anchor(top: userNameLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
    
    fileprivate func setupLogoutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    func handleLogout() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do {
                try Auth.auth().signOut()
                let navController = UINavigationController(rootViewController: LoginController())
                self.present(navController, animated: true, completion: nil)
            } catch let signOutError {
                AppHUD.error(signOutError.localizedDescription)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else {
            AppHUD.error("Cannot retrieve the current user")
            return
        }
        Database.database().reference().child(USERS_NODE).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userDict = snapshot.value as? [String: Any] else { return }
            let uid = snapshot.key
            self.user = User(dictionary: userDict, uid: uid)
            
        }) { (error) in
            AppHUD.error(error.localizedDescription)
            return
        }
    }
}
