//
//  PreviewPhotoController.swift
//  Blur
//
//  Created by xiandong wang on 2017/10/3.
//  Copyright © 2017年 xiandong wang. All rights reserved.
//

import UIKit
import Firebase

class PreviewPhotoController: UIViewController {
    private let PROCESSING_IMAGE_ERR = "Error processing images. Please try again."
    private let UPLOADING_IMAGE_ERR = "Error uploading images. Please try again."
    
    var user: User?
    var editedImage: UIImage?
    var uneditedImage: UIImage?
    
    lazy var previewImageView: UIImageView = {
        let iv = UIImageView(image: self.editedImage)
        iv.backgroundColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let containerView : UIView = {
        let iv = UIView()
        iv.backgroundColor = .white
        return iv
    }()
    
    let questionlabel : UILabel = {
        let lb =  UILabel()
        lb.numberOfLines = 0
        lb.lineBreakMode = NSLineBreakMode.byWordWrapping
        //lb.textAlignment = .center
        lb.text = "Do you allow the recipient to view the unedited image?"
        lb.font = UIFont.systemFont(ofSize: 16)
        lb.textColor = .gray
        return lb
    }()
    
    let allowLabel : UILabel = {
        let lb =  UILabel()
        lb.text = "Allow"
        lb.font = UIFont.boldSystemFont(ofSize: 16)
        return lb
    }()
    
    let allowSwitch : UISwitch = {
        let s = UISwitch()
        s.isOn = false
        s.onTintColor = PRIMARY_COLOR
        
        return s
    }()
    
    lazy var userToSendLabel : UILabel = {
        let lb =  UILabel()
        if let name = self.user?.username  {
            lb.text = "The image is sent to \(name)"
        }
        lb.font = UIFont.boldSystemFont(ofSize: 16)
        return lb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BACKGROUND_GRAY
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(sendPhoto))
        setupViews()
    }
    
    func setupViews() {
        view.addSubview(userToSendLabel)
        userToSendLabel.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: (self.navigationController?.navigationBar.bounds.height)! + 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        userToSendLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(previewImageView)
        previewImageView.anchor(top: userToSendLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20
            , paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 200)
        
        view.addSubview(containerView)
        containerView.anchor(top: previewImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 102)
        
        containerView.addSubview(questionlabel)
        questionlabel.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: 0)
        
        containerView.addSubview(allowLabel)
        allowLabel.anchor(top: questionlabel.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        containerView.addSubview(allowSwitch)
        allowSwitch.anchor(top: questionlabel.bottomAnchor, left: nil, bottom: nil, right: containerView.rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        allowSwitch.centerYAnchor.constraint(equalTo: allowSwitch.centerYAnchor).isActive = true
    }
    
    func sendPhoto() {
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        guard let fromUid = Auth.auth().currentUser?.uid else { return }
        guard let uneditedImage = uneditedImage, let editedImage = editedImage else {
            showError(PROCESSING_IMAGE_ERR)
            return
        }
        
        let meta = StorageMetadata(dictionary: ["contentType": "image/jpeg"])
        guard let uneditedJpeg = UIImageJPEGRepresentation(uneditedImage, 0.3) else {
            showError(PROCESSING_IMAGE_ERR)
            return
        }
        let uneditedTask = Storage.storage().reference().child("imagesSent").child(fromUid).child(UUID().uuidString).putData(uneditedJpeg, metadata: meta)
        
        guard let editedJpeg = UIImageJPEGRepresentation(editedImage, 0.3) else {
            showError(PROCESSING_IMAGE_ERR)
            return
        }
        let editedTask = Storage.storage().reference().child("imagesSent").child(fromUid).child(UUID().uuidString).putData(editedJpeg, metadata: meta)
        print(editedJpeg.count)
        print(uneditedJpeg.count)
        uneditedTask.observe(.failure) { (snap) in
            self.showError(self.UPLOADING_IMAGE_ERR)
            return
        }
        
        editedTask.observe(.failure) { (_) in
            self.showError(self.UPLOADING_IMAGE_ERR)
            return
        }
        
        uneditedTask.observe(.success) { (uneditedSnap) in
            editedTask.observe(.success, handler: { (editedSnap) in
                guard let editedImageUrl = editedSnap.metadata?.downloadURL()?.absoluteString else {
                    self.showError(self.UPLOADING_IMAGE_ERR)
                    return
                }
                guard let uneditedImageUrl =  uneditedSnap.metadata?.downloadURL()?.absoluteString else {
                    self.showError(self.UPLOADING_IMAGE_ERR)
                    return
                }
                guard let toUid = self.user?.uid else { return }
                let values = ["fromId": fromUid, "toId": toUid,
                              "editedImageUrl": editedImageUrl, "uneditedImageUrl": uneditedImageUrl,
                              "allowUnedited": self.allowSwitch.isOn, "isAcknowledged": false, "isUneditedViewed": false,
                              "createdTime": Date()] as [String : Any]
                
                Firestore.firestore().collection("imageMessages").addDocument(data: values, completion: { (error) in
                    if let error = error {
                        self.showError(error.localizedDescription)
                        return
                    }
                    print("success")
                    self.navigationController?.popToRootViewController(animated: true)
                })
            })
        }
    }
    
    fileprivate func showError(_ message: String) {
        AppHUD.error(message)
        self.navigationItem.setHidesBackButton(false, animated: true)
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
}
