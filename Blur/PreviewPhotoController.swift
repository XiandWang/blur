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
    var originalImage: UIImage?
    
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
        lb.lineBreakMode = .byWordWrapping
        //lb.textAlignment = .center
        lb.text = "Do you allow the recipient to view the original image?"
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
        s.onTintColor = RED_COLOR
        
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
        navigationItem.title = "Allow?"
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
    
    @objc func sendPhoto() {
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        guard let senderId = Auth.auth().currentUser?.uid else { return }
        guard let originalImage = originalImage, let editedImage = editedImage else {
            showError(PROCESSING_IMAGE_ERR)
            return
        }
        
        // uploading images to Firebase Storage
        let meta = StorageMetadata(dictionary: ["contentType": "image/jpeg"])
        
        guard let originalJpeg = UIImageJPEGRepresentation(originalImage, 0.3) else {
            showError(PROCESSING_IMAGE_ERR)
            return
        }
        
        let originalTask = Storage.storage().reference().child("imagesSent").child(senderId).child(UUID().uuidString).putData(originalJpeg, metadata: meta)
        
        guard let editedJpeg = UIImageJPEGRepresentation(editedImage, 0.9) else {
            showError(PROCESSING_IMAGE_ERR)
            return
        }
        let editedTask = Storage.storage().reference().child("imagesSent").child(senderId).child(UUID().uuidString).putData(editedJpeg, metadata: meta)
        print(editedJpeg.count)
        print(originalJpeg.count)
        
    
        originalTask.observe(.failure) { (snap) in
            self.showError(self.UPLOADING_IMAGE_ERR)
            return
        }
        
        editedTask.observe(.failure) { (snap) in
            self.showError(self.UPLOADING_IMAGE_ERR)
            return
        }
        
        
        originalTask.observe(.success) { (originalSnap) in
            editedTask.observe(.success, handler: { (editedSnap) in
                guard let editedImageUrl = editedSnap.metadata?.downloadURL()?.absoluteString else {
                    self.showError(self.UPLOADING_IMAGE_ERR)
                    return
                }
                guard let originalImageUrl =  originalSnap.metadata?.downloadURL()?.absoluteString else {
                    self.showError(self.UPLOADING_IMAGE_ERR)
                    return
                }
                guard let receiverId = self.user?.uid else { return }
                let data = [MessageSchema.SENDER_ID: senderId, MessageSchema.RECEIVER_ID: receiverId,
                            MessageSchema.EDITED_IMAGE_URL: editedImageUrl,
                            MessageSchema.ORIGINAL_IMAGE_URL: originalImageUrl,
                            MessageSchema.ALLOW_ORIGINAL: self.allowSwitch.isOn,
                            MessageSchema.IS_ACKNOWLEDGED: false, MessageSchema.IS_ORIGINAL_VIEWED: false,
                            MessageSchema.IS_DELETED: false, MessageSchema.CREATED_TIME: Date()] as [String : Any]
                var ref: DocumentReference? = nil
                ref = Firestore.firestore().collection("imageMessages").addDocument(data: data, completion: { (error) in
                    if let error = error {
                        self.showError(error.localizedDescription)
                        return
                    }
                    print("success")
                    guard let ref = ref else { return }
                    let message = Message(dict: data, messageId: ref.documentID)
                    let userInfo = ["message": message]
                    NotificationCenter.default.post(name: NEW_MESSAGE_CREATED, object: nil, userInfo: userInfo)
                    self.navigationController?.popToRootViewController(animated: true)
                })
            })
        }
    }
    
    fileprivate func showError(_ message: String) {
        AppHUD.error(message, isDarkTheme: true)
        self.navigationItem.setHidesBackButton(false, animated: true)
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
}
