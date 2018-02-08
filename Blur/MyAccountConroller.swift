//
//  MyAccountConroller.swift
//  Blur
//
//  Created by xiandong wang on 12/30/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit
import Firebase

class MyAccountController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let headerId = "myAccountHeaderId"
    private let cellId = "myAccountCellId"
    var user: User?
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        collectionView?.register(MyAccountHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.register(MyAccountImageCell.self, forCellWithReuseIdentifier: cellId)
        navigationItem.title = "My Account"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        setupLogoutButton()
        getCurrentUser()
        getRecentMessages()
        UIFont.familyNames.map {UIFont.fontNames(forFamilyName: $0)}
            .forEach {(n:[String]) in n.forEach {print($0)}}
        NotificationCenter.default.addObserver(self, selector: #selector(addNewMessage), name: NEW_MESSAGE_CREATED, object: nil)
    }
    
    fileprivate func setupLogoutButton() {
        let logoutImg = UIImage.fontAwesomeIcon(name: .signOut, textColor: .black, size: CGSize(width: 30, height: 44))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: logoutImg, style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -8)
    }
    
    @objc func handleLogout() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do {
                CurrentUser.user = nil
                try Auth.auth().signOut()
                let navController = UINavigationController(rootViewController: LoginController())
                self.present(navController, animated: true, completion: nil)
            } catch let signOutError {
                AppHUD.error(signOutError.localizedDescription, isDarkTheme: true)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func addNewMessage(notification: NSNotification) {
        print("hey notifications work")
        guard let message = notification.userInfo?["message"] as? Message else { return }
        self.messages.insert(message, at: 0)
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else { return }

        messages = messages.filter { (message) -> Bool in
            return message.createdTime >= yesterday
        }
        collectionView?.reloadData()
        
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! MyAccountHeader
        header.user = user
        header.editProfileImageButton.addTarget(self, action: #selector(handleChangeProfileImage), for: .touchUpInside)
        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 160)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = messages.count
        if count == 0 {
            let label = UILabel()
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.textColor = TEXT_GRAY
            label.text = "No images sent yet"
            label.textAlignment = .center
            collectionView.backgroundView = label
            label.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor, constant: -80).isActive = true
            return 0
        } else {
            collectionView.backgroundView = nil
            return count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MyAccountImageCell
        cell.message = messages[indexPath.item]
        cell.backgroundColor = .white
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let message = messages[indexPath.item]
        let senderMessageController = SenderImageMessageController()
        senderMessageController.message = message
        senderMessageController.hidesBottomBarWhenPushed = true
        configureTransparentNav()
        
        navigationController?.pushViewController(senderMessageController, animated: true)
    }
    
    fileprivate func configureTransparentNav() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear

        navigationItem.backBarButtonItem?.tintColor = YELLOW_COLOR
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: YELLOW_COLOR]
    }
    
    fileprivate func getCurrentUser() {
        CurrentUser.getUser { (user, error) in
            if let user = user {
                self.user = user
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            } else if let error = error {
                print(error)
                AppHUD.error("Error retrieving user",  isDarkTheme: true)
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getRecentMessages() {
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else { return }
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("imageMessages").whereField(MessageSchema.SENDER_ID, isEqualTo: currentUserId).whereField(MessageSchema.CREATED_TIME, isGreaterThan: yesterday).getDocuments { (messagesSnap, error) in
            if let error = error {
                print(error.localizedDescription)
                AppHUD.error(error.localizedDescription,  isDarkTheme: true)
                return
            }
            guard let messageDocs = messagesSnap?.documents else { return }
            for doc in messageDocs {
                let message = Message(dict: doc.data(), messageId: doc.documentID)
                self.messages.insert(message, at: 0)
                self.collectionView?.reloadData()
            }
        }
    }
    
    @objc func handleChangeProfileImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        present(imagePicker, animated: true, completion: nil)
    }
    
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
        guard let data = UIImageJPEGRepresentation(image, 0.3) else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        Storage.storage().reference().child(PROFILE_IMAGES_NODE).child(uid).putData(data, metadata: metaData, completion: { (metaData, error) in
            if let error = error {
                AppHUD.error(error.localizedDescription + "\nPlease try again.",  isDarkTheme: false)
                return
            }
            
            guard let profileImgUrl = metaData?.downloadURL()?.absoluteString else { return }
            Database.database().reference().child(USERS_NODE).child(uid).updateChildValues(["profileImgUrl": profileImgUrl], withCompletionBlock: { (error, ref) in
                if let error = error {
                    AppHUD.error(error.localizedDescription + "\nPlease try again.",  isDarkTheme: false)
                    return
                }
                DispatchQueue.main.async {
                    self.user?.profileImgUrl = profileImgUrl
                    self.collectionView?.reloadData()
                }
            })
        })
    }
}
