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
    
    var user: User? {
        didSet {
            guard let username = user?.username else { return }
            self.questionlabel.text = "Do you allow \(username) to view the original image?"
        }
    }
    var editedImage: UIImage?
    var originalImage: UIImage?
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView(image: self.editedImage)
        iv.backgroundColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    
    let questionlabel: UILabel = {
        let lb =  UILabel()
        lb.numberOfLines = 0
        lb.lineBreakMode = .byWordWrapping
        lb.text = ""
        lb.font = UIFont.boldSystemFont(ofSize: 17)
        lb.backgroundColor = .clear
        lb.textColor = TEXT_GRAY
        lb.textAlignment = .center
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
        s.onTintColor = DEEP_PURPLE_COLOR
        
        return s
    }()

    let captionTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()

    let imageContainer = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BACKGROUND_GRAY
        navigationItem.title = "Allow?"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(sendPhoto))
        setupImageAndTextViews()
        setupAllow()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    fileprivate func setupImageAndTextViews() {
        imageContainer.backgroundColor = .white
        
        view.addSubview(imageContainer)
        imageContainer.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        
        imageContainer.addSubview(imageView)
        imageView.anchor(top: imageContainer.topAnchor, left: imageContainer.leftAnchor, bottom: imageContainer.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 84, height: 0)
        
        imageContainer.addSubview(captionTextView)
        captionTextView.anchor(top: imageContainer.topAnchor, left: imageView.rightAnchor, bottom: imageContainer.bottomAnchor, right: imageContainer.rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    fileprivate func setupAllow() {
        view.addSubview(self.questionlabel)
        questionlabel.anchor(top: imageContainer.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 56)
        
        let allowContainer = UIView()
        allowContainer.backgroundColor = .white
        allowContainer.addSubview(allowLabel)
        allowContainer.addSubview(allowSwitch)
        view.addSubview(allowContainer)
        
        allowLabel.centerYAnchor.constraint(equalTo: allowContainer.centerYAnchor).isActive = true
        allowSwitch.centerYAnchor.constraint(equalTo: allowContainer.centerYAnchor).isActive = true
        
        allowLabel.anchor(top: nil, left: allowContainer.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        allowSwitch.anchor(top: nil, left: nil, bottom: nil, right: allowContainer.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        allowContainer.anchor(top: questionlabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 48)
    }
    
    func checkIfCanSend(completion: @escaping ((Bool) -> ())) {
        guard let senderId = Auth.auth().currentUser?.uid else { return }
        guard let receiver = user else { return }
        Database.database().reference().child(FRIENDS_NODE).child(receiver.uid).child(senderId).observeSingleEvent(of: DataEventType.value) { (snap) in
            if !snap.exists() {
                completion(false)
                return
            } else {
                guard let dict = snap.value as? [String: Any] else {
                    completion(false)
                    return
                }
                guard let status = dict["status"] as? String else {
                    completion(false)
                    return
                }
                if status != FriendStatus.added.rawValue {
                    completion(false)
                    return
                } else {
                    completion(true)
                }
            }
        }
    }
    
    @objc func sendPhoto() {
        captionTextView.resignFirstResponder()
        if captionTextView.text.count > 120 {
            AppHUD.error("Caption should be less than 120 characters", isDarkTheme: false)
            return
        }
        AppHUD.progress(nil, isDarkTheme: true)
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        checkIfCanSend(completion: { (canSend) in
            if canSend {
                print("--___-----------------------", "canSend😉")
                self.send()
            } else {
                AppHUD.progressHidden()
                AppHUD.error("Not Authorized", isDarkTheme: true)
                self.navigationController?.popToRootViewController(animated: true)
            }
        })
    }
    
    fileprivate func send() {
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
                            MessageSchema.EDITED_IMAGE_URL: editedImageUrl, MessageSchema.ORIGINAL_IMAGE_URL: originalImageUrl,
                            MessageSchema.ALLOW_ORIGINAL: self.allowSwitch.isOn,
                            MessageSchema.IS_ACKNOWLEDGED: false, MessageSchema.IS_ORIGINAL_VIEWED: false,
                            MessageSchema.IS_LIKED: false,  MessageSchema.CAPTION: self.captionTextView.text ?? "",
                            MessageSchema.IS_DELETED: false, MessageSchema.CREATED_TIME: Date()] as [String : Any]
                var ref: DocumentReference? = nil
                ref = Firestore.firestore().collection("imageMessages").addDocument(data: data, completion: { (error) in
                    if let error = error {
                        self.showError(error.localizedDescription)
                        return
                    }
                    AppHUD.progressHidden()
                    print("success")
                    guard let ref = ref else {
                        self.navigationController?.popToRootViewController(animated: true)
                        return
                    }
                    let message = Message(dict: data, messageId: ref.documentID)
                    let userInfo = ["message": message]
                    NotificationCenter.default.post(name: NEW_MESSAGE_CREATED, object: nil, userInfo: userInfo)
                    self.navigationController?.popToRootViewController(animated: true)
                })
            })
        }
    }
    
    fileprivate func showError(_ message: String) {
        AppHUD.progressHidden()
        AppHUD.error(message, isDarkTheme: true)
        self.navigationItem.setHidesBackButton(false, animated: true)
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
}
