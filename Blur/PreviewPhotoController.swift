//
//  PreviewPhotoController.swift
//  Blur
//
//  Created by xiandong wang on 2017/10/3.
//  Copyright © 2017年 xiandong wang. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class PreviewPhotoController: UIViewController {
    private let PROCESSING_IMAGE_ERR = "Error processing images. Please try again."
    private let UPLOADING_IMAGE_ERR = "Error uploading images. Please try again."
    
    var currentUser: User?
    
    var user: User? {
        didSet {
            guard let username = user?.username else { return }
            self.questionlabel.text = "Do you allow @\(username) to view the original image?"
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
        lb.font = UIFont(name: APP_FONT_BOLD, size: 17)
        lb.backgroundColor = .clear
        lb.textColor = TEXT_GRAY
        lb.textAlignment = .center
        return lb
    }()
    
    let countdownlabel: UILabel = {
        let lb =  UILabel()
        lb.lineBreakMode = .byWordWrapping
        lb.text = "Delay revealing with a count down? (optional)"
        lb.font = UIFont(name: APP_FONT_BOLD, size: 17)
        lb.backgroundColor = .clear
        lb.textColor = TEXT_GRAY
        lb.textAlignment = .center
        lb.alpha = 0
        lb.numberOfLines = 0
        return lb
    }()
    
    let allowLabel : UILabel = {
        let lb =  UILabel()
        lb.text = "Allow"
        lb.font = BOLD_FONT
        return lb
    }()
    
    let allowSwitch : UISwitch = {
        let s = UISwitch()
        s.isOn = false
        s.onTintColor = TINT_COLOR
        s.addTarget(self, action: #selector(handleAllowSwitchChanged), for: .valueChanged)
        return s
    }()

    let captionTextView: UITextView = {
        let tv = UITextView()
        tv.font = TEXT_FONT
        return tv
    }()

    let imageContainer = UIView()
    
    let allowNoteLabel : UILabel = {
        let lb =  UILabel()
        lb.text = "*Can allow later in 24 hours."
        lb.font = UIFont(name: APP_FONT, size: 13)
        lb.textColor = .lightGray
        return lb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BACKGROUND_GRAY
        navigationItem.title = "Allow?"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(sendPhoto))
        setupImageAndTextViews()
        setupAllow()
        
        
        picker.delegate = self
        picker.dataSource = self
        picker.selectRow(0, inComponent: 0, animated: true)
        picker.showsSelectionIndicator = true
        setupPicker()
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
        questionlabel.anchor(top: imageContainer.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        let allowContainer = UIView()
        allowContainer.backgroundColor = .white
        allowContainer.addSubview(allowLabel)
        allowContainer.addSubview(allowSwitch)
        view.addSubview(allowContainer)
        
        allowLabel.centerYAnchor.constraint(equalTo: allowContainer.centerYAnchor).isActive = true
        allowSwitch.centerYAnchor.constraint(equalTo: allowContainer.centerYAnchor).isActive = true
        
        allowLabel.anchor(top: nil, left: allowContainer.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        allowSwitch.anchor(top: nil, left: nil, bottom: nil, right: allowContainer.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        allowContainer.anchor(top: questionlabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 48)
        
        view.addSubview(allowNoteLabel)
        allowNoteLabel.anchor(top: allowContainer.bottomAnchor, left: allowContainer.leftAnchor, bottom: nil, right: allowContainer.rightAnchor, paddingTop: 2, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
    }
    
    func setupPicker() {
        view.addSubview(countdownlabel)
        countdownlabel.anchor(top: allowNoteLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)

        view.addSubview(picker)
        picker.anchor(top: countdownlabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
    }
    
    func checkIfCanSend(completion: @escaping ((Bool) -> ())) {
        guard let senderId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        guard let receiver = user else {
            completion(false)
            return
        }
        Database.database().reference().child(FRIENDS_NODE).child(receiver.uid).child(senderId).observeSingleEvent(of: .value) { (snap) in
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
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        checkIfCanSend(completion: { (canSend) in
            if canSend {
                self.send()
            } else {
                AppHUD.progressHidden()
                AppHUD.error("Not Authorized", isDarkTheme: true)
                self.navigationController?.popToRootViewController(animated: true)
            }
        })
    }
    
    fileprivate func send() {
        AppHUD.progress("Uploading...", isDarkTheme: true)
        guard let senderId = Auth.auth().currentUser?.uid, let senderUser = currentUser else {
            showError("Cannot retrieve current user. Please try again.")
            return
        }
        guard let receiverId = self.user?.uid else {
            showError("cannot retrieve receiver id")
            return
        }
        
        guard let originalImage = originalImage, let editedImage = editedImage else {
            showError(PROCESSING_IMAGE_ERR)
            return
        }
        
        // uploading images to Firebase Storage
        let meta = StorageMetadata()
        meta.customMetadata = ["senderId": senderId, "receiverId": receiverId]
        meta.contentType = "image/jpeg"
        
        guard let originalJpeg = UIImageJPEGRepresentation(originalImage, 0.7) else {
            showError(PROCESSING_IMAGE_ERR)
            return
        }
        
        guard let editedJpeg = UIImageJPEGRepresentation(editedImage, 0.7) else {
            showError(PROCESSING_IMAGE_ERR)
            return
        }
        
        let originalTask = FIRRef.getImageMessages().child(senderId).child(UUID().uuidString).putData(originalJpeg, metadata: meta)
        
       
        let editedTask = FIRRef.getImageMessages().child(senderId).child(UUID().uuidString).putData(editedJpeg, metadata: meta)
        print(editedJpeg.count)
        print(originalJpeg.count)
        
        
        Analytics.logEvent(COUNT_DOWN_TIMER, parameters: ["timerValue": self.picker.selectedRow(inComponent: 0)])
        Analytics.logEvent(ALLOW, parameters: ["allowValue": self.allowSwitch.isOn])

        originalTask.observe(.failure) { (snap) in
            self.showError(self.UPLOADING_IMAGE_ERR )
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
                print(editedImageUrl, "edited")
                print(originalImageUrl, "original")
                let countDown = self.timerValues[safe: self.picker.selectedRow(inComponent: 0)]
                let data = [MessageSchema.SENDER_ID: senderId, MessageSchema.RECEIVER_ID: receiverId,
                            MessageSchema.SENDER_USER: ["username": senderUser.username, "profileImgUrl": senderUser.profileImgUrl ?? "", "fullName": senderUser.fullName],
                            MessageSchema.EDITED_IMAGE_URL: editedImageUrl, MessageSchema.ORIGINAL_IMAGE_URL: originalImageUrl,
                            MessageSchema.ALLOW_ORIGINAL: self.allowSwitch.isOn, "countDown": countDown ?? 5,
                            MessageSchema.IS_ACKNOWLEDGED: false, MessageSchema.IS_ORIGINAL_VIEWED: false,
                            MessageSchema.IS_LIKED: false,  MessageSchema.CAPTION: self.captionTextView.text ?? "",
                            MessageSchema.IS_DELETED: false, MessageSchema.CREATED_TIME: Date()] as [String : Any]
                let messageId = UUID().uuidString
                AppHUD.progressHidden()
                AppHUD.progress("Finalizing...", isDarkTheme: true)
                FIRRef.getMessages().document(messageId).setData(data, completion: { (error) in
                    if let _ = error {
                        self.showError("Sorry, we experienced an issue. Please try again.")
                        return
                    }
                    AppHUD.progressHidden()
                    let message = Message(dict: data, messageId: messageId)
                    let userInfo = ["message": message]
                    NotificationCenter.default.post(name: NEW_MESSAGE_CREATED, object: nil, userInfo: userInfo)
                    
                    
                    ImageCache.default.store(originalImage, forKey: originalImageUrl)
                    ImageCache.default.store(editedImage, forKey: editedImageUrl)
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
    
    let picker : UIPickerView = {
        let p = UIPickerView()
        p.backgroundColor = .white
        p.alpha = 0
        return p
    }()
    
    let timerValues = [0, 5, 10, 60, 300, 600, 1800, 3600]
}

extension PreviewPhotoController {
    @objc func handleAllowSwitchChanged() {
        if allowSwitch.isOn {
            UIView.animate(withDuration: 0.33, animations: {
                self.picker.alpha = 1
                self.countdownlabel.alpha = 1
            })
        } else {
            UIView.animate(withDuration: 0.33, animations: {
                self.picker.alpha = 0
                self.countdownlabel.alpha = 0
            })
        }
    }
}

extension PreviewPhotoController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timerValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let num = timerValues[row]

        if num == 0 {
            return "none"
        }
        if num < 60 {
            return "\(num) sec"
        } else if num < 3600 {
            return "\(num / 60) min"
        } else if num >= 3600 {
            return "\(num / 3600) hour"
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    

}

