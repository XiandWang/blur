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

class UserProfileController: UIViewController {
    var user : User? {
        didSet {
            guard let name = user?.username else { return }
            userNameLabel.text = "Username: \(name)"
            guard let userProfileImgUrl = user?.profileImgUrl, userProfileImgUrl != "" else {
                return
            }
            
            userProfileImageView.kf.setImage(with: URL(string: userProfileImgUrl))
        }
    }
    
    let userNameLabel : UILabel = {
        let label = UILabel()
        label.font = BOLD_FONT
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
        
        iv.layer.borderWidth = 5
        iv.layer.borderColor = UIColor.white.cgColor
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
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            picker.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
            picker.sourceType = .camera
            picker.allowsEditing = false
            self.present(picker, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            picker.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
            picker.sourceType = .photoLibrary
            picker.allowsEditing = false
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
        
        userView.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        userView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20).isActive = true

        view.addSubview(userProfileImageView)
        userProfileImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        userProfileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        userProfileImageView.centerYAnchor.constraint(equalTo: userView.topAnchor).isActive = true
        
        view.addSubview(userNameLabel)
        userNameLabel.anchor(top: userProfileImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        userNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true

        view.addSubview(sendPhotoButton)
        sendPhotoButton.anchor(top: userView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 44)
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
