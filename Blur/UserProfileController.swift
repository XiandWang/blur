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

class UserProfileController: UIViewController {
    private let imageWidth: CGFloat = 80.0
    
    var user : User? {
        didSet {
            if let name = user?.username {
                userNameLabel.text = "Username: \(name)"
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
        label.font = UIFont(name: APP_FONT_BOLD, size: 18)
        label.numberOfLines = 0
        label.text = ""
        return label
    }()
    
    let fullNameLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: APP_FONT_BOLD, size: 17)
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.text = ""
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
    
    
    let sendPhotoButton: UIButton = {
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
    
    let userInfoContainer : UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 15
        return v
    }()
    
    let statsContainer : UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 15
        return v
    }()
    
    let statsTitleLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.text = "Sent to you in 7 days:"
        lb.font = UIFont(name: APP_FONT_BOLD, size: 17)
        return lb
    }()
    
    let likeStatsLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.text = "_ likes"
        lb.textColor = PINK_COLOR
        lb.font = UIFont(name: APP_FONT_BOLD, size: 16)
        lb.layer.cornerRadius = 20
        lb.layer.masksToBounds  = true
        lb.backgroundColor = BACKGROUND_GRAY
        return lb
    }()
    
    let chatStatsLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.text = "_ chats"
        lb.textColor = BLUE_COLOR
        lb.font = UIFont(name: APP_FONT_BOLD, size: 16)
        lb.layer.cornerRadius = 20
        lb.layer.masksToBounds  = true

        lb.backgroundColor = BACKGROUND_GRAY
        return lb
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Profile"
        view?.backgroundColor = BACKGROUND_GRAY
        setupViews()
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(navback))
        swipe.direction = .right
        view.addGestureRecognizer(swipe)
        setupHeroTransition()
        
        getLikeStats()
        getChatStats()
    }
    
    @objc func navback() {
        self.navigationController?.popToRootViewController(animated: true)
    }

    @objc func handleSendImage() {
        if checkImagePermission() == .denied || checkCameraPermission() == .denied {
            let dialog = AZDialogViewController(title: "Camera and image permission", message: "Most people use HidingChat to send images. Do you want to grant permission?", verticalSpacing: -1, buttonSpacing: 10, sideSpacing: 20, titleFontSize: 22, messageFontSize: 14, buttonsHeight: 50, cancelButtonHeight: 50, fontName: "AvenirNext-Medium", boldFontName: "AvenirNext-DemiBold")
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
            dialog.addAction(AZDialogAction(title: "Go to settings", handler: { (dialog) -> (Void) in
                self.openSettings()
                dialog.dismiss()
            }))
            
//            dialog.addAction(AZDialogAction(title: "Cancel", handler: { (dialog) -> (Void) in
//                dialog.dismiss()
//            }))
           
            dialog.show(in: self)
        } else {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            
            let actionSheet = UIAlertController(title: "HidingChat Image", message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
                picker.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
                picker.sourceType = .camera
                self.present(picker, animated: true, completion: nil)
            }))
            actionSheet.addAction(UIAlertAction(title: "Image Library", style: .default, handler: { (action) in
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
    
    func openSettings() {
        guard let url = URL(string: UIApplicationOpenSettingsURLString) else { return }
        UIApplication.shared.open(url, completionHandler: nil)
    }
    
    fileprivate func setupViews() {
        view.addSubview(userInfoContainer)
        
        userInfoContainer.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 120)

        userInfoContainer.addSubview(userProfileImageView)
        userProfileImageView.anchor(top: userInfoContainer.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: imageWidth, height: imageWidth)
        userProfileImageView.centerXAnchor.constraint(equalTo: userInfoContainer.centerXAnchor, constant: -80).isActive = true
        
        userInfoContainer.addSubview(userNameLabel)
        userNameLabel.anchor(top: nil, left: userProfileImageView.rightAnchor, bottom: nil, right: userInfoContainer.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        userNameLabel.centerYAnchor.constraint(equalTo: userProfileImageView.centerYAnchor, constant: -20).isActive = true
        
        userInfoContainer.addSubview(fullNameLabel)
        fullNameLabel.anchor(top: userNameLabel.bottomAnchor, left: userProfileImageView.rightAnchor, bottom: nil, right: userInfoContainer.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        
        view.addSubview(statsContainer)
        statsContainer.anchor(top: userInfoContainer.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 100)
        statsContainer.addSubview(statsTitleLabel)
        statsTitleLabel.anchor(top: statsContainer.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        statsTitleLabel.centerXAnchor.constraint(equalTo: statsContainer.centerXAnchor).isActive = true
        
        statsContainer.addSubview(likeStatsLabel)
        statsContainer.addSubview(chatStatsLabel)
        likeStatsLabel.anchor(top: statsTitleLabel.bottomAnchor, left: statsContainer.leftAnchor, bottom: nil, right: statsContainer.centerXAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 10, width: 120, height: 40)
        chatStatsLabel.anchor(top: statsTitleLabel.bottomAnchor, left: statsContainer.centerXAnchor, bottom: nil, right: statsContainer.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 20, width: 120, height: 40)
        
        view.addSubview(sendPhotoButton)
        sendPhotoButton.anchor(top: statsContainer.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 44)

    }
    
    fileprivate func getLikeStats() {
        guard let user = self.user else { return }
        guard let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("messageLikes").whereField("senderId", isEqualTo: user.uid).whereField("receiverId", isEqualTo: uid).whereField("createdTime", isGreaterThan: sevenDaysAgo).getDocuments { (snap, error) in
            if let error = error {
                print(error.localizedDescription)
                AppHUD.error(error.localizedDescription, isDarkTheme: true)
                return
            }
            if let snap = snap {
                print(snap, snap.count, snap.documents)
                self.likeStatsLabel.text = "\(snap.count) likes"
            }
        }
    }
    
    fileprivate func getChatStats() {
        guard let user = self.user else { return }
        guard let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("imageMessages")
            .whereField("senderId", isEqualTo: user.uid)
            .whereField("receiverId", isEqualTo: uid)
            .whereField("createdTime", isGreaterThan: sevenDaysAgo).getDocuments { (snap, error) in
            if let error = error {
                print(error.localizedDescription)
                AppHUD.error(error.localizedDescription, isDarkTheme: true)
                return
            }
            if let snap = snap {
                print(snap, snap.count, snap.documents)
                self.chatStatsLabel.text = "\(snap.count) chats"
            }
        }
    }
    
    fileprivate func setupHeroTransition() {
        userProfileImageView.heroID = "imageViewHeroId"
        userProfileImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleShowImage))
        userProfileImageView.addGestureRecognizer(tap)
    }
    
    @objc func handleShowImage() {
        let imageController = SimpleImageController()        
        self.present(imageController, animated: true) {
            imageController.imageView.image = self.userProfileImageView.image
        }
    }
}


extension UserProfileController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage        
        picker.dismiss(animated: true) {
            guard let user = self.user, let image = UIImage.fixOrientationOfImage(image: image) else { return }
            let editor = XWImageEditorController(with: image, sendTo: user)
            editor.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(editor, animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
