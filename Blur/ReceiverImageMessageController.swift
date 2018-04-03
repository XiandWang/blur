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
import FaveButton
import AZDialogView
import JSSAlertView
import SCLAlertView

class ReceiverImageMessageController : UIViewController {
    private let controlPanelHeight: CGFloat = 96.0
    private let controlPanelAlpha: CGFloat = 1.0
    private let controlSidePadding: CGFloat = UIScreen.main.bounds.width / 4.0 - 35
    
    private let fireStoreRef = Firestore.firestore()
    private var isShowingEdited = true
    private var isShowingControlPanel = true
    
    var senderUser: User?
    var photoIndex : Int?
    
    var pageController: UIPageViewController?
    
    var message: Message? {
        didSet {
            if let message = message {
                let editedUrl = URL(string: message.editedImageUrl)
                editedImageView.kf.indicatorType = .activity
                editedImageView.kf.setImage(with: editedUrl, placeholder:#imageLiteral(resourceName: "image_bg_512"), options: nil, progressBlock: nil, completionHandler: nil)
                
                let originalUrl = URL(string: message.originalImageUrl)
                originalImageView.kf.indicatorType = .activity
                originalImageView.kf.setImage(with: originalUrl, placeholder:#imageLiteral(resourceName: "image_bg_512"), options: nil, progressBlock: nil, completionHandler: nil)
                
                setupControlPanel(message: message)
                
                if !message.caption.trimmingCharacters(in: .whitespaces).isEmpty {
                    setupCaptionLabel()
                }
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
    
    var originalScrollView: UIScrollView = {
        let sv = UIScrollView()
        return sv
    }()
    
    let captionLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        lb.textColor = .white
        lb.numberOfLines = 0
        lb.font = SMALL_TEXT_FONT
        return lb
    }()
    
    lazy var controlPanel: UIView = {
        let padding = getSafePadding()
        let frame = CGRect(x: 0, y: UIScreen.main.bounds.height - self.controlPanelHeight - padding , width: UIScreen.main.bounds.width, height: self.controlPanelHeight + padding)
        let panel = UIView(frame: frame)
        panel.backgroundColor = .clear

        return panel
    }()
    
    private func getSafePadding() -> CGFloat {
        if #available(iOS 11.0, *) {
            if let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom,
                bottomPadding > 0 {
                return 20
            }
        }
        
        return 0
    }
    
    let showOriginalControl: ControlItemView = {
        let size = ControlItemView.IMAGE_SIZE
        let info = ControlItemInfo(image: UIImage.fontAwesomeIcon(name: .thumbsUp, textColor: GREEN_COLOR, size: size), backgroundColor: GREEN_COLOR_LIGHT, textColor: GREEN_COLOR, itemText: "Reveal")
        let control = ControlItemView(target: self, action: #selector(handleShowOriginalImage))
        control.itemInfo = info
        control.alpha = 0
        return control
    }()
    
    let rejectControl: ControlItemView = {
        let size = ControlItemView.IMAGE_SIZE
        let info = ControlItemInfo(image: UIImage.fontAwesomeIcon(name: .thumbsDown, textColor: RED_COLOR, size: size), backgroundColor: RED_COLOR_LIGHT, textColor: RED_COLOR, itemText: "Reject")
        let control = ControlItemView(target: self, action: #selector(handleRejectImage))
        control.itemInfo = info
        control.alpha = 0
        return control
    }()
    
    let requestControl: ControlItemView = {
        let size = ControlItemView.IMAGE_SIZE
        let info = ControlItemInfo(image: UIImage.fontAwesomeIcon(name: .unlockAlt, textColor: BLUE_COLOR, size: size), backgroundColor:  BLUE_COLOR_LIGHT.withAlphaComponent(0.9), textColor: BLUE_COLOR, itemText: "Request Access")
        let control = ControlItemView(target: self, action: #selector(handleRequestAccess))
        control.itemInfo = info
        control.alpha = 0
        return control
    }()
    
    let viewImageControl: ControlItemView = {
        let size = ControlItemView.IMAGE_SIZE
        let info = ControlItemInfo(image: UIImage.fontAwesomeIcon(name: .eye, textColor: BLUE_COLOR, size: size), backgroundColor: BLUE_COLOR_LIGHT, textColor: BLUE_COLOR, itemText: "Reveal")
        let viewControl = ControlItemView(target: self, action: #selector(handleRotateImage))
        viewControl.itemInfo = info
        viewControl.alpha = 0
        return viewControl
    }()
    
    lazy var likeControl: ControlItemView = {
        let size = CGSize(width: 38, height: 38)
        let info = ControlItemInfo(image: UIImage.fontAwesomeIcon(name: .heart, textColor: PINK_COLOR, size: size), backgroundColor: PINK_COLOR_LIGHT, textColor: PINK_COLOR, itemText: "Like")
        let viewControl = ControlItemView(target: self, action: #selector(handleLikeImage))
        let likeBtn = FaveButton(frame:  CGRect(x: 0, y: 0, width: 50, height: 50), faveIconNormal: UIImage.fontAwesomeIcon(name: .heart, textColor: PINK_COLOR, size: size))
        likeBtn.dotSecondColor = RED_COLOR
        likeBtn.dotFirstColor = YELLOW_COLOR
        likeBtn.selectedColor = PINK_COLOR
        viewControl.itemButton = likeBtn
        viewControl.addSubview(viewControl.itemButton)
        viewControl.itemButton.isSelected  = self.message?.isLiked ?? false
    
        viewControl.itemButton.addTarget(self, action: #selector(handleLikeImage), for: .touchUpInside)
        viewControl.itemButton.layer.cornerRadius = ControlItemView.BUTTON_WIDTH / 2
        viewControl.itemButton.layer.masksToBounds = true
        
        viewControl.itemInfo = info
        viewControl.alpha = 0
        viewControl.setupConstraints()
        if let liked = self.message?.isLiked {
            viewControl.itemButton.isSelected  = liked
            viewControl.isUserInteractionEnabled = !liked
        } else {
            viewControl.itemButton.isSelected = false
        }
       return viewControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false

        self.view.backgroundColor = .black
        setupScrollView()
        setupImageView()
        AnimationHelper.perspectiveTransform(for: view)
        originalScrollView.layer.transform = AnimationHelper.yRotation(.pi / 2)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleControlPanel))
        view.addGestureRecognizer(tapRecognizer)
        addSwipeDown()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else { return }
        guard let message = message else { return }
        if message.createdTime < yesterday {
            AppHUD.progress("HidingChat expired. Deleting...", isDarkTheme: false)
            
            FIRRef.getMessages()
                .document(message.messageId).updateData([MessageSchema.IS_DELETED: true], completion: { (error) in
                    if let err = error {
                        AppHUD.progressHidden()
                        AppHUD.error("Deleting Chat error: " + err.localizedDescription, isDarkTheme: false)
                        return
                    }
                    AppHUD.progressHidden()
                    self.navigationController?.popToRootViewController(animated: true)
                })
        }
        
        guard let sender = senderUser else { return }
        pageController?.navigationItem.title = "\(sender.fullName) • \(message.createdTime.timeAgoDisplay())"
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    fileprivate func setupCaptionLabel() {
        guard let caption = message?.caption else { return }
        captionLabel.text = caption
        view.addSubview(captionLabel)
        let rect = NSString(string: caption).boundingRect(with: CGSize(width:view.width, height:999), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedStringKey.font: SMALL_TEXT_FONT], context: nil).size
        let height = max(rect.height + 16.0, 40)

        
        captionLabel.frame = CGRect(x: 0, y: view.frame.height / 2.0, width: view.frame.width, height: height)
        
        captionLabel.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleCaptionPan(sender:))))
        captionLabel.isUserInteractionEnabled = true
    }
    
    var captionLabelPoint: CGPoint?
    
    @objc func handleCaptionPan(sender: UIPanGestureRecognizer) {
    
        let p = sender.translation(in: self.view)
        if sender.state == .began {
            self.captionLabelPoint = self.captionLabel.center
            
        }
        guard let point = self.captionLabelPoint else { return }
        
        self.captionLabel.center = CGPoint(x: point.x, y: point.y + p.y)
        
        UIView.animate(withDuration: 0.33, delay: 0, options: .curveEaseOut, animations: {
            self.captionLabel.center.x -= self.view.frame.width
        }, completion: nil)
    }
    
    fileprivate func setupScrollView() {
        originalScrollView = UIScrollView(frame: view.bounds)
        originalScrollView.backgroundColor = .black
        originalScrollView.contentSize = originalImageView.bounds.size
        originalScrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        originalScrollView.showsVerticalScrollIndicator = false
        originalScrollView.showsHorizontalScrollIndicator = false
        originalScrollView.clipsToBounds = false
        if #available(iOS 11.0, *) {
            originalScrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        originalScrollView.addSubview(originalImageView)
        view.addSubview(originalScrollView)
        originalScrollView.delegate = self
        
        originalScrollView.layer.transform = AnimationHelper.yRotation(.pi / 2)
        
        refreshOriginalImageView()
    }
    
    fileprivate func setupControlPanel(message: Message) {
        view.addSubview(controlPanel)
    
        if !message.isAcknowledged {
            addControlsToControlPanel(leftControl: rejectControl, rightControl: showOriginalControl)
        } else {
            if message.allowOriginal && message.isOriginalViewed {
                addControlsToControlPanel(leftControl: likeControl, rightControl: viewImageControl)
            } else if message.allowOriginal && !message.isOriginalViewed {
                addControlsToControlPanel(leftControl: rejectControl, rightControl: showOriginalControl)
            } else {
                addControlsToControlPanel(leftControl: rejectControl, rightControl: requestControl)
            }
        }
    }
    
    fileprivate func addControlsToControlPanel(leftControl: ControlItemView, rightControl: ControlItemView) {
        for view in self.controlPanel.subviews {
            view.removeFromSuperview()
        }
        controlPanel.addSubview(leftControl)
        controlPanel.addSubview(rightControl)
        leftControl.anchor(top: controlPanel.topAnchor, left: controlPanel.leftAnchor, bottom: nil, right: nil, paddingTop: 4, paddingLeft: controlSidePadding, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        rightControl.anchor(top: controlPanel.topAnchor, left: nil, bottom: nil, right: controlPanel.rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: controlSidePadding, width: 50, height: 50)
        
        UIView.animate(withDuration: 0.5) {
            leftControl.alpha = 1
            rightControl.alpha = 1
        }
    }
    
    fileprivate func setupImageView() {
        view.addSubview(editedImageView)
        editedImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    @objc func handleRotateImage() {
        self.originalImageView.isHidden = false
        animateRotatingImage(toOriginal: isShowingEdited)
    }
    
    fileprivate func hideControlViews() {
        for v in controlPanel.subviews {
            v.alpha = 0
        }
        self.navigationController?.navigationBar.alpha = 0
    }
    
    fileprivate func hideCaptionLabel() {
        captionLabel.alpha = 0
    }

    fileprivate func showCaptionLabel() {
        captionLabel.alpha = 1
    }
    
    fileprivate func showControlViews() {
        for v in controlPanel.subviews {
            v.alpha = 1
        }
        self.navigationController?.navigationBar.alpha = 1
    }
    
    fileprivate func rotateToOriginalFirstTime() {
        view.isUserInteractionEnabled = false
        self.likeControl.frame = self.rejectControl.frame
        self.viewImageControl.frame = self.showOriginalControl.frame
        UIView.animateKeyframes(
            withDuration: 2.0, delay: 0, options: .calculationModeCubic,
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/9) {
                    self.hideControlViews()
                }
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2) {
                    self.editedImageView.layer.transform = AnimationHelper.yRotation(-.pi / 2)
                    self.captionLabel.layer.transform =  AnimationHelper.yRotation(-.pi / 2)
                }
                UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2) {
                    self.originalScrollView.layer.transform = AnimationHelper.yRotation(0.0)
                    self.refreshOriginalImageView()
                }
                UIView.addKeyframe(withRelativeStartTime: 9/10, relativeDuration: 1/10) {
                    for view in self.controlPanel.subviews {
                        view.removeFromSuperview()
                    }
                    self.controlPanel.addSubview(self.likeControl)
                    self.controlPanel.addSubview(self.viewImageControl)
                    self.likeControl.alpha = 1
                    self.viewImageControl.alpha = 1
                }
        }, completion: { (bool) in
            self.view.isUserInteractionEnabled = true
            if bool {
                self.isShowingEdited = false
            }
        })
    }
    
    fileprivate func animateRotatingImage(toOriginal: Bool) {
        if toOriginal {
            UIView.animateKeyframes(
                withDuration: 2.0, delay: 0, options: .calculationModeCubic,
                animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/9) {
                        self.hideControlViews()
                    }
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2) {
                        self.editedImageView.layer.transform = AnimationHelper.yRotation(-.pi / 2)
                        self.captionLabel.layer.transform =  AnimationHelper.yRotation(-.pi / 2)
                    }
                    UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2) {
                        self.originalScrollView.layer.transform = AnimationHelper.yRotation(0.0)
                        self.refreshOriginalImageView()
                    }
                    UIView.addKeyframe(withRelativeStartTime: 9/10, relativeDuration: 1/10) {
                        self.showControlViews()
                    }
            }, completion: { (bool) in
                self.view.isUserInteractionEnabled = true
                if bool {
                    self.isShowingEdited = false
                }
            })
        } else {
            UIView.animateKeyframes(
                withDuration: 2.0, delay: 0, options: .calculationModeCubic,
                animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/9) {
                        self.hideControlViews()
                    }
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2) {
                        self.originalScrollView.layer.transform = AnimationHelper.yRotation(.pi / 2)
                        
                    }
                    UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2) {
                        self.editedImageView.layer.transform = CATransform3DIdentity
                        self.captionLabel.layer.transform = CATransform3DIdentity
                    }
                    UIView.addKeyframe(withRelativeStartTime: 9/10, relativeDuration: 1/10) {
                        self.showControlViews()
                    }
            }, completion: { (bool) in
                self.view.isUserInteractionEnabled = true
                if bool {
                    self.isShowingEdited = true
                }
            })
        }
    }
    
    fileprivate func showRejectMoodDialog() {
        let dialog = AZDialogViewController(title: "Rejection mood?", message: nil,  titleFontSize: 22, buttonsHeight: 50)
        dialog.dismissWithOutsideTouch = false
        dialog.blurBackground = false
        dialog.buttonStyle = { (button,height,position) in
            button.setTitleColor(PINK_COLOR, for: .normal)
            button.titleLabel?.font = TEXT_FONT
            button.layer.masksToBounds = true
            button.layer.borderColor = PINK_COLOR.cgColor
        }
        
        for mood in ["😔😔😔", "😤😤😤", "😜😜😜", "😎😎😎"] {
            dialog.addAction(AZDialogAction(title: mood) { (dialog) -> (Void) in
                self.rejectImageMessage(shouldSendNotification: true, additionalText: mood)
                dialog.dismiss()
            })
        }
        dialog.addAction(AZDialogAction(title: "No mood") { (dialog) -> (Void) in
            self.rejectImageMessage(shouldSendNotification: true, additionalText: "")
            dialog.dismiss()
        })
        dialog.show(in: self)
    }
}

extension ReceiverImageMessageController {
    fileprivate func likeImage(messageId: String, senderId: String, receiverId: String, likeType: String) {
        let batch = fireStoreRef.batch()
        let likeDoc = FIRRef.getMessageLikes().document(messageId)
        batch.setData(["type": likeType, "createdTime": Date(), "senderId": senderId, "receiverId": receiverId], forDocument: likeDoc)
        
        let messageDoc = FIRRef.getMessages().document(messageId)
        batch.updateData([MessageSchema.IS_LIKED: true], forDocument: messageDoc)
        
        batch.commit { error in
            if let error = error {
                AppHUD.error("Like error: " + error.localizedDescription, isDarkTheme: false)
                return
            }
            self.message?.isLiked = true
            AppHUD.success("Liked", isDarkTheme: false)
        }
        guard let message = self.message else { return }
        CurrentUser.getUser(completion: { (curUser, error) in
            if let curUser = curUser {
                NotificationHelper.createMessageNotification(messageId: messageId, message: message, receiverUserId: receiverId, type: .likeMessage, senderUser: curUser, text: nil, completion: { (_) in
                })
            }
        })
        
        Analytics.logEvent(LIKE_TYPE, parameters: ["type": likeType])
    }
    
    func rejectImageMessage(shouldSendNotification: Bool, additionalText: String?) {
        guard let messageId = message?.messageId  else { return }
        self.view.isUserInteractionEnabled = false
        message?.isAcknowledged = true
        FIRRef.getMessages()
            .document(messageId).updateData([MessageSchema.IS_DELETED: true, MessageSchema.IS_ACKNOWLEDGED: true, MessageSchema.ACKNOWLEDGE_TYPE: "Reject"]) { (error) in
                self.view.isUserInteractionEnabled = true
                if let error = error {
                    AppHUD.error("Failed to reject: " + error.localizedDescription, isDarkTheme: true)
                    return
                }
                
              
        }
        if shouldSendNotification {
            guard let message = self.message else { return }
            guard let notificationUser = self.senderUser else { return }
            CurrentUser.getUser(completion: { (curUser, error) in
                if let curUser = curUser {
                    NotificationHelper.createMessageNotification(messageId: messageId, message: message, receiverUserId: notificationUser.uid, type: .rejectMessage, senderUser: curUser, text: additionalText, completion: { (error) in
                        if let error = error {
                            AppHUD.error("Failed to send rejection: " + error.localizedDescription, isDarkTheme: true)
                        }
                    })
                }
            })
        }
        
        Analytics.logEvent(REJECT_MOOD, parameters: ["mood": additionalText ?? ""])
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func updateAllowOriginalTime( allowOriginalTime: Date) {
        guard let messageId = message?.messageId  else { return }
        let data = [MessageSchema.ALLOW_ORIGINAL_TIME: allowOriginalTime]
        FIRRef.getMessages()
            .document(messageId).updateData(data) { (error) in
                if let error = error {
                    AppHUD.error(error.localizedDescription,  isDarkTheme: false)
                    return
                }
        }
    }
    
    func acceptImageMessage(isOriginalViewed: Bool, allowOriginalTime: Date?=nil) {
        guard let messageId = message?.messageId  else { return }
        self.message?.isAcknowledged = true
        self.message?.isOriginalViewed = isOriginalViewed
        var data = [MessageSchema.IS_ACKNOWLEDGED: true,
                    MessageSchema.ACKNOWLEDGE_TYPE: "Accept",
                    MessageSchema.IS_ORIGINAL_VIEWED: isOriginalViewed] as [String : Any]
        if let time =  allowOriginalTime {
            data[MessageSchema.ALLOW_ORIGINAL_TIME] = time
        }
        FIRRef.getMessages()
            .document(messageId).updateData(data) { (error) in
                if let error = error {
                    AppHUD.error("Error connecting database: " + error.localizedDescription,  isDarkTheme: false)
                    return
                }
        }
    }
    
    fileprivate func requestAccess(messageId: String, receiverUserId: String, mood: String) {
        guard let message = self.message else { return }
        CurrentUser.getUser { (curUser, error) in
            if let curUser = curUser {
                NotificationHelper.createMessageNotification(messageId: messageId, message: message, receiverUserId: receiverUserId, type: .requestAccess, senderUser: curUser, text: mood, completion: { (error) in
                    if let error = error {
                        AppHUD.error("Error sending request: \(error.localizedDescription). Please try again.", isDarkTheme: false)
                        return
                    }
                })
                FIRRef.getHasSentRequest().document(messageId).setData(["createdTime": Date()])
                AppHUD.success("Request sent", isDarkTheme: false)
            } else if let error = error {
                AppHUD.error("Error retrieving current user \(error.localizedDescription).", isDarkTheme: false)
            }
        }
        
        Analytics.logEvent(REQUEST_MOOD, parameters: ["mood": mood])
    }
}

// MARK: actions
extension ReceiverImageMessageController {
    @objc func handleShowOriginalImage() {
        guard let message = self.message else {
            return
        }

        let allowOriginal = message.allowOriginal
        let countDownInterval = message.countDown
        
        let now = Date()
        let allowOriginalTime: Date
        if let time = message.allowOriginalTime {
            allowOriginalTime = time
        } else {
            allowOriginalTime = now.addingTimeInterval(TimeInterval(countDownInterval))
            self.message?.allowOriginalTime = allowOriginalTime
        }
        let timeInterval = allowOriginalTime.timeIntervalSince(now)
        // less than one minute show it directly
        if (allowOriginal && timeInterval <= 0)  {
            if !message.isAcknowledged || !message.isOriginalViewed {
                self.acceptImageMessage(isOriginalViewed: true)
            }
            self.originalImageView.isHidden = false
            self.rotateToOriginalFirstTime()
            self.message?.isOriginalViewed = true
        } else if allowOriginal && timeInterval > 0 {
            if !message.isAcknowledged {
                self.acceptImageMessage(isOriginalViewed: false, allowOriginalTime: allowOriginalTime)
            }
            
            let view = JSSAlertView().show(self, title: "Counting down...", text: "HidingChat will reveal after:",
                                           buttonText: "I'll wait",color: DEEP_PURPLE_COLOR_LIGHT, timeLeft: UInt(timeInterval))
            view.setTextFont(APP_FONT)
            view.setTimerFont(APP_FONT)
            view.setTitleFont(APP_FONT_BOLD)
            view.setTextTheme(.light)
        } else if !allowOriginal {
            AppHUD.custom("Not allowed at current time. Try requesting access.", img: #imageLiteral(resourceName: "tongue"))
            self.acceptImageMessage(isOriginalViewed: false)
            self.controlPanel.addSubview(requestControl)
            requestControl.alpha = 1
            requestControl.frame = showOriginalControl.frame
            UIView.transition(from: showOriginalControl, to: requestControl, duration: 0.5, options: .transitionFlipFromTop, completion: nil)
        }
        
        Analytics.logEvent(ACCEPT_TAPPED, parameters: nil)
    }
    
    func addSwipeDown() {
        let down = UISwipeGestureRecognizer(target: self, action: #selector(navBack))
        down.direction = .down
        view.addGestureRecognizer(down)
    }
    
    @objc func navBack() {
        if let nav = navigationController {
            nav.isNavigationBarHidden = false
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func handleLikeImage() {
        guard let messageId = message?.messageId else { return }
        guard let receiverUid = self.senderUser?.uid else { return }
        guard let senderId = Auth.auth().currentUser?.uid else { return }
        if let liked = message?.isLiked, liked {
            AppHUD.success("Already liked", isDarkTheme: false)
            return
        }
        self.likeControl.itemButton.isEnabled = false
        let dialog = AZDialogViewController(title: "Like type?", message: nil, verticalSpacing: -1, buttonSpacing: 10, sideSpacing: 20, titleFontSize: 22, messageFontSize: 0, buttonsHeight: 50)
        dialog.dismissWithOutsideTouch = false
        dialog.blurBackground = false
        dialog.imageHandler = { (imageView) in
            imageView.image = UIImage.fontAwesomeIcon(name: .heart, textColor: PINK_COLOR, size: CGSize(width: 50, height: 50))
            imageView.backgroundColor = PINK_COLOR_LIGHT
            imageView.contentMode = .center
            return true //must return true, otherwise image won't show.
        }
        dialog.buttonStyle = { (button,height,position) in
            button.setTitleColor(PURPLE_COLOR, for: .normal)
            button.titleLabel?.font = TEXT_FONT
            button.layer.masksToBounds = true
            button.layer.borderColor = PURPLE_COLOR.cgColor
        }
        for liketype in ["♥️♥️♥️","😍😍😍", "😂😂😂", "😐😐😐"] {
            dialog.addAction(AZDialogAction(title: liketype) { (dialog) -> (Void) in
                self.likeImage(messageId: messageId,  senderId: senderId, receiverId: receiverUid, likeType: liketype)
                dialog.dismiss()
            })
        }
        dialog.show(in: self)
    }
    
    @objc func handleRejectImage() {
        let dialog = AZDialogViewController(title: "Reject", message: "Do you want to send your rejection back?",  titleFontSize: 22, messageFontSize: 15, buttonsHeight: 50, cancelButtonHeight: 50)
        dialog.cancelTitle = "Cancel"
        dialog.cancelEnabled = true
        dialog.cancelButtonStyle = { (button,height) in
            button.setTitleColor(PINK_COLOR, for: .normal)
            button.titleLabel?.font = TEXT_FONT
            return true
        }
        dialog.buttonStyle = { (button,height,position) in
            button.setTitleColor(PINK_COLOR, for: .normal)
            button.titleLabel?.font = TEXT_FONT
            button.layer.masksToBounds = true
            button.layer.borderColor = PINK_COLOR.cgColor
        }
        dialog.dismissWithOutsideTouch = false
        dialog.blurBackground = false
        dialog.addAction(AZDialogAction(title: "Yes, send") { (dialog) -> (Void) in
            dialog.removeAllActions()
            dialog.title = "Rejection Mood?"
            dialog.message = nil
            for mood in ["😔😔😔", "😤😤😤", "😜😜😜", "😎😎😎"] {
                dialog.addAction(AZDialogAction(title: mood) { (dialog) -> (Void) in
                    self.rejectImageMessage(shouldSendNotification: true, additionalText: mood)
                    dialog.dismiss()
                })
            }
            dialog.addAction(AZDialogAction(title: "No mood") { (dialog) -> (Void) in
                self.rejectImageMessage(shouldSendNotification: true, additionalText: "")
                dialog.dismiss()
            })
        })
        dialog.addAction(AZDialogAction(title: "No, don't send") { (dialog) -> (Void) in
            self.rejectImageMessage(shouldSendNotification: false, additionalText: nil)
            dialog.dismiss()
        })
        dialog.show(in: self)
        
        Analytics.logEvent(REJECT_TAPPED, parameters: nil)
    }
    
    @objc func handleRequestAccess() {
        guard let messageId = message?.messageId else { return }
        guard let notificationUser = self.senderUser else { return }
        self.requestControl.itemButton.isEnabled = false
        FIRRef.getHasSentRequest().document(messageId).getDocument { (snap, error) in
            if let error = error {
                AppHUD.error("Error retrieving request: " + error.localizedDescription, isDarkTheme: false)
                return
            }
            if let data = snap?.data(),
               let time = data["createdTime"] as? Date,
               Date().timeIntervalSince1970 - time.timeIntervalSince1970 < 600 {
                AppHUD.success("Request already sent. Please wait 10 minutes.", isDarkTheme: false)
                return
            } else {
                let dialog = AZDialogViewController(title: "Request mood?", titleFontSize: 22, messageFontSize: 14, buttonsHeight: 50)
                dialog.dismissWithOutsideTouch = false
                dialog.blurBackground = false
                dialog.buttonStyle = { (button,height,position) in
                    button.setTitleColor(BLUE_COLOR, for: .normal)
                    button.titleLabel?.font = TEXT_FONT
                    button.layer.masksToBounds = true
                    button.layer.borderColor = BLUE_COLOR.cgColor
                }
                
                for title in [ "😔😔😔", "☹️☹️☹️", "😎😎😎", "😍😍😍"] {
                    dialog.addAction(AZDialogAction(title: title) { (dialog) -> (Void) in
                        self.requestAccess(messageId: messageId, receiverUserId: notificationUser.uid, mood: title)
                        dialog.dismiss()
                    })
                }
                dialog.addAction(AZDialogAction(title: "Custom") { (dialog) -> (Void) in
                    dialog.dismiss(animated: true, completion: {
                        let alert = SCLAlertView(appearance: SCLAlertView.getAppearance())
                        let textView = alert.addTextView()
                        textView.layer.cornerRadius = 5.0
                        alert.addButton("Send", backgroundColor: BLUE_COLOR, textColor: UIColor.white) {
                            textView.resignFirstResponder()
                            let mood = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
                            if mood.count > 100  {
                                AppHUD.error("Please keep it under 100 emojis.", isDarkTheme: true)
                            } else if !mood.containsOnlyEmoji {
                                AppHUD.error("Please only use emojis.", isDarkTheme: true)
                            } else {
                                self.requestAccess(messageId: messageId, receiverUserId: notificationUser.uid, mood: mood)
                                alert.hideView()
                            }
                        }
                        let image = UIImage.fontAwesomeIcon(name: .pencil, textColor: .white, size: CGSize(width: 40, height: 40))
                        alert.showCustom("Request mood", subTitle: "(please only use emojis)", color: BLUE_COLOR, icon: image)
                    })
                })
                dialog.show(in: self)
            }
        }
    }
    
    @objc func toggleControlPanel() {
        view.isUserInteractionEnabled = false
        if isShowingControlPanel {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                self.hideControlViews()
                self.hideCaptionLabel()
            }) { (bool) in
                self.view.isUserInteractionEnabled = true
                if bool {
                    self.isShowingControlPanel = false
                }
            }
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.showControlViews()
                self.showCaptionLabel()
            }, completion: { (bool) in
                self.view.isUserInteractionEnabled = true
                if bool {
                    self.isShowingControlPanel = true
                }
            })
        }
    }
}

//MARK: scroll view delegate
extension ReceiverImageMessageController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return originalImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let Ws = scrollView.frame.size.width - scrollView.contentInset.left - scrollView.contentInset.right
        let Hs = scrollView.frame.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom
        let W = originalImageView.frame.size.width
        let H = originalImageView.frame.size.height
        
        var rct = originalImageView.frame
        rct.origin.x = max((Ws - W) / 2, 0)
        rct.origin.y = max((Hs - H) / 2, 0)
        originalImageView.frame = rct
    }
    
    fileprivate func resetOriginalImageViewFrame() {
        var size: CGSize = originalImageView.frame.size
        if let imageSize = originalImageView.image?.size  {
            size = imageSize
        }
        if size.width > 0 && size.height > 0 {
            let ratio: CGFloat = min(originalScrollView.frame.size.width / size.width, originalScrollView.frame.size.height / size.height)
            let W = ratio * size.width * originalScrollView.zoomScale
            let H = ratio * size.height * originalScrollView.zoomScale
            originalImageView.frame = CGRect(x: max(0, (originalScrollView.width - W) / 2), y: max(0, (originalScrollView.height - H) / 2), width: W, height: H)
        }
    }
    
    fileprivate func resetOriginalZoomScale(animated: Bool) {
        var wR = originalScrollView.frame.size.width / originalImageView.frame.size.width
        var hR = originalScrollView.frame.size.height / originalImageView.frame.size.height
        
        let scale: CGFloat = 1
        if let img = originalImageView.image {
            wR = max(wR, img.size.width / (scale * originalScrollView.frame.size.width))
            hR = max(hR, img.size.height / (scale * originalScrollView.frame.size.height))
        }
        
        originalScrollView.contentSize = originalImageView.frame.size
        originalScrollView.minimumZoomScale = 1
        originalScrollView.maximumZoomScale = max(max(wR, hR), 1)
        
        originalScrollView.setZoomScale(originalScrollView.minimumZoomScale, animated: animated)
    }
    
    func refreshOriginalImageView() {
        self.resetOriginalImageViewFrame()
        self.resetOriginalZoomScale(animated: false)
    }
}
