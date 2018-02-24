//
//  MyAccountConroller.swift
//  Blur
//
//  Created by xiandong wang on 12/30/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit
import Firebase

class MyAccountController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
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
        navigationItem.title = "Me"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        setupLogoutButton()
        getCurrentUser()
        getRecentMessages()
        
        NotificationCenter.default.addObserver(self, selector: #selector(addNewMessage), name: NEW_MESSAGE_CREATED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeFullName), name: USER_CHANGED, object: nil)
    }
    
    fileprivate func setupLogoutButton() {
        let settings = UIImage.fontAwesomeIcon(name: .cog, textColor: .black, size: CGSize(width: 30, height: 44))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: settings, style: .plain, target: self, action: #selector(handleShowSettings))
        navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -8)
    }
    
    @objc func handleShowSettings() {
        guard let user = self.user else { return }
        self.navigationController?.pushViewController( SettingsController(user: user), animated: true)
    }
    
    @objc func changeFullName(notification: NSNotification) {
        guard let user = notification.userInfo?["user"] as? User else { return }
        self.user = user
        self.collectionView?.reloadData()
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
        
        header.userProfileImageView.heroID = "imageViewHeroId"
        header.userProfileImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleShowImage))
        header.userProfileImageView.addGestureRecognizer(tap)
        
        return header
    }
    
    @objc func handleShowImage() {
        print("************************debugging")
        let imageController = SimpleImageController()
        guard let profileImg = self.user?.profileImgUrl else { return }
        self.present(imageController, animated: true) {
            imageController.imageView.kf.setImage(with: URL(string: profileImg))
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 144)
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
            label.font = UIFont(name: APP_FONT_BOLD, size: 20)
            label.textColor = TEXT_GRAY
            label.text = "No images sent yet~"
            label.textAlignment = .center
            collectionView.backgroundView = label
            label.center = collectionView.center
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
}
