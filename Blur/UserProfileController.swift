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

class UserProfileController: UIViewController {
    var user : User? {
        didSet {
            if let name = user?.username {
                userNameLabel.text = name
            }
            if let userProfileImgUrl = user?.profileImgUrl, userProfileImgUrl != ""  {
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
        label.textColor = UIColor.hexStringToUIColor(hex: "#5D4037")
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
    
    let userProfileImageView : UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .lightGray
        iv.layer.cornerRadius = 50
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
    
    let userView : UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 15
        
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Profile"
        view?.backgroundColor = BACKGROUND_GRAY
        setupViews()
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(navback))
        swipe.direction = .right
        view.addGestureRecognizer(swipe)
        
        checkImagePermission()
        checkCameraPermission()
    }
    
    @objc func navback() {
        self.navigationController?.popToRootViewController(animated: true)
    }

    @objc func handleSendImage() {
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
   
   
    
    
    fileprivate func checkImagePermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        print(status)
        
        if status == .notDetermined {
            print("image not deter")
        }
        
        if status == .authorized {
            print("image  authorized")
        }
        
        if status == .denied {
            print("image denied")
        }
        
        if status == .restricted {
            print("image restricted")
        }
    }
    
    fileprivate func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        print(status.rawValue)
        
        if status == .notDetermined {
            print("cam not deter")
        }
        
        if status == .authorized {
            print("cam  authorized")
        }
        
        if status == .denied {
            print("cam denied")
        }
        
        if status == .restricted {
            print("cam restricted")
        }
    }
    
    func openSettings() {
        guard let url = URL(string: UIApplicationOpenSettingsURLString) else { return }
        UIApplication.shared.open(url, completionHandler: nil)
    }
    
    fileprivate func setupViews() {
        view.addSubview(userView)
        
        userView.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 200)

        userView.addSubview(userProfileImageView)
        userProfileImageView.anchor(top: userView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        userProfileImageView.centerXAnchor.constraint(equalTo: userView.centerXAnchor, constant: -80).isActive = true
        
        userView.addSubview(userNameLabel)
        userNameLabel.anchor(top: nil, left: userProfileImageView.rightAnchor, bottom: nil, right: userView.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        userNameLabel.centerYAnchor.constraint(equalTo: userProfileImageView.centerYAnchor, constant: -20).isActive = true
        
        userView.addSubview(fullNameLabel)
        fullNameLabel.anchor(top: userNameLabel.bottomAnchor, left: userProfileImageView.rightAnchor, bottom: nil, right: userView.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        
        let divider = UIView()
        divider.backgroundColor = BACKGROUND_GRAY
        userView.addSubview(divider)
        divider.anchor(top: userProfileImageView.bottomAnchor, left: userView.leftAnchor, bottom: nil, right: userView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 1)

        view.addSubview(sendPhotoButton)
        sendPhotoButton.anchor(top: userView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 44)
        
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
