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
import KOAlertController

class ReceiverImageMessageController : UIViewController{
    private let controlPanelHeight: CGFloat = 80.0
    private let controlPanelAlpha: CGFloat = 1.0

    let fireStoreRef = Firestore.firestore()
    private var isShowingEdited = true
    private var isShowingControlPanel = true
    var senderUser: User?
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
                
                if !message.caption.trimmingCharacters(in: .whitespaces).isEmpty {
                    setupCaptionLabel()
                }
            }
        }
    }
    
    fileprivate func setupCaptionLabel() {
        guard let caption = message?.caption else { return }
        captionLabel.text = caption
        view.addSubview(captionLabel)
        let rect = NSString(string: caption).boundingRect(with: CGSize(width:view.width, height:999), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize:CGFloat(14))], context: nil).size
        print(rect)
        let height = max(rect.height + 16.0, 40)
        captionLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: height)
        captionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
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
        lb.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        lb.textColor = .white
        lb.numberOfLines = 0
        lb.font = UIFont.systemFont(ofSize:CGFloat(14))
        return lb
    }()
    
    
    lazy var controlPanel: UIView = {
        let frame = CGRect(x: 0, y: UIScreen.main.bounds.height - self.controlPanelHeight, width: UIScreen.main.bounds.width, height: self.controlPanelHeight)
        let panel = UIView(frame: frame)
        panel.backgroundColor = .clear

        return panel
    }()
    
    let showOriginalControl: ControlItemView = {
        let size = CGSize(width: 44, height: 44)
        let green = UIColor.rgb(red: 56, green: 142, blue: 60, alpha: 1)
        let info = ControlItemInfo(image: UIImage.fontAwesomeIcon(name: .thumbsUp, textColor: green, size: size), backgroundColor: UIColor.rgb(red: 165, green: 214, blue: 167, alpha: 0.9), textColor: green, itemText: "Yes, show")
        let control = ControlItemView(target: self, action: #selector(handleShowOriginalImage))
        control.itemInfo = info
        control.alpha = 0
        
        return control
    }()
    
    let rejectControl: ControlItemView = {
        let size = CGSize(width: 44, height: 44)
        let red = UIColor.rgb(red: 211, green: 47, blue: 47, alpha: 1)
        let info = ControlItemInfo(image: UIImage.fontAwesomeIcon(name: .thumbsDown, textColor: red, size: size), backgroundColor: UIColor.rgb(red: 239, green: 154, blue: 154, alpha: 0.9), textColor: red, itemText: "No, reject")
        let control = ControlItemView(target: self, action: #selector(handleRejectImage))
        control.itemInfo = info
        control.alpha = 0
        
        return control
    }()
    
    let requestControl: ControlItemView = {
        let size = CGSize(width: 44, height: 44)
        let purple = UIColor.rgb(red: 81, green: 45, blue: 168, alpha: 1)
        let info = ControlItemInfo(image: UIImage.fontAwesomeIcon(name: .user, textColor: purple, size: size), backgroundColor:  UIColor.rgb(red: 179, green: 157, blue: 219, alpha: 0.9), textColor: purple, itemText: "Request Access")
        let control = ControlItemView(target: self, action: #selector(handleRequestAccess))
        control.itemInfo = info
        control.alpha = 0
        
        return control
    }()
    
    let viewImageControl: ControlItemView = {
        let size = CGSize(width: 44, height: 44)
        let blue = UIColor.rgb(red: 25, green: 118, blue: 210, alpha: 1)
        let info = ControlItemInfo(image: UIImage.fontAwesomeIcon(name: .eye, textColor: blue, size: size), backgroundColor: UIColor.rgb(red: 144, green: 202, blue: 249, alpha: 0.9), textColor: blue, itemText: "View")
        let viewControl = ControlItemView(target: self, action: #selector(handleRotateImage))
        viewControl.itemInfo = info
        viewControl.alpha = 0
        
        return viewControl
    }()
    
    lazy var likeControl: ControlItemView = {
        let size = CGSize(width: 38, height: 38)
        let pink = UIColor.rgb(red: 194, green: 24, blue: 91, alpha: 1)
        let info = ControlItemInfo(image: UIImage.fontAwesomeIcon(name: .heart, textColor: pink, size: size), backgroundColor: UIColor.rgb(red: 244, green: 143, blue: 177, alpha: 0.9), textColor: pink, itemText: "Like")
        let viewControl = ControlItemView(target: self, action: #selector(handleLikeImage))
        let likeBtn = FaveButton(frame:  CGRect(x: 0, y: 0, width: 50, height: 50), faveIconNormal: UIImage.fontAwesomeIcon(name: .heart, textColor: pink, size: size))
        likeBtn.dotSecondColor = RED_COLOR
        likeBtn.dotFirstColor = YELLOW_COLOR
        likeBtn.selectedColor = pink
        viewControl.itemButton = likeBtn
        viewControl.addSubview(viewControl.itemButton)
        viewControl.itemButton.isSelected  = self.message?.isLiked ?? false
    
        viewControl.itemButton.addTarget(self, action: #selector(handleLikeImage), for: .touchUpInside)
        viewControl.itemButton.layer.cornerRadius = 25
        viewControl.itemButton.layer.masksToBounds = true
        
        viewControl.itemInfo = info
        viewControl.alpha = 0
        viewControl.setupConstraints()
        if let liked = self.message?.isLiked {
            viewControl.itemButton.isSelected  = liked
            if liked {
                viewControl.isUserInteractionEnabled = false
            }
        } else {
            viewControl.itemButton.isSelected = false
        }
        return viewControl
    }()
    
    @objc func handleLikeImage() {
        print("************************debugging", "like tapped")
        guard let messageId = message?.messageId else { return }
        guard let receiverUid = self.senderUser?.uid else { return }
        if let liked = message?.isLiked, liked {
            AppHUD.success("Already liked", isDarkTheme: false)
            return
        }
        self.likeControl.itemButton.isEnabled = false
        
        let alert = KOAlertController("How do you like it?", nil, UIImage.fontAwesomeIcon(name: .heart, textColor: PINK_COLOR, size: CGSize(width: 60, height: 60)))
        
        let niceButton = KOAlertButtonUtil.getAppButton(title: "")
        niceButton.title = "😍Nice"
        let creativeButton = KOAlertButtonUtil.getAppButton(title: "")
        creativeButton.title = "😍Creative"
        let underwhelmedButton = KOAlertButtonUtil.getAppButton(title: "")
        underwhelmedButton.title = "😐Underwhelmed"
        
        alert.style = configureAlertStyle()
        alert.addAction(niceButton) {
            print("Action:nice")
            self.likeImage(messageId: messageId, receiverId: receiverUid, likeType: "😍Nice")
        }
        alert.addAction(creativeButton) {
            print("Action:creative")
            self.likeImage(messageId: messageId, receiverId: receiverUid, likeType: "😍Creative")
        }
        alert.addAction(underwhelmedButton) {
            print("Action:underwhelmed")
            self.likeImage(messageId: messageId, receiverId: receiverUid, likeType: "😐Underwhelmed")
        }
        self.present(alert, animated: true) {}
    }
    
    fileprivate func configureAlertStyle() -> KOAlertStyle {
        let style                       = KOAlertStyle()
        style.position = .center
        style.backgroundColor           = DEEP_PURPLE_COLOR_LIGHT
        style.cornerRadius              = 15
        style.titleColor                = UIColor.white
        style.titleFont                 = UIFont.systemFont(ofSize: 24)
        return style
    }
    
    fileprivate func likeImage(messageId: String, receiverId: String, likeType: String) {
        let batch = fireStoreRef.batch()
        let likeDoc = fireStoreRef.collection("messageLikes").document(messageId)
        batch.setData(["type": likeType, "createdTime": Date()], forDocument: likeDoc)
        
        let messageDoc = fireStoreRef.collection("imageMessages").document(messageId)
        batch.updateData([MessageSchema.IS_LIKED: true], forDocument: messageDoc)
        
        AppHUD.progress(nil, isDarkTheme: false)
        batch.commit { error in
            AppHUD.progressHidden()
            if let error = error {
                AppHUD.error(error.localizedDescription, isDarkTheme: false)
                return
            }
            self.message?.isLiked = true
            AppHUD.success("Liked", isDarkTheme: false)
            CurrentUser.getUser(completion: { (curUser, error) in
                if let curUser = curUser {
                    NotificationHelper.createMessageNotification(messageId: messageId, receiverUserId: receiverId, type: .likeMessage, senderUser: curUser, text: nil, completion: { (_) in
                    })
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        setupScrollView()
        setupImageView()
        AnimationHelper.perspectiveTransform(for: view)
        originalScrollView.layer.transform = AnimationHelper.yRotation(.pi / 2)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleControlPanel))
        view.addGestureRecognizer(tapRecognizer)
        
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(navBack))
        swipeRecognizer.direction = .down
        view.addGestureRecognizer(swipeRecognizer)
    }
    
    @objc func navBack() {
        navigationController?.isNavigationBarHidden = false
        navigationController?.popViewController(animated: true)
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
    
    fileprivate func setupControlPanel(message: Message) {
        view.addSubview(controlPanel)
    
        if !message.isAcknowledged {
            print("not ack, show yes and no")
            addButtonsToControlPanel(leftControl: showOriginalControl, rightControl: rejectControl)
        } else {
            if message.allowOriginal {
                print("allowed, show like and view")
                addButtonsToControlPanel(leftControl: likeControl, rightControl: viewImageControl)
            } else {
                print("not allowed, show request and view")
                addButtonsToControlPanel(leftControl: requestControl, rightControl: rejectControl)
            }
        }
    }
    
    fileprivate func addButtonsToControlPanel(leftControl: ControlItemView, rightControl: ControlItemView) {
        for view in self.controlPanel.subviews {
            view.removeFromSuperview()
        }
        controlPanel.addSubview(leftControl)
        controlPanel.addSubview(rightControl)
        leftControl.anchor(top: controlPanel.topAnchor, left: controlPanel.leftAnchor, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 32, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        rightControl.anchor(top: controlPanel.topAnchor, left: nil, bottom: nil, right: controlPanel.rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 32, width: 50, height: 50)
        
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
        //isShowingEdited = false
        view.isUserInteractionEnabled = false
        self.likeControl.frame = self.showOriginalControl.frame
        self.viewImageControl.frame = self.rejectControl.frame
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
            //isShowingEdited = false
            UIView.animateKeyframes(
                withDuration: 2.0, delay: 0, options: .calculationModeCubic,
                animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/9) {
                        self.hideControlViews()
                        //self.hideCaptionLabel()
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
//            isShowingEdited = true
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
                        //self.showCaptionLabel()
                    }
            }, completion: { (bool) in
                self.view.isUserInteractionEnabled = true
                if bool {
                    self.isShowingEdited = true
                }
            })
        }
    }
}

extension ReceiverImageMessageController {
    @objc func handleShowOriginalImage() {
        guard let allowOriginal = message?.allowOriginal else { return }
        if allowOriginal {
            self.originalImageView.isHidden = false
            self.acceptImageMessage(isOriginalViewed: true)
            self.rotateToOriginalFirstTime()
        } else {
            self.acceptImageMessage(isOriginalViewed: false)
            self.controlPanel.addSubview(requestControl)
            requestControl.alpha = 1
            requestControl.frame = showOriginalControl.frame
            UIView.transition(from: showOriginalControl, to: requestControl, duration: 0.5, options: .transitionFlipFromTop, completion: nil)
            
        }
    }
    
    func rejectImageMessage(shouldSendNotification: Bool, additionalText: String?) {
        guard let messageId = message?.messageId  else { return }
        self.view.isUserInteractionEnabled = false
        message?.isAcknowledged = true
        fireStoreRef.collection("imageMessages")
            .document(messageId).updateData([MessageSchema.IS_DELETED: true, MessageSchema.IS_ACKNOWLEDGED: true, MessageSchema.ACKNOWLEDGE_TYPE: "Reject"]) { (error) in
                self.view.isUserInteractionEnabled = true
                if let error = error {
                    AppHUD.error(error.localizedDescription, isDarkTheme: true)
                    return
                }
    
                if shouldSendNotification {
                    guard let notificationUser = self.senderUser else { return }
                    CurrentUser.getUser(completion: { (curUser, error) in
                        if let curUser = curUser {
                            NotificationHelper.createMessageNotification(messageId: messageId, receiverUserId: notificationUser.uid, type: .rejectMessage, senderUser: curUser, text: additionalText, completion: { (error) in
                                if let error = error {
                                    print(error.localizedDescription)
                                }
                            })
                        }
                    })
                    
                }
                self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func acceptImageMessage(isOriginalViewed: Bool) {
        guard let messageId = message?.messageId  else { return }
        message?.isAcknowledged = true
        print("************************debugging", "accept")
        let data = [MessageSchema.IS_ACKNOWLEDGED: true,
                    MessageSchema.ACKNOWLEDGE_TYPE: "Accept",
                    MessageSchema.IS_ORIGINAL_VIEWED: isOriginalViewed] as [String : Any]
        fireStoreRef.collection("imageMessages")
            .document(messageId).updateData(data) { (error) in
                if let error = error {
                    AppHUD.error(error.localizedDescription,  isDarkTheme: false)
                    return
                }
                print("************************debugging", "accept", "success")
        }
    }
    
    @objc func handleRejectImage() {
        let senderName = self.senderUser?.username ?? ""
        let alert = UIAlertController(title: nil, message: "Do you want to notify \(senderName) your rejection?", preferredStyle: .alert)
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
    
    @objc func handleRequestAccess() {
        guard let messageId = message?.messageId else { return }
        guard let notificationUser = self.senderUser else { return }
        self.requestControl.itemButton.isEnabled = false
        AppHUD.progress(nil, isDarkTheme: false)
        Firestore.firestore().collection("hasSentRequest").document(messageId).getDocument { (snap, error) in
            if let error = error {
                AppHUD.progressHidden()
                AppHUD.error(error.localizedDescription, isDarkTheme: false)
                return
            }
            if let _ = snap?.data() {
                AppHUD.progressHidden()
                AppHUD.error("Request already sent", isDarkTheme: false)
                return
            } else {
                CurrentUser.getUser { (curUser, error) in
                    if let curUser = curUser {
                        NotificationHelper.createMessageNotification(messageId: messageId, receiverUserId: notificationUser.uid, type: .requestAccess, senderUser: curUser, text: nil, completion: { (error) in
                            if let error = error {
                                AppHUD.progressHidden()
                                AppHUD.error(error.localizedDescription, isDarkTheme: false)
                                return
                            } else {
                                AppHUD.progressHidden()
                                AppHUD.success("Request sent", isDarkTheme: false)
                                Firestore.firestore().collection("hasSentRequest").document(messageId).setData(["date": Date()])
                            }
                        })
                    } else if let _ = error {
                        AppHUD.progressHidden()
                        AppHUD.error("Error retrieving current user", isDarkTheme: false)
                    }
                }
            }
        }
    }
}

//MARK: scroll view funcs
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
