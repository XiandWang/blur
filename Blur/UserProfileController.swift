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
        label.font = UIFont.boldSystemFont(ofSize: 16)
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
        bt.backgroundColor = PRIMARY_COLOR
        
        bt.setTitle("Send a Photo", for: .normal)
        bt.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        bt.setTitleColor(.white, for: .normal)
        
        bt.layer.cornerRadius = 20
        bt.layer.masksToBounds = true
        bt.addTarget(self, action: #selector(handleSendPhoto), for: .touchUpInside)
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
    }

    @objc func handleSendPhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            picker.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
            picker.sourceType = .camera
            picker.allowsEditing = false
            self.present(picker, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            picker.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
            picker.sourceType = .photoLibrary
            picker.allowsEditing = false
            self.present(picker, animated: true, completion: nil)
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    
    }
    
    fileprivate func setupViews() {
        view.addSubview(userView)
        
        userView.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        userView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20).isActive = true

//        userView.addSubview(userProfileImageView)

//        userProfileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
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
