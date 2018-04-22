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

import FBSDKShareKit

class SenderImageMessageController: UIViewController, UINavigationControllerDelegate {
    
    fileprivate let controlPanelHeight: CGFloat = 96.0
    fileprivate let controlSidePadding: CGFloat = UIScreen.main.bounds.width / 4.0 - 35
    
    let fireStoreRef = Firestore.firestore()
    var listener: ListenerRegistration?
    
    fileprivate let heartImg = UIImage.fontAwesomeIcon(name: .heart, textColor: PINK_COLOR, size: CGSize(width: 44, height: 44))
    
    fileprivate var isShowingEdited = true
    fileprivate var isShowingControlPanel = true
    
    var likeType: String? {
        didSet {
            setupLikeImage()
        }
    }
    
    var receiverUser: User? {
        didSet {
            if let receiverUser = receiverUser {
                var title = "\(receiverUser.fullName)"
                if let message = self.message {
                    title += " • \(message.createdTime.timeAgoDisplay())"
                }
                self.navigationItem.title = title
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
                
                self.listener = FIRRef.getMessageLikes().document(message.messageId)
                    .addSnapshotListener({ (snap, error) in
                        if let snapData = snap?.data() {
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
        let rect = NSString(string: caption.trimmingCharacters(in: .whitespacesAndNewlines)).boundingRect(with: CGSize(width:view.width, height:999), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedStringKey.font: TEXT_FONT], context: nil).size

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
    }
    
     fileprivate func setupLikeImage() {
        controlPanel.addSubview(likeButton)
        likeButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 44, height: 44)
        likeButton.centerXAnchor.constraint(equalTo: controlPanel.centerXAnchor).isActive = true
        likeButton.centerYAnchor.constraint(equalTo: viewImageControl.centerYAnchor).isActive = true
    }
    
    @objc func handleShowLikeType() {
        guard let likeType = self.likeType else { return }
        AppHUD.custom(likeType, img: heartImg)
        return
    }
    
    let editedImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.kf.indicatorType = .activity
        return iv
    }()
    
    let originalImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.kf.indicatorType = .activity
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
        let padding = getSafePadding()
        let frame = CGRect(x: 0, y: UIScreen.main.bounds.height - self.controlPanelHeight - padding, width: UIScreen.main.bounds.width, height: self.controlPanelHeight + padding)
        let panel = UIView(frame: frame)
        panel.backgroundColor = .clear
        
        return panel
    }()
    
    func getSafePadding() -> CGFloat {
        if #available(iOS 11.0, *) {
            if let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom,
                bottomPadding > 0 {
                return 20.0
            }
        }
        return 0.0
    }
    
    
    lazy var likeButton: UIButton = {
        let bt = UIButton()
        bt.setImage(heartImg, for: .normal)
        bt.addTarget(self, action: #selector(handleShowLikeType), for: .touchUpInside)
        return bt
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
        let info = ControlItemInfo(image: UIImage.fontAwesomeIcon(name: .eye, textColor: blue, size: size), backgroundColor: UIColor.rgb(red: 144, green: 202, blue: 249, alpha: 0.9), textColor: blue, itemText: "Reveal")
        let viewControl = ControlItemView(target: self, action: #selector(handleRotateImage))
        viewControl.itemInfo = info
        viewControl.alpha = 0
        
        return viewControl
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        setupScrollView()
        setupEditedImageView()
        AnimationHelper.perspectiveTransform(for: view)
        setupGestures()
        setupControls()
        
        setupShare()
    }
    
    func setupShare() {
        let shareImg = UIImage.fontAwesomeIcon(name: .facebook, textColor: TINT_COLOR, size: CGSize(width: 30, height: 30))
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: shareImg, style: .plain, target: self, action: #selector(handleShare(_:)))]
    }
    
    @objc func handleShare(_ sender: AnyObject) {
        guard let editedImage = self.editedImageView.image, let originalImage = self.originalImageView.image else { return }
        
        
        let alert = UIAlertController(title: "Share on Facebook", message: "(Requires the Facebook app)", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Share hiding photo", style: .default, handler: { (_) in
            self.shareOnFacebook(editedImage)
        }))
        alert.addAction(UIAlertAction(title: "Share original photo", style: .default, handler: { (_) in
            self.shareOnFacebook(originalImage)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func shareOnFacebook(_ image: UIImage) {
        let photo = FBSDKSharePhoto(image: image, userGenerated: true)
        let content = FBSDKSharePhotoContent()
        content.photos = [photo as Any]
        content.contentURL = URL(string: ITUNES_URL)
        FBSDKShareDialog.show(from: self, with: content, delegate: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            self.navigationController?.navigationBar.alpha = 1
            self.navigationController?.navigationBar.isTranslucent = false
            self.setupNavTitleAttr()
            self.navigationController?.navigationBar.tintColor = UIColor.black
        }
    }
    
    fileprivate func setupGestures() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleControlPanel))
        view.addGestureRecognizer(tapRecognizer)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(navBack))
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(rightSwipe)
    }
    
    fileprivate func setupEditedImageView() {
        view.addSubview(editedImageView)
        editedImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    fileprivate func setupControls() {
        addControlsToControlPanel(leftControl: allowAccessControl, rightControl: viewImageControl)
    }
    
    fileprivate func addControlsToControlPanel(leftControl: ControlItemView, rightControl: ControlItemView) {
        view.addSubview(controlPanel)
        controlPanel.addSubview(leftControl)
        controlPanel.addSubview(rightControl)
        
        leftControl.anchor(top: controlPanel.topAnchor, left: controlPanel.leftAnchor, bottom: nil, right: nil, paddingTop: 4, paddingLeft: controlSidePadding, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        rightControl.anchor(top: controlPanel.topAnchor, left: nil, bottom: nil, right: controlPanel.rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: controlSidePadding, width: 50, height: 50)
        
        UIView.animate(withDuration: 0.5) {
            leftControl.alpha = 1
            rightControl.alpha = 1
        }
    }
    
    fileprivate func hideControlViews() {
        for v in controlPanel.subviews {
            v.alpha = 0
        }
        self.navigationController?.navigationBar.alpha = 0
    }
    
    fileprivate func showControlViews() {
        for v in controlPanel.subviews {
            v.alpha = 1
        }
        self.navigationController?.navigationBar.alpha = 1
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
}

//MARK: database
extension SenderImageMessageController {
    fileprivate func allowAccess(messageId: String, receiverUser: User) {
        FIRRef.getMessages().document(messageId).updateData([MessageSchema.ALLOW_ORIGINAL: true]) { (error) in
            if let error = error {
                AppHUD.progressHidden()
                AppHUD.error(error.localizedDescription, isDarkTheme: false)
                return
            }
            self.message?.allowOriginal = true
            guard let message = self.message else { return }
            CurrentUser.getUser(completion: { (senderUser, error) in
                if let senderUser = senderUser {
                    NotificationHelper.createMessageNotification(messageId: messageId, message: message,  receiverUserId: receiverUser.uid, type: .allowAccess, senderUser: senderUser, text: nil, completion: { (error) in
                        if error == nil {
                            AppHUD.progressHidden()
                            AppHUD.success("Access allowed", isDarkTheme: false)
                            FIRRef.getHasAllowedAccess().document(messageId).setData(["createdTime": Date()])
                        } else  {
                            AppHUD.progressHidden()
                            AppHUD.error(error?.localizedDescription, isDarkTheme: false)
                        }
                    })
                }
            })
        }
    }
    
    fileprivate func getUserData(uid senderId: String) {
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

//MARK: scroll view
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
}

//MARK: actions
extension SenderImageMessageController {
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
        self.allowAccessControl.itemButton.isEnabled = false
        
        FIRRef.getHasAllowedAccess().document(messageId).getDocument { (snap, error) in
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
    
    @objc func handleRotateImage() {
        animateRotatingImage(toOriginal: isShowingEdited)
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
}
