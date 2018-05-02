//
//  UserProfileController.swift
//  Blur
//
//  Created by xiandong wang on 2017/10/2.
//  Copyright © 2017年 xiandong wang. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import Photos
import AVFoundation
import Hero
import AZDialogView
import SCLAlertView


class UserProfileController: UIViewController {
    private let imageWidth: CGFloat = 80.0
    
    var user : User? {
        didSet {
            if let name = user?.username {
                userNameLabel.text = "@\(name)"
            }
            if let userProfileImgUrl = user?.profileImgUrl {
                userProfileImageView.kf.setImage(with: URL(string: userProfileImgUrl))
            }
            if let fullName = user?.fullName {
                fullNameLabel.text = fullName 
            }
            
        }
    }
    
    let userNameLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = ""
        label.textAlignment = .center
        label.font = UIFont(name: APP_FONT_BOLD, size: 18)
        label.textColor = .lightGray
        return label
    }()
    
    let fullNameLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: APP_FONT_BOLD, size: 18)
        label.numberOfLines = 1
        label.text = ""
        label.textAlignment = .center

        return label
    }()
    
    lazy var userProfileImageView : UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = BACKGROUND_GRAY
        iv.layer.cornerRadius = self.imageWidth / 2
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
    
    let sendChatButton: UIButton = {
        let bt = UIButton(type: .system)
        bt.backgroundColor = YELLOW_COLOR
        
        bt.setTitle("Send", for: .normal)
        bt.titleLabel?.font = BOLD_FONT
        bt.setTitleColor(.black, for: .normal)
        
        bt.layer.cornerRadius = 22
        bt.layer.masksToBounds = true
        bt.addTarget(self, action: #selector(handleSendImage), for: .touchUpInside)
        return bt
    }()

    
    let showMoreButton: UIButton = {
        let bt = UIButton(type: .system)
        
        bt.setTitle("Ask for a photo", for: .normal)
        bt.titleLabel?.font = BOLD_FONT
        bt.setTitleColor(TINT_COLOR, for: .normal)
        bt.layer.cornerRadius = 22
        bt.backgroundColor = .white

        bt.addTarget(self, action: #selector(handleShowAdvanced), for: .touchUpInside)
        return bt
    }()
    
    
    let statsTitleLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.text = "Sent to me in 7 days:"
        
        //lb.textColor = UIColor.b
        lb.font = UIFont(name: APP_FONT_BOLD, size: 17)
        return lb
    }()
    
    let likeStatsLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.text = "_ likes"
        lb.textColor = PINK_COLOR
        lb.numberOfLines = 0
        lb.font = UIFont(name: APP_FONT_BOLD, size: 16)

        return lb
    }()
    
    let chatStatsLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.text = "_ chats"
        lb.numberOfLines = 0
        lb.textColor = BLUE_COLOR
        lb.font = UIFont(name: APP_FONT_BOLD, size: 16)

        return lb
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Profile"
        
        configureViews()
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(navback))
        swipe.direction = .right
        view.addGestureRecognizer(swipe)
        setupHeroTransition()
        
        getLikeStats()
        getChatStats()
    }
    
    @objc func handleShowAdvanced() {
        let color = TINT_COLOR
        let dialog = AZDialogViewController(title: "Ask for a photo", message: "Miss your friend? Ask for a photo", titleFontSize: 22, messageFontSize: 16, buttonsHeight: 50, cancelButtonHeight: 50)
        dialog.blurBackground = false
        dialog.buttonStyle = { (button,height,position) in
            button.setTitleColor(color, for: .normal)
            button.titleLabel?.font = TEXT_FONT
            button.layer.masksToBounds = true
            button.layer.borderColor = color.cgColor
            button.layer.borderWidth = 1.0
            button.backgroundColor = .white
        }
        dialog.cancelEnabled = true
        dialog.cancelTitle = "Cancel"
        dialog.cancelButtonStyle = { (button,height) in
            button.setTitleColor(color, for: .normal)
            button.titleLabel?.font = TEXT_FONT
            return true
        }
        dialog.addAction(AZDialogAction(title: "Ask for a photo", handler: { (dialog) -> (Void) in
            let currentInvites = CurrentUser.numInvites
            if currentInvites < 5 {
                dialog.removeAllActions()
                dialog.title = "Invites to unlock"
                let message = "Need a total of 5 invites to unlock. Currently: \(currentInvites)/5"
                dialog.message = message
                dialog.addAction(AZDialogAction(title: "Let's invite", handler: { (dialog) -> (Void) in
                    let contactController = ContactsController()
                    self.navigationController?.pushViewController(contactController, animated: true)
                    dialog.dismiss()
                }))
            } else {
                dialog.removeAllActions()
                dialog.title = "Confirm asking?"
                dialog.message = nil
                dialog.addAction(AZDialogAction(title: "Ask", handler: { (dialog) -> (Void) in
                    self.checkAndAsk()
                    dialog.dismiss()
                }))
            }
        }))
        dialog.show(in: self)
    }
    
    func askForChats() {
        guard let curUid = Auth.auth().currentUser?.uid else { return }
        guard let uid = self.user?.uid else { return }
        CurrentUser.getUser { (user, error) in
            if let sender = user {
                let userData = ["userId": sender.uid, "username": sender.username, "profileImgUrl": sender.profileImgUrl, "fullName": sender.fullName]
                let notifData = ["type": NotificationType.askForChat.rawValue, "user": userData, "isRead": false, "createdTime": Date()] as [String : Any]
                
                let batch = Firestore.firestore().batch()
                batch.setData(["lastAskTime": Date()], forDocument: FIRRef.getActivities().document(curUid).collection("activities").document(uid), options: SetOptions.merge())
                batch.setData(notifData, forDocument: FIRRef.getNotifications().document(uid).collection("messageNotifications").document())
                batch.commit(completion: { (error) in
                    if let error = error {
                        AppHUD.error(error.localizedDescription, isDarkTheme: true)
                        return
                    }
                    AppHUD.success("Sent", isDarkTheme: true)
                })
            }
        }
    }

    func checkAndAsk() {
        guard let curUid = Auth.auth().currentUser?.uid else { return }
        guard let uid = self.user?.uid else { return }
        FIRRef.getActivities().document(curUid).collection("activities").document(uid).getDocument { (snap, error) in
            if let error = error {
                AppHUD.error(error.localizedDescription, isDarkTheme: true)
                return
            }
            if let data = snap?.data(), let time = data["lastAskTime"] as? Date, Date().timeIntervalSince(time) < 60 {
                let img = UIImage.fontAwesomeIcon(name: .warning, textColor: YELLOW_COLOR, size: CGSize(width: 44, height: 44))
                AppHUD.custom("Please wait a minute to ask again.", img: img)
                return
            } else {
                self.askForChats()
            }
        }
    }

    
    @objc func navback() {
        self.navigationController?.popToRootViewController(animated: true)
    }

    @objc func handleSendImage() {
        if checkImagePermission() == .denied || checkCameraPermission() == .denied {
            let dialog = AZDialogViewController(title: "Camera and photo permission", message: "Most people use HidingChat to send photos. Do you want to grant permission?", titleFontSize: 22, messageFontSize: 16, buttonsHeight: 50, cancelButtonHeight: 50)
            dialog.blurBackground = false
            dialog.buttonStyle = { (button,height,position) in
                button.setTitleColor(.white, for: .normal)
                button.titleLabel?.font = TEXT_FONT
                button.layer.masksToBounds = true
                button.layer.borderColor = PURPLE_COLOR.cgColor
                button.backgroundColor = PURPLE_COLOR
            }
            dialog.cancelEnabled = true
            dialog.cancelTitle = "Cancel"
            dialog.cancelButtonStyle = { (button,height) in
                button.setTitleColor(PURPLE_COLOR, for: .normal)
                button.titleLabel?.font = TEXT_FONT
                return true
            }
            dialog.dismissWithOutsideTouch = false
            dialog.addAction(AZDialogAction(title: "Grant permisions", handler: { (dialog) -> (Void) in
                self.openSettings()
                dialog.dismiss()
            }))
            dialog.show(in: self)
        } else {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            
            let actionSheet = UIAlertController(title: "HidingChat photo source", message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "From Camera", style: .default, handler: { (action) in
                picker.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
                picker.sourceType = .camera
                self.present(picker, animated: true, completion: nil)
            }))
            actionSheet.addAction(UIAlertAction(title: "From Photo Library", style: .default, handler: { (action) in
                picker.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true, completion: nil)
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(actionSheet, animated: true, completion: nil)
        }
    }

    fileprivate func checkImagePermission() -> PHAuthorizationStatus  {
        return PHPhotoLibrary.authorizationStatus()
    }
    
    fileprivate func checkCameraPermission() -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    fileprivate func openSettings() {
        guard let url = URL(string: UIApplicationOpenSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, completionHandler: nil)
        }
    }
    
    fileprivate func getLikeStats() {
        guard let user = self.user else { return }
        guard let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        FIRRef.getMessageLikes().whereField("senderId", isEqualTo: user.uid).whereField("receiverId", isEqualTo: uid).whereField("createdTime", isGreaterThan: sevenDaysAgo).getDocuments { (snap, error) in
            if let error = error {
                AppHUD.error(error.localizedDescription, isDarkTheme: true)
                return
            }
            if let snap = snap {
                self.likeStatsLabel.text = "\(snap.count) likes"
            }
        }
    }
    
    fileprivate func getChatStats() {
        guard let user = self.user else { return }
        guard let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        FIRRef.getMessages()
            .whereField("senderId", isEqualTo: user.uid)
            .whereField("receiverId", isEqualTo: uid)
            .whereField("createdTime", isGreaterThan: sevenDaysAgo).getDocuments { (snap, error) in
            if let error = error {
                AppHUD.error(error.localizedDescription, isDarkTheme: true)
                return
            }
            if let snap = snap {
                self.chatStatsLabel.text = "\(snap.count) chats"
            }
        }
    }
    
    fileprivate func setupHeroTransition() {
        userProfileImageView.hero.id = IMAGE_VIEW_HERO_ID
        userProfileImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleShowImage))
        userProfileImageView.addGestureRecognizer(tap)
    }
    
    @objc func handleShowImage() {
        guard let image = userProfileImageView.image else {
            return
        }
        let imageController = SimpleImageController()        
        self.present(imageController, animated: true) {
            imageController.imageView.image = image
        }
    }
    
    
    func configureViews() {
        self.automaticallyAdjustsScrollViewInsets = false

        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -35, right: 0)

        view.addSubview(scrollView)
        scrollView.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: bottomLayoutGuide.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
       
        let container = UIView()
        scrollView.addSubview(container)
        container.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: view.frame.height)
        
        
        container.addSubview(userProfileImageView)
        userProfileImageView.anchor(top: container.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: imageWidth, height: imageWidth)
        userProfileImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        
        container.addSubview(fullNameLabel)
        fullNameLabel.anchor(top: userProfileImageView.bottomAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        container.addSubview(userNameLabel)
        userNameLabel.anchor(top: fullNameLabel.bottomAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, paddingTop: 2, paddingLeft: 8, paddingBottom: 0, paddingRight: 9, width: 0, height: 0)
        
        let divider = UIView()
        container.addSubview(divider)
        divider.backgroundColor = .clear
        divider.anchor(top: userNameLabel.bottomAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.8)
        
        container.addSubview(statsTitleLabel)
        statsTitleLabel.anchor(top: divider.bottomAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        container.addSubview(chatStatsLabel)
        container.addSubview(likeStatsLabel)
        
        chatStatsLabel.anchor(top: statsTitleLabel.bottomAnchor, left: container.leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 60, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        likeStatsLabel.anchor(top: statsTitleLabel.bottomAnchor, left: nil, bottom: nil, right: container.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 60, width: 0, height: 0)
        
        let bottomdivider = UIView()
        container.addSubview(bottomdivider)
        bottomdivider.backgroundColor = BACKGROUND_GRAY
        bottomdivider.anchor(top: chatStatsLabel.bottomAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, paddingTop: 12, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0.8)
        
        container.addSubview(sendChatButton)
        sendChatButton.anchor(top: bottomdivider.bottomAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 44)
        UIView.addShadow(for: sendChatButton)
        
        container.addSubview(showMoreButton)
        showMoreButton.anchor(top: sendChatButton.bottomAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 44)
        UIView.addShadow(for: showMoreButton)
    
    }
    
    @objc func dismissNav() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}


extension UserProfileController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage        
        picker.dismiss(animated: true) {
            guard let user = self.user, let image = UIImage.fixOrientationOfImage(image: image) else { return }
            let editor = XWImageEditorController(with: image, sendTo: user)
            editor.hidesBottomBarWhenPushed = true
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(editor, animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
