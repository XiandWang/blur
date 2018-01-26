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
    private let controlPanelHeight: CGFloat = 80.0
    private let controlPanelAlpha: CGFloat = 1.0
    
    let fireStoreRef = Firestore.firestore()
    private var isShowingEdited = true
    private var isShowingControlPanel = true
    
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
                editedImageView.kf.setImage(with: editedUrl)
                
                let originalUrl = URL(string: message.originalImageUrl)
                originalImageView.kf.indicatorType = .activity
                originalImageView.kf.setImage(with: originalUrl)
              
                setupControlPanel()
                
                let receiverId = message.receiverId
                getUserData(uid: receiverId)
            }
        }
    }
    
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
    
    let rotateImageButton: UIButton = {
        let bt = UIButton(type: .custom)
        let size = CGSize(width: 44, height: 44)
        let blue = UIColor.rgb(red: 25, green: 118, blue: 210, alpha: 1)
        bt.setImage(UIImage.fontAwesomeIcon(name: .eye, textColor: blue, size: size), for: .normal)
        bt.backgroundColor = UIColor.rgb(red: 144, green: 202, blue: 249, alpha: 0.9)
        bt.layer.cornerRadius = 25
        bt.layer.masksToBounds = true
        bt.alpha = 0
        bt.addTarget(self, action: #selector(handleRotateImage), for: .touchUpInside)
        
        return bt
    }()
    
    let rotateImageLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Rotate"
        lb.font = UIFont.boldSystemFont(ofSize: 14)
        lb.textColor =  UIColor.rgb(red: 25, green: 118, blue: 210, alpha: 1)
        lb.textAlignment = .center
        lb.alpha = 0
        return lb
    }()
    
    let allowAccessButton: UIButton = {
        let bt = UIButton(type: .custom)
        let size = CGSize(width: 44, height: 44)
        let green = UIColor.rgb(red: 56, green: 142, blue: 60, alpha: 1)
        bt.setImage(UIImage.fontAwesomeIcon(name: .unlockAlt, textColor: green, size: size), for: .normal)
        bt.backgroundColor = UIColor.rgb(red: 165, green: 214, blue: 167, alpha: 0.9)
        bt.layer.cornerRadius = 25
        bt.layer.masksToBounds = true
        bt.alpha = 0
        
        bt.addTarget(self, action: #selector(allowAccess), for: .touchUpInside)
        return bt
    }()
    
    let allowAccessLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Allow Access"
        lb.font = UIFont.boldSystemFont(ofSize: 14)
        lb.textColor = UIColor.rgb(red: 56, green: 142, blue: 60, alpha: 1)
        lb.textAlignment = .center
        lb.alpha = 0
        return lb
    }()
    
//    lazy var controlPanel: UIView = {
//        let frame = CGRect(x: 0, y: UIScreen.main.bounds.height - self.controlPanelHeight, width: UIScreen.main.bounds.width, height: self.controlPanelHeight)
//        let panel = UIView(frame: frame)
//        panel.backgroundColor = UIColor.clear
//
////        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
////        let blurEffectView = UIVisualEffectView(effect: blurEffect)
////        blurEffectView.frame = panel.bounds
////        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
////        panel.addSubview(blurEffectView)
//        //panel.alpha = self.controlPanelAlpha
//        return panel
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        setupScrollView()
        setupImageView()
        AnimationHelper.perspectiveTransform(for: view)
        setupGestures()
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
        self.navigationController?.navigationBar.alpha = 1
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func allowAccess() {
        guard let receiverUser = receiverUser else { return }
        guard let messageId = message?.messageId else { return }
        AppHUD.progress(nil, isDarkTheme: false)
        fireStoreRef.collection("imageMessages").document(messageId).updateData([MessageSchema.ALLOW_ORIGINAL: true]) { (error) in
            AppHUD.progressHidden()
            if let error = error {
                AppHUD.error(error.localizedDescription, isDarkTheme: false)
                return
            }
            CurrentUser.getUser(completion: { (senderUser, error) in
                if let senderUser = senderUser {
                    NotificationHelper.createMessageNotification(messageId: messageId, receiverUserId: receiverUser.uid, type: .allowAccess, senderUser: senderUser, text: nil, shouldShowHUD: false, hudSuccessText: nil)
                }
            })
            
            AppHUD.success("Access allowed", isDarkTheme: false)
        }
    }
    
    fileprivate func hideControlViews() {
        for v in [allowAccessButton, allowAccessLabel, rotateImageButton, rotateImageLabel] {
            v.alpha = 0
        }
        self.navigationController?.navigationBar.alpha = 0
    }
    
    fileprivate func showControlViews() {
        for v in [allowAccessButton, allowAccessLabel, rotateImageButton, rotateImageLabel] {
            v.alpha = 1
        }
        self.navigationController?.navigationBar.alpha = 1
    }
    
    @objc func toggleControlPanel() {
        view.isUserInteractionEnabled = false
        if isShowingControlPanel {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                self.hideControlViews()
            }) { (bool) in
                self.view.isUserInteractionEnabled = true
                if bool {
                    self.isShowingControlPanel = false
                }
            }
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                //self.controlPanel.center.y -= self.controlPanelHeight
                self.showControlViews()
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
    
    fileprivate func setupControlPanel() {
        //view.addSubview(controlPanel)
        view.addSubview(rotateImageButton)
        view.addSubview(allowAccessButton)
        allowAccessButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 32, paddingBottom: 50, paddingRight: 0, width: 50, height: 50)
        rotateImageButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 50, paddingRight: 32, width: 50, height: 50)
        
        view.addSubview(rotateImageLabel)
        view.addSubview(allowAccessLabel)
        rotateImageLabel.anchor(top: rotateImageButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 0)
        allowAccessLabel.anchor(top: allowAccessButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 120, height: 0)
        allowAccessLabel.centerXAnchor.constraint(equalTo: allowAccessButton.centerXAnchor).isActive = true
        rotateImageLabel.centerXAnchor.constraint(equalTo: rotateImageButton.centerXAnchor).isActive = true
        
        UIView.animate(withDuration: 1, delay: 0.3, options: [.showHideTransitionViews], animations: {
            self.showControlViews()
        }, completion: nil)
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
                        //self.editedImageView.layer.transform = AnimationHelper.yRotation(-.pi / 2)
                        //self.controlPanel.center.y += self.controlPanelHeight
                        self.hideControlViews()
                    }
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2) {
                        self.editedImageView.layer.transform = AnimationHelper.yRotation(-.pi / 2)
                        //self.controlPanel.center.y += self.controlPanelHeight
                        //self.controlPanel.alpha = 0.0
                    }
                    UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2) {
                        self.originalScrollView.layer.transform = AnimationHelper.yRotation(0.0)
                        //self.controlPanel.center.y -= self.controlPanelHeight
                        //self.controlPanel.alpha = 1.0
                        self.refreshOriginalImageView()
                    }
                    UIView.addKeyframe(withRelativeStartTime: 9/10, relativeDuration: 1/10) {
                        //self.editedImageView.layer.transform = AnimationHelper.yRotation(-.pi / 2)
                        //self.controlPanel.center.y += self.controlPanelHeight
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
                        //self.controlPanel.center.y += self.controlPanelHeight

                    }
                    UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2) {
                        self.editedImageView.layer.transform = CATransform3DIdentity
                        //self.controlPanel.center.y -= self.controlPanelHeight
                    }
                    UIView.addKeyframe(withRelativeStartTime: 9/10, relativeDuration: 1/10) {
                        //self.editedImageView.layer.transform = AnimationHelper.yRotation(-.pi / 2)
                        //self.controlPanel.center.y += self.controlPanelHeight
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
