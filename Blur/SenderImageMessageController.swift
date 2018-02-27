//
//  SenderImageMessageController.swift
//  Blur
//
//  Created by xiandong wang on 1/2/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class SenderImageMessageController: UIViewController, UINavigationControllerDelegate {
    let fireStoreRef = Firestore.firestore()
    var listener: ListenerRegistration?
    private let controlSidePadding: CGFloat = UIScreen.main.bounds.width / 4.0 - 35
    let heartImg = UIImage.fontAwesomeIcon(name: .heart, textColor: PINK_COLOR, size: CGSize(width: 44, height: 44))
    
    private var isShowingEdited = true
    private var isShowingControlPanel = true
    
    var likeType: String? {
        didSet {
            setupLikeImage()
        }
    }
    
    var receiverUser: User? {
        didSet {
            if let receiverUser = receiverUser {
                self.navigationItem.title = "Sent to \(receiverUser.username)"
            }
        }
    }
    
    var message: Message? {
        didSet {
            if let message = message {
                let editedUrl = URL(string: message.editedImageUrl)
                editedImageView.kf.indicatorType = .activity
                editedImageView.kf.setImage(with: editedUrl, placeholder:#imageLiteral(resourceName: "image_bg_512"), options: nil, progressBlock: nil, completionHandler: nil)
                let originalUrl = URL(string: message.originalImageUrl)
                originalImageView.kf.indicatorType = .activity
                originalImageView.kf.setImage(with: originalUrl, placeholder:#imageLiteral(resourceName: "image_bg_512"), options: nil, progressBlock: nil, completionHandler: nil)
              
                setupControls()
                
                let receiverId = message.receiverId
                getUserData(uid: receiverId)
                
                self.listener = self.fireStoreRef.collection("messageLikes").document(message.messageId)
                    .addSnapshotListener({ (snap, error) in
                        if let snapData = snap?.data() {
                            print(snapData)
                            if let type = snapData["type"] as? String {
                                self.likeType = type
                            }
                        }
                })
                
                if !message.caption.trimmingCharacters(in: .whitespaces).isEmpty {
                    setupCaptionLabel()
                }
            }
        }
    }
    
    deinit {
        self.listener?.remove()
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
    
    func setupLikeImage() {
        print("************************debugging")
        view.addSubview(likeButton)
        likeButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 44, height: 44)
        likeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        likeButton.centerYAnchor.constraint(equalTo: viewImageControl.centerYAnchor).isActive = true
    }
    
    @objc func handleShowLikeType() {
        print("like tapped", "😊")
        guard let likeType = self.likeType else { return }
        AppHUD.custom(likeType, img: heartImg)
        return
    }
    
    let captionLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        lb.textColor = .white
        lb.numberOfLines = 0
        lb.font = UIFont.systemFont(ofSize:CGFloat(14))
        return lb
    }()
    
    lazy var likeButton: UIButton = {
        let bt = UIButton()
        bt.setImage(heartImg, for: .normal)
        bt.addTarget(self, action: #selector(handleShowLikeType), for: .touchUpInside)
        return bt
    }()
    
    let editedImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let originalImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    var originalScrollView: UIScrollView = {
        let sv = UIScrollView()
        return sv
    }()
    
    lazy var allowAccessControl: ControlItemView = {
        let size = CGSize(width: 44, height: 44)
        let green = UIColor.rgb(red: 56, green: 142, blue: 60, alpha: 1)
        let info = ControlItemInfo(image: UIImage.fontAwesomeIcon(name: .unlockAlt, textColor: green, size: size), backgroundColor: UIColor.rgb(red: 165, green: 214, blue: 167, alpha: 0.9), textColor: green, itemText: "Allow access")
        let allowControl = ControlItemView(target: self, action: #selector(handleAllowAccess))
        allowControl.itemInfo = info
        allowControl.alpha = 0

        return allowControl
    }()
    
    lazy var viewImageControl: ControlItemView = {
        let size = CGSize(width: 44, height: 44)
        let blue = UIColor.rgb(red: 25, green: 118, blue: 210, alpha: 1)
        let info = ControlItemInfo(image: UIImage.fontAwesomeIcon(name: .eye, textColor: blue, size: size), backgroundColor: UIColor.rgb(red: 144, green: 202, blue: 249, alpha: 0.9), textColor: blue, itemText: "View")
        let viewControl = ControlItemView(target: self, action: #selector(handleRotateImage))
        viewControl.itemInfo = info
        viewControl.alpha = 0
        
        return viewControl
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        setupScrollView()
        setupImageView()
        AnimationHelper.perspectiveTransform(for: view)
        setupGestures()
        setupControls()
    }
    
    func setupControls() {
        view.addSubview(allowAccessControl)
        allowAccessControl.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: controlSidePadding, paddingBottom: 40, paddingRight: 0, width: 60, height: 60)
        
        view.addSubview(viewImageControl)
        viewImageControl.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 40, paddingRight: controlSidePadding, width: 60, height: 60)
        
        UIView.animate(withDuration: 1, delay: 0.3, options: [.showHideTransitionViews], animations: {
            self.showControlViews()
        }, completion: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        self.navigationController?.navigationBar.barTintColor = YELLOW_COLOR
        self.navigationController?.navigationBar.isTranslucent = false
        
        super.viewWillDisappear(animated)
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
    
    fileprivate func setupGestures() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleControlPanel))
        view.addGestureRecognizer(tapRecognizer)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(navBack))
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(rightSwipe)
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            self.navigationController?.navigationBar.alpha = 1
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        }
    }
    
    @objc func navBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func handleAllowAccess() {
        guard let receiverUser = receiverUser else { return }
        guard let messageId = message?.messageId else { return }
        if let allow = message?.allowOriginal, allow {
            AppHUD.success("Already allowed", isDarkTheme: false)
            return
        }
        AppHUD.progress(nil, isDarkTheme: false)
        self.allowAccessControl.itemButton.isEnabled = false
        
        self.fireStoreRef.collection("hasAllowedAccess").document(messageId).getDocument { (snap, error) in
            if let error = error {
                AppHUD.progressHidden()
                AppHUD.error(error.localizedDescription, isDarkTheme: false)
                return
            }
            if let _ = snap?.data() {
                AppHUD.progressHidden()
                AppHUD.success("Already allowed", isDarkTheme: false)
                return
            } else {
                self.allowAccess(messageId: messageId, receiverUser: receiverUser)
            }
        }
    }
    
    fileprivate func allowAccess(messageId: String, receiverUser: User) {
        fireStoreRef.collection("imageMessages").document(messageId).updateData([MessageSchema.ALLOW_ORIGINAL: true]) { (error) in
            if let error = error {
                AppHUD.progressHidden()
                AppHUD.error(error.localizedDescription, isDarkTheme: false)
                return
            }
            CurrentUser.getUser(completion: { (senderUser, error) in
                if let senderUser = senderUser {
                    NotificationHelper.createMessageNotification(messageId: messageId, receiverUserId: receiverUser.uid, type: .allowAccess, senderUser: senderUser, text: nil, completion: { (error) in
                        if error == nil {
                            AppHUD.progressHidden()
                            AppHUD.success("Access allowed", isDarkTheme: false)
                            self.fireStoreRef.collection("hasAllowedAccess").document(messageId).setData(["date": Date()])
                        } else {
                            AppHUD.progressHidden()
                            AppHUD.error(error?.localizedDescription, isDarkTheme: false)
                        }
                    })
                }
            })
        }
    }
    
    fileprivate func hideControlViews() {
        for v in [allowAccessControl, viewImageControl, likeButton] as [UIView] {
            v.alpha = 0
        }
        self.navigationController?.navigationBar.alpha = 0
    }
    
    fileprivate func showControlViews() {
        for v in [allowAccessControl, viewImageControl, likeButton] as [UIView] {
            v.alpha = 1
        }
        self.navigationController?.navigationBar.alpha = 1
    }
    
    @objc func toggleControlPanel() {
        view.isUserInteractionEnabled = false
        if isShowingControlPanel {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                self.hideControlViews()
                self.captionLabel.alpha = 0
            }) { (bool) in
                self.view.isUserInteractionEnabled = true
                if bool {
                    self.isShowingControlPanel = false
                }
            }
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.showControlViews()
                self.captionLabel.alpha = 1
            }, completion: { (bool) in
                self.view.isUserInteractionEnabled = true
                if bool {
                    self.isShowingControlPanel = true
                }
            })
        }
    }
    
    fileprivate func setupImageView() {
        view.addSubview(editedImageView)
        editedImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    @objc func handleRotateImage() {
        animateRotatingImage(toOriginal: isShowingEdited)
    }

    fileprivate func animateRotatingImage(toOriginal: Bool) {
        if toOriginal {
            isShowingEdited = false
            UIView.animateKeyframes(
                withDuration: 2.0, delay: 0, options: .calculationModeCubic,
                animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/9) {
                        self.hideControlViews()
                    }
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2) {
                        self.editedImageView.layer.transform = AnimationHelper.yRotation(-.pi / 2)
                        self.captionLabel.layer.transform = AnimationHelper.yRotation(-.pi / 2)
                    }
                    UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2) {
                        self.originalScrollView.layer.transform = AnimationHelper.yRotation(0.0)
                        self.refreshOriginalImageView()
                    }
                    UIView.addKeyframe(withRelativeStartTime: 9/10, relativeDuration: 1/10) {
                        self.showControlViews()
                    }
            }, completion: nil)
            
        } else {
            isShowingEdited = true
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
            }, completion: nil)
        }
    }
    
    func getUserData(uid senderId: String) {
        Database.getUser(uid: senderId) { (user, error) in
            if let error = error {
                AppHUD.error(error.localizedDescription, isDarkTheme: false)
                return
            } else if let user = user {
                self.receiverUser = user
            }
        }
    }
}

extension SenderImageMessageController: UIScrollViewDelegate {
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
}
