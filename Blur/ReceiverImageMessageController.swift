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
    
    let showButton: UIButton = {
        let bt = UIButton(type: .custom)
        let size = CGSize(width: 44, height: 44)
        bt.setImage(UIImage.fontAwesomeIcon(name: .thumbsOUp, textColor: .white, size: size), for: .normal)
        bt.backgroundColor = GREEN_COLOR
        bt.layer.cornerRadius = 25
        bt.layer.masksToBounds = true
        bt.alpha = 1.0
        bt.addTarget(self, action: #selector(handleShowOriginalImage), for: .touchUpInside)
        
        return bt
    }()
    
    let showLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Show"
        lb.font = UIFont.boldSystemFont(ofSize: 14)
        lb.textColor = GREEN_COLOR
        lb.textAlignment = .center
        lb.alpha = 1.0

        return lb
    }()
    
    let rejectButton: UIButton = {
        let bt = UIButton(type: .custom)
        let size = CGSize(width: 44, height: 44)
        bt.setImage(UIImage.fontAwesomeIcon(name: .thumbsODown, textColor: .white, size: size), for: .normal)
        bt.backgroundColor = RED_COLOR
        bt.layer.cornerRadius = 25
        bt.layer.masksToBounds = true
        bt.alpha = 1.0
        bt.addTarget(self, action: #selector(handleRejectImage), for: .touchUpInside)
        return bt
    }()
    
    let rejectLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Reject"
        lb.font = UIFont.boldSystemFont(ofSize: 14)
        lb.textColor = RED_COLOR
        lb.textAlignment = .center
        lb.alpha = 1.0

        return lb
    }()
    
    let requestButton: UIButton = {
        let bt = UIButton(type: .custom)
        let size = CGSize(width: 44, height: 44)
        bt.setImage(UIImage.fontAwesomeIcon(name: .userO, textColor: .white, size: size), for: .normal)
        bt.backgroundColor = .purple
        bt.layer.cornerRadius = 25
        bt.layer.masksToBounds = true
        bt.alpha = 1.0
        bt.addTarget(self, action: #selector(handleRequestAccess), for: .touchUpInside)
        return bt
    }()
    
    let requestLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Request"
        lb.font = UIFont.boldSystemFont(ofSize: 14)
        lb.textColor = .purple
        lb.numberOfLines = 0
        lb.textAlignment = .center
        lb.alpha = 1.0

        return lb
    }()
    
    let toggleImageButton: UIButton = {
        let bt = UIButton(type: .custom)
        let size = CGSize(width: 44, height: 44)
        bt.setImage(UIImage.fontAwesomeIcon(name: .eye, textColor: .white, size: size), for: .normal)
        bt.backgroundColor = .purple
        bt.layer.cornerRadius = 25
        bt.layer.masksToBounds = true
        bt.addTarget(self, action: #selector(handleRotateImage), for: .touchUpInside)
        return bt
    }()
    
    lazy var controlPanel: UIView = {
        let frame = CGRect(x: 0, y: UIScreen.main.bounds.height - self.controlPanelHeight, width: UIScreen.main.bounds.width, height: self.controlPanelHeight)
        let panel = UIView(frame: frame)
        panel.backgroundColor = .clear
//        panel.alpha = self.controlPanelAlpha
//        panel.layer.shouldRasterize = true
        // No setting rasterizationScale, will cause blurry images on retina.
        //panel.layer.rasterizationScale = UIScreen.main.scale
        return panel
    }()
    
    let backButton: UIButton = {
        let bt = UIButton()
        let backImg = UIImage.fontAwesomeIcon(name: .arrowCircleLeft, textColor: .white, size: CGSize(width: 30, height: 30))
        bt.setImage(backImg, for: .normal)
        bt.addTarget(self, action: #selector(handleNavBack), for: .touchUpInside)
        bt.backgroundColor = .black
        bt.alpha = 0.7
        bt.layer.cornerRadius = 18
        bt.layer.masksToBounds = true
      
        return bt
    }()
    
    let clockButton: UIButton = {
        let bt = UIButton()
        let clockImg = UIImage.fontAwesomeIcon(name: .clockO, textColor: YELLOW_COLOR, size: CGSize(width: 30, height: 30))
        bt.setImage(clockImg, for: .normal)
        bt.addTarget(self, action: #selector(handleShowTime), for: .touchUpInside)
        bt.backgroundColor = .clear
        bt.layer.cornerRadius = 18
        bt.layer.masksToBounds = true
        bt.alpha = 0.7
        
        return bt
    }()
    
    @objc func handleShowTime() {
        print("time")
    }
    
    @objc func handleNavBack(){
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.popViewController(animated: true)
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
    
    func setupTopControls() {
        view.addSubview(backButton)
        backButton.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 36, height: 36)
        
        view.addSubview(clockButton)
        clockButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 30, height: 30)
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
    
    @objc func toggleControlPanel() {
        view.isUserInteractionEnabled = false
        if isShowingControlPanel {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                self.controlPanel.center.y += self.controlPanelHeight
                self.controlPanel.alpha = 0
                for view in [self.backButton, self.clockButton] {
                    view.alpha = 0
                }
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
                for view in [self.backButton, self.clockButton] {
                    view.alpha = self.controlPanelAlpha
                }
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
            addButtonsToControlPanel(leftButton: showButton)
        } else {
            if message.allowOriginal {
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
        leftButton.anchor(top: controlPanel.topAnchor, left: controlPanel.leftAnchor, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 32, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        rejectButton.anchor(top: controlPanel.topAnchor, left: nil, bottom: nil, right: controlPanel.rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 32, width: 50, height: 50)
        
        var leftLabel = showLabel
        if leftButton == requestButton {
            leftLabel = requestLabel
        }
        controlPanel.addSubview(leftLabel)
        controlPanel.addSubview(rejectLabel)
        leftLabel.anchor(top: leftButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 0)
        rejectLabel.anchor(top: rejectButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 0)
        leftLabel.centerXAnchor.constraint(equalTo: leftButton.centerXAnchor).isActive = true
        rejectLabel.centerXAnchor.constraint(equalTo: rejectButton.centerXAnchor).isActive = true
    }
    
    fileprivate func setupImageView() {
        view.addSubview(editedImageView)
        editedImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    @objc func handleRotateImage() {
        self.originalImageView.isHidden = false
        animateRotatingImage(toOriginal: isShowingEdited)
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
                        self.originalScrollView.layer.transform = AnimationHelper.yRotation(0.0)
                        self.controlPanel.center.y -= self.controlPanelHeight
                        self.refreshOriginalImageView()
                    }
            }, completion: nil)
        } else {
            isShowingEdited = true
            UIView.animateKeyframes(
                withDuration: 2.0, delay: 0, options: .calculationModeCubic,
                animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2) {
                        self.originalScrollView.layer.transform = AnimationHelper.yRotation(.pi / 2)
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

extension ReceiverImageMessageController {
    @objc func handleShowOriginalImage() {
        guard let allowOriginal = message?.allowOriginal else { return }
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
            .document(messageId).updateData([MessageSchema.IS_DELETED: true, MessageSchema.IS_ACKNOWLEDGED: true, MessageSchema.ACKNOWLEDGE_TYPE: "Reject"]) { (error) in
                if let error = error {
                    AppHUD.error(error.localizedDescription, isDarkTheme: true)
                    return
                }
    
                if shouldSendNotification {
                    guard let notificationUser = self.senderUser else { return }
                    CurrentUser.getUser(completion: { (curUser, error) in
                        if let curUser = curUser {
                            NotificationHelper.createMessageNotification(messageId: messageId, receiverUserId: notificationUser.uid, type: .rejectMessage, senderUser: curUser, text: additionalText, shouldShowHUD: false, hudSuccessText: nil)
                        }
                    })
                    
                }
                self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func acceptImageMessage(isOriginalViewed: Bool) {
        guard let messageId = message?.messageId  else { return }
        let data = [MessageSchema.IS_ACKNOWLEDGED: true,
                    MessageSchema.ACKNOWLEDGE_TYPE: "Accept",
                    MessageSchema.IS_ORIGINAL_VIEWED: isOriginalViewed] as [String : Any]
        fireStoreRef.collection("imageMessages")
            .document(messageId).updateData(data) { (error) in
                if let error = error {
                    AppHUD.error(error.localizedDescription,  isDarkTheme: false)
                    return
                }
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
        CurrentUser.getUser { (curUser, error) in
            if let curUser = curUser {
                NotificationHelper.createMessageNotification(messageId: messageId, receiverUserId: notificationUser.uid, type: .requestAccess, senderUser: curUser, text: nil, shouldShowHUD: true, hudSuccessText: "Request to access sent")
            }
        }
    }
}

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
}
