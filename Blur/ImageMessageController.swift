//
//  ImageMessageController.swift
//  Blur
//
//  Created by xiandong wang on 11/4/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase

class ImageMessageController : UIViewController {
    private let controlPanelHeight: CGFloat = 88.0
    private let controlPanelAlpha: CGFloat = 1

    let fireStoreRef = Firestore.firestore()
    private var isShowingEdited = true
    private var isShowingControlPanel = true
    var fromUser: User?
    var photoIndex : Int?
    
    var message: Message? {
        didSet {
            if let message = message {
                let editedUrl = URL(string: message.editedImageUrl)
                editedImageView.kf.indicatorType = .activity
                editedImageView.kf.setImage(with: editedUrl)
                
                let originalUrl = URL(string: message.originalImageUrl)
                originalImageView.kf.indicatorType = .activity
                originalImageView.kf.setImage(with: originalUrl)
                
                setupControlPanel(message: message)
            }
        }
    }
    
    let editedImageView : UIImageView = {
        let iv = UIImageView()
        iv.kf.indicatorType = .activity
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let originalImageView : UIImageView = {
        let iv = UIImageView()
        iv.kf.indicatorType = .activity
        iv.contentMode = .scaleAspectFit
        iv.isHidden = true
        return iv
    }()
    
    let showButton: UIButton = {
        let bt = UIButton(type: .custom)
        let size = CGSize(width: 44, height: 44)
        bt.setImage(UIImage.fontAwesomeIcon(name: .thumbsOUp, textColor: .white, size: size), for: .normal)
        bt.backgroundColor = GREEN_COLOR
        bt.layer.cornerRadius = 25
        bt.layer.masksToBounds = true
        bt.addTarget(self, action: #selector(handleShowOriginalImage), for: .touchUpInside)
        
        return bt
    }()
    
    let showLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Show"
        lb.font = UIFont.boldSystemFont(ofSize: 15)
        lb.textColor = GREEN_COLOR
        lb.textAlignment = .center
        return lb
    }()
    
    let rejectButton: UIButton = {
        let bt = UIButton(type: .custom)
        let size = CGSize(width: 44, height: 44)
        bt.setImage(UIImage.fontAwesomeIcon(name: .thumbsODown, textColor: .white, size: size), for: .normal)
        bt.backgroundColor = PRIMARY_COLOR
        bt.layer.cornerRadius = 25
        bt.layer.masksToBounds = true
        bt.addTarget(self, action: #selector(handleRejectImage), for: .touchUpInside)
        return bt
    }()
    
    let rejectLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Reject"
        lb.font = UIFont.boldSystemFont(ofSize: 15)
        lb.textColor = PRIMARY_COLOR
        lb.textAlignment = .center

        return lb
    }()
    
    let requestButton: UIButton = {
        let bt = UIButton(type: .custom)
        let size = CGSize(width: 44, height: 44)
        bt.setImage(UIImage.fontAwesomeIcon(name: .userO, textColor: .white, size: size), for: .normal)
        bt.backgroundColor = .purple
        bt.layer.cornerRadius = 25
        bt.layer.masksToBounds = true
        bt.addTarget(self, action: #selector(handleRequestAccess), for: .touchUpInside)
        return bt
    }()
    
    let requestLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Request"
        lb.font = UIFont.boldSystemFont(ofSize: 15)
        lb.textColor = .purple
        lb.numberOfLines = 0
        lb.textAlignment = .center

        return lb
    }()
    
    let toggleImageButton: UIButton = {
        let bt = UIButton(type: .custom)
        let size = CGSize(width: 44, height: 44)
        bt.setImage(UIImage.fontAwesomeIcon(name: .refresh, textColor: .white, size: size), for: .normal)
        bt.backgroundColor = GREEN_COLOR
        bt.layer.cornerRadius = 25
        bt.layer.masksToBounds = true
        bt.addTarget(self, action: #selector(handleRotateImage), for: .touchUpInside)
        return bt
    }()
    
    lazy var controlPanel: UIView = {
        let frame = CGRect(x: 0, y: UIScreen.main.bounds.height - self.controlPanelHeight, width: UIScreen.main.bounds.width, height: self.controlPanelHeight)
        let panel = UIView(frame: frame)
        panel.backgroundColor = .black
        //panel.alpha = 0.7
        return panel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        view.addSubview(originalImageView)
        view.addSubview(editedImageView)
        view.addSubview(controlPanel)
        setupImageViews()
        AnimationHelper.perspectiveTransform(for: view)
        originalImageView.layer.transform = AnimationHelper.yRotation(.pi / 2)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleControlPanel))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func toggleControlPanel() {
        view.isUserInteractionEnabled = false
        if isShowingControlPanel {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                self.controlPanel.center.y += self.controlPanelHeight
                self.controlPanel.alpha = 0
            }) { (bool) in
                self.view.isUserInteractionEnabled = true
                if bool {
                    self.isShowingControlPanel = false
                }
            }
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.controlPanel.center.y -= self.controlPanelHeight
                self.controlPanel.alpha = self.controlPanelAlpha
            }, completion: { (bool) in
                self.view.isUserInteractionEnabled = true
                if bool {
                    self.isShowingControlPanel = true
                }
            })
        }
    }
    
    fileprivate func setupControlPanel(message: Message) {
        if !message.isAcknowledged {
            addButtonsToControlPanel(leftButton: showButton)
        } else {
            if message.allowOrignal {
                addToggleImageButton()
            } else {
                addButtonsToControlPanel(leftButton: requestButton)
            }
        }
    }
    
    fileprivate func addToggleImageButton() {
        self.controlPanel.addSubview(self.toggleImageButton)
        self.toggleImageButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 16, paddingRight: 0, width: 50, height: 50)
        self.toggleImageButton.centerXAnchor.constraint(equalTo: self.controlPanel.centerXAnchor).isActive = true
        self.toggleImageButton.centerYAnchor.constraint(equalTo: self.controlPanel.centerYAnchor).isActive = true
    }
    
    fileprivate func addButtonsToControlPanel(leftButton: UIButton) {
        controlPanel.addSubview(leftButton)
        controlPanel.addSubview(rejectButton)
        leftButton.anchor(top: controlPanel.topAnchor, left: controlPanel.leftAnchor, bottom: nil, right: nil, paddingTop: 11, paddingLeft: 44, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        rejectButton.anchor(top: controlPanel.topAnchor, left: nil, bottom: nil, right: controlPanel.rightAnchor, paddingTop: 11, paddingLeft: 0, paddingBottom: 0, paddingRight: 44, width: 50, height: 50)
        
        var leftLabel = showLabel
        if leftButton == requestButton {
            leftLabel = requestLabel
        }
        controlPanel.addSubview(leftLabel)
        controlPanel.addSubview(rejectLabel)
        leftLabel.anchor(top: leftButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 0)
        rejectLabel.anchor(top: rejectButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 0)
        leftLabel.centerXAnchor.constraint(equalTo: leftButton.centerXAnchor).isActive = true
        rejectLabel.centerXAnchor.constraint(equalTo: rejectButton.centerXAnchor).isActive = true
    }
    
    fileprivate func setupImageViews() {
        editedImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        originalImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func handleRotateImage() {
        self.originalImageView.isHidden = false
        if isShowingEdited {
            animateRotatingImage(toOriginal: true)
            UIView.animateKeyframes(withDuration: 2.0, delay: 0, options: .calculationModeCubic, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1, animations: {
                    self.toggleImageButton.layer.transform = CATransform3DIdentity
                })
            }, completion: nil)
        } else {
            animateRotatingImage(toOriginal: false)
            UIView.animateKeyframes(withDuration: 2.0, delay: 0, options: .calculationModeCubic, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1, animations: {
                    self.toggleImageButton.layer.transform = AnimationHelper.zRotation(.pi)
                })
            }, completion: nil)
        }
    }
    
    fileprivate func animateRotatingImage(toOriginal: Bool) {
        if toOriginal {
            isShowingEdited = false
            UIView.animateKeyframes(
                withDuration: 2.0, delay: 0, options: .calculationModeCubic,
                animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2) {
                        self.editedImageView.layer.transform = AnimationHelper.yRotation(-.pi / 2)
                        self.controlPanel.center.y += self.controlPanelHeight
                    }
                    UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2) {
                        self.originalImageView.layer.transform = AnimationHelper.yRotation(0.0)
                        self.controlPanel.center.y -= self.controlPanelHeight
                    }
            }, completion: nil)
        } else {
            isShowingEdited = true
            UIView.animateKeyframes(
                withDuration: 2.0, delay: 0, options: .calculationModeCubic,
                animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2) {
                        self.originalImageView.layer.transform = AnimationHelper.yRotation(.pi / 2)
                        self.controlPanel.center.y += self.controlPanelHeight
                    }
                    UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2) {
                        self.editedImageView.layer.transform = CATransform3DIdentity
                        self.controlPanel.center.y -= self.controlPanelHeight

                    }
            }, completion: nil)
        }
    }
}

extension ImageMessageController {
    func handleShowOriginalImage() {
        guard let allowOriginal = message?.allowOrignal else { return }
        if allowOriginal {
            self.originalImageView.isHidden = false
            self.animateRotatingImage(toOriginal: true)
            self.acceptImageMessage(isOriginalViewed: true)
            UIView.animate(withDuration: 1.0, animations: {
                for view in self.controlPanel.subviews {
                    view.alpha = 0
                }
            }, completion: { (_) in
                for view in self.controlPanel.subviews {
                    view.removeFromSuperview()
                }
                self.addToggleImageButton()
            })
        } else {
            self.acceptImageMessage(isOriginalViewed: false)
            requestButton.frame = showButton.frame
            requestLabel.frame = showLabel.frame
            UIView.transition(from: showButton, to: requestButton, duration: 0.5, options: .transitionFlipFromTop, completion: nil)
            UIView.transition(from: showLabel, to: requestLabel, duration: 0.5, options: .transitionFlipFromTop, completion: nil)
        }
    }
    
    func rejectImageMessage(shouldSendNotification: Bool, additionalText: String?) {
        guard let messageId = message?.messageId  else { return }
        fireStoreRef.collection("imageMessages")
            .document(messageId).updateData(["isDeleted": true, "isAcknowledged": true, "AcknowledgeType": "Reject"]) { (error) in
                if let error = error {
                    AppHUD.error(error.localizedDescription)
                    return
                }
    
                if shouldSendNotification {
                   guard let uid = self.fromUser?.uid else { return }
                   NotificationHelper.createMessageNotification(messageId: messageId, type: NotificationType.REJECT_MESSAGE, forUser: uid, text: additionalText, shouldShowHUD: false, hudSuccessText: nil)
                }
                self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func acceptImageMessage(isOriginalViewed: Bool) {
        guard let messageId = message?.messageId  else { return }
        let data = ["isAcknowledged": true,
                    "AcknowledgeType": "Accept",
                    "isOriginalViewed": isOriginalViewed] as [String : Any]
        fireStoreRef.collection("imageMessages")
            .document(messageId).updateData(data) { (error) in
                if let error = error {
                    AppHUD.error(error.localizedDescription)
                    return
                }
        }
    }
    
    func handleRejectImage() {
        let fromUserName = self.fromUser?.username ?? ""
        let alert = UIAlertController(title: nil, message: "Do you want to notify \(fromUserName) your rejection?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes, notify", style: .default) { (action) in
            if let text = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespaces), text.count != 0 {
                self.rejectImageMessage(shouldSendNotification: true, additionalText: text)
            } else {
                self.rejectImageMessage(shouldSendNotification: true, additionalText: nil)
            }
        }
        
        let noAction = UIAlertAction(title: "No, reject silently", style: .default) { (action) in
            self.rejectImageMessage(shouldSendNotification: false, additionalText: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel rejection", style: .default, handler: nil)
        
        alert.addTextField { (textField) in
            textField.placeholder = "rejection message (optional)"
        }
        alert.addAction(yesAction)
        alert.addAction(noAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func handleRequestAccess() {
        guard let messageId = message?.messageId else { return }
        guard let userId = fromUser?.uid else { return }
        NotificationHelper.createMessageNotification(messageId: messageId, type: .REQUEST_ACCESS, forUser: userId, text: nil, shouldShowHUD: true, hudSuccessText: "Your request to access has been sent")
    }
}

struct AnimationHelper {
    static func yRotation(_ angle: Double) -> CATransform3D {
        return CATransform3DMakeRotation(CGFloat(angle), 0.0, 1.0, 0.0)
    }
    
    static func zRotation(_ angle: Double) -> CATransform3D {
        return CATransform3DMakeRotation(CGFloat(angle), 0.0, 0.0, 1.0)
    }
    
    static func perspectiveTransform(for containerView: UIView) {
        var transform = CATransform3DIdentity
        transform.m34 = -0.002
        containerView.layer.sublayerTransform = transform
    }
}

struct NotificationHelper {
    static func createMessageNotification(messageId: String, type: NotificationType, forUser userId: String, text: String?, shouldShowHUD: Bool, hudSuccessText: String?) {
        if shouldShowHUD {
            AppHUD.progress(nil)
        }
        var data = ["type": type.rawValue, "userId": userId, "messageId": messageId]
        if let text = text {
            data["text"] = text
        }
        Firestore.firestore()
            .collection("userNotifications")
            .document(userId).collection("notifications").addDocument(data: data) { (error) in
                if shouldShowHUD {
                    AppHUD.progressHidden()
                    AppHUD.success(hudSuccessText ?? "Success")
                }
                if let error = error {
                    print(error)
                    return
                }
        }
    }
}
